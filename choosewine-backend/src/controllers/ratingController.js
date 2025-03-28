const Rating = require('../models/Rating');
const Wine = require('../models/Wine');

exports.createRating = async (req, res) => {
  try {
    const { id_user, id_wine, rating, comment } = req.body;
    
    // Validação simples para o rating (exemplo: deve estar entre 0 e 5)
    if (typeof rating !== 'number' || rating < 0 || rating > 5) {
      return res.status(400).json({ error: 'Rating deve ser um número entre 0 e 5' });
    }
    
    // Verificar se o vinho existe
    const wine = await Wine.findOne({ id_wine });
    if (!wine) {
      return res.status(404).json({ error: 'Vinho não encontrado' });
    }
    
    // Atualiza os dados do vinho:
    // Novo total de ratings e nova média considerando o rating atual
    const currentCount = wine.ratings;
    const currentAverage = wine.average_rating;
    const newCount = currentCount + 1;
    const newAverage = ((currentAverage * currentCount) + rating) / newCount;
    
    wine.ratings = newCount;
    wine.average_rating = newAverage;
    await wine.save();
    
    // Gerar um novo id_rating de forma sequencial
    const lastRating = await Rating.findOne({}).sort({ id_rating: -1 });
    const newIdRating = lastRating && lastRating.id_rating ? lastRating.id_rating + 1 : 1;
    
    // Criar o novo rating
    const newRating = new Rating({
      id_rating: newIdRating,
      id_user,
      id_wine,
      rating,
      comment,
    });
    
    await newRating.save();
    
    return res.status(201).json(newRating);
  } catch (error) {
    console.error('Erro ao criar rating:', error);
    return res.status(500).json({ error: 'Erro ao criar rating' });
  }
};
