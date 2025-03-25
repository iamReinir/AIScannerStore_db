BEGIN;
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') 
    LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;CREATE TABLE store (
    store_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_name VARCHAR(255) UNIQUE NOT NULL,
    store_location TEXT,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);
CREATE TABLE pos_device (
    device_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),    
	store_id UUID,
    CONSTRAINT fk_pos_of_store FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);CREATE TABLE staff (
    staff_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    staff_name VARCHAR(255) NOT NULL,
    staff_phone VARCHAR(20),
    staff_email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    "role" varchar(50),
    store_id UUID,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_manager_of_store FOREIGN KEY (store_id)
        REFERENCES store(store_id) ON DELETE SET NULL
);

-- Admin
INSERT INTO staff (
    staff_id,
    staff_name,    
    staff_email,
    password_hash,
    "role",
	code
) VALUES (
    '03485000-6353-4e33-b878-32328d89ba51',
    'admin',
    'admin',
    'AQAAAAIAAYagAAAAEM5qkMuCZU6mxSl3jhkZ8csttfpfjuTt8ehoAbSYVQNjRxhJwAATFQjkzeUPA/B7Wg==',
    'ADMIN',
	'ADMIN');CREATE TABLE category (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name VARCHAR(255) NOT NULL,
    category_description TEXT,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);
CREATE TABLE product (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_name VARCHAR(255) UNIQUE NOT NULL,
    product_description TEXT,
    product_image_url VARCHAR(255),
	barcode VARCHAR(255),
    category_id UUID,
	base_price DECIMAL(20,2),
    CONSTRAINT fk_product_of_category FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE   
);CREATE TABLE drink_mapping (
    mapping_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    drink_product_id UUID NOT NULL,
    map_code VARCHAR(50) NOT NULL,
    CONSTRAINT fk_drink_mapping FOREIGN KEY (drink_product_id)
    REFERENCES product(product_id),
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE   
);
CREATE TABLE food_mapping (
    mapping_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    food_product_id UUID NOT NULL,
    map_code VARCHAR(50) NOT NULL,
    CONSTRAINT fk_food_mapping FOREIGN KEY (food_product_id)
    REFERENCES product(product_id),
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);
CREATE TABLE customer (
    customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20),
    customer_email VARCHAR(255) UNIQUE NOT NULL,
    image_url VARCHAR(255),
    password_hash VARCHAR(255) NOT NULL,    
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE    
);CREATE TABLE deposit (
    deposit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    amount NUMERIC(20,2),
	status VARCHAR(50),
    CONSTRAINT fk_deposit_of_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE    
);

