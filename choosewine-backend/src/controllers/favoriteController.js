const Favorite = require('../models/Favorite');
const Wine = require('../models/Wine');

exports.createFavorite = async (req, res) => {
  try {
    const { id_user, id_wine } = req.body;
    
     // Verifica se o vinho existe
     const wine = await Wine.findOne({ id_wine: id_wine });
     if (!wine) {
       return res.status(404).json({ error: 'Vinho não encontrado' });
     }

    //verifica se já existe relação
    const existe = await Favorite.findOne({ id_user, id_wine });
    if (existe) return res.status(400).json({ error: "Favorito já registrado" });
    
    // Busca o último favorito para gerar um novo id_fav sequencial
    const lastFav = await Favorite.findOne({}).sort({ id_fav: -1 });
    const newIdFav = lastFav && lastFav.id_fav ? lastFav.id_fav + 1 : 1;
    
    const newFavorite = new Favorite({
      id_fav: newIdFav,
      id_user,
      id_wine,
    });
    
    await newFavorite.save();
    return res.status(201).json(newFavorite);
  } catch (error) {
    console.error('Erro ao criar favorite:', error);
    return res.status(500).json({ error: 'Erro ao criar favorite' });
  }
};

// Listar todos os favoritos
exports.getAllFavorites = async (req, res) => {
  try {
    const favorites = await Favorite.find();
    return res.json(favorites);
  } catch (error) {
    console.error('Erro ao buscar favorites:', error);
    return res.status(500).json({ error: 'Erro ao buscar favorites' });
  }
};

// Buscar favorito por id_fav
exports.getFavoriteById = async (req, res) => {
  try {
    const { id } = req.params;
    const favorite = await Favorite.findOne({ id_fav: id });
    if (!favorite) {
      return res.status(404).json({ error: 'Favorite não encontrado' });
    }
    return res.json(favorite);
  } catch (error) {
    console.error('Erro ao buscar favorite:', error);
    return res.status(500).json({ error: 'Erro ao buscar favorite' });
  }
};

// Atualizar favorito (por exemplo, atualizar id_wine se necessário)
exports.updateFavorite = async (req, res) => {
  try {
    const { id } = req.params;
    // Permite atualizar o id_wine; id_user não é alterado para manter a associação
    const { id_wine } = req.body;
    const updatedFavorite = await Favorite.findOneAndUpdate(
      { id_fav: id },
      { id_wine },
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
    const deletedFavorite = await Favorite.findOneAndDelete({ id_fav: id });
    if (!deletedFavorite) {
      return res.status(404).json({ error: 'Favorite não encontrado' });
    }
    return res.json({ message: 'Favorite deletado com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar favorite:', error);
    return res.status(500).json({ error: 'Erro ao deletar favorite' });
  }
};
