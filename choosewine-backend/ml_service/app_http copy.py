# ml_service/app_http.py
"""
Serviço FastAPI para recomendação de vinhos via HTTP usando Node.js como fonte de dados.
Algoritmo:
1) Usuários com histórico (favoritos ou ratings):
   - Exclui vinhos já consumidos e recomenda todos os demais ordenados por similaridade de atributos (preço, nota, país e região).
2) Usuários sem histórico:
   - Identifica cidade do usuário via endpoint específico (que retorna lista ou dict)
   - Recomenda peers na mesma cidade primeiro, em seguida os restantes ordenados por similaridade.
"""
import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import requests
import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics.pairwise import cosine_distances
from sklearn.neighbors import NearestNeighbors
from dotenv import load_dotenv

# Carrega variáveis de ambiente

def load_env():
    base = os.path.dirname(__file__)
    load_dotenv(os.path.join(base, '.env'))
    return os.getenv('NODE_API_URL', 'http://192.168.0.118:3000')

NODE_API_URL = load_env()
app = FastAPI()

class RecRequest(BaseModel):
    user_id: str

# Extrai interações de favorites ou ratings
# Lida com estrutura de JSON aninhado

def extract_interactions(data):
    rows = []
    for it in data:
        # user id
        uid = None
        if 'user' in it:
            u = it['user']
            uid = u.get('_id') if isinstance(u, dict) else u
        elif 'id_user' in it:
            uid = it.get('id_user')
        # wine id
        wid = None
        if 'wine' in it:
            w = it['wine']
            wid = w.get('_id') if isinstance(w, dict) else w
        elif 'id_wine' in it:
            wid = it.get('id_wine')
        if uid and wid:
            rows.append({'id_user': str(uid), 'id_wine': str(wid)})
    return pd.DataFrame(rows)

# Carrega interações do backend (favoritos + ratings)

def load_user_wines():
    dfs = []
    for endpoint in ('favorites', 'ratings'):
        r = requests.get(f"{NODE_API_URL}/{endpoint}")
        if r.ok and isinstance(r.json(), list):
            df = extract_interactions(r.json())
            if not df.empty:
                dfs.append(df)
    if dfs:
        return pd.concat(dfs, ignore_index=True).drop_duplicates()
    return pd.DataFrame(columns=['id_user','id_wine'])

# Carrega endereços completos para fallback

def load_addresses():
    r = requests.get(f"{NODE_API_URL}/addresses")
    if not r.ok or not isinstance(r.json(), list):
        raise RuntimeError("Erro ao buscar addresses")
    df = pd.DataFrame(r.json())
    # extrai id_user do campo user
    if 'id_user' not in df.columns and 'user' in df.columns:
        sample = df.at[0,'user']
        df['id_user'] = df['user'].apply(lambda u: u.get('_id') if isinstance(u, dict) else u)
    df['id_user'] = df['id_user'].astype(str)
    # mantém última address por usuário
    df_last = df.groupby('id_user').last().reset_index()
    if 'city' not in df_last.columns:
        raise RuntimeError("City não encontrada em addresses")
    return df_last[['id_user','city']]

# Carrega cidade de um único usuário via endpoint dedicado

def load_user_city(user_id: str) -> str:
    r = requests.get(f"{NODE_API_URL}/addresses/user/{user_id}")
    if not r.ok:
        raise RuntimeError(f"Endereço não encontrado para usuário {user_id}")
    data = r.json()
    # pode ser dict ou lista com um item
    if isinstance(data, list) and data:
        item = data[-1]
    elif isinstance(data, dict):
        item = data
    else:
        raise RuntimeError("Resposta inválida ao buscar cidade do usuário")
    city = item.get('city')
    if not city:
        raise RuntimeError("Campo 'city' ausente na resposta de cidade")
    return city

# Carrega vinhos e prepara modelo de similaridade

def load_wines_and_model():
    r = requests.get(f"{NODE_API_URL}/wines")
    r.raise_for_status()
    df = pd.DataFrame(r.json())
    # define id_wine
    if '_id' in df.columns:
        df['id_wine'] = df['_id'].astype(str)
    else:
        df['id_wine'] = df['id_wine'].astype(str)
    # atributos
    df['price'] = df.get('price', pd.Series(0, index=df.index)).fillna(0)
    df['rating'] = df.get('rating', df.get('average_rating', pd.Series(0, index=df.index))).fillna(0)
    df['country'] = df.get('country', pd.Series('', index=df.index)).fillna('')
    df['region'] = df.get('region', pd.Series('', index=df.index)).fillna('')
    # codifica
    enc_c = LabelEncoder()
    enc_r = LabelEncoder()
    df['country_enc'] = enc_c.fit_transform(df['country'])
    df['region_enc'] = enc_r.fit_transform(df['region'])
    # kNN
    X = df[['price','rating','country_enc','region_enc']].values
    nn = NearestNeighbors(metric='cosine', algorithm='brute')
    nn.fit(X)
    return df, X, nn

# Inicialização global
df_uw = load_user_wines()
df_addr = load_addresses()
df_w, X_w, nn_w = load_wines_and_model()
all_wine_ids = df_w['id_wine'].tolist()
id_index = {w:i for i,w in enumerate(all_wine_ids)}

@app.get("/recommend/{user_id}")
async def recommend_get(user_id: str):
    try:
        return _recommend(user_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/recommend")
async def recommend_post(req: RecRequest):
    try:
        return _recommend(req.user_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Função principal de recomendação
def _recommend(user_id: str):
    cons = df_uw[df_uw['id_user']==user_id]['id_wine'].tolist()
    # usuário ativo
    if cons:
        rest = [w for w in all_wine_ids if w not in cons]
        idx_rest = [id_index[w] for w in rest]
        idx_cons = [id_index[w] for w in cons if w in id_index]
        if idx_cons and idx_rest:
            dists = cosine_distances(X_w[idx_rest], X_w[idx_cons])
            scores = dists.min(axis=1)
            order = np.argsort(scores)
            return [rest[i] for i in order]
        return rest
    # usuário novo: fallback por cidade
    city = load_user_city(user_id)
    peers = df_addr[df_addr['city']==city]['id_user'].tolist()
    region_wines = df_uw[df_uw['id_user'].isin(peers)]['id_wine'].unique().tolist()
    used = set(region_wines)
    rest = [w for w in all_wine_ids if w not in used]
    if region_wines and rest:
        idx_rest = [id_index[w] for w in rest]
        idx_reg = [id_index[w] for w in region_wines if w in id_index]
        if idx_reg:
            dists = cosine_distances(X_w[idx_rest], X_w[idx_reg])
            scores = dists.min(axis=1)
            order = np.argsort(scores)
            return region_wines + [rest[i] for i in order]
    # fallback geral: por rating
    return df_w.sort_values('rating', ascending=False)['id_wine'].tolist()
