# ml_service/app_http.py

"""
Serviço FastAPI para recomendação de vinhos via HTTP usando Node.js como fonte de dados.
Algoritmo:
1) Users com histórico de favoritos:
   - Obtém o último favorito registrado para o usuário e recomenda vinhos similares a ele.
2) Se não existir favorito, usa histórico de navegação (History):
   - Obtém o último vinho acessado e recomenda vinhos similares a ele.
3) Se não houver histórico nem favoritos:
   - Identifica cidade do usuário via endpoint dedicado.
   - Reúne vinhos consumidos por peers na mesma cidade.
   - Primeiro recomenda esses vinhos de peers; depois, o restante ordenado por similaridade.
4) Fallback geral:
   - Se nada acima aplicar, retorna todos os vinhos ordenados por rating decrescente.
Todas as chamadas ao Node.js incluem o header "x-service-key" com a chave secreta.
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
from datetime import datetime
from dotenv import load_dotenv

# -------------------------------------------------------------------
# Carrega variáveis de ambiente
# -------------------------------------------------------------------

def load_env():
    base = os.path.dirname(__file__)
    load_dotenv(os.path.join(base, '.env'))
    url = os.getenv('NODE_API_URL', '').rstrip('/')
    secret = os.getenv('API_SECRET_KEY', '')
    if not url:
        raise RuntimeError("NODE_API_URL não configurada no .env")
    if not secret:
        raise RuntimeError("API_SECRET_KEY não configurada no .env")
    return url, secret

NODE_API_URL, API_SECRET_KEY = load_env()
HEADERS = {'x-service-key': API_SECRET_KEY}

app = FastAPI()

class RecRequest(BaseModel):
    user_id: str

# -------------------------------------------------------------------
# Helpers para obter histórico
# -------------------------------------------------------------------

def get_all_favorites():
    """
    Retorna lista de JSONs de GET /favorites.
    """
    r = requests.get(f"{NODE_API_URL}/favorites", headers=HEADERS)
    if not r.ok or not isinstance(r.json(), list):
        return []
    return r.json()

def get_all_ratings():
    """
    Retorna lista de JSONs de GET /ratings.
    """
    r = requests.get(f"{NODE_API_URL}/ratings", headers=HEADERS)
    if not r.ok or not isinstance(r.json(), list):
        return []
    return r.json()

def get_last_favorite(user_id: str) -> str | None:
    favs = [f for f in get_all_favorites() if f.get('user') == user_id]
    if not favs:
        return None
    last = favs[-1]
    wine = last.get('wine')
    return wine.get('_id') if isinstance(wine, dict) else None

def get_last_history(user_id: str) -> str | None:
    """
    Encontra o último histórico (History) para um dado usuário, baseado em accessed_at.
    Retorna o wine._id (string) ou None se não houver histórico.
    """
    r = requests.get(f"{NODE_API_URL}/history", headers=HEADERS)
    if not r.ok or not isinstance(r.json(), list):
        return None
    records = [h for h in r.json() if h.get('user') == user_id]
    if not records:
        return None
    def parse_date(item):
        dt = item.get('accessed_at')
        return datetime.fromisoformat(dt) if isinstance(dt, str) else datetime.min
    records.sort(key=parse_date)
    last = records[-1]
    wine = last.get('wine')
    return wine.get('_id') if isinstance(wine, dict) else None

# -------------------------------------------------------------------
# Carregamento de moradas 
# -------------------------------------------------------------------

def load_addresses():
    r = requests.get(f"{NODE_API_URL}/addresses", headers=HEADERS)
    if not r.ok or not isinstance(r.json(), list):
        raise RuntimeError("Erro ao buscar addresses")
    df = pd.DataFrame(r.json())

    # Normaliza 'user' para 'id_user'
    if 'id_user' not in df.columns and 'user' in df.columns:
        df['id_user'] = df['user'].apply(lambda u: u.get('_id') if isinstance(u, dict) else u)
    df['id_user'] = df['id_user'].astype(str)

    # Pega última entrada de cada usuário
    df_last = df.groupby('id_user', as_index=False).last()
    if 'city' not in df_last.columns:
        raise RuntimeError("Campo 'city' não encontrado em addresses")
    return df_last[['id_user','city']]

df_addr = load_addresses()

def load_user_city(user_id: str) -> str:
    """
    Busca GET /addresses/user/{user_id} e retorna o campo 'city' do último item.
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

