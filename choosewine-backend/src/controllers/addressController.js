const Address = require('../models/Address');
const User = require('../models/User');

// Criar nova morada
exports.createAddress = async (req, res) => {
  try {
    const { userId, country, city, address, postal } = req.body;

    // Verificar se o utilizador existe
    const userExists = await User.findById(userId);
    if (!userExists) {
      return res.status(404).json({ error: 'Utilizador não encontrado' });
    }

    const newAddress = new Address({
      user: userId,
      country,
      city,
      address,
      postal
    });

    await newAddress.save();
    return res.status(201).json(newAddress);
  } catch (error) {
    console.error('Erro ao criar morada:', error);
    return res.status(500).json({ error: 'Erro ao criar morada' });
  }
};

// Listar todas as moradas
exports.getAllAddresses = async (req, res) => {
  try {
    const addresses = await Address.find().populate('user');
    return res.json(addresses);
  } catch (error) {
    console.error('Erro ao buscar moradas:', error);
    return res.status(500).json({ error: 'Erro ao buscar moradas' });
  }
};

// Obter morada por ID
exports.getAddressById = async (req, res) => {
  try {
    const { id } = req.params;
    const address = await Address.findById(id).populate('user');
    if (!address) {
      return res.status(404).json({ error: 'Morada não encontrada' });
    }
    return res.json(address);
  } catch (error) {
    console.error('Erro ao buscar morada:', error);
    return res.status(500).json({ error: 'Erro ao buscar morada' });
  }
};

// Atualizar morada
exports.updateAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const { country, city, address, postal } = req.body;

    const updatedAddress = await Address.findByIdAndUpdate(
      id,
      { country, city, address, postal },
      { new: true }
    );

    if (!updatedAddress) {
      return res.status(404).json({ error: 'Morada não encontrada' });
    }

    return res.json(updatedAddress);
  } catch (error) {
    console.error('Erro ao atualizar morada:', error);
    return res.status(500).json({ error: 'Erro ao atualizar morada' });
  }
};

// Remover morada
exports.deleteAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedAddress = await Address.findByIdAndDelete(id);
    if (!deletedAddress) {
      return res.status(404).json({ error: 'Morada não encontrada' });
    }
    return res.json({ message: 'Morada removida com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar morada:', error);
    return res.status(500).json({ error: 'Erro ao deletar morada' });
  }
};

// Listar moradas de um utilizador
exports.getAddressesByUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const addresses = await Address.find({ user: userId });
    return res.json(addresses);
  } catch (error) {
    console.error('Erro ao buscar moradas do utilizador:', error);
    return res.status(500).json({ error: 'Erro ao buscar moradas do utilizador' });
  }
};

