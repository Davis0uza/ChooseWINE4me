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
// Registo e Login Email
router.post('/users/register', userController.createUser)
router.post('/auth/email',    authController.loginWithEmail); 
//Pedidos autorizados pela proxy
router.get('/images/proxy', authController.proxyImage);


// Recomendações
router.get('/recommend/:userId', recommendController.getRecommendations);

//Middleware
const { verifyToken } = require('../middleware/authMiddleware'); 
router.use(verifyToken); //daqui para baixo todas as rotas necessitam de token

// Rotas para Users
router.get('/users', userController.getAllUsers);
router.get('/users/:id', userController.getUserById);

router.put('/users/:id', userController.updateUser);
router.delete('/users/:id', userController.deleteUser);

// Rotas para Addresses
router.get('/addresses', addressController.getAllAddresses);
router.get('/addresses/user/:userId', addressController.getAddressesByUser);
router.get('/addresses/:id', addressController.getAddressById);
router.post('/addresses', addressController.createAddress);
router.put('/addresses/:id', addressController.updateAddress);
router.delete('/addresses/:id', addressController.deleteAddress);

// Rotas para Vinhos
//pesquisa e filtros em vinhos
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
router.get('/history/:userId', historyController.getUserHistory);
router.post('/history', historyController.createOrUpdateHistory);  
router.put('/history/:id', historyController.updateHistory);      
router.delete('/history/:id', historyController.deleteHistory); 

// Ratings
router.get('/ratings', ratingController.getAllRatings);
router.get('/ratings/:id', ratingController.getRatingById);
router.post('/ratings', ratingController.createRating);
router.delete('/ratings/:id', ratingController.deleteRating);



module.exports = router;
