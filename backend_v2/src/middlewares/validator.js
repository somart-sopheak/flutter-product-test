const { errorResponse } = require('../utils/response');

const validateProduct = (req, res, next) => {
  const { name, price, stock } = req.body;
  const errors = [];

  if (!name || typeof name !== 'string' || name.trim() === '') {
    errors.push('Product name is required and cannot be empty');
  } else if (name.trim().length > 100) {
    errors.push('Product name cannot exceed 100 characters');
  }

  if (price === undefined || price === null || price === '') {
    errors.push('Price is required');
  } else {
    const priceValue = parseFloat(price);
    if (isNaN(priceValue)) {
      errors.push('Price must be a valid number');
    } else if (priceValue < 0) {
      errors.push('Price must be a positive number');
    } else if (priceValue > 99999999.99) {
      errors.push('Price cannot exceed 99999999.99');
    }
  }

  if (stock === undefined || stock === null || stock === '') {
    errors.push('Stock is required');
  } else {
    const stockValue = parseInt(stock);
    if (isNaN(stockValue) || !Number.isInteger(Number(stock))) {
      errors.push('Stock must be a valid integer');
    } else if (stockValue < 0) {
      errors.push('Stock must be a positive integer');
    } else if (stockValue > 2147483647) {
      errors.push('Stock value is too large');
    }
  }

  if (errors.length > 0) {
    return errorResponse(res, 'Validation failed', 400, errors);
  }
  next();
};

const validateId = (req, res, next) => {
  const { id } = req.query;

  if (!id) {
    return errorResponse(res, 'ID parameter is required', 400);
  }

  const idValue = parseInt(id);
  if (isNaN(idValue) || idValue <= 0) {
    return errorResponse(res, 'ID must be a positive integer', 400);
  }

  next();
};

const sanitizeInput = (req, res, next) => {
  if (req.body.name) {
    req.body.name = req.body.name
      .replace(/[<>]/g, '') 
      .trim();
  }
  next();
};

const validateBody = (req, res, next) => {
  if (!req.body || Object.keys(req.body).length === 0) {
    return errorResponse(res, 'Request body is required', 400);
  }
  next();
};

module.exports = {
  validateProduct,
  validateId,
  sanitizeInput,
  validateBody
};