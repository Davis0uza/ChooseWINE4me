🍷 ChooseWine4me
ChooseWine4me é uma plataforma digital que facilita a descoberta e seleção de vinhos personalizados, combinando preferências do utilizador com um sistema de recomendação inteligente. A aplicação permite favoritar, avaliar e explorar vinhos, além de receber sugestões automáticas com base em comportamento e localização.

<img width="1119" height="745" alt="Captura de ecrã 2025-07-01 104115" src="https://github.com/user-attachments/assets/b17d7bcb-fc28-4443-b812-3f4779e78424" />

📝 Descrição do Projeto
O ChooseWine4me visa tornar a experiência de escolher vinho mais simples, intuitiva e personalizada. Com um design acessível e tecnologia moderna, qualquer utilizador — conhecedor ou iniciante — pode descobrir novas opções com base nos seus gostos e hábitos.


<img width="526" height="933" alt="Captura de ecrã 2025-07-01 101608" src="https://github.com/user-attachments/assets/b5d803cb-c19c-4d42-8bbb-7e50b6537960" />

<img width="526" height="936" alt="Captura de ecrã 2025-07-01 104906" src="https://github.com/user-attachments/assets/0dc7b93c-2e07-4bc8-8d1f-7978fabfebd6" />

<img width="529" height="937" alt="Captura de ecrã 2025-07-01 105445" src="https://github.com/user-attachments/assets/808a2756-e212-4a9c-bb06-38d88d2e8889" />


🔍 Funcionalidades
📚 Catálogo de Vinhos: Consulta e pesquisa por nome, tipo, país, região e produtor.

❤️ Favoritos: Guarda vinhos preferidos para referência futura.

⭐ Avaliação de Vinhos: Sistema de avaliação simples para indicar os preferidos.

🧠 Recomendações Inteligentes: Sugestões de vinhos com base no perfil do utilizador e nos seus hábitos.

🔐 Autenticação com Firebase: Login rápido e seguro com conta Google.

📊 Firebase Analytics: Monitorização de interações para melhor personalização e análise de comportamento.


🤖 Sistema de Recomendação
O módulo de recomendação do ChooseWine4me é híbrido, combinando várias técnicas de machine learning e análise comportamental. A lógica de recomendação inclui:

  1. 🔁 Recomendações Baseadas em Conteúdo (Content-Based Filtering)
  Se o utilizador tiver um histórico de favoritos ou vinhos visualizados, o sistema analisa os atributos do último vinho interagido e recomenda outros similares, com base em:
  
    Preço (price)
    Avaliação (rating)
    País (country)
    Região (region)
    Tipo (type)
    Produtor (winery)
  
  Utiliza algoritmos de Nearest Neighbors com distância cosseno para determinar a similaridade.
  
  2. 🧑‍🤝‍🧑 Filtragem por Localização (Geo-Based Peer Filtering)
  Se não houver interações prévias, o sistema:
  
    Identifica a cidade do utilizador (com base no seu endereço registado).
    Recolhe os vinhos consumidos por outros utilizadores da mesma cidade.
    Recomenda esses vinhos primeiro, seguidos de outros similares.
  
  3. ⭐ Fallback por Popularidade Global
  Se todas as estratégias anteriores falharem, o sistema sugere os vinhos mais bem avaliados em toda a plataforma, ordenados por rating.
