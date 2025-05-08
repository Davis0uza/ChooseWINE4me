# ml_service/extract_data.py

import os
from urllib.parse import urlparse
from dotenv import load_dotenv
from pymongo import MongoClient
import pandas as pd

# 1) Carrega o .env da raiz do projeto
env_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '.env'))
load_dotenv(env_path)

# 2) Conecta ao MongoDB
mongo_uri = os.getenv('MONGODB_URI')
if not mongo_uri:
    raise ValueError("MONGODB_URI não encontrado no .env")
client = MongoClient(mongo_uri)

# 3) Extrai o nome do database da URI
parsed = urlparse(mongo_uri)
db_name = parsed.path.lstrip('/').split('?')[0]
db = client[db_name]

# 4) Lê e exporta favoritos
fav_docs = list(db.favorites.find({}, {'_id': 0, 'id_user': 1, 'id_wine': 1}))
df_fav = pd.DataFrame(fav_docs)
os.makedirs('data', exist_ok=True)
df_fav.to_csv('data/favorites.csv', index=False)
print(f"✓ Exportadas {len(df_fav)} linhas para data/favorites.csv")

# 5) Lê e exporta ratings
rat_docs = list(db.ratings.find({}, {'_id': 0, 'id_user': 1, 'id_wine': 1, 'rating': 1}))
df_rat = pd.DataFrame(rat_docs)
df_rat.to_csv('data/ratings.csv', index=False)
print(f"✓ Exportadas {len(df_rat)} linhas para data/ratings.csv")
