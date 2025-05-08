# ml_service/app.py

import os
from urllib.parse import urlparse
from dotenv     import load_dotenv
from fastapi    import FastAPI, HTTPException
from pydantic   import BaseModel
from pymongo    import MongoClient
import pandas    as pd
import numpy     as np
import scipy.sparse as sp
from sklearn.neighbors import NearestNeighbors

# ---- Carrega .env da raiz ----
env_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '.env'))
load_dotenv(env_path)

# ---- Conecta ao Mongo (para ler dados se preferir direto do DB) ----
mongo_uri = os.getenv('MONGODB_URI')
if not mongo_uri:
    raise RuntimeError("MONGODB_URI não está definido no .env")
client = MongoClient(mongo_uri)
parsed = urlparse(mongo_uri)
db_name = parsed.path.lstrip('/').split('?')[0]
db = client[db_name]

# ---- Pega os dados de interações ----
def load_interactions():
    # Tenta favoritos
    favs = list(db.favorites.find({}, {'_id':0,'id_user':1,'id_wine':1}))
    if favs:
        df = pd.DataFrame(favs)
        print(f"Usando {len(df)} favoritos para treinar CF")
    else:
        # fallback para ratings
        rats = list(db.ratings.find({}, {'_id':0,'id_user':1,'id_wine':1}))
        if not rats:
            raise RuntimeError("Nenhum favorito ou rating encontrado para treinar CF")
        df = pd.DataFrame(rats)
        print(f"favorites vazio, usando {len(df)} ratings como feedback")
    return df

df = load_interactions()

# ---- Mapeia IDs para índices ----
user_ids = sorted(df['id_user'].unique())
wine_ids = sorted(df['id_wine'].unique())
user_map = {u:i for i,u in enumerate(user_ids)}
wine_map = {w:i for i,w in enumerate(wine_ids)}

# ---- Monta matriz esparsa ----
rows = df['id_user'].map(user_map)
cols = df['id_wine'].map(wine_map)
data = np.ones(len(df), dtype=np.int8)
interaction_matrix = sp.csr_matrix(
    (data, (rows, cols)),
    shape=(len(user_ids), len(wine_ids))
)

# ---- Treina o modelo CF (user-based) ----
nn_model = NearestNeighbors(metric='cosine', algorithm='brute')
nn_model.fit(interaction_matrix)
print(f"✓ NearestNeighbors treinado com {len(user_ids)} usuários e {len(wine_ids)} vinhos")

# ---- Define request/response ----
class RecRequest(BaseModel):
    user_id: int
    k:       int = 10

app = FastAPI()

@app.post("/recommend")
async def recommend_post(req: RecRequest):
    return _recommend(req.user_id, req.k)

@app.get("/recommend/{user_id}")
async def recommend_get(user_id: int, k: int = 10):
    return _recommend(user_id, k)

def _recommend(user_id: int, k: int):
    if user_id not in user_map:
        # sem histórico, devolve lista vazia (poderia ser top-rated)
        return []
    uid = user_map[user_id]
    # encontra os K+1 vizinhos (inclui o próprio)
    neigh_dist, neigh_idx = nn_model.kneighbors(
        interaction_matrix[uid], n_neighbors=min(len(user_ids), k+1)
    )
    neigh_idx = neigh_idx[0].tolist()
    # remove o próprio índice
    neigh_idx = [i for i in neigh_idx if i != uid]

    # agrega as interações dos vizinhos
    neigh_matrix = interaction_matrix[neigh_idx]
    counts = np.asarray(neigh_matrix.sum(axis=0)).ravel()  # soma por coluna

    # itens já consumidos pelo usuário
    user_consumed = set(df[df['id_user']==user_id]['id_wine'])

    # ordena os vinhos por contagem decrescente
    recommendations = []
    for wine_idx in np.argsort(-counts):
        if counts[wine_idx] <= 0:
            break
        wine_id = wine_ids[wine_idx]
        if wine_id in user_consumed:
            continue
        recommendations.append(wine_id)
        if len(recommendations) >= k:
            break

    return recommendations
