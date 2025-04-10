const History = require('../models/History');

exports.createHistory = async (req, res) => {
  try {
    // Se desejar, permita que accessed_at seja enviado ou utilize o default Date.now()
    const { id_user, accessed_at } = req.body;
    
    // Busca o último histórico para definir o novo id_history de forma sequencial
    const lastHistory = await History.findOne({}).sort({ id_history: -1 });
    const newIdHistory = lastHistory && lastHistory.id_history ? lastHistory.id_history + 1 : 1;
    
    const newHistory = new History({
      id_history: newIdHistory,
      id_user,
      accessed_at: accessed_at ? accessed_at : Date.now(),
    });
    
    await newHistory.save();
    return res.status(201).json(newHistory);
  } catch (error) {
    console.error('Erro ao criar history:', error);
    return res.status(500).json({ error: 'Erro ao criar history' });
  }
};

exports.getAllHistories = async (req, res) => {
  try {
    const histories = await History.find();
    return res.json(histories);
  } catch (error) {
    console.error('Erro ao buscar histories:', error);
    return res.status(500).json({ error: 'Erro ao buscar histories' });
  }
};

exports.getHistoryById = async (req, res) => {
  try {
    const { id } = req.params;
    const history = await History.findOne({ id_history: id });
    if (!history) {
      return res.status(404).json({ error: 'History não encontrado' });
    }
    return res.json(history);
  } catch (error) {
    console.error('Erro ao buscar history:', error);
    return res.status(500).json({ error: 'Erro ao buscar history' });
  }
};

exports.updateHistory = async (req, res) => {
  try {
    const { id } = req.params;
    // Permite atualizar o id_user ou accessed_at, se necessário
    const { id_user, accessed_at } = req.body;
    const updatedHistory = await History.findOneAndUpdate(
      { id_history: id },
      { id_user, accessed_at },
      { new: true }
    );
    
    if (!updatedHistory) {
      return res.status(404).json({ error: 'History não encontrado' });
    }
    return res.json(updatedHistory);
  } catch (error) {
    console.error('Erro ao atualizar history:', error);
    return res.status(500).json({ error: 'Erro ao atualizar history' });
  }
};

exports.deleteHistory = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedHistory = await History.findOneAndDelete({ id_history: id });
    if (!deletedHistory) {
      return res.status(404).json({ error: 'History não encontrado' });
    }
    return res.json({ message: 'History deletado com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar history:', error);
    return res.status(500).json({ error: 'Erro ao deletar history' });
  }
};
