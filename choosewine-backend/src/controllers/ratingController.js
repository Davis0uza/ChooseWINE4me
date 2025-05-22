const Rating = require('../models/Rating');
const Wine = require('../models/Wine');

// Criar um novo rating
exports.createRating = async (req, res) => {
  try {
    const { user, wineId, rating, comment } = req.body;

    if (typeof rating !== 'number' || rating < 0 || rating > 5) {
      return res.status(400).json({ error: 'Rating deve ser um número entre 0 e 5' });
    }

    // Verificar se o vinho existe
    const wine = await Wine.findById(wineId);
    if (!wine) {
      return res.status(404).json({ error: 'Vinho não encontrado' });
    }

    // Atualiza média e contagem
    const currentCount = wine.ratings || 0;
    const currentAverage = wine.average_rating || 0;
    const newCount = currentCount + 1;
    const newAverage = ((currentAverage * currentCount) + rating) / newCount;

    wine.ratings = newCount;
    wine.average_rating = newAverage;
    await wine.save();

    // Criar rating
    const newRating = new Rating({
      user,
      wine: wine._id,
      rating,
      comment
    });

    await newRating.save();
    return res.status(201).json(newRating);
  } catch (error) {
    console.error('Erro ao criar rating:', error);
    return res.status(500).json({ error: 'Erro ao criar rating' });
  }
};

// Obter todos os ratings
exports.getAllRatings = async (req, res) => {
  try {
    const ratings = await Rating.find().populate('wine');
    return res.json(ratings);
  } catch (error) {
    console.error('Erro ao buscar ratings:', error);
    return res.status(500).json({ error: 'Erro ao buscar ratings' });
  }
};

// Obter rating por ID
exports.getRatingById = async (req, res) => {
  try {
    const { id } = req.params;
    const rating = await Rating.findById(id).populate('wine');
    if (!rating) {
      return res.status(404).json({ error: 'Rating não encontrado' });
    }
    return res.json(rating);
  } catch (error) {
    console.error('Erro ao buscar rating:', error);
    return res.status(500).json({ error: 'Erro ao buscar rating' });
  }
};

// Deletar rating
exports.deleteRating = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedRating = await Rating.findByIdAndDelete(id);
    if (!deletedRating) {
      return res.status(404).json({ error: 'Rating não encontrado' });
    }
    return res.json({ message: 'Rating deletado com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar rating:', error);
    return res.status(500).json({ error: 'Erro ao deletar rating' });
  }
};
