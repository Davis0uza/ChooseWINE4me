# ml_service/extract_data.py

import os
from urllib.parse import urlparse
from dotenv import load_dotenv
from pymongo import MongoClient
import pandas as pd

# 1) Carrega variáveis do .env
env_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '.env'))
load_dotenv(env_path)

# 2) Conecta ao MongoDB
mongo_uri = os.getenv('MONGODB_URI')
if not mongo_uri:
    raise ValueError("MONGODB_URI não encontrado no .env")
client = MongoClient(mongo_uri)

# 3) Extrai o nome da base de dados da URI
parsed = urlparse(mongo_uri)
db_name = parsed.path.lstrip('/').split('?')[0]
db = client[db_name]

# Cria pasta se não existir
os.makedirs('data', exist_ok=True)

# 4) Exporta favoritos (user e wine como _id em string)
fav_docs = list(db.favorites.find({}, {'_id': 0, 'user': 1, 'wine': 1}))
df_fav = pd.DataFrame(fav_docs)
if not df_fav.empty:
    df_fav['user'] = df_fav['user'].astype(str)
    df_fav['wine'] = df_fav['wine'].astype(str)
    df_fav.to_csv('ml_service/data/favorites.csv', index=False)
    print(f"✓ Exportadas {len(df_fav)} linhas para data/favorites.csv")
else:
    print("⚠️ Nenhum favorito encontrado no MongoDB.")

# 5) Exporta ratings (como alternativa)
rat_docs = list(db.ratings.find({}, {'_id': 0, 'user': 1, 'wine': 1, 'rating': 1}))
df_rat = pd.DataFrame(rat_docs)
if not df_rat.empty:
    df_rat['user'] = df_rat['user'].astype(str)
    df_rat['wine'] = df_rat['wine'].astype(str)
    df_rat.to_csv('ml_service/data/ratings.csv', index=False)
    print(f"✓ Exportadas {len(df_rat)} linhas para data/ratings.csv")
else:
    print("⚠️ Nenhum rating encontrado no MongoDB.")
