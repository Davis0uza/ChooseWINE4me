const axios = require('axios');
const Wine = require('../models/Wine'); 

exports.getRecommendations = async (req, res) => {
  const { userId } = req.params;

  try {
    //Faz a chamada ao serviço de ML, que retorna um array de IDs de vinhos (strings)
    const response = await axios.get(`http://127.0.0.1:8000/recommend/${userId}`);
    const recommendedIds = response.data; // ex.: ["682daf7b49846205368a80d5", "682daf7b49846205368a80e0", ...]

    //Busca todos os vinhos 
    const wines = await Wine.find({ _id: { $in: recommendedIds } });

    //Ordenar os vinhos para que fique igual à ordem de IDs recebidos
    const orderedWines = recommendedIds
      .map(idStr => wines.find(w => w._id.toString() === idStr))
      .filter(w => w); // remove possíveis undefined se algum ID não existir

    //Retorna o array de documentos de Wine
    return res.json(orderedWines);
  } catch (error) {
    console.error('Erro ao obter recomendações:', error.message);
    return res
      .status(500)
      .json({ error: 'Erro ao obter recomendações do sistema de recomendação.' });
  }
};
