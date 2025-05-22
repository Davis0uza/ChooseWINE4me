const User = require('../models/User');
const bcrypt = require('bcrypt');

// Listar todos os users
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find();
    return res.json(users);
  } catch (error) {
    return res.status(500).json({ error: 'Erro ao buscar users' });
  }
};

// Obter user por _id
exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ error: 'User não encontrado' });
    }
    return res.json(user);
  } catch (error) {
    return res.status(500).json({ error: 'Erro ao buscar user' });
  }
};

// Criar novo user
exports.createUser = async (req, res) => {
  try {
    const { email, name, password } = req.body;

    if (!email.includes('@') || !email.includes('.')) {
      return res.status(400).json({ error: 'Email inválido. Deve conter "@" e "."' });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'Email já registrado' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = new User({
      email,
      name,
      password: hashedPassword
    });

    await newUser.save();
    return res.status(201).json(newUser);
  } catch (error) {
    console.error('Erro ao criar user:', error);
    return res.status(500).json({ error: 'Erro ao criar user' });
  }
};

// Atualizar nome do user
exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { name } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'O campo "name" é obrigatório para atualização.' });
    }

    const updatedUser = await User.findByIdAndUpdate(id, { name }, { new: true });
    if (!updatedUser) {
      return res.status(404).json({ error: 'User não encontrado.' });
    }

    return res.json(updatedUser);
  } catch (error) {
    console.error('Erro ao atualizar user:', error);
    return res.status(500).json({ error: 'Erro ao atualizar user' });
  }
};

// Deletar user
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedUser = await User.findByIdAndDelete(id);
    if (!deletedUser) {
      return res.status(404).json({ error: 'User não encontrado' });
    }
    return res.json({ message: 'User deletado com sucesso' });
  } catch (error) {
    return res.status(500).json({ error: 'Erro ao deletar user' });
  }
};
