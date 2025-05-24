const express = require('express');
const router = express.Router();

const userController = require('../controllers/userController');
const addressController = require('../controllers/addressController');
const wineController = require('../controllers/wineController');
const favoriteController = require('../controllers/favoriteController');
const historyController = require('../controllers/historyController');
const ratingController = require('../controllers/ratingController')
const recommendController = require('../controllers/recommendController');
const authController = require('../controllers/authController');


// Autenticação com Firebase
router.post('/auth/firebase', authController.loginWithFirebase);
router.post('/auth/social-login', userController.socialLogin);


/*const { verifyToken } = require('../middleware/authMiddleware'); 

router.use(verifyToken);*/

// Rotas para Users
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
//pesquisa e filtros em vinhos
router.get('/wines/search/text', wineController.searchWineByText);
router.get('/wines/types', wineController.getWineTypes);
router.get('/wines/wineries', wineController.getWineries);
// Rotas para Vinhos...
router.get('/wines', wineController.getAllWines);
router.post('/wines', wineController.createWine);
router.get('/wines/:id', wineController.getWineById);
router.put('/wines/:id', wineController.updateWine);
router.delete('/wines/:id', wineController.deleteWine);

// Rotas para Favoritos
router.get('/favorites', favoriteController.getAllFavorites);
router.get('/favorites/:id', favoriteController.getFavoriteById);
router.post('/favorites', favoriteController.createFavorite);
router.put('/favorites/:id', favoriteController.updateFavorite);
router.delete('/favorites/:id', favoriteController.deleteFavorite);

// Rotas para Histórico
router.post('/history', historyController.createOrUpdateHistory); // adiciona ou atualiza
router.get('/history/:userId', historyController.getUserHistory); // obter os 10 últimos
router.put('/history/:id', historyController.updateHistory);      // atualizar manualmente
router.delete('/history/:id', historyController.deleteHistory);   // remover

// Ratings
router.get('/ratings', ratingController.getAllRatings);
router.get('/ratings/:id', ratingController.getRatingById);
router.post('/ratings', ratingController.createRating);
router.delete('/ratings/:id', ratingController.deleteRating);

// Recomendações
router.get('/recommend/:userId', recommendController.getRecommendations);

module.exports = router;
