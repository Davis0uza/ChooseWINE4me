# ml_service/train_cf.py

import os
import pandas as pd
import scipy.sparse as sp
from sklearn.neighbors import NearestNeighbors
from joblib import dump
from pandas.errors import EmptyDataError

# Caminhos dos CSVs
fav_path = 'data/favorites.csv'
rat_path = 'data/ratings.csv'

# 1) Tenta ler favorites.csv
try:
    df_fav = pd.read_csv(fav_path)
    print(f"favorites.csv carregado com {len(df_fav)} linhas")
except EmptyDataError:
    print("favorites.csv vazio ou não existe; pulando")
    df_fav = pd.DataFrame()

# 2) Se estiver vazio, cai em ratings.csv
if df_fav.empty:
    try:
        df_rat = pd.read_csv(rat_path)
        print(f"ratings.csv carregado com {len(df_rat)} linhas")
    except EmptyDataError:
        raise ValueError("ratings.csv também está vazio ou não existe — sem dados para treinar CF.")
    # usa id_user e id_wine de ratings como feedback implícito
    df_fav = df_rat[['id_user', 'id_wine']].copy()
else:
    print("Usando favorites.csv para feedback implícito")

# 3) Mapeia IDs únicos de usuário e vinho para índices
user_ids = sorted(df_fav['id_user'].unique())
wine_ids = sorted(df_fav['id_wine'].unique())
user_map = {u: i for i, u in enumerate(user_ids)}
wine_map = {w: i for i, w in enumerate(wine_ids)}

# 4) Prepara arrays para a matriz esparsa
rows = df_fav['id_user'].map(user_map)
cols = df_fav['id_wine'].map(wine_map)
data = [1] * len(df_fav)  # feedback implícito

# 5) Monta a matriz usuário×vinho
mat = sp.csr_matrix(
    (data, (rows, cols)),
    shape=(len(user_ids), len(wine_ids))
)

# 6) Treina o modelo NearestNeighbors (user-based CF)
model = NearestNeighbors(metric='cosine', algorithm='brute')
model.fit(mat)

# 7) Salva o modelo e os mapeamentos
os.makedirs('models', exist_ok=True)
dump((model, user_ids, wine_ids), 'models/model_cf.joblib')

print(f"✓ Modelo treinado e salvo em models/model_cf.joblib")
print(f"  • {len(user_ids)} usuários, {len(wine_ids)} vinhos")
