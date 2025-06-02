# ml_service/app_http.py

"""
Serviço FastAPI para recomendação de vinhos via HTTP usando Node.js como fonte de dados.
Algoritmo:
1) Usuários com histórico (favoritos ou ratings):
   - Exclui vinhos já consumidos e recomenda todos os demais ordenados por similaridade de atributos.
2) Usuários sem histórico:
   - Identifica cidade do usuário via endpoint dedicado.
   - Reúne vinhos consumidos por peers na mesma cidade.
   - Em seguida, recomenda os demais ordenados por similaridade.
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

# ------------------------------------------------------------------------------
# Carregamento de .env e configuração global
# ------------------------------------------------------------------------------

def load_env():
    """Carrega NODE_API_URL e API_SECRET_KEY de .env."""
    base = os.path.dirname(__file__)
    load_dotenv(os.path.join(base, '.env'))
    url = os.getenv('NODE_API_URL', 'http://192.168.151.206:3000')
    secret = os.getenv('API_SECRET_KEY', '')
    if not secret:
        raise RuntimeError("API_SECRET_KEY não configurada no .env")
    return url, secret

NODE_API_URL, API_SECRET_KEY = load_env()
HEADERS = {'x-service-key': API_SECRET_KEY}

app = FastAPI()

class RecRequest(BaseModel):
    user_id: str

# ------------------------------------------------------------------------------
# Helpers de extração
# ------------------------------------------------------------------------------

def extract_interactions(data):
    """
    Gera DataFrame com colunas id_user, id_wine a partir de lista de JSONs
    que podem ter formato {user: ..., wine: {...}} ou {id_user: ..., id_wine: ...}.
    """
    rows = []
    for it in data:
        uid = None
        if 'user' in it:
            u = it['user']
            uid = u.get('_id') if isinstance(u, dict) else u
        elif 'id_user' in it:
            uid = it.get('id_user')
        wid = None
        if 'wine' in it:
            w = it['wine']
            wid = w.get('_id') if isinstance(w, dict) else w
        elif 'id_wine' in it:
            wid = it.get('id_wine')
        if uid and wid:
            rows.append({'id_user': str(uid), 'id_wine': str(wid)})
    return pd.DataFrame(rows)

# ------------------------------------------------------------------------------
# Carregamento de interações (favoritos + ratings)
# ------------------------------------------------------------------------------

def load_user_wines():
    """Busca /favorites e /ratings do Node API, extrai e concatena."""
    dfs = []
    for ep in ('favorites', 'ratings'):
        r = requests.get(f"{NODE_API_URL}/{ep}", headers=HEADERS)
        if r.ok and isinstance(r.json(), list):
            df = extract_interactions(r.json())
            if not df.empty:
                dfs.append(df)
    if dfs:
        return pd.concat(dfs, ignore_index=True).drop_duplicates()
    return pd.DataFrame(columns=['id_user','id_wine'])

df_uw = load_user_wines()

# ------------------------------------------------------------------------------
# Carregamento de endereços
# ------------------------------------------------------------------------------

def load_addresses():
    """Busca /addresses, normaliza coluna id_user, agrupa pela última city."""
    r = requests.get(f"{NODE_API_URL}/addresses", headers=HEADERS)
    if not r.ok or not isinstance(r.json(), list):
        raise RuntimeError("Erro ao buscar addresses")
    df = pd.DataFrame(r.json())
    # normaliza user -> id_user
    if 'id_user' not in df.columns and 'user' in df.columns:
        df['id_user'] = df['user'].apply(lambda u: u.get('_id') if isinstance(u, dict) else u)
    df['id_user'] = df['id_user'].astype(str)
    # pega última morada por usuário
    df_last = df.groupby('id_user', as_index=False).last()
    if 'city' not in df_last.columns:
        raise RuntimeError("City não encontrada em addresses")
    return df_last[['id_user','city']]

df_addr = load_addresses()

# ------------------------------------------------------------------------------
# Carrega cidade de um usuário
# ------------------------------------------------------------------------------

def load_user_city(user_id: str) -> str:
    """
    Busca /addresses/user/{user_id}, pode retornar dict ou list.
    Retorna o campo city do último item.
    """
    r = requests.get(f"{NODE_API_URL}/addresses/user/{user_id}", headers=HEADERS)
    if not r.ok:
        raise RuntimeError(f"Endereço não encontrado para usuário {user_id}")
    data = r.json()
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

# ------------------------------------------------------------------------------
# Carregamento de vinhos e treinamento kNN
# ------------------------------------------------------------------------------

def load_wines_and_model():
    """Busca /wines, monta features e treina NearestNeighbors."""
    r = requests.get(f"{NODE_API_URL}/wines", headers=HEADERS)
    r.raise_for_status()
    df = pd.DataFrame(r.json())
    df['id_wine'] = df['_id'].astype(str)

    # preencher atributos numéricos/textuais
    df['price']   = df.get('price', pd.Series(0, index=df.index)).fillna(0)
    df['rating']  = df.get('rating', pd.Series(0, index=df.index)).fillna(0)
    df['country'] = df.get('country', pd.Series('', index=df.index)).fillna('')
    df['region']  = df.get('region', pd.Series('', index=df.index)).fillna('')
    df['type']    = df.get('type', pd.Series('', index=df.index)).fillna('')
    df['winery']  = df.get('winery', pd.Series('', index=df.index)).fillna('')

    # label encoding
    enc_c = LabelEncoder()
    enc_r = LabelEncoder()
    enc_t = LabelEncoder()
    enc_w = LabelEncoder()

    df['country_enc'] = enc_c.fit_transform(df['country'])
    df['region_enc']  = enc_r.fit_transform(df['region'])
    df['type_enc']    = enc_t.fit_transform(df['type'])
    df['winery_enc']  = enc_w.fit_transform(df['winery'])

    X = df[['price','rating','country_enc','region_enc','type_enc','winery_enc']].values
    nn = NearestNeighbors(metric='cosine', algorithm='brute')
    nn.fit(X)

    return df, X, nn

df_w, X_w, nn_w = load_wines_and_model()
all_wine_ids = df_w['id_wine'].tolist()
id_index = {w: i for i, w in enumerate(all_wine_ids)}

# ------------------------------------------------------------------------------
# Endpoints FastAPI
# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------
# Lógica de recomendação
# ------------------------------------------------------------------------------

def _recommend(user_id: str):
    # vinhos já consumidos por este usuário
    cons = df_uw[df_uw['id_user'] == user_id]['id_wine'].tolist()

    # 1) usuário ativo (com consumo)
    if cons:
        rest = [w for w in all_wine_ids if w not in cons]
        idx_rest = [id_index[w] for w in rest if w in id_index]
        idx_cons = [id_index[w] for w in cons if w in id_index]
        if idx_cons and idx_rest:
            # distância mínima (item-based CF)
            dists  = cosine_distances(X_w[idx_rest], X_w[idx_cons])
            scores = dists.min(axis=1)
            order  = np.argsort(scores)
            return [rest[i] for i in order]
        return rest

    # 2) usuário sem histórico
    city = load_user_city(user_id)
    peers = df_addr[df_addr['city'] == city]['id_user'].tolist()
    region_wines = df_uw[df_uw['id_user'].isin(peers)]['id_wine'].unique().tolist()
    used = set(region_wines)
    rest = [w for w in all_wine_ids if w not in used]

    if region_wines and rest:
        idx_rest = [id_index[w] for w in rest if w in id_index]
        idx_reg  = [id_index[w] for w in region_wines if w in id_index]
        if idx_reg:
            dists  = cosine_distances(X_w[idx_rest], X_w[idx_reg])
            scores = dists.min(axis=1)
            order  = np.argsort(scores)
            return region_wines + [rest[i] for i in order]

    # fallback geral: ordena por rating decrescente
    return df_w.sort_values('rating', ascending=False)['id_wine'].tolist()
