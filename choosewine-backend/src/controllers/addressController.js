const Address = require('../models/Address');

exports.createAddress = async (req, res) => {
  try {
    const { id_user, country, city, address, postal } = req.body;
    
    // Busca o último endereço cadastrado e define o novo id_address como (último + 1)
    const lastAddress = await Address.findOne({}).sort({ id_address: -1 });
    const newIdAddress = lastAddress && lastAddress.id_address ? lastAddress.id_address + 1 : 1;
    
    const newAddress = new Address({
      id_address: newIdAddress,
      id_user,
      country,
      city,
      address,
      postal,
    });
    
    await newAddress.save();
    
    return res.status(201).json(newAddress);
  } catch (error) {
    console.error('Erro ao criar address:', error);
    return res.status(500).json({ error: 'Erro ao criar address' });
  }
};

exports.getAllAddresses = async (req, res) => {
  try {
    const addresses = await Address.find();
    return res.json(addresses);
  } catch (error) {
    console.error('Erro ao buscar addresses:', error);
    return res.status(500).json({ error: 'Erro ao buscar addresses' });
  }
};

exports.getAddressById = async (req, res) => {
  try {
    const { id } = req.params;
    const address = await Address.findOne({ id_address: id });
    if (!address) {
      return res.status(404).json({ error: 'Address não encontrado' });
    }
    return res.json(address);
  } catch (error) {
    console.error('Erro ao buscar address:', error);
    return res.status(500).json({ error: 'Erro ao buscar address' });
  }
};

exports.updateAddress = async (req, res) => {
  try {
    const { id } = req.params;
    // Permite atualizar somente os campos de endereço, sem interferir em id_address e id_user
    const { country, city, address, postal } = req.body;
    const updatedAddress = await Address.findOneAndUpdate(
      { id_address: id },
      { country, city, address, postal },
      { new: true }
    );
    if (!updatedAddress) {
      return res.status(404).json({ error: 'Address não encontrado' });
    }
    return res.json(updatedAddress);
  } catch (error) {
    console.error('Erro ao atualizar address:', error);
    return res.status(500).json({ error: 'Erro ao atualizar address' });
  }
};

exports.deleteAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedAddress = await Address.findOneAndDelete({ id_address: id });
    if (!deletedAddress) {
      return res.status(404).json({ error: 'Address não encontrado' });
    }
    return res.json({ message: 'Address deletado com sucesso' });
  } catch (error) {
    console.error('Erro ao deletar address:', error);
    return res.status(500).json({ error: 'Erro ao deletar address' });
  }
};
