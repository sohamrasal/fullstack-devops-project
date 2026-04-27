CREATE DATABASE ecommerce_db;
USE ecommerce_db;
CREATE TABLE products (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255),
  price DECIMAL(10,2),
  quantity INT
);