CREATE TABLE card (
    card_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID,
	card_data_hash VARCHAR(255),
    expiration_date TIMESTAMP,
	"type" VARCHAR(50),
	CONSTRAINT fk_card_of_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);CREATE TABLE "order" (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    card_id UUID,
    device_id UUID,
    staff_id UUID,
    old_order_id UUID,
    total NUMERIC(20,2) NOT NULL,
    status varchar(50),
    image1 varchar(255),
    image2 varchar(255),
    image3 varchar(255),
	is_flagged BOOL DEFAULT FALSE,
	is_correction BOOL DEFAULT FALSE,
    CONSTRAINT fk_manual_order FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    CONSTRAINT fk_order_of_card FOREIGN KEY (card_id) REFERENCES card(card_id) ON DELETE SET NULL,
    CONSTRAINT fk_order_from_device FOREIGN KEY (device_id) REFERENCES pos_device(device_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);CREATE TABLE product_in_store (
    product_in_store_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID NOT NULL,
    product_id UUID NOT NULL,
    price NUMERIC(20,2),
    stock int,
    CONSTRAINT fk_inventory_of_store FOREIGN KEY (store_id)
    REFERENCES store(store_id),
    CONSTRAINT fk_product_in_inventory FOREIGN KEY (product_id)
    REFERENCES product(product_id),
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE   
);
CREATE TABLE inventory_note (
    inventory_note_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    store_id UUID,
    "type" varchar(50),
    image_url varchar(255),
    "description" text,
    CONSTRAINT fk_inventory_log FOREIGN KEY (store_id) 
    REFERENCES store(store_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);
CREATE TABLE inventory_note_item (
    inventory_note_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_note_id UUID NOT NULL,
    product_in_store_id UUID,
    stock_change int NOT NULL,
	before_change int,
    CONSTRAINT fk_inventory_note_item FOREIGN KEY (inventory_note_id) 
    REFERENCES inventory_note(inventory_note_id) ON DELETE CASCADE,
    CONSTRAINT fk_inv_log FOREIGN KEY (product_in_store_id) 
    REFERENCES product_in_store(product_in_store_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE   
);CREATE TABLE wallet (
    wallet_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    balance NUMERIC(20,2),
	priority INT NOT NULL DEFAULT 0,
	wallet_type VARCHAR(50) DEFAULT 'MAIN',
    CONSTRAINT fk_wallet_of_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE    
);CREATE TABLE wallet_transaction (
    wallet_transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),    
	wallet_id UUID NOT NULL,
    amount decimal(20,2),
	"type" varchar(50),
	description TEXT,
	order_id UUID,
	deposit_id UUID,
    CONSTRAINT fk_transaction_of_wallet FOREIGN KEY (wallet_id) REFERENCES wallet(wallet_id) ON DELETE CASCADE,
	CONSTRAINT fk_transaction_of_order FOREIGN KEY (order_id) REFERENCES "order"(order_id) ON DELETE SET NULL,
	CONSTRAINT fk_transaction_of_deposit FOREIGN KEY (deposit_id) REFERENCES deposit(deposit_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);CREATE TABLE vnp_transaction (
    vnp_transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),    
    deposit_id UUID,
	ref_payment_id varchar(50),
	is_success bool,
	description TEXT,
	"timestamp" TIMESTAMP,
	ref_vnpay_transaction_id varchar(50),
	payment_method varchar(50),
	vnp_payment_response_code varchar(50),
	bank_transaction_status_code varchar(50),
	bank_code varchar(50),
	bank_transaction_id varchar(50),
    CONSTRAINT fk_vnp_transaction_of_deposit FOREIGN KEY (deposit_id) REFERENCES deposit(deposit_id)
	ON DELETE SET NULL,    
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);CREATE TABLE order_item (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    product_id UUID,
    product_name VARCHAR(255),
    "count" INTEGER NOT NULL,
    unit_price DECIMAL(20,2) NOT NULL,
    CONSTRAINT fk_item_of_order FOREIGN KEY (order_id) REFERENCES "order"(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_product_of_order_item FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE    
);COMMIT;
INSERT INTO category (category_id, category_name, category_description) VALUES
('f1a2b3c4-5678-90ab-cdef-123456789001', 'Bread & Pastries', 'A selection of freshly baked bread, croissants, and sandwiches.'),
('f1a2b3c4-5678-90ab-cdef-123456789002', 'Cakes & Desserts', 'Delicious cakes, muffins, and pastries for any occasion.'),
('f1a2b3c4-5678-90ab-cdef-123456789003', 'Soft Drinks & Energy Drinks', 'Carbonated beverages and energy drinks for a refreshing boost.'),
('f1a2b3c4-5678-90ab-cdef-123456789004', 'Alcoholic Drinks', 'A variety of beers and other alcoholic beverages.'),
('f1a2b3c4-5678-90ab-cdef-123456789005', 'Bottled Water', 'Clean and refreshing bottled water for hydration.'),
('f1a2b3c4-5678-90ab-cdef-123456789006', 'Packaging & Containers', 'Various drink packaging such as bottles and cans.');


INSERT INTO product (
    product_id, product_name, product_description, category_id
) VALUES
('a1b2c3d4-5678-90ab-cdef-123456789001', 'Butter Sugar Bread', 'A soft and sweet bread topped with butter and sugar.', 'f1a2b3c4-5678-90ab-cdef-123456789001'),
('a1b2c3d4-5678-90ab-cdef-123456789002', 'Chicken Floss Bread', 'A fluffy bread topped with savory chicken floss.', 'f1a2b3c4-5678-90ab-cdef-123456789001'),
('a1b2c3d4-5678-90ab-cdef-123456789003', 'Chicken Floss Sandwich', 'A sandwich filled with rich and flavorful chicken floss.', 'f1a2b3c4-5678-90ab-cdef-123456789001'),
('a1b2c3d4-5678-90ab-cdef-123456789004', 'Cream Puff', 'A light and airy pastry filled with creamy custard.', 'f1a2b3c4-5678-90ab-cdef-123456789002'),
('a1b2c3d4-5678-90ab-cdef-123456789005', 'Croissant', 'A flaky and buttery French pastry.', 'f1a2b3c4-5678-90ab-cdef-123456789001'),
('a1b2c3d4-5678-90ab-cdef-123456789006', 'Donut', 'A soft and sweet deep-fried treat with various toppings.', 'f1a2b3c4-5678-90ab-cdef-123456789002'),
('a1b2c3d4-5678-90ab-cdef-123456789007', 'Muffin', 'A moist and fluffy baked treat, perfect for any time of the day.', 'f1a2b3c4-5678-90ab-cdef-123456789002'),
('a1b2c3d4-5678-90ab-cdef-123456789008', 'Salted Egg Sponge Cake', 'A soft sponge cake infused with rich salted egg flavor.', 'f1a2b3c4-5678-90ab-cdef-123456789002'),
('a1b2c3d4-5678-90ab-cdef-123456789009', 'Sandwich', 'A classic combination of bread and filling for a satisfying meal.', 'f1a2b3c4-5678-90ab-cdef-123456789001'),
('a1b2c3d4-5678-90ab-cdef-123456789010', 'Sponge Cake', 'A light and airy cake with a delicate texture.', 'f1a2b3c4-5678-90ab-cdef-123456789002'),
('a1b2c3d4-5678-90ab-cdef-123456789011', 'Tiramisu', 'A classic Italian dessert with layers of coffee-soaked sponge and mascarpone.', 'f1a2b3c4-5678-90ab-cdef-123456789002'),
('a1b2c3d4-5678-90ab-cdef-123456789012', 'Beer Tiger', 'A popular beer brand with a refreshing taste.', 'f1a2b3c4-5678-90ab-cdef-123456789004'),
('a1b2c3d4-5678-90ab-cdef-123456789013', 'Boncha', 'A fizzy and refreshing flavored soft drink.', 'f1a2b3c4-5678-90ab-cdef-123456789003'),
('a1b2c3d4-5678-90ab-cdef-123456789014', 'Bottle', 'A standard drink bottle container.', 'f1a2b3c4-5678-90ab-cdef-123456789006'),
('a1b2c3d4-5678-90ab-cdef-123456789015', 'Can', 'A convenient canned drink packaging.', 'f1a2b3c4-5678-90ab-cdef-123456789006'),
('a1b2c3d4-5678-90ab-cdef-123456789016', 'CocaCola', 'The world-famous cola soft drink.', 'f1a2b3c4-5678-90ab-cdef-123456789003'),
('a1b2c3d4-5678-90ab-cdef-123456789017', 'CocaCola Light', 'A low-calorie version of the classic CocaCola.', 'f1a2b3c4-5678-90ab-cdef-123456789003'),
('a1b2c3d4-5678-90ab-cdef-123456789018', 'Green Tea', 'A refreshing bottled green tea beverage.', 'f1a2b3c4-5678-90ab-cdef-123456789003'),
('a1b2c3d4-5678-90ab-cdef-123456789019', 'Pepsi', 'A bold and refreshing cola beverage.', 'f1a2b3c4-5678-90ab-cdef-123456789003'),
('a1b2c3d4-5678-90ab-cdef-123456789020', 'Red Bull', 'A popular energy drink that gives you wings.', 'f1a2b3c4-5678-90ab-cdef-123456789003'),
('a1b2c3d4-5678-90ab-cdef-123456789021', 'Revive Lemon Salt', 'A hydrating sports drink with a lemon-salt flavor.', 'f1a2b3c4-5678-90ab-cdef-123456789003'),
('a1b2c3d4-5678-90ab-cdef-123456789022', 'Revive Regular', 'An electrolyte drink for hydration and energy.', 'f1a2b3c4-5678-90ab-cdef-123456789003'),
('a1b2c3d4-5678-90ab-cdef-123456789023', 'Strawberry Sting', 'A strawberry-flavored energy drink.', 'f1a2b3c4-5678-90ab-cdef-123456789003'),
('a1b2c3d4-5678-90ab-cdef-123456789024', 'Vinh Hao Water', 'Premium bottled mineral water for daily hydration.', 'f1a2b3c4-5678-90ab-cdef-123456789005');

-- Food Mappings
INSERT INTO food_mapping (food_product_id, map_code) VALUES
('a1b2c3d4-5678-90ab-cdef-123456789001', '0'),
('a1b2c3d4-5678-90ab-cdef-123456789002', '1'),
('a1b2c3d4-5678-90ab-cdef-123456789003', '2'),
('a1b2c3d4-5678-90ab-cdef-123456789004', '3'),
('a1b2c3d4-5678-90ab-cdef-123456789005', '4'),
('a1b2c3d4-5678-90ab-cdef-123456789006', '5'),
('a1b2c3d4-5678-90ab-cdef-123456789007', '6'),
('a1b2c3d4-5678-90ab-cdef-123456789008', '7'),
('a1b2c3d4-5678-90ab-cdef-123456789009', '8'),
('a1b2c3d4-5678-90ab-cdef-123456789010', '9'),
('a1b2c3d4-5678-90ab-cdef-123456789011', '10');

-- Drink Mappings
INSERT INTO drink_mapping (drink_product_id, map_code) VALUES
('a1b2c3d4-5678-90ab-cdef-123456789012', '0'),
('a1b2c3d4-5678-90ab-cdef-123456789013', '1'),
('a1b2c3d4-5678-90ab-cdef-123456789014', '2'),
('a1b2c3d4-5678-90ab-cdef-123456789015', '3'),
('a1b2c3d4-5678-90ab-cdef-123456789016', '4'),
('a1b2c3d4-5678-90ab-cdef-123456789017', '5'),
('a1b2c3d4-5678-90ab-cdef-123456789018', '6'),
('a1b2c3d4-5678-90ab-cdef-123456789019', '7'),
('a1b2c3d4-5678-90ab-cdef-123456789020', '8'),
('a1b2c3d4-5678-90ab-cdef-123456789021', '9'),
('a1b2c3d4-5678-90ab-cdef-123456789022', '10'),
('a1b2c3d4-5678-90ab-cdef-123456789023', '11'),
('a1b2c3d4-5678-90ab-cdef-123456789024', '12');

INSERT INTO store (
    store_id,
    store_name,
    store_location 
) 
VALUES
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'SuperMart Downtown', '123 Main Street, Downtown'),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'QuickShop Central', '456 Center Avenue, Central'),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'MegaStore North', '789 North Road, Uptown'),
    ('d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444', 'BudgetMart East', '321 East Lane, Eastside'),
    ('e5b3c2f1-2d75-4f3a-9a21-3b4a1c8f5555', 'ValueShop West', '654 West Street, Westend'),
    ('f6c4e1a7-1b63-41c2-bf82-2f1c7a5b6666', 'Neighborhood Market', '987 South Avenue, Southside'),
    ('a7d2b5c3-6f14-49c2-9f31-7a1c4b2f7777', 'FreshMart Hills', '159 Hills Road, Hilltop'),
    ('b8e1c3f7-4a62-48d2-bf41-1c7a2b8f8888', 'GreenLeaf Organic', '753 Garden Street, Greenfield'),
    ('c9f7a2d1-3b81-4e2a-bf24-4a1c5b7f9999', 'Urban Market', '246 City Center Blvd, Midtown'),
    ('d0a5e4c8-2b17-4f3a-bc52-3f1a7c2f0000', 'Family Grocery', '369 Maple Avenue, Riverside'),
    ('f47ac10b-58cc-4372-a567-0e02b2c3d479', 'Downtown Market', '123 Main Street, Downtown'),
    ('9c858901-8a57-4791-81fe-4c455b099bc9', 'Uptown Grocery', '456 Elm Street, Uptown'),
    ('3fa85f64-5717-4562-b3fc-2c963f66afa6', 'Central Plaza Store', '789 Oak Avenue, Central Plaza'),
    ('16fd2706-8baf-433b-82eb-8c7fada847da', 'Riverside Mart', '321 River Road, Riverside'),
    ('7c9e6679-7425-40de-944b-e07fc1f90ae7', 'Hilltop Supplies', '654 Pine Street, Hilltop');

