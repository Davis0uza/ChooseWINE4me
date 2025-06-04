// controllers/ratingController.js

const mongoose = require('mongoose');
const Rating = require('../models/Rating');
const Wine = require('../models/Wine');
const User = require('../models/User');

/**
 * Helper: recolhe todos os ratings de um vinho (wineId),
 * calcula a nova média (arredondada a 1 casa decimal),
 * e atualiza o campo `rating` do documento Wine correspondente.
 */
async function recalculateWineAverage(wineId) {
  // 1) Busque todos os ratings daquele vinho
  const ratings = await Rating.find({ wine: wineId }).select('rating').lean();

  // 2) Se não houver avaliações, sete rating do vinho para 0
  if (!ratings.length) {
    await Wine.findByIdAndUpdate(wineId, { rating: 0.0 });
    return;
  }

  // 3) Some todos os valores
  const sum = ratings.reduce((acc, doc) => acc + (doc.rating || 0), 0);
  const count = ratings.length;
  const avgRaw = sum / count;

  // 4) Arredonde a uma casa decimal
  const avgRounded = Math.round(avgRaw * 10) / 10;

  // 5) Atualize o campo `rating` do vinho
  await Wine.findByIdAndUpdate(wineId, { rating: avgRounded });
}


/**
 * Cria um novo rating para um vinho.
 * Endpoint: POST /ratings
 * Body esperado: {
 *   user:   "<ObjectId do usuário>",
 *   wineId: "<ObjectId do vinho>",
 *   rating: <número entre 0 e 5>,
 *   comment?: "<string opcional>"
 * }
 */
exports.createRating = async (req, res) => {
  try {
    const { user, wineId, rating, comment } = req.body;

    // ✅ 1) Validações básicas:
    if (!mongoose.Types.ObjectId.isValid(user)) {
      return res.status(400).json({ error: 'ID de usuário inválido.' });
    }
    if (!mongoose.Types.ObjectId.isValid(wineId)) {
      return res.status(400).json({ error: 'ID de vinho inválido.' });
    }
    if (typeof rating !== 'number' || rating < 0 || rating > 5) {
      return res.status(400).json({ error: 'Rating deve ser um número entre 0 e 5.' });
    }

    // ✅ 2) Verifique se o usuário existe
    const userExists = await User.findById(user);
    if (!userExists) {
      return res.status(404).json({ error: 'Usuário não encontrado.' });
    }

    // ✅ 3) Verifique se o vinho existe
    const wine = await Wine.findById(wineId);
    if (!wine) {
      return res.status(404).json({ error: 'Vinho não encontrado.' });
    }

    // ✅ 4) Crie o novo Rating
    const newRating = new Rating({
      user: user,
      wine: wineId,
      rating,
      comment
    });
    await newRating.save();

    // ✅ 5) Recalcule a média do vinho (campo `rating` em Wine)
    await recalculateWineAverage(wineId);

    // ✅ 6) Recarregue o Rating criado, populando user e wine
    const populated = await Rating.findById(newRating._id)
      .populate('user', 'name email')
      .populate('wine', 'name');

    return res.status(201).json(populated);
  } catch (error) {
    console.error('Erro ao criar rating:', error);
    return res.status(500).json({ error: 'Erro ao criar rating.' });
  }
};


/**
 * Retorna todos os ratings (cada rating já vem populado com user e wine).
 * Endpoint: GET /ratings
 */
exports.getAllRatings = async (req, res) => {
  try {
    const ratings = await Rating.find()
      .populate('user', 'name email')
      .populate('wine', 'name');
    return res.json(ratings);
  } catch (error) {
    console.error('Erro ao buscar ratings:', error);
    return res.status(500).json({ error: 'Erro ao buscar ratings.' });
  }
};


/**
 * Retorna um rating por ID (populado).
 * Endpoint: GET /ratings/:id
 */
exports.getRatingById = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'ID de rating inválido.' });
    }

    const rating = await Rating.findById(id)
      .populate('user', 'name email')
      .populate('wine', 'name');
    if (!rating) {
      return res.status(404).json({ error: 'Rating não encontrado.' });
    }
    return res.json(rating);
  } catch (error) {
    console.error('Erro ao buscar rating:', error);
    return res.status(500).json({ error: 'Erro ao buscar rating.' });
  }
};


/**
 * Atualiza um rating existente.
 * Endpoint: PUT /ratings/:id
 * Body esperado: { rating: <número entre 0 e 5>, comment?: "<string opcional>" }
 *
 * Após atualizar, recalcula a média do vinho e retorna o rating atualizado (populado).
 */
exports.updateRating = async (req, res) => {
  try {
    const { id } = req.params;
    const { rating, comment } = req.body;

    // ✅ 1) Validações
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'ID de rating inválido.' });
    }
    if (typeof rating !== 'number' || rating < 0 || rating > 5) {
      return res.status(400).json({ error: 'Rating deve ser um número entre 0 e 5.' });
    }

    // ✅ 2) Busque o Rating existente
    const existing = await Rating.findById(id);
    if (!existing) {
      return res.status(404).json({ error: 'Rating não encontrado.' });
    }

    // ✅ 3) Atualize os campos
    existing.rating = rating;
    existing.comment = comment;
    await existing.save();

    // ✅ 4) Recalcule média do vinho correspondente
    await recalculateWineAverage(existing.wine);

    // ✅ 5) Recarregue o Rating atualizado e popule user e wine
    const populated = await Rating.findById(id)
      .populate('user', 'name email')
      .populate('wine', 'name');

    return res.json(populated);
  } catch (error) {
    console.error('Erro ao atualizar rating:', error);
    return res.status(500).json({ error: 'Erro ao atualizar rating.' });
  }
};


/**
 * Remove um rating existente.
 * Endpoint: DELETE /ratings/:id
 *
 * Após remover, recalcula a média do vinho.
 */
exports.deleteRating = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'ID de rating inválido.' });
    }

    // Use findByIdAndDelete em vez de existing.remove()
    const existing = await Rating.findByIdAndDelete(id);
    if (!existing) {
      return res.status(404).json({ error: 'Rating não encontrado.' });
    }

    await recalculateWineAverage(existing.wine);

    return res.json({ message: 'Rating deletado com sucesso.' });
  } catch (error) {
    console.error('Erro ao deletar rating:', error);
    return res.status(500).json({ error: 'Erro ao deletar rating.' });
  }
};
