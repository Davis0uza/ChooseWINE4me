import os
from urllib.parse import urlparse
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from pymongo import MongoClient
import pandas as pd
import numpy as np
import scipy.sparse as sp
from sklearn.neighbors import NearestNeighbors

# --- Carrega .env ---
env_path = os.path.join(os.path.dirname(__file__), '..', '.env')
load_dotenv(env_path)

# --- MongoDB ---
mongo_uri = os.getenv('MONGODB_URI')
if not mongo_uri:
    raise RuntimeError("MONGODB_URI não definido")
client = MongoClient(mongo_uri)
parsed = urlparse(mongo_uri)
db = client[ parsed.path.lstrip('/').split('?')[0] ]

# --- Extrai interações ---
favs = list(db.favorites.find({}, {'_id':0,'id_user':1,'id_wine':1}))
if favs:
    df_int = pd.DataFrame(favs)
else:
    rats = list(db.ratings.find({}, {'_id':0,'id_user':1,'id_wine':1}))
    df_int = pd.DataFrame(rats)

if df_int.empty:
    raise RuntimeError("Nenhuma interação encontrada para treinar CF")

# --- Normaliza tipos ---
df_int['id_user'] = df_int['id_user'].astype(str)
df_int['id_wine'] = df_int['id_wine'].astype(str)

# --- Mapas e matriz esparsa ---
user_ids = sorted(df_int['id_user'].unique())
wine_ids = sorted(df_int['id_wine'].unique())
user_map = {u:i for i,u in enumerate(user_ids)}
wine_map = {w:i for i,w in enumerate(wine_ids)}

rows = df_int['id_user'].map(user_map)
cols = df_int['id_wine'].map(wine_map)
data = np.ones(len(df_int), dtype=np.int8)
interaction_matrix = sp.csr_matrix((data, (rows, cols)),
                                   shape=(len(user_ids), len(wine_ids)))

# --- Modelos CF ---
user_nn = NearestNeighbors(metric='cosine', algorithm='brute')
user_nn.fit(interaction_matrix)
item_nn = NearestNeighbors(metric='cosine', algorithm='brute')
item_nn.fit(interaction_matrix.T)

app = FastAPI()
class RecRequest(BaseModel):
    user_id: str

@app.get("/recommend/{user_id}")
async def recommend_get(user_id: str):
    return _recommend(user_id)

@app.post("/recommend")
async def recommend_post(req: RecRequest):
    return _recommend(req.user_id)

def _recommend(user_id: str):
    recs = []
    consumed = set(df_int[df_int['id_user']==user_id]['id_wine'])

    # Usuário com histórico
    if user_id in user_map:
        # para cada vinho consumido, pega todos similares
        for wid in consumed:
            idx = wine_map[wid]
            _, idxs = item_nn.kneighbors(interaction_matrix.T[idx],
                                         n_neighbors=len(wine_ids))
            for sim_idx in idxs[0]:
                wid_sim = wine_ids[sim_idx]
                if wid_sim not in consumed and wid_sim not in recs:
                    recs.append(wid_sim)

    # Usuário sem histórico
    else:
        addr = db.addresses.find_one({'id_user': user_id},
                                     {'_id':0,'city':1})
        region_recs = []
        if addr and addr.get('city'):
            city = addr['city']
            pipeline = [
                {'$match': {'city': city}},
                {'$lookup': {
                   'from': 'favorites',
                   'localField': 'id_user',
                   'foreignField': 'id_user',
                   'as': 'fav'}},
                {'$unwind': '$fav'},
                {'$group': {'_id': '$fav.id_wine','count':{'$sum':1}}},
                {'$sort': {'count': -1}}
            ]
            for doc in db.addresses.aggregate(pipeline):
                region_recs.append(str(doc['_id']))
        recs = region_recs

    # Fallback complementar: similaridade aos já sugeridos
    fill = []
    for wid in recs:
        if wid not in wine_map:
            continue
        idx = wine_map[wid]
        _, idxs = item_nn.kneighbors(interaction_matrix.T[idx],
                                     n_neighbors=len(wine_ids))
        for sim_idx in idxs[0]:
            wid_sim = wine_ids[sim_idx]
            if (wid_sim not in consumed
               and wid_sim not in recs
               and wid_sim not in fill):
                fill.append(wid_sim)
    recs.extend(fill)

    return recs
