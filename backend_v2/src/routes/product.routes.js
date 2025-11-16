const express = require('express');
const router = express.Router();
const ProductController = require('../controllers/product.controller');
const { 
  validateProduct, 
  validateId, 
  sanitizeInput, 
  validateBody 
} = require('../middlewares/validator');

router.get('/', ProductController.getProducts);

router.get('/search', ProductController.searchProducts);

router.post(
  '/',
  validateBody,
  sanitizeInput,
  validateProduct,
  ProductController.createProduct
);

router.put(
  '/:id', 
  validateBody,
  sanitizeInput,
  validateProduct,
  ProductController.updateProduct
);

router.delete(
  '/:id', 
  ProductController.deleteProduct
);

module.exports = router;