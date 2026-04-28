-- ============================================
-- DROP tables (in ordine inversa dependentelor)
-- ============================================
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ============================================
-- CUSTOMERS
-- ============================================
CREATE TABLE customers (
    id           INT PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(100) NOT NULL UNIQUE,
    country      VARCHAR(50),
    city         VARCHAR(50),
    created_at   DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE INDEX idx_customers_country ON customers(country);
CREATE INDEX idx_customers_created_at ON customers(created_at);

-- ============================================
-- PRODUCTS
-- ============================================
CREATE TABLE products (
    id           INT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    category     VARCHAR(50)  NOT NULL,
    price        DECIMAL(8,2) NOT NULL CHECK (price >= 0),
    stock        INT          NOT NULL DEFAULT 0 CHECK (stock >= 0),
    created_at   DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_stock ON products(stock);

-- ============================================
-- ORDERS
-- ============================================
CREATE TABLE orders (
    id             INT PRIMARY KEY,
    customer_id    INT           NOT NULL,
    status         VARCHAR(20)   NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending', 'shipped', 'delivered', 'cancelled', 'returned')),
    total_amount   DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    order_date     DATE          NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT
);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- ============================================
-- ORDER_ITEMS
-- ============================================
CREATE TABLE order_items (
    id           INT PRIMARY KEY,
    order_id     INT          NOT NULL,
    product_id   INT          NOT NULL,
    quantity     INT          NOT NULL CHECK (quantity > 0),
    unit_price   DECIMAL(8,2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);