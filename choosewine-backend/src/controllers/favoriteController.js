const Favorite = require('../models/Favorite');
const Wine = require('../models/Wine');

// Criar um favorito
exports.createFavorite = async (req, res) => {
  try {
    const { user, wineId } = req.body;

    // Verifica se o vinho existe
    const wine = await Wine.findById(wineId);
    if (!wine) {
      return res.status(404).json({ error: 'Vinho não encontrado' });
    }

    // Verifica se já existe relação
    const existe = await Favorite.findOne({ user, wine: wineId });
    if (existe) {
      return res.status(400).json({ error: 'Favorito já registrado' });
    }

    const newFavorite = new Favorite({
      user,
      wine: wine._id
    });

    await newFavorite.save();
    return res.status(201).json(newFavorite);
  } catch (error) {
    console.error('Erro ao criar favorite:', error);
    return res.status(500).json({ error: 'Erro ao criar favorite' });
  }
};

// Listar todos os favoritos (com vinho populado)
exports.getAllFavorites = async (req, res) => {
  try {
    const favorites = await Favorite.find().populate('wine');
    return res.json(favorites);
  } catch (error) {
    console.error('Erro ao buscar favorites:', error);
    return res.status(500).json({ error: 'Erro ao buscar favorites' });
  }
};

// Buscar favorito por ID (do Mongo)
exports.getFavoriteById = async (req, res) => {
  try {
    const { id } = req.params;
    const favorite = await Favorite.findById(id).populate('wine');
    if (!favorite) {
      return res.status(404).json({ error: 'Favorite não encontrado' });
    }
    return res.json(favorite);
  } catch (error) {
    console.error('Erro ao buscar favorite:', error);
    return res.status(500).json({ error: 'Erro ao buscar favorite' });
  }
};

// Atualizar vinho associado a um favorito
exports.updateFavorite = async (req, res) => {
  try {
    const { id } = req.params;
    const { wineId } = req.body;

    const updatedFavorite = await Favorite.findByIdAndUpdate(
      id,
      { wine: wineId },
      { new: true }
    );

    if (!updatedFavorite) {
      return res.status(404).json({ error: 'Favorite não encontrado' });
    }

    return res.json(updatedFavorite);
  } catch (error) {
    console.error('Erro ao atualizar favorite:', error);
    return res.status(500).json({ error: 'Erro ao atualizar favorite' });
  }
};

// Deletar favorito
exports.deleteFavorite = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedFavorite = await Favorite.findByIdAndDelete(id);
    if (!deletedFavorite) {
      return res.status(404).json({ error: 'Favorite não encontrado' });
    }
    return res.json({ message: 'Favorite deletado com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar favorite:', error);
    return res.status(500).json({ error: 'Erro ao deletar favorite' });
  }
};
