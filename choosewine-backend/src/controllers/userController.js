const User = require('../models/User');
const bcrypt = require('bcrypt');

exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find();
    return res.json(users);
  } catch (error) {
    return res.status(500).json({ error: 'Erro ao buscar users' });
  }
};

exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findOne({ id_user: id });
    if (!user) {
      return res.status(404).json({ error: 'user não encontrado' });
    }
    return res.json(user);
  } catch (error) {
    return res.status(500).json({ error: 'Erro ao buscar user' });
  }
};

// Criar um novo user
exports.createUser = async (req, res) => {
  try {
    let { email, name, password } = req.body;
    
    // Validação simples do email: deve conter "@" e "."
    if (!email.includes('@') || !email.includes('.')) {
      return res.status(400).json({ error: 'Email inválido. Deve conter "@" e "."' });
    }
    
    // Verificar se o email já está registrado
    const existingUser = await User.findOne({ email: email });
    if (existingUser) {
      return res.status(400).json({ error: 'Email já registrado' });
    }
    
    // Criptografar a senha
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    // Buscar o último id_user para definir o novo de forma sequencial
    const lastUser = await User.findOne({}).sort({ id_user: -1 });
    const newIdUser = lastUser && lastUser.id_user ? lastUser.id_user + 1 : 1;
    
    // Criar novo usuário com os dados validados e a senha criptografada
    const newUser = new User({
      id_user: newIdUser,
      email,
      name,
      password: hashedPassword,
    });
    
    await newUser.save();
    
    return res.status(201).json(newUser);
  } catch (error) {
    console.error('Erro ao criar user:', error);
    return res.status(500).json({ error: 'Erro ao criar user' });
  }
};


exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { name } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'O campo "name" é obrigatório para atualização.' });
    }
    
    // Atualiza somente o campo "name"
    const updatedUser = await User.findOneAndUpdate(
      { id_user: id },
      { name },
      { new: true }
    );
    
    if (!updatedUser) {
      return res.status(404).json({ error: 'User não encontrado.' });
    }
    
    return res.json(updatedUser);
  } catch (error) {
    console.error('Erro ao atualizar user:', error);
    return res.status(500).json({ error: 'Erro ao atualizar user' });
  }
};

exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedUser = await User.findOneAndDelete({ id_user: id });
    if (!deletedUser) {
      return res.status(404).json({ error: 'user não encontrado' });
    }
    return res.json({ message: 'user deletado com sucesso' });
  } catch (error) {
    return res.status(500).json({ error: 'Erro ao deletar user' });
  }
};