INSERT INTO pos_device (device_id, store_id, code) VALUES
('3fa85f64-5717-4562-b3fc-2c963f66a001', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'TEST_DEV_1'),
('3fa85f64-5717-4562-b3fc-2c963f66a002', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'TEST_DEV_2'),
('3fa85f64-5717-4562-b3fc-2c963f66a003', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'TEST_DEV_3'),

('3fa85f64-5717-4562-b3fc-2c963f66a004', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'TEST_DEV_4'),
('3fa85f64-5717-4562-b3fc-2c963f66a005', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'TEST_DEV_5'),
('3fa85f64-5717-4562-b3fc-2c963f66a006', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'TEST_DEV_6'),

('3fa85f64-5717-4562-b3fc-2c963f66a007', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'TEST_DEV_7'),
('3fa85f64-5717-4562-b3fc-2c963f66a008', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'TEST_DEV_8'),
('3fa85f64-5717-4562-b3fc-2c963f66a009', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'TEST_DEV_9');
INSERT INTO staff (staff_id, staff_name, staff_phone, staff_email, "role", password_hash, store_id) 
    VALUES
    ('0a5c236e-ff54-449e-834c-99c113b3b582', 'Alice Johnson', '123-456-7890', 'alice.johnson@example.com', 'STORE_MANAGER','AQAAAAIAAYagAAAAEC8oYrDXu9vZRjDm5YFf6y1fJ/D3NqsFopVqgqg3J/c1EjNZVWyTL4jiBVhX2/P4bA==', 'f47ac10b-58cc-4372-a567-0e02b2c3d479'),
    ('6d4b69f1-bc1f-41d1-b105-e12e0b45d7f0', 'Bob Smith', '987-654-3210', 'bob.smith@example.com', 'STAFF','AQAAAAIAAYagAAAAEG32wBFgkmCLoGRWjnFvnT+oDaaEQM1TKzt2kvRyZPhI1sC4nipNOzMMDo2y+6fQYg==', '9c858901-8a57-4791-81fe-4c455b099bc9'),
    ('86e3635b-f1d4-4e98-b30b-095c7d32b42b', 'Clara Lee', NULL, 'clara.lee@example.com', 'STAFF','AQAAAAIAAYagAAAAEOOyXW7YyT1OapqCpnWtH3zuwSaprpYYnNNNRugFERty3kzvCG77dmzSc/sf5VjnCQ==', '3fa85f64-5717-4562-b3fc-2c963f66afa6'),
    ('4ce18af5-130c-44ed-ba84-38a4411fdf95', 'NghiaNT', NULL, 'nghiant@aistore.com', 'IT_HD', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'),
    ('d8d0e33a-a490-4fce-beee-fcad5eaef9a3', 'TrungNX', NULL, 'trungnx@aistore.com', 'IT_HD', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111')
    ;

INSERT INTO product_in_store (store_id, product_id, price, stock)
VALUES
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789001', 59900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789002', 61900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789003', 58900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789004', 49900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789005', 69900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789006', 39900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789007', 42900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789008', 51900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789009', 47900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789010', 45900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789011', 72900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789012', 89900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789013', 25900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789014', 34900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789015', 30900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789016', 31900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789017', 32900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789018', 28900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789019', 57900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789020', 79900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789021', 48900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789022', 45900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789023', 50900, 30),
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789024', 27900, 30);


INSERT INTO product_in_store (store_id, product_id, price, stock)
VALUES
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789001', 60900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789002', 62900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789003', 59900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789004', 50900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789005', 70900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789006', 38900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789007', 43900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789008', 52900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789009', 46900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789010', 46900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789011', 73900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789012', 90900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789013', 26900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789014', 33900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789015', 31900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789016', 32900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789017', 31900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789018', 29900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789019', 58900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789020', 80900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789021', 49900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789022', 46900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789023', 51900, 30),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789024', 28900, 30);

INSERT INTO product_in_store (store_id, product_id, price, stock)
VALUES
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789001', 57900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789002', 59900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789003', 57900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789004', 48900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789005', 68900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789006', 36900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789007', 41900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789008', 50900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789009', 45900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789010', 44900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789011', 71900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789012', 88900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789013', 25900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789014', 32900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789015', 30900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789016', 31900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789017', 30900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789018', 28900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789019', 56900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789020', 78900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789021', 47900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789022', 44900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789023', 49900, 30),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789024', 27900, 30);


