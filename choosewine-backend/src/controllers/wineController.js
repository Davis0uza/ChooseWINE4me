const Wine = require('../models/Wine');

// Listar todos os vinhos
exports.getAllWines = async (req, res) => {
  try {
    const wines = await Wine.find();
    return res.json(wines);
  } catch (error) {
    console.error('Erro ao buscar vinhos:', error);
    return res.status(500).json({ error: 'Erro ao buscar vinhos' });
  }
};

// Buscar vinho por ID
exports.getWineById = async (req, res) => {
  try {
    const { id } = req.params;
    const wine = await Wine.findOne({ id_wine: id });
    if (!wine) {
      return res.status(404).json({ error: 'Vinho não encontrado' });
    }
    return res.json(wine);
  } catch (error) {
    console.error('Erro ao buscar vinho:', error);
    return res.status(500).json({ error: 'Erro ao buscar vinho' });
  }
};

// Criar um novo vinho
exports.createWine = async (req, res) => {
  try {
    const { name, thumb, country, region, price } = req.body;
    
    // Busca o último vinho e gera um novo id_wine de forma sequencial
    const lastWine = await Wine.findOne({}).sort({ id_wine: -1 });
    const newIdWine = lastWine && lastWine.id_wine ? lastWine.id_wine + 1 : 1;
    
    const newWine = new Wine({
      id_wine: newIdWine,
      name,
      thumb,
      country,
      region,
      price,
      // average_rating e ratings usarão os valores default (0)
    });
    
    await newWine.save();
    return res.status(201).json(newWine);
  } catch (error) {
    console.error('Erro ao criar vinho:', error);
    return res.status(500).json({ error: 'Erro ao criar vinho' });
  }
};

// Atualizar um vinho (exceto id_wine, average_rating e ratings)
exports.updateWine = async (req, res) => {
  try {
    const { id } = req.params;
    // Permite atualizar os campos editáveis: name, thumb, country, region e price
    const { name, thumb, country, region, price } = req.body;
    
    const updatedWine = await Wine.findOneAndUpdate(
      { id_wine: id },
      { name, thumb, country, region, price },
      { new: true }
    );
    
    if (!updatedWine) {
      return res.status(404).json({ error: 'Vinho não encontrado' });
    }
    return res.json(updatedWine);
  } catch (error) {
    console.error('Erro ao atualizar vinho:', error);
    return res.status(500).json({ error: 'Erro ao atualizar vinho' });
  }
};

// Deletar um vinho
exports.deleteWine = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedWine = await Wine.findOneAndDelete({ id_wine: id });
    if (!deletedWine) {
      return res.status(404).json({ error: 'Vinho não encontrado' });
    }
    return res.json({ message: 'Vinho deletado com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar vinho:', error);
    return res.status(500).json({ error: 'Erro ao deletar vinho' });
  }
};
