const express = require('express');
const router = express.Router();

const userController = require('../controllers/userController');
const addressController = require('../controllers/addressControllers');

// Rotas para Usuários
router.get('/users', userController.getAllUsers);
router.get('/users/:id', userController.getUserById);
router.post('/users', userController.createUser);
router.put('/users/:id', userController.updateUser);
router.delete('/users/:id', userController.deleteUser);

// Rotas para Addresses
router.get('/addresses', addressController.getAllAddresses);
router.get('/addresses/:id', addressController.getAddressById);
router.post('/addresses', addressController.createAddress);
router.put('/addresses/:id', addressController.updateAddress);
router.delete('/addresses/:id', addressController.deleteAddress);

module.exports = router;
