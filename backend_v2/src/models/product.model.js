const { sql, getPool } = require('../config/database');

class ProductModel {
  
  static async getPaginatedProducts({
    page = 1,
    limit = 5,
    searchTerm = '',
    sortBy = 'PRODUCTID',
    sortOrder = 'DESC',
    priceMin,
    priceMax,
    stockMin,
    stockMax,
    dateFrom,
    dateTo
  }) {
    try {
      const pool = await getPool();
      const request = pool.request();
      let query = 'FROM PRODUCTS WHERE 1=1';

      if (searchTerm) {
        query += ' AND PRODUCTNAME LIKE @searchTerm';
        request.input('searchTerm', sql.NVarChar, `%${searchTerm}%`);
      }
      if (priceMin != null) {
        query += ' AND PRICE >= @priceMin';
        request.input('priceMin', sql.Decimal(10, 2), priceMin);
      }
      if (priceMax != null) {
        query += ' AND PRICE <= @priceMax';
        request.input('priceMax', sql.Decimal(10, 2), priceMax);
      }
      if (stockMin != null) {
        query += ' AND STOCK >= @stockMin';
        request.input('stockMin', sql.Int, stockMin);
      }
      if (stockMax != null) {
        query += ' AND STOCK <= @stockMax';
        request.input('stockMax', sql.Int, stockMax);
      }
      if (dateFrom) {
        query += ' AND CREATED_AT >= @dateFrom';
        request.input('dateFrom', sql.DateTime, new Date(dateFrom));
      }
      if (dateTo) {
        query += ' AND CREATED_AT <= @dateTo';
        request.input('dateTo', sql.DateTime, new Date(dateTo));
      }

      const validSortColumns = ['PRODUCTID', 'PRODUCTNAME', 'PRICE', 'STOCK', 'CREATED_AT'];
      if (!validSortColumns.includes(sortBy.toUpperCase())) {
        sortBy = 'PRODUCTID';
      }
      
      if (sortOrder.toUpperCase() !== 'ASC' && sortOrder.toUpperCase() !== 'DESC') {
        sortOrder = 'DESC';
      }

      const offset = (page - 1) * limit;
      request.input('offset', sql.Int, offset);
      request.input('limit', sql.Int, limit);

      const paginatedQuery = `
        SELECT * ${query}
        ORDER BY ${sortBy} ${sortOrder}
        OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY
      `;

      const result = await request.query(paginatedQuery);
      return result.recordset;
    } catch (error) {
      throw new Error(`Error fetching paginated products: ${error.message}`);
    }
  }

  static async getTotalProductCount({
    searchTerm = '',
    priceMin,
    priceMax,
    stockMin,
    stockMax,
    dateFrom,
    dateTo
  }) {
    try {
      const pool = await getPool();
      const request = pool.request();
      let query = 'SELECT COUNT(*) as total FROM PRODUCTS WHERE 1=1';

      if (searchTerm) {
        query += ' AND PRODUCTNAME LIKE @searchTerm';
        request.input('searchTerm', sql.NVarChar, `%${searchTerm}%`);
      }
      if (priceMin != null) {
        query += ' AND PRICE >= @priceMin';
        request.input('priceMin', sql.Decimal(10, 2), priceMin);
      }
      if (priceMax != null) {
        query += ' AND PRICE <= @priceMax';
        request.input('priceMax', sql.Decimal(10, 2), priceMax);
      }
      if (stockMin != null) {
        query += ' AND STOCK >= @stockMin';
        request.input('stockMin', sql.Int, stockMin);
      }
      if (stockMax != null) {
        query += ' AND STOCK <= @stockMax';
        request.input('stockMax', sql.Int, stockMax);
      }
      if (dateFrom) {
        query += ' AND CREATED_AT >= @dateFrom';
        request.input('dateFrom', sql.DateTime, new Date(dateFrom));
      }
      if (dateTo) {
        query += ' AND CREATED_AT <= @dateTo';
        request.input('dateTo', sql.DateTime, new Date(dateTo));
      }

      const result = await request.query(query);
      return result.recordset[0].total;
    } catch (error) {
      throw new Error(`Error getting product count: ${error.message}`);
    }
  }

  static async getAllProducts() {
    try {
      const pool = await getPool();
      const result = await pool.request()
        .query('SELECT * FROM PRODUCTS ORDER BY PRODUCTID DESC');
      return result.recordset;
    } catch (error) {
      throw new Error(`Error fetching products: ${error.message}`);
    }
  }

  static async getProductById(id) {
    try {
      const pool = await getPool();
      const result = await pool.request()
        .input('id', sql.Int, id)
        .query('SELECT * FROM PRODUCTS WHERE PRODUCTID = @id');
      
      return result.recordset.length > 0 ? result.recordset[0] : null;
    } catch (error) {
      throw new Error(`Error fetching product: ${error.message}`);
    }
  }

  static async createProduct({ name, price, stock }) {
    try {
      const pool = await getPool();
      const result = await pool.request()
        .input('name', sql.NVarChar(100), name)
        .input('price', sql.Decimal(10, 2), price)
        .input('stock', sql.Int, stock)
        .query(`
          INSERT INTO PRODUCTS (PRODUCTNAME, PRICE, STOCK)
          OUTPUT INSERTED.*
          VALUES (@name, @price, @stock)
        `);
      
      return result.recordset[0];
    } catch (error) {
      throw new Error(`Error creating product: ${error.message}`);
    }
  }

  static async updateProduct(id, { name, price, stock }) {
    try {
      const pool = await getPool();
      const result = await pool.request()
        .input('id', sql.Int, id)
        .input('name', sql.NVarChar(100), name)
        .input('price', sql.Decimal(10, 2), price)
        .input('stock', sql.Int, stock)
        .query(`
          UPDATE PRODUCTS
          SET PRODUCTNAME = @name, PRICE = @price, STOCK = @stock
          OUTPUT INSERTED.*
          WHERE PRODUCTID = @id
        `);
      
      return result.recordset.length > 0 ? result.recordset[0] : null;
    } catch (error) {
      throw new Error(`Error updating product: ${error.message}`);
    }
  }

  static async deleteProduct(id) {
    try {
      const pool = await getPool();
      
      // First get the product
      const product = await this.getProductById(id);
      
      if (!product) {
        return null;
      }
      
      await pool.request()
        .input('id', sql.Int, id)
        .query('DELETE FROM PRODUCTS WHERE PRODUCTID = @id');
      
      return product;
    } catch (error) {
      throw new Error(`Error deleting product: ${error.message}`);
    }
  }

  static async productExists(id) {
    try {
      const product = await this.getProductById(id);
      return product !== null;
    } catch (error) {
      throw new Error(`Error checking product existence: ${error.message}`);
    }
  }

  static async searchProducts(searchTerm) {
    try {
      const pool = await getPool();
      const result = await pool.request()
        .input('searchTerm', sql.NVarChar(100), `%${searchTerm}%`)
        .query('SELECT * FROM PRODUCTS WHERE PRODUCTNAME LIKE @searchTerm ORDER BY PRODUCTID DESC');
      
      return result.recordset;
    } catch (error) {
      throw new Error(`Error searching products: ${error.message}`);
    }
  }
}

module.exports = ProductModel;