# -------------------------------------------------------------------
# Carregamento de vinhos e treinamento de modelo
# -------------------------------------------------------------------

def load_wines_and_model():
    r = requests.get(f"{NODE_API_URL}/wines", headers=HEADERS)
    r.raise_for_status()
    df = pd.DataFrame(r.json())
    df['id_wine'] = df['_id'].astype(str)

    # Preenche colunas numéricas/textuais
    df['price']   = df.get('price', pd.Series(0, index=df.index)).fillna(0)
    df['rating']  = df.get('rating', pd.Series(0, index=df.index)).fillna(0)
    df['country'] = df.get('country', pd.Series('', index=df.index)).fillna('')
    df['region']  = df.get('region', pd.Series('', index=df.index)).fillna('')
    df['type']    = df.get('type', pd.Series('', index=df.index)).fillna('')
    df['winery']  = df.get('winery', pd.Series('', index=df.index)).fillna('')

    # Label encoding
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

# -------------------------------------------------------------------
# Carregamento das interações globais (favoritos + ratings)
# -------------------------------------------------------------------

def load_all_interactions_df():
    """
    Monta DataFrame global de interações (favoritos + ratings) para peers.
    Colunas: [id_user, id_wine]
    """
    favs = get_all_favorites()
    rats = get_all_ratings()
    rows = []
    # Extrai de favoritos
    for f in favs:
        u = f.get('user')
        w = f.get('wine')
        if not u or not isinstance(w, dict):
            continue
        wid = w.get('_id')
        if not wid:
            continue
        rows.append({'id_user': str(u), 'id_wine': str(wid)})
    # Extrai de ratings
    for h in rats:
        u = h.get('user')
        w = h.get('wine')
        if not u or not isinstance(w, dict):
            continue
        wid = w.get('_id')
        if not wid:
            continue
        rows.append({'id_user': str(u), 'id_wine': str(wid)})
    df = pd.DataFrame(rows)
    if df.empty:
        return df
    return df.drop_duplicates(subset=['id_user','id_wine'])

df_uw = load_all_interactions_df()

# -------------------------------------------------------------------
# Lógica de recomendação
# -------------------------------------------------------------------

def _recommend(user_id: str):
    """
    1) Tenta obter último favorito -> recomenda similares.
    2) Se não encontrar favorito, obtém último history -> similares.
    3) Se não encontrar histórico nem favoritos, usa peers da cidade.
    4) Fallback geral por rating decrescente.
    """

    # 1) Último favorito
    last_fav = get_last_favorite(user_id)
    if last_fav:
        idx_last = id_index.get(last_fav)
        if idx_last is None:
            return []
        rest = [w for w in all_wine_ids if w != last_fav]
        idx_rest = [id_index[w] for w in rest if w in id_index]
        dists = cosine_distances(X_w[idx_rest], X_w[[idx_last]]).flatten()
        order = np.argsort(dists)
        return [rest[i] for i in order]

    # 2) Último histórico
    last_hist = get_last_history(user_id)
    if last_hist:
        idx_last = id_index.get(last_hist)
        if idx_last is None:
            return []
        rest = [w for w in all_wine_ids if w != last_hist]
        idx_rest = [id_index[w] for w in rest if w in id_index]
        dists = cosine_distances(X_w[idx_rest], X_w[[idx_last]]).flatten()
        order = np.argsort(dists)
        return [rest[i] for i in order]

    # 3) Usuário sem histórico/favoritos: peers por cidade
    city = load_user_city(user_id)
    peers = df_addr[df_addr['city'] == city]['id_user'].tolist()
    region_wines = df_uw[df_uw['id_user'].isin(peers)]['id_wine'].unique().tolist()
    used = set(region_wines)
    rest = [w for w in all_wine_ids if w not in used]

    if region_wines and rest:
        idx_reg  = [id_index[w] for w in region_wines if w in id_index]
        idx_rest = [id_index[w] for w in rest if w in id_index]
        if idx_reg:
            dists  = cosine_distances(X_w[idx_rest], X_w[idx_reg])
            scores = dists.min(axis=1)
            order  = np.argsort(scores)
            return region_wines + [rest[i] for i in order]

    # 4) Fallback geral: ordena por rating decrescente
    return df_w.sort_values('rating', ascending=False)['id_wine'].tolist()

# -------------------------------------------------------------------
# Endpoints FastAPI
# -------------------------------------------------------------------

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
