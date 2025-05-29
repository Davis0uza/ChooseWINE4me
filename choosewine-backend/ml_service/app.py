# ml_service/app.py

import os
from urllib.parse import urlparse
from dotenv import load_dotenv
from fastapi import FastAPI
from pymongo import MongoClient
from pydantic import BaseModel
import pandas as pd
import numpy as np
import scipy.sparse as sp
from sklearn.neighbors import NearestNeighbors

# --- Configuração .env e MongoDB ---
env_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '.env'))
load_dotenv(env_path)

mongo_uri = os.getenv('MONGODB_URI')
client = MongoClient(mongo_uri)
parsed = urlparse(mongo_uri)
db_name = parsed.path.lstrip('/').split('?')[0]
db = client[db_name]

wines_col = db.wines
favs_col = db.favorites
addr_col = db.addresses

# --- Carrega dados de interação ---
try:
    df = pd.read_csv("data/favorites.csv")
except FileNotFoundError:
    df = pd.read_csv("data/ratings.csv")

df['user'] = df['user'].astype(str)
df['wine'] = df['wine'].astype(str)

user_ids = sorted(df['user'].unique())
wine_ids = sorted(df['wine'].unique())
user_map = {u: i for i, u in enumerate(user_ids)}
wine_map = {w: i for i, w in enumerate(wine_ids)}

rows = df['user'].map(user_map)
cols = df['wine'].map(wine_map)
data = np.ones(len(df), dtype=np.int8)
interaction_matrix = sp.csr_matrix((data, (rows, cols)), shape=(len(user_ids), len(wine_ids)))

model = NearestNeighbors(metric='cosine', algorithm='brute')
model.fit(interaction_matrix)

# --- API FastAPI ---
app = FastAPI()

@app.get("/recommend/{user_id}")
async def recommend(user_id: str):
    recommendations = recommend_cf(user_id)

    if not recommendations:
        print("🔄 Nenhuma recomendação CF — aplicando fallback…")
        recommendations = recommend_fallback(user_id)

    return recommendations


def recommend_cf(user_id: str):
    if user_id not in user_map:
        return []

    uid = user_map[user_id]
    neigh_dist, neigh_idx = model.kneighbors(interaction_matrix[uid], n_neighbors=min(len(user_ids), 6))
    neigh_idx = neigh_idx[0].tolist()
    neigh_idx = [i for i in neigh_idx if i != uid]

    neigh_matrix = interaction_matrix[neigh_idx]
    counts = np.asarray(neigh_matrix.sum(axis=0)).ravel()
    consumed = set(df[df['user'] == user_id]['wine'])

    results = []
    for wine_idx in np.argsort(-counts):
        if counts[wine_idx] <= 0:
            break
        wine_id = wine_ids[wine_idx]
        if wine_id in consumed:
            continue
        vinho = wines_col.find_one({"_id": wine_id})
        if vinho:
            results.append({
                "_id": str(vinho["_id"]),
                "name": vinho.get("name"),
                "rating": vinho.get("rating"),
                "type": vinho.get("type"),
                "winery": vinho.get("winery"),
                "price" : vinho.get("price"),
                "country" : vinho.get("country")
            })
    return results


def recommend_fallback(user_id: str):
    # 1. Obter cidade do utilizador
    morada = addr_col.find_one({"user": user_id})
    if not morada or "city" not in morada:
        return recommend_top_rated()

    cidade = morada["city"]
    # 2. Buscar todos os utilizadores dessa cidade
    user_ids_same_city = [
        str(a["user"]) for a in addr_col.find({"city": cidade}, {"user": 1})
    ]

    if not user_ids_same_city:
        return recommend_top_rated()

    # 3. Buscar favoritos desses utilizadores
    favs = list(favs_col.find({"user": {"$in": user_ids_same_city}}, {"wine": 1}))
    if not favs:
        return recommend_top_rated()

    wine_freq = {}
    for f in favs:
        wine_id = str(f["wine"])
        wine_freq[wine_id] = wine_freq.get(wine_id, 0) + 1

    # Ordena por frequência
    ordered = sorted(wine_freq.items(), key=lambda x: -x[1])

    results = []
    for wine_id, count in ordered:
        vinho = wines_col.find_one({"_id": wine_id})
        if vinho:
            results.append({
                "_id": str(vinho["_id"]),
                "name": vinho.get("name"),
                "rating": vinho.get("rating"),
                "type": vinho.get("type"),
                "winery": vinho.get("winery"),
                "price" : vinho.get("price"),
                "country" : vinho.get("country"),
                "region_count": count
            })
    return results


def recommend_top_rated():
    vinhos = list(wines_col.find())
    vinhos.sort(
        key=lambda v: (v.get("rating", 0), favs_col.count_documents({"wine": v["_id"]})),
        reverse=True
    )
    return [
        {
            "_id": str(v["_id"]),
            "name": v.get("name"),
            "rating": v.get("rating"),
            "type": v.get("type"),
            "price" : v.get("price"),
            "country" : v.get("country")
        }
        for v in vinhos
    ]
