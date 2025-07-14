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

🚀 Iniciar o Projeto Localmente
Para correr o projeto localmente, certifica-te de que tens os pré-requisitos instalados:

    Node.js
    Python (versão 3.10+)
    Flutter SDK
    MongoDB Atlas configurado

⚙️ Backend (API Node.js)

    cd choosewine-backend
    node src/server.js
    
Garante que o ficheiro .env está corretamente configurado com os dados da base de dados e a chave do serviço.

🤖 Microserviço de Recomendação (FastAPI em Python)

    cd choosewine-backend
    cd ml_service
    . .\.venv\Scripts\Activate.ps1  # (no Windows PowerShell)
    uvicorn app_http:app --reload --port 8000
O microserviço carrega dados da API Node.js e utiliza modelos baseados em similaridade para recomendações.
Importante: O ficheiro .env deve conter o IP correto da API principal (por exemplo, NODE_API_URL=http://127.0.0.1:3000).

📱 Frontend (Flutter)

    cd flutter_frontend
    flutter pub get
    flutter run
    
Certifica-te de que os IPs e portas estão corretos no ficheiro .env ou ficheiros de configuração usados no Flutter.

⚠️ Configuração dos IPs
Para garantir o bom funcionamento do sistema, é obrigatório ajustar os IPs locais nos ficheiros .env dos módulos:

No backend: configurações da base de dados, Firebase, e API do recomendador.

No ml_service: variável NODE_API_URL com o IP/porta do backend.

No frontend: endpoints para os serviços HTTP devem apontar para os IPs e portas corretos (ex: http://10.0.2.2:3000 no Android Emulator).