INSERT INTO customer (customer_id, customer_name, customer_email, customer_phone, image_url, password_hash, code) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'Alice Johnson', 'alice@example.com', '123-456-7890', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'CUST74829301'),
('6f9619ff-8b86-d011-b42d-00c04fc964ff', 'Bob Smith', 'bob@example.com', '987-654-3210', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'CUST91827364'),
('1b4e28ba-2fa1-11d2-883f-0016d3cca427', 'Charlie Brown', 'charlie@example.com', '555-123-4567', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'CUST50392718'),
('110ec58a-a0f2-4ac4-8393-c866d813b8d1', 'Diana Prince', 'diana@example.com', '444-555-6666', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'CUST37482019'),
('7d793037-a124-486c-91f8-49a8b8b4f9da', 'Edward Nigma', 'edward@example.com', '222-333-4444', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'CUST83749202');

INSERT INTO customer (customer_id, customer_name, customer_phone, customer_email, image_url, password_hash, code) VALUES
('65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 'Lợi Nguyễn', '1234567', 'dongloi2504@gmail.com', '', 'AQAAAAIAAYagAAAAEO4oH0xNjb5agvpL1sPzytxzqq0Yz1UxApqBWKzxgDyDvLNW4N+8HHH7JSQWfNykTw==', 'CUST29574382');INSERT INTO card (card_id, customer_id, expiration_date, "type")
VALUES 
    ('a1b2c3d4-e5f6-4789-abcd-1234567890ab', '550e8400-e29b-41d4-a716-446655440000', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('b2c3d4e5-f6a7-4890-bcde-2345678901bc', '6f9619ff-8b86-d011-b42d-00c04fc964ff', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('c3d4e5f6-a7b8-4901-cdef-3456789012cd', '1b4e28ba-2fa1-11d2-883f-0016d3cca427', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('d4e5f6a7-b8c9-4012-def0-4567890123de', '110ec58a-a0f2-4ac4-8393-c866d813b8d1', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('e5f6a7b8-c9d0-4123-ef01-5678901234ef', '7d793037-a124-486c-91f8-49a8b8b4f9da', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('f6a7b8c9-d0e1-4234-f012-6789012345f0', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', '2026-01-01 00:00:00', 'VIRTUAL');
INSERT INTO public."order" (order_id,card_id,device_id,staff_id,total,status) VALUES
	 ('24962082-ea1a-4829-8a9d-bb35118649a1','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', NULL,1480100.00,'PAID'),
	 ('ff718dc5-340c-4323-9b95-4391260b16d8','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', NULL,1391200.00,'FINISHED'),
	 ('67c10684-7479-4e6b-bcb0-1c7ac52b7475','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', '0a5c236e-ff54-449e-834c-99c113b3b582',1215300.00,'EDITED'),
	 ('307506a4-87a9-418d-97a6-43829f58f90a', NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001', '0a5c236e-ff54-449e-834c-99c113b3b582', 1305300.00,'STAFF_CANCELLED'),
	 ('3b7605ff-d7c0-4a04-bb2b-0117889f87c6','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', NULL,961800.00,'CANCELLED'),
	 ('c49c3e2e-ceee-4732-9c5c-aea6fa7594b3', NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001', NULL, 1145500.00,'CREATED');

INSERT INTO public.order_item (order_item_id,order_id,product_id,product_name,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('5d6d5229-df17-4a1e-ac45-489e788ddaf9','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789016','CocaCola',3,31900.00,'2025-03-10 18:44:08.073133','2025-03-10 18:44:08.073134',false,false),
	 ('5d8e0714-3b4f-4a28-84eb-fdc3c75a8764','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789014','Bottle',1,34900.00,'2025-03-10 18:44:08.07276','2025-03-10 18:44:08.072761',false,false),
	 ('6bb723a2-bb7e-4a0f-bd8b-6378a94be572','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789005','Croissant',3,69900.00,'2025-03-10 18:44:08.073186','2025-03-10 18:44:08.073186',false,false),
	 ('8736726d-957d-4483-b02d-4efa524e32bf','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789013','Boncha',3,25900.00,'2025-03-10 18:44:08.072697','2025-03-10 18:44:08.072699',false,false),
	 ('8844a202-27aa-43eb-9633-ce886bd8169d','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789009','Sandwich',4,47900.00,'2025-03-10 18:44:08.073254','2025-03-10 18:44:08.073254',false,false),
	 ('8ae66e02-4b15-44e8-9ccc-181a1f701236','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789008','Salted Egg Sponge Cake',1,51900.00,'2025-03-10 18:44:08.073232','2025-03-10 18:44:08.073233',false,false),
	 ('8e7d151a-b664-4cd9-aebe-9b01711f4955','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789006','Donut',2,39900.00,'2025-03-10 18:44:08.073201','2025-03-10 18:44:08.073201',false,false),
	 ('9d665ce7-d5c8-4079-b1fe-7b15c8dc1d76','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789004','Cream Puff',2,49900.00,'2025-03-10 18:44:08.073168','2025-03-10 18:44:08.073169',false,false),
	 ('b278fccb-1161-46dc-9619-b4b0a39afc2e','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789015','Can',2,30900.00,'2025-03-10 18:44:08.072782','2025-03-10 18:44:08.072783',false,false),
	 ('eaf50af0-931b-4dca-a5b0-2ca7ee16f659','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789012','Beer Tiger',4,89900.00,'2025-03-10 18:44:08.054875','2025-03-10 18:44:08.054876',false,false),
	 ('fe9263ff-892d-47ba-969f-86878fe42f23','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789007','Muffin',3,42900.00,'2025-03-10 18:44:08.073217','2025-03-10 18:44:08.073217',false,false);
	 
INSERT INTO public.order_item (order_item_id,order_id,product_id,product_name,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('0e3e1b95-4b3a-4f68-957a-997204d2a712','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789006','Donut',2,39900.00,'2025-03-10 18:58:50.084282','2025-03-10 18:58:50.084282',false,false),
	 ('123df01e-20a7-438e-a8e4-eaaf3fd62f3e','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789005','Croissant',2,69900.00,'2025-03-10 18:58:50.084261','2025-03-10 18:58:50.084262',false,false),
	 ('43bef7a7-c894-4921-aaa0-f1c249e1e3a7','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789008','Salted Egg Sponge Cake',2,51900.00,'2025-03-10 18:58:50.084319','2025-03-10 18:58:50.08432',false,false),
	 ('5a9c1665-29dd-4fce-b930-c11dd2aeb996','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789004','Cream Puff',3,49900.00,'2025-03-10 18:58:50.084243','2025-03-10 18:58:50.084243',false,false),
	 ('86fcc0c1-7fd0-488f-84a9-518cf9b2f087','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789013','Boncha',3,25900.00,'2025-03-10 18:58:50.084131','2025-03-10 18:58:50.084131',false,false),
	 ('872b5f74-c144-4101-b3bd-e43f027b90bc','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789014','Bottle',4,34900.00,'2025-03-10 18:58:50.084165','2025-03-10 18:58:50.084165',false,false),
	 ('91a08bba-ac10-4b35-952a-fa5a785f2048','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789015','Can',1,30900.00,'2025-03-10 18:58:50.084185','2025-03-10 18:58:50.084185',false,false),
	 ('a4bebb2b-c6d2-47ef-a079-b075f4115f97','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789016','CocaCola',4,31900.00,'2025-03-10 18:58:50.084219','2025-03-10 18:58:50.084219',false,false),
	 ('afde9ded-7005-4316-8cc3-f40165594ae4','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789009','Sandwich',3,47900.00,'2025-03-10 18:58:50.084338','2025-03-10 18:58:50.084338',false,false),
	 ('cdf99521-e42c-444f-865f-6635fb8d8bfb','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789012','Beer Tiger',2,89900.00,'2025-03-10 18:58:50.084037','2025-03-10 18:58:50.084038',false,false),
	 ('e23f216e-9de6-4b28-ac2d-dd2661488e54','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789007','Muffin',1,42900.00,'2025-03-10 18:58:50.084303','2025-03-10 18:58:50.084304',false,false);

INSERT INTO public.order_item (order_item_id,order_id,product_id,product_name,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('072f4685-de03-4df4-bb95-58ebf5dc08f4','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789005','Croissant',2,69900.00,'2025-03-10 18:59:51.356691','2025-03-10 18:59:51.356691',false,false),
	 ('1f102ae9-5586-4a25-9928-0eaf60bd48e5','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789006','Donut',3,39900.00,'2025-03-10 18:59:51.356705','2025-03-10 18:59:51.356706',false,false),
	 ('287b23da-0784-4afa-8478-629d1d4d3b5b','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789012','Beer Tiger',3,89900.00,'2025-03-10 18:59:51.356499','2025-03-10 18:59:51.356499',false,false),
	 ('3162d185-05d0-4198-bfea-906e9adbb917','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789014','Bottle',4,34900.00,'2025-03-10 18:59:51.356617','2025-03-10 18:59:51.356617',false,false),
	 ('339e0c02-db12-49bf-a9f0-42cc77e02bea','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789016','CocaCola',1,31900.00,'2025-03-10 18:59:51.356657','2025-03-10 18:59:51.356658',false,false),
	 ('3c038fee-af3f-4344-aa87-a2cf19ba3529','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789015','Can',1,30900.00,'2025-03-10 18:59:51.356637','2025-03-10 18:59:51.356637',false,false),
	 ('3e7750c3-b549-4a2c-a060-7567c7d47cd8','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789013','Boncha',2,25900.00,'2025-03-10 18:59:51.356588','2025-03-10 18:59:51.356588',false,false),
	 ('dd2fef85-0c87-4f91-8ce9-a24570a000c7','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789004','Cream Puff',3,49900.00,'2025-03-10 18:59:51.356677','2025-03-10 18:59:51.356677',false,false),
	 ('de3a7d93-b66c-4d55-85a4-6b87101902ea','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789008','Salted Egg Sponge Cake',1,51900.00,'2025-03-10 18:59:51.356781','2025-03-10 18:59:51.356781',false,false),
	 ('f53ea42a-fe37-4470-9950-76d5043a38a6','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789007','Muffin',3,42900.00,'2025-03-10 18:59:51.356723','2025-03-10 18:59:51.356723',false,false),
	 ('fd3328d0-5f62-44c2-8f82-1d6e23164caa','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789009','Sandwich',4,47900.00,'2025-03-10 18:59:51.356799','2025-03-10 18:59:51.356799',false,false);
INSERT INTO public.order_item (order_item_id,order_id,product_id,product_name,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('22234eba-4025-4eae-a7d7-83f1ae86476b','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789005','Croissant',1,69900.00,'2025-03-10 19:00:44.534604','2025-03-10 19:00:44.534605',false,false),
	 ('2c084353-87df-43bb-a2d7-9463308bc62d','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789006','Donut',2,39900.00,'2025-03-10 19:00:44.534626','2025-03-10 19:00:44.534626',false,false),
	 ('46c82c5e-773b-4c75-9f36-f5e1b914d631','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789014','Bottle',1,34900.00,'2025-03-10 19:00:44.534473','2025-03-10 19:00:44.534473',false,false),
	 ('4ad505f8-5e06-4da2-9b16-7e08e8657d23','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789012','Beer Tiger',1,89900.00,'2025-03-10 19:00:44.53429','2025-03-10 19:00:44.534291',false,false),
	 ('692e4dae-c57b-4165-8ec1-d20b979250dd','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789016','CocaCola',4,31900.00,'2025-03-10 19:00:44.534532','2025-03-10 19:00:44.534532',false,false),
	 ('72bcdc1c-e85d-4613-b342-368472683e46','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789015','Can',2,30900.00,'2025-03-10 19:00:44.534506','2025-03-10 19:00:44.534506',false,false),
	 ('9097dea3-18e2-4f73-b0de-2158f8f6a897','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789013','Boncha',2,25900.00,'2025-03-10 19:00:44.534427','2025-03-10 19:00:44.534428',false,false),
	 ('92bd2b97-d9aa-4b2a-98b3-6e7b19e93ec1','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789007','Muffin',1,42900.00,'2025-03-10 19:00:44.534649','2025-03-10 19:00:44.534649',false,false),
	 ('95c5c8fc-d8b3-4b9d-8d81-6b5d94526b97','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789008','Salted Egg Sponge Cake',4,51900.00,'2025-03-10 19:00:44.534668','2025-03-10 19:00:44.534668',false,false),
	 ('b991179e-1de0-4484-a171-50a583740dfd','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789004','Cream Puff',2,49900.00,'2025-03-10 19:00:44.534578','2025-03-10 19:00:44.534579',false,false),
	 ('fd82ecbd-6178-4370-8f2b-8ed184ec7aa7','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789009','Sandwich',2,47900.00,'2025-03-10 19:00:44.534687','2025-03-10 19:00:44.534687',false,false);

INSERT INTO public.order_item (order_item_id,order_id,product_id,product_name,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('153cf309-ce46-4897-986f-440e67ff1711','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789007','Muffin',4,42900.00,'2025-03-10 19:01:07.091063','2025-03-10 19:01:07.091063',false,false),
	 ('44828ce7-b95b-4716-9223-046c5e7d5909','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789014','Bottle',3,34900.00,'2025-03-10 19:01:07.090745','2025-03-10 19:01:07.090745',false,false),
	 ('57acd8c2-4f1d-4dfd-a0bd-b1a233d6ec93','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789013','Boncha',2,25900.00,'2025-03-10 19:01:07.090716','2025-03-10 19:01:07.090716',false,false),
	 ('5a47d562-0aad-49af-a8f7-8b9b6d37279f','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789008','Salted Egg Sponge Cake',3,51900.00,'2025-03-10 19:01:07.091074','2025-03-10 19:01:07.091074',false,false),
	 ('87353834-fa87-4614-ad54-55f7ce0ff7f3','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789012','Beer Tiger',1,89900.00,'2025-03-10 19:01:07.090629','2025-03-10 19:01:07.090629',false,false),
	 ('880262b3-73d3-42f1-b898-234af18ed8e5','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789005','Croissant',3,69900.00,'2025-03-10 19:01:07.091035','2025-03-10 19:01:07.091035',false,false),
	 ('9468f6d3-ada9-4ad4-9d32-46827d6a76b6','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789016','CocaCola',3,31900.00,'2025-03-10 19:01:07.090787','2025-03-10 19:01:07.090787',false,false),
	 ('a34e74b4-33e8-4551-8772-420bb3fe64d5','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789006','Donut',1,39900.00,'2025-03-10 19:01:07.091048','2025-03-10 19:01:07.091048',false,false),
	 ('a7ed847e-7c6b-498c-a462-04a8aa37f5ac','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789004','Cream Puff',2,49900.00,'2025-03-10 19:01:07.09101','2025-03-10 19:01:07.091011',false,false),
	 ('ba6f5b61-0f58-469f-906d-86c7e4af3e62','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789015','Can',1,30900.00,'2025-03-10 19:01:07.090766','2025-03-10 19:01:07.090766',false,false),
	 ('cc07599f-5ff4-4223-b7e8-643ab40fb31e','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789009','Sandwich',2,47900.00,'2025-03-10 19:01:07.091084','2025-03-10 19:01:07.091085',false,false);

/*
INSERT INTO public.order_item (order_item_id,order_id,product_id,product_name,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('16e6935f-e1ee-40ad-a877-317fc366233d','a7c7fe68-25dd-44ae-80e5-f298a51e6d1c','a1b2c3d4-5678-90ab-cdef-123456789013','Boncha',2,25900.00,'2025-03-10 19:01:36.240473','2025-03-10 19:01:36.240474',false,false),
	 ('4671f98b-1cdd-4aa5-beb9-76bf808808a1','a7c7fe68-25dd-44ae-80e5-f298a51e6d1c','a1b2c3d4-5678-90ab-cdef-123456789012','Beer Tiger',1,89900.00,'2025-03-10 19:01:36.240129','2025-03-10 19:01:36.24013',false,false),
	 ('478cf8ec-61c2-4c2f-8ce2-9c906e84b193','a7c7fe68-25dd-44ae-80e5-f298a51e6d1c','a1b2c3d4-5678-90ab-cdef-123456789004','Cream Puff',2,49900.00,'2025-03-10 19:01:36.240523','2025-03-10 19:01:36.240523',false,false),
	 ('5cc66b69-9dee-4bcf-997e-0a96875bc7b7','a7c7fe68-25dd-44ae-80e5-f298a51e6d1c','a1b2c3d4-5678-90ab-cdef-123456789009','Sandwich',2,47900.00,'2025-03-10 19:01:36.240558','2025-03-10 19:01:36.240558',false,false),
	 ('6ead74bc-3de2-4a5d-b2e1-e36621978acd','a7c7fe68-25dd-44ae-80e5-f298a51e6d1c','a1b2c3d4-5678-90ab-cdef-123456789005','Croissant',1,69900.00,'2025-03-10 19:01:36.240532','2025-03-10 19:01:36.240532',false,false),
	 ('b15cae1b-4970-40ae-ad71-f69dcbcb6666','a7c7fe68-25dd-44ae-80e5-f298a51e6d1c','a1b2c3d4-5678-90ab-cdef-123456789006','Donut',4,39900.00,'2025-03-10 19:01:36.240539','2025-03-10 19:01:36.240539',false,false),
	 ('ce2f4d48-bdf3-41ab-8c14-fc6c3f2e2c1b','a7c7fe68-25dd-44ae-80e5-f298a51e6d1c','a1b2c3d4-5678-90ab-cdef-123456789016','CocaCola',3,31900.00,'2025-03-10 19:01:36.240511','2025-03-10 19:01:36.240511',false,false),
	 ('deb17f46-fa47-4b3b-bd0a-e74bb8a0f935','a7c7fe68-25dd-44ae-80e5-f298a51e6d1c','a1b2c3d4-5678-90ab-cdef-123456789014','Bottle',4,34900.00,'2025-03-10 19:01:36.240494','2025-03-10 19:01:36.240494',false,false),
	 ('dfe75a01-ff90-4ea9-bac6-600a6ac84b6a','a7c7fe68-25dd-44ae-80e5-f298a51e6d1c','a1b2c3d4-5678-90ab-cdef-123456789008','Salted Egg Sponge Cake',2,51900.00,'2025-03-10 19:01:36.240552','2025-03-10 19:01:36.240552',false,false),
	 ('e866e7aa-3cd4-44dd-af5d-bca1a2091ca5','a7c7fe68-25dd-44ae-80e5-f298a51e6d1c','a1b2c3d4-5678-90ab-cdef-123456789015','Can',1,30900.00,'2025-03-10 19:01:36.240502','2025-03-10 19:01:36.240502',false,false),
	 ('f5419a8f-e782-4c4d-8cc1-5127407f2530','a7c7fe68-25dd-44ae-80e5-f298a51e6d1c','a1b2c3d4-5678-90ab-cdef-123456789007','Muffin',2,42900.00,'2025-03-10 19:01:36.240546','2025-03-10 19:01:36.240546',false,false);
*/
INSERT INTO public.order_item (order_item_id,order_id,product_id,product_name,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('123629d2-f9af-4fc0-bc78-733067e3f6bc','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789006','Donut',4,39900.00,'2025-03-10 19:01:58.029057','2025-03-10 19:01:58.029057',false,false),
	 ('272bfec1-2cce-411b-aa17-82aacdf711fd','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789004','Cream Puff',3,49900.00,'2025-03-10 19:01:58.02905','2025-03-10 19:01:58.02905',false,false),
	 ('27af2718-62e6-4177-b66b-df855a2a5c64','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789008','Salted Egg Sponge Cake',1,51900.00,'2025-03-10 19:01:58.029065','2025-03-10 19:01:58.029065',false,false),
	 ('2e87bc6b-766f-4c1e-aee4-60b3520e812d','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789015','Can',1,30900.00,'2025-03-10 19:01:58.029038','2025-03-10 19:01:58.029038',false,false),
	 ('3440cd02-c085-41df-9679-a4b03af0bb3c','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789007','Muffin',3,42900.00,'2025-03-10 19:01:58.029062','2025-03-10 19:01:58.029062',false,false),
	 ('3b0a94b4-8d68-407a-ab84-8ccc493c0f54','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789012','Beer Tiger',4,89900.00,'2025-03-10 19:01:58.028984','2025-03-10 19:01:58.028985',false,false),
	 ('679c23ca-274d-46bb-8aab-eb3b7ac802b4','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789013','Boncha',3,25900.00,'2025-03-10 19:01:58.029029','2025-03-10 19:01:58.029029',false,false),
	 ('bf30c0d3-c119-4951-89ba-821f4dac1282','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789005','Croissant',4,69900.00,'2025-03-10 19:01:58.029053','2025-03-10 19:01:58.029053',false,false),
	 ('d110a7a8-d249-4e2d-b635-ce06493365b1','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789014','Bottle',1,34900.00,'2025-03-10 19:01:58.029034','2025-03-10 19:01:58.029034',false,false),
	 ('ee8f1460-d814-4c2c-b217-10e49ce9b3e6','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789009','Sandwich',3,47900.00,'2025-03-10 19:01:58.029069','2025-03-10 19:01:58.029069',false,false),
	 ('f85c2313-bde6-49db-9251-e9b3c90ffe0f','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789016','CocaCola',2,31900.00,'2025-03-10 19:01:58.029044','2025-03-10 19:01:58.029044',false,false);INSERT INTO deposit (deposit_id, customer_id, amount, status, code) VALUES
('550e8400-e29b-41d4-a716-446655440010', '110ec58a-a0f2-4ac4-8393-c866d813b8d1', 500000.00, 'CREATED', 'DEP20240319_001'),
('6f9619ff-8b86-d011-b42d-00c04fc964f3', '7d793037-a124-486c-91f8-49a8b8b4f9da', 1500000.00, 'SUCCEED', 'DEP20240319_002'),
('1b4e28ba-2fa1-11d2-883f-0016d3cca430', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 300000.00, 'FAILED', 'DEP20240319_003'),
('110ec58a-a0f2-4ac4-8393-c866d813b8d4', '110ec58a-a0f2-4ac4-8393-c866d813b8d1', 2000000.00, 'SUCCEED', 'DEP20240319_004'),
('7d793037-a124-486c-91f8-49a8b8b4f9dd', '7d793037-a124-486c-91f8-49a8b8b4f9da', 750000.00, 'CREATED', 'DEP20240319_005');

INSERT INTO deposit (deposit_id, customer_id, amount, status, code) VALUES
('2e4b28ba-3fa2-22d2-884f-0016d3cca431', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 3000000.00, 'SUCCEED', 'DEP20240319_006'),
('3f5e48ca-4fa3-33e3-995f-0026d3dda432', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 800000.00, 'SUCCEED', 'DEP20240319_007'),
('4a6f58db-5fa4-44f4-aa6f-0036d3eeb433', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 1000000.00, 'FAILED', 'DEP20240319_008');INSERT INTO wallet (customer_id, wallet_id, balance, priority, wallet_type) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'e2b7c3f9-5a44-4b1e-9b8d-7f3d2e1a6c75', 7500000.00, 0, 'MAIN'),
('6f9619ff-8b86-d011-b42d-00c04fc964ff', 'a8c1f2d3-7e5b-42f6-9a9c-1d4e8b3f6c27', 250000.00, 0, 'MAIN'),
('1b4e28ba-2fa1-11d2-883f-0016d3cca427', 'd4f8a2b9-3e7c-4a1d-8c5f-6b2e9f7a3c81', 100000.00, 0, 'MAIN'),
('110ec58a-a0f2-4ac4-8393-c866d813b8d1', 'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a', 750000.00, 0, 'MAIN'),
('7d793037-a124-486c-91f8-49a8b8b4f9da', '9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15', 50000.00, 0, 'MAIN');

INSERT INTO wallet (wallet_id, customer_id, balance, priority, wallet_type) VALUES
	('0195836d-7063-7e95-99bc-e59da39bb55e','65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 3800000.00, 0, 'MAIN'),
	('0195836d-7063-7e95-99bc-e59da39bb55f','65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 60000.00, 1, 'BONUS');

INSERT INTO wallet_transaction (wallet_id, amount, type, order_id, deposit_id, description, created_at, updated_at) VALUES
('0195836d-7063-7e95-99bc-e59da39bb55e', 3000000.00, 'DEPOSIT', NULL,'2e4b28ba-3fa2-22d2-884f-0016d3cca431','Deposit','2025-03-11 19:00:00', '2025-03-11 19:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', -1465100.00, 'ORDER_DEDUCT','24962082-ea1a-4829-8a9d-bb35118649a1',NULL,'Order', '2025-03-11 19:30:00', '2025-03-11 19:30:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', -1383200.00, 'ORDER_DEDUCT','ff718dc5-340c-4323-9b95-4391260b16d8',NULL,'Order', '2025-03-11 20:00:00', '2025-03-11 20:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', 800000.00, 'DEPOSIT',NULL,'3f5e48ca-4fa3-33e3-995f-0026d3dda432','Deposit', '2025-03-11 21:00:00', '2025-03-11 21:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', -75000.00, 'ORDER_ERROR','307506a4-87a9-418d-97a6-43829f58f90a',NULL,'Order error', '2025-03-11 22:00:00', '2025-03-11 22:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55f', 15000.00, 'DEPOSIT', NULL,'2e4b28ba-3fa2-22d2-884f-0016d3cca431','Deposit','2025-03-11 19:00:00', '2025-03-11 19:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55f', 8000.00, 'DEPOSIT', NULL,'3f5e48ca-4fa3-33e3-995f-0026d3dda432','Deposit','2025-03-11 19:00:00', '2025-03-11 19:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55f', -15000.00, 'ORDER_DEDUCT','24962082-ea1a-4829-8a9d-bb35118649a1',NULL,'Online shopping', '2025-03-11 19:30:00', '2025-03-11 19:30:00'),
('0195836d-7063-7e95-99bc-e59da39bb55f', -8000.00, 'ORDER_DEDUCT','ff718dc5-340c-4323-9b95-4391260b16d8',NULL,'Mobile recharge', '2025-03-11 20:00:00', '2025-03-11 20:00:00');