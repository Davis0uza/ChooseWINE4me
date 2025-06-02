const Wine = require('../models/Wine');

// Obter todos os vinhos
exports.getAllWines = async (req, res) => {
  try {
    const wines = await Wine.find();
    return res.json(wines);
  } catch (error) {
    console.error('Erro ao buscar vinhos:', error);
    return res.status(500).json({ error: 'Erro ao buscar vinhos' });
  }
};

// Obter vinho por _id
exports.getWineById = async (req, res) => {
  try {
    const { id } = req.params;
    const wine = await Wine.findById(id);
    if (!wine) {
      return res.status(404).json({ error: 'Vinho não encontrado' });
    }
    return res.json(wine);
  } catch (error) {
    console.error('Erro ao buscar vinho:', error);
    return res.status(500).json({ error: 'Erro ao buscar vinho' });
  }
};

// Criar novo vinho
exports.createWine = async (req, res) => {
  try {
    const { url, name, type, rating, country, winery, alcoholLevel, image, price, year } = req.body;

    const newWine = new Wine({
      url,
      name,
      type,
      rating,
      country,
      winery,
      alcoholLevel,
      image,
      price,
      year
    });

    await newWine.save();
    return res.status(201).json(newWine);
  } catch (error) {
    console.error('Erro ao criar vinho:', error);
    return res.status(500).json({ error: 'Erro ao criar vinho' });
  }
};

// Atualizar vinho existente
exports.updateWine = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const updatedWine = await Wine.findByIdAndUpdate(id, updateData, { new: true });

    if (!updatedWine) {
      return res.status(404).json({ error: 'Vinho não encontrado' });
    }

    return res.json(updatedWine);
  } catch (error) {
    console.error('Erro ao atualizar vinho:', error);
    return res.status(500).json({ error: 'Erro ao atualizar vinho' });
  }
};

// Apagar vinho
exports.deleteWine = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedWine = await Wine.findByIdAndDelete(id);

    if (!deletedWine) {
      return res.status(404).json({ error: 'Vinho não encontrado' });
    }

    return res.json({ message: 'Vinho deletado com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar vinho:', error);
    return res.status(500).json({ error: 'Erro ao deletar vinho' });
  }
};



//PESQUISAS E FILTROS

//Pesquisa por types
exports.getWineTypes = async (req, res) => {
  try {
    const types = await Wine.distinct('type');
    const validTypes = types.filter(type => type && type !== 'N/A');
    return res.json(validTypes.sort());
  } catch (error) {
    console.error('Erro ao listar tipos de vinho:', error);
    return res.status(500).json({ error: 'Erro ao obter os tipos de vinho' });
  }
};

//Pesquisa por Castas
exports.getWineries = async (req, res) => {
  try {
    const wineries = await Wine.distinct('winery');
    const validWineries = wineries.filter(w => w && w !== 'N/A');
    return res.json(validWineries.sort());
  } catch (error) {
    console.error('Erro ao listar vinícolas:', error);
    return res.status(500).json({ error: 'Erro ao obter as vinícolas' });
  }
};