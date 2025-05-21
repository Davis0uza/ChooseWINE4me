# ml_service/train_cf.py

import os
import pandas as pd
import scipy.sparse as sp
from sklearn.neighbors import NearestNeighbors
from joblib import dump
from pandas.errors import EmptyDataError

# Caminhos dos CSVs
fav_path = 'ml_service/data/favorites.csv'
rat_path = 'ml_service/data/ratings.csv'

# 1) Tenta ler favorites.csv
try:
    df_fav = pd.read_csv(fav_path)
    print(f"favorites.csv carregado com {len(df_fav)} linhas")
except EmptyDataError:
    print("favorites.csv vazio ou não existe; pulando")
    df_fav = pd.DataFrame()

# 2) Fallback para ratings
if df_fav.empty:
    try:
        df_rat = pd.read_csv(rat_path)
        print(f"ratings.csv carregado com {len(df_rat)} linhas")
    except EmptyDataError:
        raise ValueError("ratings.csv também está vazio ou não existe — sem dados para treinar CF.")
    df_fav = df_rat[['user', 'wine']].copy()  # campos já convertidos de _id

# 3) Garante que os IDs são strings
df_fav['user'] = df_fav['user'].astype(str)
df_fav['wine'] = df_fav['wine'].astype(str)

# 4) Mapeia IDs únicos para índices
user_ids = sorted(df_fav['user'].unique())
wine_ids = sorted(df_fav['wine'].unique())
user_map = {u: i for i, u in enumerate(user_ids)}
wine_map = {w: i for i, w in enumerate(wine_ids)}

# 5) Prepara matriz esparsa
rows = df_fav['user'].map(user_map)
cols = df_fav['wine'].map(wine_map)
data = [1] * len(df_fav)

mat = sp.csr_matrix((data, (rows, cols)), shape=(len(user_ids), len(wine_ids)))

# 6) Treina modelo CF
model = NearestNeighbors(metric='cosine', algorithm='brute')
model.fit(mat)

# 7) Salva modelo
os.makedirs('ml_service/models', exist_ok=True)
dump((model, user_ids, wine_ids), 'ml_service/models/model_cf.joblib')

print(f"✓ Modelo treinado e salvo em models/model_cf.joblib")
print(f"  • {len(user_ids)} users, {len(wine_ids)} vinhos")
