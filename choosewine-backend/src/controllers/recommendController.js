const axios = require('axios');

exports.getRecommendations = async (req, res) => {
  const { userId } = req.params;

  try {
    const response = await axios.get(`http://localhost:8000/recommend/${userId}`);
    return res.json(response.data);
  } catch (error) {
    console.error('Erro ao obter recomendações:', error.message);
    return res.status(500).json({ error: 'Erro ao obter recomendações do sistema de recomendação.' });
  }
};
