const express = require('express');
const router = express.Router();

const userController = require('../controllers/userController');
const addressController = require('../controllers/addressController');
const wineController = require('../controllers/wineController');
const favoriteController = require('../controllers/favoriteController');
const historyController = require('../controllers/historyController');

const { verifyToken } = require('../middleware/authMiddleware'); 

router.use(verifyToken);

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

// Rotas para Vinhos
router.get('/wines', wineController.getAllWines);
router.get('/wines/:id', wineController.getWineById);
router.post('/wines', wineController.createWine);
router.put('/wines/:id', wineController.updateWine);
router.delete('/wines/:id', wineController.deleteWine);

// Rotas para Favoritos
router.get('/favorites', favoriteController.getAllFavorites);
router.get('/favorites/:id', favoriteController.getFavoriteById);
router.post('/favorites', favoriteController.createFavorite);
router.put('/favorites/:id', favoriteController.updateFavorite);
router.delete('/favorites/:id', favoriteController.deleteFavorite);

// Rotas para Histórico
router.get('/history', historyController.getAllHistories);
router.get('/history/:id', historyController.getHistoryById);
router.post('/history', historyController.createHistory);
router.put('/history/:id', historyController.updateHistory);
router.delete('/history/:id', historyController.deleteHistory);

module.exports = router;
