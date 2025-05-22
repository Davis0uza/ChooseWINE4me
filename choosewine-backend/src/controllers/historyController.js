const History = require('../models/History');
const Wine = require('../models/Wine');

// Adicionar ou atualizar histórico
exports.createOrUpdateHistory = async (req, res) => {
  try {
    const { userId, wineId } = req.body;

    // Verifica se vinho existe
    const wine = await Wine.findById(wineId);
    if (!wine) {
      return res.status(404).json({ error: 'Vinho não encontrado' });
    }

    // Verifica se já existe este vinho no histórico do user
    const existing = await History.findOne({ user: userId, wine: wineId });

    if (existing) {
      // Atualiza data de acesso
      existing.accessed_at = new Date();
      await existing.save();
    } else {
      // Adiciona novo histórico
      await History.create({ user: userId, wine: wineId, accessed_at: new Date() });
    }

    // Garante que só existam os 10 mais recentes
    const total = await History.countDocuments({ user: userId });
    if (total > 10) {
      const excess = await History.find({ user: userId })
        .sort({ accessed_at: 1 })
        .limit(total - 10);
      const toDelete = excess.map(h => h._id);
      await History.deleteMany({ _id: { $in: toDelete } });
    }

    return res.status(201).json({ message: 'Histórico atualizado' });
  } catch (error) {
    console.error('Erro ao atualizar histórico:', error);
    return res.status(500).json({ error: 'Erro ao atualizar histórico' });
  }
};

// Obter os últimos 10 acessos
exports.getUserHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const history = await History.find({ user: userId })
      .sort({ accessed_at: -1 })
      .limit(10)
      .populate('wine');
    return res.json(history);
  } catch (error) {
    console.error('Erro ao buscar histórico:', error);
    return res.status(500).json({ error: 'Erro ao buscar histórico' });
  }
};

// Atualizar manualmente um histórico (ex: corrigir vinho ou timestamp)
exports.updateHistory = async (req, res) => {
  try {
    const { id } = req.params;
    const { wineId, accessed_at } = req.body;

    const updated = await History.findByIdAndUpdate(
      id,
      {
        ...(wineId && { wine: wineId }),
        ...(accessed_at && { accessed_at })
      },
      { new: true }
    ).populate('wine');

    if (!updated) {
      return res.status(404).json({ error: 'Histórico não encontrado' });
    }

    return res.json(updated);
  } catch (error) {
    console.error('Erro ao atualizar histórico:', error);
    return res.status(500).json({ error: 'Erro ao atualizar histórico' });
  }
};

// Remover histórico
exports.deleteHistory = async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await History.findByIdAndDelete(id);
    if (!deleted) {
      return res.status(404).json({ error: 'Histórico não encontrado' });
    }
    return res.json({ message: 'Histórico removido com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar histórico:', error);
    return res.status(500).json({ error: 'Erro ao deletar histórico' });
  }
};
