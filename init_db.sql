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
	code VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);
CREATE TABLE pos_device (
    device_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),    
	store_id UUID,
	hashed_token TEXT,
	expire_at TIMESTAMP DEFAULT NULL,
    CONSTRAINT fk_pos_of_store FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255) UNIQUE,
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
	code VARCHAR(255) UNIQUE,
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
	'ADMIN'),
	('6e9bac05-802d-46c3-9f58-5ce37cfc038e',
	'system',
    'system',
    'AQAAAAIAAYagAAAAEM5qkMuCZU6mxSl3jhkZ8csttfpfjuTt8ehoAbSYVQNjRxhJwAATFQjkzeUPA/B7Wg==',
    'SYSTEM',
	'SYSTEM');CREATE TABLE category (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name VARCHAR(255) NOT NULL,
    category_description TEXT,
    -- Common for all table
	code VARCHAR(255) UNIQUE,
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
	code VARCHAR(255) UNIQUE,
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
	is_email_confirmed BOOL DEFAULT FALSE,
    -- Common for all table
	code VARCHAR(255) UNIQUE,
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
	code VARCHAR(255) UNIQUE,
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
	code VARCHAR(255) UNIQUE,
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
	CONSTRAINT fk_old_order FOREIGN KEY (old_order_id) REFERENCES "order"(order_id) ON DELETE SET NULL,
    CONSTRAINT chk_no_self_ref CHECK (old_order_id IS NULL OR old_order_id <> order_id),
    -- Common for all table
	code VARCHAR(255) UNIQUE,
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
	staff_id UUID,
    "type" varchar(50),
    image_url varchar(255),
    "description" text,
    CONSTRAINT fk_inventory_log FOREIGN KEY (store_id) 
    REFERENCES store(store_id) ON DELETE SET NULL,
	CONSTRAINT fk_inv_log_of_staff FOREIGN KEY (staff_id) 
    REFERENCES staff(staff_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255) UNIQUE,
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
	expire_at TIMESTAMP DEFAULT NULL,
    CONSTRAINT fk_wallet_of_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
    -- Common for all table
	code VARCHAR(255) UNIQUE,
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
);CREATE TABLE promotion (
    promotion_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	detail JSONB,
	"type" varchar(50) DEFAULT 'UNKNOWN',
    -- Common for all table    
	code VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);CREATE TABLE password_reset_attempt (
    attempt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID,
	hashed_token TEXT,
    expire_time TIMESTAMP NOT NULL DEFAULT NOW() + INTERVAL '15 minutes',
	is_succeed BOOL DEFAULT FALSE,
	email VARCHAR(255) NOT NULL,
    CONSTRAINT fk_attempt_of_customer FOREIGN KEY (customer_id)
    REFERENCES customer(customer_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE   
);CREATE TABLE email_confirm_attempt (
    attempt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
	hashed_token TEXT NOT NULL,
    expire_time TIMESTAMP NOT NULL DEFAULT NOW() + INTERVAL '1 hour',
	is_succeed BOOL DEFAULT FALSE,
    CONSTRAINT fk_attempt_of_customer FOREIGN KEY (customer_id)
    REFERENCES customer(customer_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);INSERT INTO category (category_id, category_name, category_description) VALUES
('f1a2b3c4-5678-90ab-cdef-123456789001', 'Bread & Pastries', 'A selection of freshly baked bread, croissants, and sandwiches.'),
('f1a2b3c4-5678-90ab-cdef-123456789002', 'Cakes & Desserts', 'Delicious cakes, muffins, and pastries for any occasion.'),
('f1a2b3c4-5678-90ab-cdef-123456789003', 'Soft Drinks & Energy Drinks', 'Carbonated beverages and energy drinks for a refreshing boost.'),
('f1a2b3c4-5678-90ab-cdef-123456789004', 'Alcoholic Drinks', 'A variety of beers and other alcoholic beverages.'),
('f1a2b3c4-5678-90ab-cdef-123456789005', 'Bottled Water', 'Clean and refreshing bottled water for hydration.'),
('f1a2b3c4-5678-90ab-cdef-123456789006', 'Packaging & Containers', 'Various drink packaging such as bottles and cans.');


INSERT INTO product (product_id, product_name, product_description, category_id, code, base_price) VALUES
('a1b2c3d4-5678-90ab-cdef-123456789001', 'Butter Sugar Bread', 'A soft and sweet bread topped with butter and sugar.', 'f1a2b3c4-5678-90ab-cdef-123456789001', 'BSB001', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789002', 'Chicken Floss Bread', 'A fluffy bread topped with savory chicken floss.', 'f1a2b3c4-5678-90ab-cdef-123456789001', 'CFB002', 18000),
('a1b2c3d4-5678-90ab-cdef-123456789003', 'Chicken Floss Sandwich', 'A sandwich filled with rich and flavorful chicken floss.', 'f1a2b3c4-5678-90ab-cdef-123456789001', 'CFS003', 20000),
('a1b2c3d4-5678-90ab-cdef-123456789004', 'Cream Puff', 'A light and airy pastry filled with creamy custard.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'CP004', 12000),
('a1b2c3d4-5678-90ab-cdef-123456789005', 'Croissant', 'A flaky and buttery French pastry.', 'f1a2b3c4-5678-90ab-cdef-123456789001', 'CR005', 25000),
('a1b2c3d4-5678-90ab-cdef-123456789006', 'Donut', 'A soft and sweet deep-fried treat with various toppings.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'DN006', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789007', 'Muffin', 'A moist and fluffy baked treat, perfect for any time of the day.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'MF007', 20000),
('a1b2c3d4-5678-90ab-cdef-123456789008', 'Salted Egg Sponge Cake', 'A soft sponge cake infused with rich salted egg flavor.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'SESC008', 22000),
('a1b2c3d4-5678-90ab-cdef-123456789009', 'Sandwich', 'A classic combination of bread and filling for a satisfying meal.', 'f1a2b3c4-5678-90ab-cdef-123456789001', 'SW009', 20000),
('a1b2c3d4-5678-90ab-cdef-123456789010', 'Sponge Cake', 'A light and airy cake with a delicate texture.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'SC010', 18000),
('a1b2c3d4-5678-90ab-cdef-123456789011', 'Tiramisu', 'A classic Italian dessert with layers of coffee-soaked sponge and mascarpone.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'TM011', 30000),
('a1b2c3d4-5678-90ab-cdef-123456789012', 'Beer Tiger', 'A popular beer brand with a refreshing taste.', 'f1a2b3c4-5678-90ab-cdef-123456789004', 'BT012', 25000),
('a1b2c3d4-5678-90ab-cdef-123456789013', 'Boncha', 'A fizzy and refreshing flavored soft drink.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'BC013', 20000),
('a1b2c3d4-5678-90ab-cdef-123456789014', 'Bottle', 'A standard drink bottle container.', 'f1a2b3c4-5678-90ab-cdef-123456789006', 'BTL014', 5000),
('a1b2c3d4-5678-90ab-cdef-123456789015', 'Can', 'A convenient canned drink packaging.', 'f1a2b3c4-5678-90ab-cdef-123456789006', 'CAN015', 5000),
('a1b2c3d4-5678-90ab-cdef-123456789016', 'CocaCola', 'The world-famous cola soft drink.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'CC016', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789017', 'CocaCola Light', 'A low-calorie version of the classic CocaCola.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'CCL017', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789018', 'Green Tea', 'A refreshing bottled green tea beverage.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'GT018', 12000),
('a1b2c3d4-5678-90ab-cdef-123456789019', 'Pepsi', 'A bold and refreshing cola beverage.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'PP019', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789020', 'Red Bull', 'A popular energy drink that gives you wings.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'RB020', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789021', 'Revive Lemon Salt', 'A hydrating sports drink with a lemon-salt flavor.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'RLS021', 12000),
('a1b2c3d4-5678-90ab-cdef-123456789022', 'Revive Regular', 'An electrolyte drink for hydration and energy.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'RR022', 12000),
('a1b2c3d4-5678-90ab-cdef-123456789023', 'Strawberry Sting', 'A strawberry-flavored energy drink.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'SS023', 12000),
('a1b2c3d4-5678-90ab-cdef-123456789024', 'Vinh Hao Water', 'Premium bottled mineral water for daily hydration.', 'f1a2b3c4-5678-90ab-cdef-123456789005', 'VHW024', 10000);

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
    store_location,
	code
) 
VALUES
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'SuperMart Downtown', '123 Main Street, Downtown', 'STOR000001'),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'QuickShop Central', '456 Center Avenue, Central', 'STOR000002'),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'MegaStore North', '789 North Road, Uptown', 'STOR000003'),
    ('d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444', 'BudgetMart East', '321 East Lane, Eastside', 'STOR000004'),
    ('e5b3c2f1-2d75-4f3a-9a21-3b4a1c8f5555', 'ValueShop West', '654 West Street, Westend', 'STOR000005'),
    ('f6c4e1a7-1b63-41c2-bf82-2f1c7a5b6666', 'Neighborhood Market', '987 South Avenue, Southside', 'STOR000006'),
    ('a7d2b5c3-6f14-49c2-9f31-7a1c4b2f7777', 'FreshMart Hills', '159 Hills Road, Hilltop', 'STOR000007'),
    ('b8e1c3f7-4a62-48d2-bf41-1c7a2b8f8888', 'GreenLeaf Organic', '753 Garden Street, Greenfield', 'STOR000008'),
    ('c9f7a2d1-3b81-4e2a-bf24-4a1c5b7f9999', 'Urban Market', '246 City Center Blvd, Midtown', 'STOR000009'),
    ('d0a5e4c8-2b17-4f3a-bc52-3f1a7c2f0000', 'Family Grocery', '369 Maple Avenue, Riverside', 'STOR000010'),
    ('f47ac10b-58cc-4372-a567-0e02b2c3d479', 'Downtown Market', '123 Main Street, Downtown', 'STOR000011'),
    ('9c858901-8a57-4791-81fe-4c455b099bc9', 'Uptown Grocery', '456 Elm Street, Uptown', 'STOR000012'),
    ('3fa85f64-5717-4562-b3fc-2c963f66afa6', 'Central Plaza Store', '789 Oak Avenue, Central Plaza', 'STOR000013'),
    ('16fd2706-8baf-433b-82eb-8c7fada847da', 'Riverside Mart', '321 River Road, Riverside', 'STOR000014'),
    ('7c9e6679-7425-40de-944b-e07fc1f90ae7', 'Hilltop Supplies', '654 Pine Street, Hilltop', 'STOR000015');

INSERT INTO pos_device (device_id,store_id,hashed_token,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('0b75b5e2-444f-4b0d-8742-ccdb20ae2e0e'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEIVwvAMb4g3A11p5V5UYWqlsZh53mCqqUvx3Bg/zVrkQjaJnCTYVZplZ/7t46DgOMQ==','2025-05-08 10:12:24.948182','STORE1_DEV4','2025-04-08 10:09:51.619462','2025-04-08 10:12:05.611998',false,false),
	 ('3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEGEux9TAcCmeyB8Sq/TC/41kda4KrvKnJ3lVsnAhtP4NZJK1hSc0Mewx1hnUhXZtmA==','2025-05-08 10:28:51.850073','TEST_DEV_1','2025-04-04 11:59:46.41674','2025-04-08 10:28:51.850082',false,false),
	 ('543be31d-eb6e-43fa-be7c-f8b3dcde0f70'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEPOQfuw0KDXV/IUB7qGLXaQq3W0K7m9fk4B0D+hgcBOcrij1Ago7HoekGUrBsZz4aA==','2025-05-08 10:27:45.385024','STORE1_DEV1','2025-04-08 09:56:11.436709','2025-04-08 10:27:45.385189',false,false),
	 ('625f0c18-2248-4991-82ff-f7add17302d9'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEOOsqIZxmarEQfDV8jc6oD7Y1VMPXktJXHtmsufXnT7E2kwFuV+j5SEv+AuxGP3bbA==','2025-05-08 08:48:43.573576','TRUNG1','2025-04-08 08:37:06.335411','2025-04-08 08:48:43.573974',false,false),
	 ('e5de17a0-4754-4195-b14e-dfd3653a6139'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEEi9Gjzfv2fqR0lxnSWplsoiDXNLMPlzEVCX8cEpErjjO6W878N9peb5a3zvYz47Kg==','2025-05-08 10:32:42.363662','STORE1_DEV3','2025-04-08 10:08:43.527947','2025-04-08 10:32:42.363666',false,false),
	 ('3fa85f64-5717-4562-b3fc-2c963f66a002'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEOUSp+LCpmkU+M7jx41Zd2Z0IxANdL7rDgrD5GuEnrmR/gNN7IJe2UfLg/oKLMKNSw==','2025-05-08 10:32:52.573886','TEST_DEV_2','2025-04-04 11:59:46.41674','2025-04-08 10:32:52.5739',true,false),
	 ('4f03b994-3900-41ed-859a-2b913ade4dcb'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEIx7PQvTZ7QISAio7ms1Qz/FwIQIi326MqSkH/GwoFbzAEbbVgPbK5UiVFHQE6FwPQ==','2025-05-08 09:34:35.269049','TRUNG2','2025-04-08 09:22:06.630657','2025-04-08 09:34:35.269065',false,false),
	 ('3fa85f64-5717-4562-b3fc-2c963f66a003'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEPbVD/Idxlc/vu1z8doMpicImrJmH86k19FQiRDTwSNtcJaXs+f1BnCwTMaH+QjkzQ==','2025-05-08 10:32:55.725334','TEST_DEV_3','2025-04-04 11:59:46.41674','2025-04-08 10:32:55.725339',true,false),
	 ('b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEMIl/sG/7QChYsOkTm6wa4PnHz2qPr6cCBDVOZ3yHm5ZzdGvUb2ZEV7c7c5hIL5AkA==','2025-05-08 10:08:33.284367','STORE1_DEV2','2025-04-08 09:59:13.334279','2025-04-08 10:08:33.289',false,false),
	 ('d24f315e-c78b-4de7-8920-c0a50a4e5954'::uuid,'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222'::uuid,'AQAAAAIAAYagAAAAEHaQIotmTRfaeOACmOIeaJDXr4VLzqvon9l2+F+Lw52EWHjzK6m31ZbUjoN0HWhXmg==','2025-05-08 10:30:08.211875','STORE2_DEV1','2025-04-08 10:18:50.066566','2025-04-08 10:30:08.211884',false,false);
INSERT INTO pos_device (device_id,store_id,hashed_token,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('0eba4315-de43-477e-bf4d-b29cdc49f4f7'::uuid,'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222'::uuid,'AQAAAAIAAYagAAAAEAl7Bqlrd/9u4alRRRvVVBkIKTAblodLAzizdS+BzJuNfTx3RNhn/x7r+uFXv90Czg==','2025-05-08 10:20:22.512675','STORE2_DEV2','2025-04-08 10:20:22.372017','2025-04-08 10:20:22.512698',false,false),
	 ('b57bae4f-d377-4334-a353-84c7b8deaff8'::uuid,'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222'::uuid,'AQAAAAIAAYagAAAAEDHXH0IMdK0+js3CHPqeOQvqz3YUzj4IknB1wElr0ZaigvVhxYVz/bPj/xMzy4oQzA==','2025-05-08 10:20:49.316239','STORE2_DEV3','2025-04-08 10:20:49.192387','2025-04-08 10:20:49.316244',false,false),
	 ('ee830759-a26a-4bb9-9a61-6f1775636201'::uuid,'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333'::uuid,'AQAAAAIAAYagAAAAELZtlNRUDPbvXrSc+zfVi8gUIEtikQPwf8RVD7KGsyK6wtnOb2XhBJrl52tzQztYMA==','2025-05-08 10:31:27.333286','STORE3_DEV3','2025-04-08 10:31:27.17926','2025-04-08 10:31:27.333292',false,false),
	 ('973711f4-2d2d-4acb-99cb-1b1303d0a147'::uuid,'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333'::uuid,'AQAAAAIAAYagAAAAEEfJzUOV9ZfXyCpgvAHXikuBN9ZAegAl5dn3RjnZu/WGZPSV1ppbwXlDzWLShUdKAQ==','2025-05-08 10:31:23.133058','STORE3_DEV2','2025-04-08 10:31:22.977947','2025-04-08 10:31:23.133065',false,false),
	 ('f5d3a5d1-d46d-4bdc-bdbe-dafd3d81d268'::uuid,'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333'::uuid,'AQAAAAIAAYagAAAAEMWyGsAiS+pH8CKJ6iojJE9XXyuUYJWLzIurXVel3v8kZgLkZrGVbVsmcJEzFkLR/A==','2025-05-08 10:31:19.824117','STORE3_DEV1','2025-04-08 10:31:19.605487','2025-04-08 10:31:19.824124',false,false),
	 ('9b9ffbf7-31c3-49b0-ae87-2bd510eb32ba'::uuid,'d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444'::uuid,'AQAAAAIAAYagAAAAEPc2nynJu+ygsJSi0pZnvzYpYe+HzCI9eRzkkMquHjbxXFcw92tISq8rR7ll31IgHg==','2025-05-08 10:32:05.439149','STORE4_DEV1','2025-04-08 10:32:05.27797','2025-04-08 10:32:05.439164',false,false),
	 ('31c91189-25ab-4a20-ac14-d3b2bce4f0ce'::uuid,'d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444'::uuid,'AQAAAAIAAYagAAAAEDxY9B98Cyswl3W5fxfDChqxJ2xRs9Rmwjn1/7zwqEs9p/I3Cmo7N8Oz8U3NdViE7A==','2025-05-08 10:32:12.649746','STORE4_DEV3','2025-04-08 10:32:12.493116','2025-04-08 10:32:12.649762',false,false),
	 ('1366abf3-5a60-4c87-ab2e-2d16a6d60fc4'::uuid,'d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444'::uuid,'AQAAAAIAAYagAAAAEAy5cscliZkR5HRBPX/4Go/tUl10mjc+LvHJABHUPOeLlFul9gNO9tJrHIuClYP3Tw==','2025-05-08 10:32:15.849199','STORE4_DEV4','2025-04-08 10:32:15.690676','2025-04-08 10:32:15.849205',false,false),
	 ('d1c81ca4-7b83-4bd3-998c-a6ce6f87f914'::uuid,'d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444'::uuid,'AQAAAAIAAYagAAAAECflozYIUqKKdzPD+MKZaLHWR4ew9TeVPNkSNjFnBongBH+4iJQ2nOMHNVY4FN+nMw==','2025-05-08 10:32:09.448916','STORE4_DEV2','2025-04-08 10:32:09.28926','2025-04-08 10:32:09.448922',false,false);
INSERT INTO staff (staff_id, staff_name, staff_phone, staff_email, "role", password_hash, store_id) 
    VALUES
    ('0a5c236e-ff54-449e-834c-99c113b3b582', 'Alice Johnson', '123-456-7890', 'alice.johnson@example.com', 'STORE_MANAGER','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'f47ac10b-58cc-4372-a567-0e02b2c3d479'),
    ('6d4b69f1-bc1f-41d1-b105-e12e0b45d7f0', 'Bob Smith', '987-654-3210', 'bob.smith@example.com', 'STAFF','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', '9c858901-8a57-4791-81fe-4c455b099bc9'),
    ('86e3635b-f1d4-4e98-b30b-095c7d32b42b', 'Clara Lee', NULL, 'clara.lee@example.com', 'STAFF','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', '3fa85f64-5717-4562-b3fc-2c963f66afa6'),
    ('4ce18af5-130c-44ed-ba84-38a4411fdf95', 'NghiaNT', NULL, 'nghiant@aistore.com', 'IT_HD', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'),
    ('d8d0e33a-a490-4fce-beee-fcad5eaef9a3', 'TrungNX', NULL, 'trungnx@aistore.com', 'IT_HD', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'),
	('d8d0e33a-a490-4fce-beee-fcad5eaef9a4', 'TrungNX', NULL, 'trung@mail.com', 'STORE_MANAGER', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111')
    ;

INSERT INTO product_in_store (product_in_store_id,store_id,product_id,price,stock,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('fffc5db9-dc6e-43e8-9b29-8b500791f35f','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789004',19900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('003e474d-e5e6-47fd-ab3d-95ac358560da','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789012',19900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('c4612c3a-e977-4597-bf6d-9ca23a60fdd5','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789013',25900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('953c8077-a15e-431a-a238-64966ff0a414','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789014',14900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('aab9c027-b1e2-490c-9d73-29f845d4671f','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789015',10900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('a8698aa1-b1ad-4d15-a23c-acd0300e9c00','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789016',11900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('aa923b69-5fdb-40fe-ab56-decda440330f','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789018',28900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('cc544259-6cc3-48d0-ba1b-da22715c6f2b','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789019',17900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('c1acbd31-f1f9-4e71-bcd7-3984ff849738','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789023',20900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('cdc6f452-bb70-4c86-9e4f-7a49fc335f17','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789024',17900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false);
INSERT INTO product_in_store (product_in_store_id,store_id,product_id,price,stock,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('ac59681b-71e3-47f2-b77e-4ddc2fe2e0c4','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789001',16900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('8b3ca2b2-3e30-4b4a-994c-84c1e4a916c9','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789002',16900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('05ec7896-a8e4-4a74-99fe-51e81ab12a3d','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789003',15900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('1e623b3b-5581-48d3-86f4-a27f8907846a','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789004',10900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('a0a11812-fcf5-4ca2-b6cc-7621d9221262','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789005',17900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('1e2363ad-4b23-44a7-84cb-87dd1e269819','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789006',18900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('6361db86-aa32-439d-8916-9528a9fc532c','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789007',13900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('258c55ea-46c1-486f-a69c-dc32b331b361','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789008',12900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('343ace46-1312-4e03-8eee-d85cc412b288','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789009',14900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('abf396de-0f69-46c6-88e3-a0d45bac9109','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789010',14900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false);
INSERT INTO product_in_store (product_in_store_id,store_id,product_id,price,stock,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('0de0f1fb-31ee-4941-b65e-ec5a2b18542e','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789011',13900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('eb7f09a8-af0e-460b-aae0-00d48f31b4d8','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789012',10900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('75425f53-c4c3-4b5b-9cd0-8532279a74be','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789013',26900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('7828b3dc-a23f-4fb2-ada6-cd4e1f484792','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789014',13900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('5e05a556-a638-41f1-a53f-a60e81612ef0','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789015',11900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('20d87da2-005e-4108-b773-974ee924ece8','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789016',12900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('ce6811b5-0060-4926-8c70-a23b6c5524ad','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789017',11900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('1c96f3b3-6552-4208-9619-1173c53829eb','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789018',20900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('c5b30347-1f7c-476c-8cc9-5b3ec4771894','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789019',18900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('c933ef2a-bfee-4830-ad45-cf280a7844b3','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789020',30900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false);
INSERT INTO product_in_store (product_in_store_id,store_id,product_id,price,stock,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('4d542f81-000c-469e-8404-bcc770ac1ca6','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789021',19900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('e2dcd193-5d5b-4f02-bec6-406aae98ccb6','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789022',26900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('98ce05b5-a214-4ede-86ca-293f5a79b03b','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789023',21900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('bf61e311-a78d-440b-9250-642f263ecf89','b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222','a1b2c3d4-5678-90ab-cdef-123456789024',28900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('b1ec4776-2858-4c6e-9f00-ac151720038c','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789001',27900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('51dcdb35-5ff5-4bcb-8c7b-daea75553501','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789002',19900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('6a9c6e15-d136-4fb1-8e1e-cd39aa5d314a','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789003',17900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('314630ec-1543-451a-aee9-5310331843fe','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789004',18900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('75c07dc1-46f1-4ab9-a5a9-113059924c75','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789005',18900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('9b584d2c-61f2-4618-855e-51f5cefc0598','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789006',16900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false);
INSERT INTO product_in_store (product_in_store_id,store_id,product_id,price,stock,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('ec580d71-68fc-4476-806c-edcf47f21f45','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789007',21900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('d7ba5c75-979a-4e87-85ac-7f2e787e25af','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789008',20900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('8179ac3b-91eb-4bd3-a3a6-391c48a63c87','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789009',35900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('71e1297c-8a25-4f25-9040-34439ba81bd1','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789010',14900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('7b09061c-ff4d-43eb-9540-8d3cd16b36f9','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789011',11900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('b38782f6-9ec5-47a8-966b-a5ae02f146fd','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789012',28900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('003b2606-7e90-4e43-b688-b848cac7be1d','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789013',25900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('16b22e21-399f-4c10-8832-84a2e90942ac','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789014',32900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('5b6acece-51b1-432b-8b23-b472b48524f0','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789015',30900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('b85b515e-df14-49e9-b19c-c3b3cdb7329c','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789016',31900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false);
INSERT INTO product_in_store (product_in_store_id,store_id,product_id,price,stock,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('060eff79-093f-4ef0-89c4-79b34fc1fbd4','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789017',30900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('1566d6e1-0c10-4794-886b-f15cb1a7a74d','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789006',19900.00,27,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:14:55.098721',false,false),
	 ('d64fbd56-f9b3-4788-a6e9-f3e5a480e6f8','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789005',19900.00,29,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:05:20.955388',false,false),
	 ('572d8467-2e33-416c-baa6-9da8b25ceedd','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789001',19900.00,28,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:13:54.448885',false,false),
	 ('a6a3d453-de6d-4905-940d-f4d2ad2cd7f4','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789010',15900.00,29,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:06:45.72082',false,false),
	 ('01dfcc2c-c7c0-4a40-bab9-7e5d49be7ef9','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789003',18900.00,26,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:14:05.43937',false,false),
	 ('a9d09d7e-e7f9-440b-a7aa-fe023d8730fb','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789007',12900.00,28,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:07:07.141376',false,false),
	 ('6c2b5115-ae28-44de-8f05-e6f796947d09','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789011',12900.00,27,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:10:50.898318',false,false),
	 ('4d60e994-87cf-445f-9015-0951998157df','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789009',17900.00,26,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:14:05.439374',false,false),
	 ('963c6740-5e92-4b5c-9c9a-d8bed451e429','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789002',20900.00,29,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:10:50.898314',false,false);
INSERT INTO product_in_store (product_in_store_id,store_id,product_id,price,stock,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('347f8b62-1bb0-495f-998d-0ffeee470d0a','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789008',11900.00,26,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:12:11.56346',false,false),
	 ('864e02dd-eb66-4af3-9873-e7606d9ccdde','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789020',19900.00,28,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:12:11.563463',false,false),
	 ('6d0e10ca-51f4-4c0c-8fec-c5cf5161affc','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789018',28900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('55340c2d-07af-4de3-98e4-f61ec67fae82','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789019',26900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('b71df378-4d40-4047-88bd-d9a51bb05b1a','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789020',18900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('a7d3b610-fd37-459f-bab8-19a2dfaea15a','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789021',27900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('1cb5afb4-34de-465e-8723-ce77a7cadd0c','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789022',24900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('3c442843-d5cd-4f31-a0cb-9af7b3c8f086','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789023',29900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('f05774a6-a890-49e1-928c-d4bcf9578743','c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333','a1b2c3d4-5678-90ab-cdef-123456789024',27900.00,30,NULL,'2025-04-09 09:55:28.15435','2025-04-09 09:55:28.15435',false,false),
	 ('81bb0fc4-039c-464d-a744-8f2267458e36','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789017',12900.00,29,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:01:24.433186',false,false);
INSERT INTO product_in_store (product_in_store_id,store_id,product_id,price,stock,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('bbb3df82-488a-41ea-8e76-ab69f3b1e75e','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789022',15900.00,29,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:01:24.433374',false,false),
	 ('ad9c2c20-8da2-47a0-831d-94a69cc424c2','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','a1b2c3d4-5678-90ab-cdef-123456789021',18900.00,28,NULL,'2025-04-09 09:55:28.15435','2025-04-09 10:07:40.619458',false,false);
INSERT INTO customer (customer_id, customer_name, customer_email, customer_phone, image_url, password_hash, code) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'Alice Johnson', 'alice@example.com', '123-456-7890', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'CUST74829301'),
('6f9619ff-8b86-d011-b42d-00c04fc964ff', 'Bob Smith', 'bob@example.com', '987-654-3210', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'CUST91827364'),
('1b4e28ba-2fa1-11d2-883f-0016d3cca427', 'Charlie Brown', 'charlie@example.com', '555-123-4567', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'CUST50392718'),
('110ec58a-a0f2-4ac4-8393-c866d813b8d1', 'Diana Prince', 'diana@example.com', '444-555-6666', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'CUST37482019'),
('7d793037-a124-486c-91f8-49a8b8b4f9da', 'TrungNX', 'trungphat555@gmail.com', '222-333-4444', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'CUST83749202');

INSERT INTO customer (customer_id, customer_name, customer_phone, customer_email, image_url, password_hash, code) VALUES
('65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 'Lợi Nguyễn', '1234567', 'dongloi2504@gmail.com', '', 'AQAAAAIAAYagAAAAEO4oH0xNjb5agvpL1sPzytxzqq0Yz1UxApqBWKzxgDyDvLNW4N+8HHH7JSQWfNykTw==', 'CUST29574382');INSERT INTO card (card_id, customer_id, expiration_date, "type")
VALUES 
    ('a1b2c3d4-e5f6-4789-abcd-1234567890ab', '550e8400-e29b-41d4-a716-446655440000', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('b2c3d4e5-f6a7-4890-bcde-2345678901bc', '6f9619ff-8b86-d011-b42d-00c04fc964ff', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('c3d4e5f6-a7b8-4901-cdef-3456789012cd', '1b4e28ba-2fa1-11d2-883f-0016d3cca427', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('d4e5f6a7-b8c9-4012-def0-4567890123de', '110ec58a-a0f2-4ac4-8393-c866d813b8d1', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('e5f6a7b8-c9d0-4123-ef01-5678901234ef', '7d793037-a124-486c-91f8-49a8b8b4f9da', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('f6a7b8c9-d0e1-4234-f012-6789012345f0', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', '2026-01-01 00:00:00', 'VIRTUAL');


INSERT INTO card (card_id, customer_id, expiration_date, "type")
VALUES 
    ('162ae899-cd71-4c3b-ba92-06af95c28f98', '7d793037-a124-486c-91f8-49a8b8b4f9da', '2026-01-01 00:00:00', 'PHYSICAL');

INSERT INTO public."order" (order_id,card_id,device_id,staff_id,total,status) VALUES
	 ('24962082-ea1a-4829-8a9d-bb35118649a1','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', NULL,1480100.00,'PAID'),
	 ('ff718dc5-340c-4323-9b95-4391260b16d8','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', NULL,1391200.00,'FINISHED'),
	 ('67c10684-7479-4e6b-bcb0-1c7ac52b7475','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', '0a5c236e-ff54-449e-834c-99c113b3b582',1215300.00,'EDITED'),
	 ('307506a4-87a9-418d-97a6-43829f58f90a', NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001', '0a5c236e-ff54-449e-834c-99c113b3b582', 1305300.00,'STAFF_CANCELLED'),
	 ('3b7605ff-d7c0-4a04-bb2b-0117889f87c6','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', NULL,961800.00,'CANCELLED'),
	 ('c49c3e2e-ceee-4732-9c5c-aea6fa7594b3', NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001', NULL, 1145500.00,'CREATED');

INSERT INTO public.order_item (order_item_id,order_id,product_id,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('5d6d5229-df17-4a1e-ac45-489e788ddaf9','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789016',3,31900.00,'2025-03-10 18:44:08.073133','2025-03-10 18:44:08.073134',false,false),
	 ('5d8e0714-3b4f-4a28-84eb-fdc3c75a8764','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789014',1,34900.00,'2025-03-10 18:44:08.07276','2025-03-10 18:44:08.072761',false,false),
	 ('6bb723a2-bb7e-4a0f-bd8b-6378a94be572','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789005',3,69900.00,'2025-03-10 18:44:08.073186','2025-03-10 18:44:08.073186',false,false),
	 ('8736726d-957d-4483-b02d-4efa524e32bf','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789013',3,25900.00,'2025-03-10 18:44:08.072697','2025-03-10 18:44:08.072699',false,false),
	 ('8844a202-27aa-43eb-9633-ce886bd8169d','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789009',4,47900.00,'2025-03-10 18:44:08.073254','2025-03-10 18:44:08.073254',false,false),
	 ('8ae66e02-4b15-44e8-9ccc-181a1f701236','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789008',1,51900.00,'2025-03-10 18:44:08.073232','2025-03-10 18:44:08.073233',false,false),
	 ('8e7d151a-b664-4cd9-aebe-9b01711f4955','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789006',2,39900.00,'2025-03-10 18:44:08.073201','2025-03-10 18:44:08.073201',false,false),
	 ('9d665ce7-d5c8-4079-b1fe-7b15c8dc1d76','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789004',2,49900.00,'2025-03-10 18:44:08.073168','2025-03-10 18:44:08.073169',false,false),
	 ('b278fccb-1161-46dc-9619-b4b0a39afc2e','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789015',2,30900.00,'2025-03-10 18:44:08.072782','2025-03-10 18:44:08.072783',false,false),
	 ('eaf50af0-931b-4dca-a5b0-2ca7ee16f659','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789012',4,89900.00,'2025-03-10 18:44:08.054875','2025-03-10 18:44:08.054876',false,false),
	 ('fe9263ff-892d-47ba-969f-86878fe42f23','ff718dc5-340c-4323-9b95-4391260b16d8','a1b2c3d4-5678-90ab-cdef-123456789007',3,42900.00,'2025-03-10 18:44:08.073217','2025-03-10 18:44:08.073217',false,false);
	 
INSERT INTO public.order_item (order_item_id,order_id,product_id,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('0e3e1b95-4b3a-4f68-957a-997204d2a712','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789006',2,39900.00,'2025-03-10 18:58:50.084282','2025-03-10 18:58:50.084282',false,false),
	 ('123df01e-20a7-438e-a8e4-eaaf3fd62f3e','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789005',2,69900.00,'2025-03-10 18:58:50.084261','2025-03-10 18:58:50.084262',false,false),
	 ('43bef7a7-c894-4921-aaa0-f1c249e1e3a7','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789008',2,51900.00,'2025-03-10 18:58:50.084319','2025-03-10 18:58:50.08432',false,false),
	 ('5a9c1665-29dd-4fce-b930-c11dd2aeb996','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789004',3,49900.00,'2025-03-10 18:58:50.084243','2025-03-10 18:58:50.084243',false,false),
	 ('86fcc0c1-7fd0-488f-84a9-518cf9b2f087','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789013',3,25900.00,'2025-03-10 18:58:50.084131','2025-03-10 18:58:50.084131',false,false),
	 ('872b5f74-c144-4101-b3bd-e43f027b90bc','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789014',4,34900.00,'2025-03-10 18:58:50.084165','2025-03-10 18:58:50.084165',false,false),
	 ('91a08bba-ac10-4b35-952a-fa5a785f2048','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789015',1,30900.00,'2025-03-10 18:58:50.084185','2025-03-10 18:58:50.084185',false,false),
	 ('a4bebb2b-c6d2-47ef-a079-b075f4115f97','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789016',4,31900.00,'2025-03-10 18:58:50.084219','2025-03-10 18:58:50.084219',false,false),
	 ('afde9ded-7005-4316-8cc3-f40165594ae4','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789009',3,47900.00,'2025-03-10 18:58:50.084338','2025-03-10 18:58:50.084338',false,false),
	 ('cdf99521-e42c-444f-865f-6635fb8d8bfb','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789012',2,89900.00,'2025-03-10 18:58:50.084037','2025-03-10 18:58:50.084038',false,false),
	 ('e23f216e-9de6-4b28-ac2d-dd2661488e54','67c10684-7479-4e6b-bcb0-1c7ac52b7475','a1b2c3d4-5678-90ab-cdef-123456789007',1,42900.00,'2025-03-10 18:58:50.084303','2025-03-10 18:58:50.084304',false,false);

INSERT INTO public.order_item (order_item_id,order_id,product_id,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('072f4685-de03-4df4-bb95-58ebf5dc08f4','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789005',2,69900.00,'2025-03-10 18:59:51.356691','2025-03-10 18:59:51.356691',false,false),
	 ('1f102ae9-5586-4a25-9928-0eaf60bd48e5','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789006',3,39900.00,'2025-03-10 18:59:51.356705','2025-03-10 18:59:51.356706',false,false),
	 ('287b23da-0784-4afa-8478-629d1d4d3b5b','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789012',3,89900.00,'2025-03-10 18:59:51.356499','2025-03-10 18:59:51.356499',false,false),
	 ('3162d185-05d0-4198-bfea-906e9adbb917','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789014',4,34900.00,'2025-03-10 18:59:51.356617','2025-03-10 18:59:51.356617',false,false),
	 ('339e0c02-db12-49bf-a9f0-42cc77e02bea','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789016',1,31900.00,'2025-03-10 18:59:51.356657','2025-03-10 18:59:51.356658',false,false),
	 ('3c038fee-af3f-4344-aa87-a2cf19ba3529','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789015',1,30900.00,'2025-03-10 18:59:51.356637','2025-03-10 18:59:51.356637',false,false),
	 ('3e7750c3-b549-4a2c-a060-7567c7d47cd8','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789013',2,25900.00,'2025-03-10 18:59:51.356588','2025-03-10 18:59:51.356588',false,false),
	 ('dd2fef85-0c87-4f91-8ce9-a24570a000c7','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789004',3,49900.00,'2025-03-10 18:59:51.356677','2025-03-10 18:59:51.356677',false,false),
	 ('de3a7d93-b66c-4d55-85a4-6b87101902ea','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789008',1,51900.00,'2025-03-10 18:59:51.356781','2025-03-10 18:59:51.356781',false,false),
	 ('f53ea42a-fe37-4470-9950-76d5043a38a6','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789007',3,42900.00,'2025-03-10 18:59:51.356723','2025-03-10 18:59:51.356723',false,false),
	 ('fd3328d0-5f62-44c2-8f82-1d6e23164caa','307506a4-87a9-418d-97a6-43829f58f90a','a1b2c3d4-5678-90ab-cdef-123456789009',4,47900.00,'2025-03-10 18:59:51.356799','2025-03-10 18:59:51.356799',false,false);
INSERT INTO public.order_item (order_item_id,order_id,product_id,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('22234eba-4025-4eae-a7d7-83f1ae86476b','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789005',1,69900.00,'2025-03-10 19:00:44.534604','2025-03-10 19:00:44.534605',false,false),
	 ('2c084353-87df-43bb-a2d7-9463308bc62d','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789006',2,39900.00,'2025-03-10 19:00:44.534626','2025-03-10 19:00:44.534626',false,false),
	 ('46c82c5e-773b-4c75-9f36-f5e1b914d631','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789014',1,34900.00,'2025-03-10 19:00:44.534473','2025-03-10 19:00:44.534473',false,false),
	 ('4ad505f8-5e06-4da2-9b16-7e08e8657d23','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789012',1,89900.00,'2025-03-10 19:00:44.53429','2025-03-10 19:00:44.534291',false,false),
	 ('692e4dae-c57b-4165-8ec1-d20b979250dd','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789016',4,31900.00,'2025-03-10 19:00:44.534532','2025-03-10 19:00:44.534532',false,false),
	 ('72bcdc1c-e85d-4613-b342-368472683e46','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789015',2,30900.00,'2025-03-10 19:00:44.534506','2025-03-10 19:00:44.534506',false,false),
	 ('9097dea3-18e2-4f73-b0de-2158f8f6a897','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789013',2,25900.00,'2025-03-10 19:00:44.534427','2025-03-10 19:00:44.534428',false,false),
	 ('92bd2b97-d9aa-4b2a-98b3-6e7b19e93ec1','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789007',1,42900.00,'2025-03-10 19:00:44.534649','2025-03-10 19:00:44.534649',false,false),
	 ('95c5c8fc-d8b3-4b9d-8d81-6b5d94526b97','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789008',4,51900.00,'2025-03-10 19:00:44.534668','2025-03-10 19:00:44.534668',false,false),
	 ('b991179e-1de0-4484-a171-50a583740dfd','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789004',2,49900.00,'2025-03-10 19:00:44.534578','2025-03-10 19:00:44.534579',false,false),
	 ('fd82ecbd-6178-4370-8f2b-8ed184ec7aa7','3b7605ff-d7c0-4a04-bb2b-0117889f87c6','a1b2c3d4-5678-90ab-cdef-123456789009',2,47900.00,'2025-03-10 19:00:44.534687','2025-03-10 19:00:44.534687',false,false);

INSERT INTO public.order_item (order_item_id,order_id,product_id,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('153cf309-ce46-4897-986f-440e67ff1711','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789007',4,42900.00,'2025-03-10 19:01:07.091063','2025-03-10 19:01:07.091063',false,false),
	 ('44828ce7-b95b-4716-9223-046c5e7d5909','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789014',3,34900.00,'2025-03-10 19:01:07.090745','2025-03-10 19:01:07.090745',false,false),
	 ('57acd8c2-4f1d-4dfd-a0bd-b1a233d6ec93','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789013',2,25900.00,'2025-03-10 19:01:07.090716','2025-03-10 19:01:07.090716',false,false),
	 ('5a47d562-0aad-49af-a8f7-8b9b6d37279f','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789008',3,51900.00,'2025-03-10 19:01:07.091074','2025-03-10 19:01:07.091074',false,false),
	 ('87353834-fa87-4614-ad54-55f7ce0ff7f3','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789012',1,89900.00,'2025-03-10 19:01:07.090629','2025-03-10 19:01:07.090629',false,false),
	 ('880262b3-73d3-42f1-b898-234af18ed8e5','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789005',3,69900.00,'2025-03-10 19:01:07.091035','2025-03-10 19:01:07.091035',false,false),
	 ('9468f6d3-ada9-4ad4-9d32-46827d6a76b6','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789016',3,31900.00,'2025-03-10 19:01:07.090787','2025-03-10 19:01:07.090787',false,false),
	 ('a34e74b4-33e8-4551-8772-420bb3fe64d5','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789006',1,39900.00,'2025-03-10 19:01:07.091048','2025-03-10 19:01:07.091048',false,false),
	 ('a7ed847e-7c6b-498c-a462-04a8aa37f5ac','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789004',2,49900.00,'2025-03-10 19:01:07.09101','2025-03-10 19:01:07.091011',false,false),
	 ('ba6f5b61-0f58-469f-906d-86c7e4af3e62','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789015',1,30900.00,'2025-03-10 19:01:07.090766','2025-03-10 19:01:07.090766',false,false),
	 ('cc07599f-5ff4-4223-b7e8-643ab40fb31e','c49c3e2e-ceee-4732-9c5c-aea6fa7594b3','a1b2c3d4-5678-90ab-cdef-123456789009',2,47900.00,'2025-03-10 19:01:07.091084','2025-03-10 19:01:07.091085',false,false);

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
INSERT INTO public.order_item (order_item_id,order_id,product_id,count,unit_price,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('123629d2-f9af-4fc0-bc78-733067e3f6bc','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789006',4,39900.00,'2025-03-10 19:01:58.029057','2025-03-10 19:01:58.029057',false,false),
	 ('272bfec1-2cce-411b-aa17-82aacdf711fd','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789004',3,49900.00,'2025-03-10 19:01:58.02905','2025-03-10 19:01:58.02905',false,false),
	 ('27af2718-62e6-4177-b66b-df855a2a5c64','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789008',1,51900.00,'2025-03-10 19:01:58.029065','2025-03-10 19:01:58.029065',false,false),
	 ('2e87bc6b-766f-4c1e-aee4-60b3520e812d','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789015',1,30900.00,'2025-03-10 19:01:58.029038','2025-03-10 19:01:58.029038',false,false),
	 ('3440cd02-c085-41df-9679-a4b03af0bb3c','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789007',3,42900.00,'2025-03-10 19:01:58.029062','2025-03-10 19:01:58.029062',false,false),
	 ('3b0a94b4-8d68-407a-ab84-8ccc493c0f54','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789012',4,89900.00,'2025-03-10 19:01:58.028984','2025-03-10 19:01:58.028985',false,false),
	 ('679c23ca-274d-46bb-8aab-eb3b7ac802b4','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789013',3,25900.00,'2025-03-10 19:01:58.029029','2025-03-10 19:01:58.029029',false,false),
	 ('bf30c0d3-c119-4951-89ba-821f4dac1282','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789005',4,69900.00,'2025-03-10 19:01:58.029053','2025-03-10 19:01:58.029053',false,false),
	 ('d110a7a8-d249-4e2d-b635-ce06493365b1','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789014',1,34900.00,'2025-03-10 19:01:58.029034','2025-03-10 19:01:58.029034',false,false),
	 ('ee8f1460-d814-4c2c-b217-10e49ce9b3e6','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789009',3,47900.00,'2025-03-10 19:01:58.029069','2025-03-10 19:01:58.029069',false,false),
	 ('f85c2313-bde6-49db-9251-e9b3c90ffe0f','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789016',2,31900.00,'2025-03-10 19:01:58.029044','2025-03-10 19:01:58.029044',false,false);INSERT INTO "order" (order_id,card_id,device_id,staff_id,old_order_id,total,status,image1,image2,image3,is_flagged,is_correction,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('81e8d956-c09f-4df8-8fa5-1177342bcede'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,47700.00,'PAID','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE282917250409','2025-04-09 10:01:08.709854','2025-04-09 10:01:23.933081',false,false),
	 ('9ade6902-9aca-471f-811b-eb9fb121138d'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE382818250409','2025-04-09 10:02:10.478545','2025-04-09 10:02:51.325177',false,false),
	 ('45348a2c-862f-4aa8-961a-2797d369291a'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'CREATED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE533020250409','2025-04-09 10:04:04.241694','2025-04-09 10:04:04.241694',false,false),
	 ('a51db88a-328c-4890-b029-4ea928e9bf15'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,19900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE792610250409','2025-04-09 10:04:21.202662','2025-04-09 10:05:20.758077',false,false),
	 ('27a79e7b-2c41-4ba9-9362-7d20ccf6d2ed'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,11900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE841315250409','2025-04-09 10:06:10.643791','2025-04-09 10:06:14.212588',false,false),
	 ('ccd7723c-e7bf-43b8-ab94-01e0643cbedf'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,11900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE022724250409','2025-04-09 10:06:20.826836','2025-04-09 10:06:26.741392',false,false),
	 ('f1d7507f-6743-467b-a941-5243714f0e68'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,19900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE486682250409','2025-04-09 10:06:30.330191','2025-04-09 10:06:35.661549',false,false),
	 ('4c85443b-c880-487d-b271-93f6c97fbaf1'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,15900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE829263250409','2025-04-09 10:06:39.571627','2025-04-09 10:06:45.492335',false,false),
	 ('90ecead0-ae49-4717-b2ed-9e0d6329f734'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE462421250409','2025-04-09 10:06:49.25596','2025-04-09 10:06:54.666255',false,false),
	 ('0cdea66a-df3c-41c5-8ab8-4980bd55635d'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'CREATED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE115458250409','2025-04-09 10:06:59.135405','2025-04-09 10:06:59.135405',false,false);
INSERT INTO "order" (order_id,card_id,device_id,staff_id,old_order_id,total,status,image1,image2,image3,is_flagged,is_correction,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('7893d725-a670-4018-a56f-376c46fa70f6'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE363499250409','2025-04-09 10:07:02.689255','2025-04-09 10:07:06.923054',false,false),
	 ('49353c3b-7ef7-403e-af1d-9e7d6159ef50'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,36800.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE323669250409','2025-04-09 10:07:11.352275','2025-04-09 10:07:16.842495',false,false),
	 ('ff2e1cbf-cb54-460c-8008-c53105039802'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,41800.00,'CREATED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE007423250409','2025-04-09 10:07:25.113549','2025-04-09 10:07:25.113549',false,false),
	 ('21241ecb-b14b-42a0-966f-8c13a1368acb'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,0.00,'CREATED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE464191250409','2025-04-09 10:07:28.663302','2025-04-09 10:07:28.663303',false,false),
	 ('b31dd818-0948-4ed9-824e-4ca67aa34759'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,38800.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE695350250409','2025-04-09 10:07:33.168282','2025-04-09 10:07:40.395502',false,false),
	 ('01dee123-4948-4c16-8d07-42fbe02a8da4'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE126477250409','2025-04-09 10:09:22.133282','2025-04-09 10:09:30.07863',false,false),
	 ('d6e8745f-f353-4ff5-b439-790a1e090e8a'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,37800.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE936620250409','2025-04-09 10:09:34.610445','2025-04-09 10:09:40.210644',false,false),
	 ('450e1abb-d4b4-4916-94a3-2fc688e2cfda'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,33800.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE705039250409','2025-04-09 10:10:43.739831','2025-04-09 10:10:50.686844',false,false),
	 ('2d5a3ccb-168c-428c-a42a-1538db744ca0'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,19900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE655914250409','2025-04-09 10:10:56.024949','2025-04-09 10:11:02.093981',false,false),
	 ('f90a7e14-22a6-48ae-852b-324cd11b448a'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,11900.00,'CREATED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE400546250409','2025-04-09 10:12:02.171509','2025-04-09 10:12:02.171509',false,false);
INSERT INTO "order" (order_id,card_id,device_id,staff_id,old_order_id,total,status,image1,image2,image3,is_flagged,is_correction,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('26d79d9c-8a22-4315-ace8-56780cf17110'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,62600.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE712459250409','2025-04-09 10:12:05.980498','2025-04-09 10:12:11.332312',false,false),
	 ('11711d74-1de5-4ba3-9dae-b5ce81384213'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,18900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE179839250409','2025-04-09 10:13:22.584428','2025-04-09 10:13:39.118534',false,false),
	 ('021145a7-918f-4278-b675-796760b1177d'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,37800.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE775606250409','2025-04-09 10:13:48.274361','2025-04-09 10:13:54.247375',false,false),
	 ('e87fe469-da67-4b66-b1b5-f79f737a78e9'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,36800.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE269140250409','2025-04-09 10:13:58.639606','2025-04-09 10:14:05.238705',false,false),
	 ('5751a689-d04b-4063-b103-d0789f7e226a'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'CREATED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE244298250409','2025-04-09 10:14:40.124572','2025-04-09 10:14:40.124572',false,false),
	 ('b489d2db-c5fc-466b-888d-c38d7303d4de'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,19900.00,'PAID','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE741994250409','2025-04-09 10:14:48.87751','2025-04-09 10:14:54.671523',false,false);


INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('602950f6-b72b-4905-8a3c-94c5e7f6c46a'::uuid,'81e8d956-c09f-4df8-8fa5-1177342bcede'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789017'::uuid,1,12900.00,'ORDE720145250409','2025-04-09 10:01:08.952297','2025-04-09 10:01:08.952297',false,false),
	 ('89c58f9c-be9e-47dd-9ddc-6ea1b9f7189b'::uuid,'81e8d956-c09f-4df8-8fa5-1177342bcede'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789021'::uuid,1,18900.00,'ORDE673861250409','2025-04-09 10:01:08.91407','2025-04-09 10:01:08.914071',false,false),
	 ('a83e6baa-16b0-42ca-8016-0ec2a9bc75ac'::uuid,'81e8d956-c09f-4df8-8fa5-1177342bcede'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789022'::uuid,1,15900.00,'ORDE665895250409','2025-04-09 10:01:08.950766','2025-04-09 10:01:08.950766',false,false),
	 ('6e9ec237-186d-4b9d-bb72-40af50180ace'::uuid,'9ade6902-9aca-471f-811b-eb9fb121138d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,12900.00,'ORDE044307250409','2025-04-09 10:02:10.5121','2025-04-09 10:02:10.5121',false,false),
	 ('07f99c0b-717b-40ca-9cab-bf5f841646e0'::uuid,'45348a2c-862f-4aa8-961a-2797d369291a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,12900.00,'ORDE417746250409','2025-04-09 10:04:04.276026','2025-04-09 10:04:04.276026',false,false),
	 ('40d615f2-f634-42ae-952a-de3b5929812e'::uuid,'a51db88a-328c-4890-b029-4ea928e9bf15'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789005'::uuid,1,19900.00,'ORDE093190250409','2025-04-09 10:04:21.235732','2025-04-09 10:04:21.235732',false,false),
	 ('529e2162-fe01-4d39-a743-be02c6186a27'::uuid,'27a79e7b-2c41-4ba9-9362-7d20ccf6d2ed'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,1,11900.00,'ORDE865204250409','2025-04-09 10:06:10.682421','2025-04-09 10:06:10.682422',false,false),
	 ('fcc5b9d4-a87a-4d5d-ba26-244a86c3f599'::uuid,'ccd7723c-e7bf-43b8-ab94-01e0643cbedf'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,1,11900.00,'ORDE198888250409','2025-04-09 10:06:20.861103','2025-04-09 10:06:20.861104',false,false),
	 ('4dbb4dc7-b19b-4f4e-8418-ac09509c0390'::uuid,'f1d7507f-6743-467b-a941-5243714f0e68'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789006'::uuid,1,19900.00,'ORDE665361250409','2025-04-09 10:06:30.364668','2025-04-09 10:06:30.364668',false,false),
	 ('5d35c41d-481c-4e5a-a03b-a46e0c38740e'::uuid,'4c85443b-c880-487d-b271-93f6c97fbaf1'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789010'::uuid,1,15900.00,'ORDE609177250409','2025-04-09 10:06:39.608044','2025-04-09 10:06:39.608044',false,false);
INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('fba18ced-add9-4717-a9db-40d275eb7bb9'::uuid,'90ecead0-ae49-4717-b2ed-9e0d6329f734'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789011'::uuid,1,12900.00,'ORDE020091250409','2025-04-09 10:06:49.29033','2025-04-09 10:06:49.290331',false,false),
	 ('756d5ca9-81d5-4ee0-8b24-d502a0ea2f11'::uuid,'0cdea66a-df3c-41c5-8ab8-4980bd55635d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789011'::uuid,1,12900.00,'ORDE789993250409','2025-04-09 10:06:59.173766','2025-04-09 10:06:59.173767',false,false),
	 ('7c1cbf69-0005-46a8-bee0-947a3fafd64c'::uuid,'7893d725-a670-4018-a56f-376c46fa70f6'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,12900.00,'ORDE884694250409','2025-04-09 10:07:02.724944','2025-04-09 10:07:02.724945',false,false),
	 ('a922d1c5-29fa-487d-8901-6d7953a5b3f7'::uuid,'49353c3b-7ef7-403e-af1d-9e7d6159ef50'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789009'::uuid,1,17900.00,'ORDE199520250409','2025-04-09 10:07:11.388794','2025-04-09 10:07:11.388794',false,false),
	 ('ee206561-c664-4460-bd03-d4869aaf1cb9'::uuid,'49353c3b-7ef7-403e-af1d-9e7d6159ef50'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,1,18900.00,'ORDE587213250409','2025-04-09 10:07:11.388755','2025-04-09 10:07:11.388755',false,false),
	 ('ed375c4c-0e79-46b6-93db-6082c5e77683'::uuid,'ff2e1cbf-cb54-460c-8008-c53105039802'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789011'::uuid,1,12900.00,'ORDE979665250409','2025-04-09 10:07:25.148952','2025-04-09 10:07:25.148952',false,false),
	 ('fc027a94-e035-4f05-9768-551f841855a3'::uuid,'ff2e1cbf-cb54-460c-8008-c53105039802'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789018'::uuid,1,28900.00,'ORDE815385250409','2025-04-09 10:07:25.148906','2025-04-09 10:07:25.148906',false,false),
	 ('637b7e53-b1d3-467d-9ef6-e46d9f0ebc59'::uuid,'b31dd818-0948-4ed9-824e-4ca67aa34759'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789021'::uuid,1,18900.00,'ORDE345166250409','2025-04-09 10:07:33.204274','2025-04-09 10:07:33.204274',false,false),
	 ('b70ae4c2-c47f-4b33-8c12-c425cb9e827c'::uuid,'b31dd818-0948-4ed9-824e-4ca67aa34759'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789001'::uuid,1,19900.00,'ORDE296569250409','2025-04-09 10:07:33.204369','2025-04-09 10:07:33.204369',false,false),
	 ('79936223-930c-40e5-8be9-4568b771f285'::uuid,'01dee123-4948-4c16-8d07-42fbe02a8da4'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789011'::uuid,1,12900.00,'ORDE303690250409','2025-04-09 10:09:22.167709','2025-04-09 10:09:22.167709',false,false);
INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('50e2f7cf-f6e5-42e2-9173-619b314892b5'::uuid,'d6e8745f-f353-4ff5-b439-790a1e090e8a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789020'::uuid,1,19900.00,'ORDE244678250409','2025-04-09 10:09:34.642615','2025-04-09 10:09:34.642615',false,false),
	 ('8b5ee517-82cb-4539-a7be-8d36d8be81a0'::uuid,'d6e8745f-f353-4ff5-b439-790a1e090e8a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789009'::uuid,1,17900.00,'ORDE687584250409','2025-04-09 10:09:34.642717','2025-04-09 10:09:34.642717',false,false),
	 ('2c4486d3-3c86-4f21-9d17-f03b49535fde'::uuid,'450e1abb-d4b4-4916-94a3-2fc688e2cfda'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789011'::uuid,1,12900.00,'ORDE710588250409','2025-04-09 10:10:43.775242','2025-04-09 10:10:43.775242',false,false),
	 ('5cb6956f-5c66-45f2-aaa7-4f93eb8ebb70'::uuid,'450e1abb-d4b4-4916-94a3-2fc688e2cfda'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789002'::uuid,1,20900.00,'ORDE225600250409','2025-04-09 10:10:43.77537','2025-04-09 10:10:43.77537',false,false),
	 ('d1d2c0be-0f4a-495f-a40e-582c31e56922'::uuid,'2d5a3ccb-168c-428c-a42a-1538db744ca0'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789006'::uuid,1,19900.00,'ORDE497239250409','2025-04-09 10:10:56.060286','2025-04-09 10:10:56.060286',false,false),
	 ('dc2c747e-dcfe-4251-b2c6-3b77ec6f3512'::uuid,'f90a7e14-22a6-48ae-852b-324cd11b448a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,1,11900.00,'ORDE552483250409','2025-04-09 10:12:02.205548','2025-04-09 10:12:02.205548',false,false),
	 ('3960aeaf-c068-461a-9cd3-1444cbef62ea'::uuid,'26d79d9c-8a22-4315-ace8-56780cf17110'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789020'::uuid,1,19900.00,'ORDE737107250409','2025-04-09 10:12:06.01449','2025-04-09 10:12:06.01449',false,false),
	 ('6e8db141-2f16-4feb-886c-b4d726d3a0ff'::uuid,'26d79d9c-8a22-4315-ace8-56780cf17110'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,2,11900.00,'ORDE128123250409','2025-04-09 10:12:06.014577','2025-04-09 10:12:06.014577',false,false),
	 ('9844a29b-0a5f-45de-a286-ed4dcb3831ec'::uuid,'26d79d9c-8a22-4315-ace8-56780cf17110'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,1,18900.00,'ORDE563952250409','2025-04-09 10:12:06.0146','2025-04-09 10:12:06.0146',false,false),
	 ('a44dcd41-81d0-4e6c-aa98-c2e23fc051e2'::uuid,'11711d74-1de5-4ba3-9dae-b5ce81384213'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,1,18900.00,'ORDE653300250409','2025-04-09 10:13:22.618646','2025-04-09 10:13:22.618646',false,false);
INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('d4f54bcf-77ed-48e1-b239-9cad83aaf2ea'::uuid,'021145a7-918f-4278-b675-796760b1177d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789001'::uuid,1,19900.00,'ORDE152870250409','2025-04-09 10:13:48.308412','2025-04-09 10:13:48.308413',false,false),
	 ('e31aed38-dae5-450e-9e53-65d3c9446b7a'::uuid,'021145a7-918f-4278-b675-796760b1177d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789009'::uuid,1,17900.00,'ORDE439592250409','2025-04-09 10:13:48.308451','2025-04-09 10:13:48.308451',false,false),
	 ('52b24104-18e4-449d-bf6f-27108b72e8e9'::uuid,'e87fe469-da67-4b66-b1b5-f79f737a78e9'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789009'::uuid,1,17900.00,'ORDE424402250409','2025-04-09 10:13:58.676879','2025-04-09 10:13:58.676879',false,false),
	 ('be014357-a9dc-45de-b951-f1810d7bd4d9'::uuid,'e87fe469-da67-4b66-b1b5-f79f737a78e9'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,1,18900.00,'ORDE502903250409','2025-04-09 10:13:58.676929','2025-04-09 10:13:58.676929',false,false),
	 ('a200cd11-2654-44c9-aff2-d5561d9ba77f'::uuid,'5751a689-d04b-4063-b103-d0789f7e226a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,12900.00,'ORDE785255250409','2025-04-09 10:14:40.16116','2025-04-09 10:14:40.16116',false,false),
	 ('63a2e637-dd10-4e02-98b8-7eda4b8f67a8'::uuid,'b489d2db-c5fc-466b-888d-c38d7303d4de'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789006'::uuid,1,19900.00,'ORDE192149250409','2025-04-09 10:14:48.911137','2025-04-09 10:14:48.911137',false,false);


INSERT INTO inventory_note (inventory_note_id,store_id,staff_id,"type",image_url,description,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('301fa990-b359-461e-9a9d-cca931280e80','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 81e8d956-c09f-4df8-8fa5-1177342bcede','INVE504778250409','2025-04-09 10:01:24.427773','2025-04-09 10:01:24.427773',false,false),
	 ('3a4ba280-9344-4b33-9784-80e88a86cfbd','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 9ade6902-9aca-471f-811b-eb9fb121138d','INVE953188250409','2025-04-09 10:02:51.536608','2025-04-09 10:02:51.536608',false,false),
	 ('7eae5420-025f-4588-8805-0d9b78fc801e','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order a51db88a-328c-4890-b029-4ea928e9bf15','INVE741268250409','2025-04-09 10:05:20.955315','2025-04-09 10:05:20.955316',false,false),
	 ('deaaf0eb-2df1-4845-8fe3-31bd963dac9f','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 27a79e7b-2c41-4ba9-9362-7d20ccf6d2ed','INVE175084250409','2025-04-09 10:06:14.434896','2025-04-09 10:06:14.434896',false,false),
	 ('643709af-c846-42b8-a7f0-4337ac80f662','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order ccd7723c-e7bf-43b8-ab94-01e0643cbedf','INVE570314250409','2025-04-09 10:06:26.952312','2025-04-09 10:06:26.952312',false,false),
	 ('6f81d89c-9929-4ef2-89a1-b4b1ffc2bbc2','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order f1d7507f-6743-467b-a941-5243714f0e68','INVE015595250409','2025-04-09 10:06:35.872782','2025-04-09 10:06:35.872782',false,false),
	 ('5dd81824-3896-46ef-9551-54c4166a36aa','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 4c85443b-c880-487d-b271-93f6c97fbaf1','INVE849174250409','2025-04-09 10:06:45.720777','2025-04-09 10:06:45.720777',false,false),
	 ('12a1e6dd-8fc4-4c23-8bcb-14d9c33b2be8','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 90ecead0-ae49-4717-b2ed-9e0d6329f734','INVE494367250409','2025-04-09 10:06:54.877888','2025-04-09 10:06:54.877888',false,false),
	 ('27b35ee2-a2c6-4434-91fa-6e09cdf3a81d','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 7893d725-a670-4018-a56f-376c46fa70f6','INVE875344250409','2025-04-09 10:07:07.141322','2025-04-09 10:07:07.141322',false,false),
	 ('4e43a035-4b18-437a-baa9-82f5401b870c','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 49353c3b-7ef7-403e-af1d-9e7d6159ef50','INVE841726250409','2025-04-09 10:07:17.055687','2025-04-09 10:07:17.055687',false,false);
INSERT INTO inventory_note (inventory_note_id,store_id,staff_id,"type",image_url,description,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('aa3cbb8e-ac3b-4cb3-a467-a8da70187c7c','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order b31dd818-0948-4ed9-824e-4ca67aa34759','INVE375672250409','2025-04-09 10:07:40.619382','2025-04-09 10:07:40.619382',false,false),
	 ('fc67dcff-1cd1-4aae-b0ba-c44dc529d81b','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 01dee123-4948-4c16-8d07-42fbe02a8da4','INVE826099250409','2025-04-09 10:09:30.283222','2025-04-09 10:09:30.283222',false,false),
	 ('3359c7e0-f294-4c1c-ad90-57c58650a1b1','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order d6e8745f-f353-4ff5-b439-790a1e090e8a','INVE736341250409','2025-04-09 10:09:40.42389','2025-04-09 10:09:40.42389',false,false),
	 ('42f1cd0d-310f-4127-8ea8-1a4708d43cdf','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 450e1abb-d4b4-4916-94a3-2fc688e2cfda','INVE746630250409','2025-04-09 10:10:50.898211','2025-04-09 10:10:50.898211',false,false),
	 ('6addc26e-b65d-4c5f-9558-428f7cabf406','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 2d5a3ccb-168c-428c-a42a-1538db744ca0','INVE599679250409','2025-04-09 10:11:02.310946','2025-04-09 10:11:02.310946',false,false),
	 ('fc57c39a-c987-40db-941a-fcfb0d09c357','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 26d79d9c-8a22-4315-ace8-56780cf17110','INVE066031250409','2025-04-09 10:12:11.563144','2025-04-09 10:12:11.563144',false,false),
	 ('e1a725f5-7c1b-4e29-8250-60a22a05d2c1','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 11711d74-1de5-4ba3-9dae-b5ce81384213','INVE768828250409','2025-04-09 10:13:39.323601','2025-04-09 10:13:39.323602',false,false),
	 ('ada3692c-8b20-4fda-8dbb-27300fb6b94a','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 021145a7-918f-4278-b675-796760b1177d','INVE050862250409','2025-04-09 10:13:54.448834','2025-04-09 10:13:54.448834',false,false),
	 ('d6138d1c-3f77-4149-8672-1e8891b82a01','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order e87fe469-da67-4b66-b1b5-f79f737a78e9','INVE161313250409','2025-04-09 10:14:05.439336','2025-04-09 10:14:05.439336',false,false),
	 ('b609d414-c3bf-4a4b-9a02-c31cc9a1375b','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','6e9bac05-802d-46c3-9f58-5ce37cfc038e','ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order b489d2db-c5fc-466b-888d-c38d7303d4de','INVE600059250409','2025-04-09 10:14:55.098685','2025-04-09 10:14:55.098685',false,false);

INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('4da0ca21-db95-474d-aded-0dda283996b3','301fa990-b359-461e-9a9d-cca931280e80','81bb0fc4-039c-464d-a744-8f2267458e36',-1,30,'INVE309351250409','2025-04-09 10:01:24.432449','2025-04-09 10:01:24.43245',false,false),
	 ('c7667198-1af2-4e74-8aa2-450bef0847ea','301fa990-b359-461e-9a9d-cca931280e80','ad9c2c20-8da2-47a0-831d-94a69cc424c2',-1,30,'INVE767881250409','2025-04-09 10:01:24.433361','2025-04-09 10:01:24.433361',false,false),
	 ('e8a330b8-85aa-4811-86c1-b39f9a910d31','301fa990-b359-461e-9a9d-cca931280e80','bbb3df82-488a-41ea-8e76-ab69f3b1e75e',-1,30,'INVE851701250409','2025-04-09 10:01:24.433373','2025-04-09 10:01:24.433373',false,false),
	 ('0533712f-c062-4c31-8533-6c852800212e','3a4ba280-9344-4b33-9784-80e88a86cfbd','a9d09d7e-e7f9-440b-a7aa-fe023d8730fb',-1,30,'INVE925550250409','2025-04-09 10:02:51.536794','2025-04-09 10:02:51.536794',false,false),
	 ('32d37da5-6e24-49d7-bcbd-b900540230d8','7eae5420-025f-4588-8805-0d9b78fc801e','d64fbd56-f9b3-4788-a6e9-f3e5a480e6f8',-1,30,'INVE542489250409','2025-04-09 10:05:20.955362','2025-04-09 10:05:20.955362',false,false),
	 ('2b1183cd-84cf-4893-aab9-0573f31b235d','deaaf0eb-2df1-4845-8fe3-31bd963dac9f','347f8b62-1bb0-495f-998d-0ffeee470d0a',-1,30,'INVE192116250409','2025-04-09 10:06:14.434944','2025-04-09 10:06:14.434944',false,false),
	 ('d6b45106-0415-4358-ab49-bc8fb91c70a0','643709af-c846-42b8-a7f0-4337ac80f662','347f8b62-1bb0-495f-998d-0ffeee470d0a',-1,29,'INVE273667250409','2025-04-09 10:06:26.952348','2025-04-09 10:06:26.952348',false,false),
	 ('7250097e-f4c1-415c-a9a4-580aadb1e539','6f81d89c-9929-4ef2-89a1-b4b1ffc2bbc2','1566d6e1-0c10-4794-886b-f15cb1a7a74d',-1,30,'INVE482668250409','2025-04-09 10:06:35.872816','2025-04-09 10:06:35.872816',false,false),
	 ('3fd254e5-0aea-414f-83b3-413fe4ec19a7','5dd81824-3896-46ef-9551-54c4166a36aa','a6a3d453-de6d-4905-940d-f4d2ad2cd7f4',-1,30,'INVE932580250409','2025-04-09 10:06:45.720814','2025-04-09 10:06:45.720814',false,false),
	 ('a9ceb053-02d4-46ce-bc3d-54976305ef8f','12a1e6dd-8fc4-4c23-8bcb-14d9c33b2be8','6c2b5115-ae28-44de-8f05-e6f796947d09',-1,30,'INVE009876250409','2025-04-09 10:06:54.877916','2025-04-09 10:06:54.877916',false,false);
INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('6d12c190-9049-40ef-aab1-bc4a0a46ec28','27b35ee2-a2c6-4434-91fa-6e09cdf3a81d','a9d09d7e-e7f9-440b-a7aa-fe023d8730fb',-1,29,'INVE636791250409','2025-04-09 10:07:07.141358','2025-04-09 10:07:07.141358',false,false),
	 ('e1c5f105-2891-4428-906f-f7b381b80961','4e43a035-4b18-437a-baa9-82f5401b870c','4d60e994-87cf-445f-9015-0951998157df',-1,30,'INVE622285250409','2025-04-09 10:07:17.055725','2025-04-09 10:07:17.055725',false,false),
	 ('fd5422ef-8230-4302-8c48-e8c1c8635964','4e43a035-4b18-437a-baa9-82f5401b870c','01dfcc2c-c7c0-4a40-bab9-7e5d49be7ef9',-1,30,'INVE200988250409','2025-04-09 10:07:17.055718','2025-04-09 10:07:17.055718',false,false),
	 ('72edfbd1-a1e1-47c3-ad01-98cc929aa852','aa3cbb8e-ac3b-4cb3-a467-a8da70187c7c','ad9c2c20-8da2-47a0-831d-94a69cc424c2',-1,29,'INVE515367250409','2025-04-09 10:07:40.619457','2025-04-09 10:07:40.619457',false,false),
	 ('b740a54d-b8a7-416f-a14c-7781275640fb','aa3cbb8e-ac3b-4cb3-a467-a8da70187c7c','572d8467-2e33-416c-baa6-9da8b25ceedd',-1,30,'INVE235068250409','2025-04-09 10:07:40.619412','2025-04-09 10:07:40.619412',false,false),
	 ('2f7fa1ff-663e-4043-979e-5173f6aa8c84','fc67dcff-1cd1-4aae-b0ba-c44dc529d81b','6c2b5115-ae28-44de-8f05-e6f796947d09',-1,29,'INVE941537250409','2025-04-09 10:09:30.283318','2025-04-09 10:09:30.283318',false,false),
	 ('69bb5252-e956-4f96-b868-bb85c1168e49','3359c7e0-f294-4c1c-ad90-57c58650a1b1','4d60e994-87cf-445f-9015-0951998157df',-1,29,'INVE060362250409','2025-04-09 10:09:40.423953','2025-04-09 10:09:40.423953',false,false),
	 ('cbf34a3b-b148-4074-a99b-8630d4f7c493','3359c7e0-f294-4c1c-ad90-57c58650a1b1','864e02dd-eb66-4af3-9873-e7606d9ccdde',-1,30,'INVE753470250409','2025-04-09 10:09:40.423937','2025-04-09 10:09:40.423937',false,false),
	 ('de31b472-485e-46e3-9b3b-33b4e4a7933d','42f1cd0d-310f-4127-8ea8-1a4708d43cdf','963c6740-5e92-4b5c-9c9a-d8bed451e429',-1,30,'INVE627893250409','2025-04-09 10:10:50.898309','2025-04-09 10:10:50.898309',false,false),
	 ('f5ad6beb-abfc-444f-bad2-d4683486c0c0','42f1cd0d-310f-4127-8ea8-1a4708d43cdf','6c2b5115-ae28-44de-8f05-e6f796947d09',-1,28,'INVE227820250409','2025-04-09 10:10:50.898317','2025-04-09 10:10:50.898317',false,false);
INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('51b5921c-7d3d-403f-b46d-5cdffa12601c','6addc26e-b65d-4c5f-9558-428f7cabf406','1566d6e1-0c10-4794-886b-f15cb1a7a74d',-1,29,'INVE971913250409','2025-04-09 10:11:02.311016','2025-04-09 10:11:02.311016',false,false),
	 ('69030529-94b9-4100-886a-f3f6c06d3895','fc57c39a-c987-40db-941a-fcfb0d09c357','347f8b62-1bb0-495f-998d-0ffeee470d0a',-2,28,'INVE050740250409','2025-04-09 10:12:11.563457','2025-04-09 10:12:11.563457',false,false),
	 ('b8bcc43c-5d76-4473-94ab-90c5a1b3ce1a','fc57c39a-c987-40db-941a-fcfb0d09c357','864e02dd-eb66-4af3-9873-e7606d9ccdde',-1,29,'INVE328506250409','2025-04-09 10:12:11.563462','2025-04-09 10:12:11.563462',false,false),
	 ('eb0645e5-39b9-4569-8aa1-c2657ce79d9f','fc57c39a-c987-40db-941a-fcfb0d09c357','01dfcc2c-c7c0-4a40-bab9-7e5d49be7ef9',-1,29,'INVE660548250409','2025-04-09 10:12:11.563443','2025-04-09 10:12:11.563443',false,false),
	 ('ff92a4a9-f0a2-4ee8-a52b-e743d27b8f66','e1a725f5-7c1b-4e29-8250-60a22a05d2c1','01dfcc2c-c7c0-4a40-bab9-7e5d49be7ef9',-1,28,'INVE460685250409','2025-04-09 10:13:39.323653','2025-04-09 10:13:39.323654',false,false),
	 ('a6bba999-8896-48b9-8098-eaa37132ff4f','ada3692c-8b20-4fda-8dbb-27300fb6b94a','4d60e994-87cf-445f-9015-0951998157df',-1,28,'INVE002400250409','2025-04-09 10:13:54.448876','2025-04-09 10:13:54.448876',false,false),
	 ('ac49c453-fe61-4662-8d77-be3cf1a819d1','ada3692c-8b20-4fda-8dbb-27300fb6b94a','572d8467-2e33-416c-baa6-9da8b25ceedd',-1,29,'INVE560381250409','2025-04-09 10:13:54.448883','2025-04-09 10:13:54.448884',false,false),
	 ('1f1cae0b-cc86-47f6-9731-651c44035bd1','d6138d1c-3f77-4149-8672-1e8891b82a01','4d60e994-87cf-445f-9015-0951998157df',-1,27,'INVE777806250409','2025-04-09 10:14:05.439372','2025-04-09 10:14:05.439372',false,false),
	 ('bccffffb-4890-47b5-8bd7-19184f003223','d6138d1c-3f77-4149-8672-1e8891b82a01','01dfcc2c-c7c0-4a40-bab9-7e5d49be7ef9',-1,27,'INVE974966250409','2025-04-09 10:14:05.439366','2025-04-09 10:14:05.439366',false,false),
	 ('56328d56-aabe-4bd4-b65c-665d6d55d66e','b609d414-c3bf-4a4b-9a02-c31cc9a1375b','1566d6e1-0c10-4794-886b-f15cb1a7a74d',-1,28,'INVE977328250409','2025-04-09 10:14:55.098716','2025-04-09 10:14:55.098716',false,false);
INSERT INTO deposit (deposit_id, customer_id, amount, status, code) VALUES
('550e8400-e29b-41d4-a716-446655440010', '110ec58a-a0f2-4ac4-8393-c866d813b8d1', 500000.00, 'CREATED', 'DEP20240319_001'),
('6f9619ff-8b86-d011-b42d-00c04fc964f3', '7d793037-a124-486c-91f8-49a8b8b4f9da', 1500000.00, 'SUCCEED', 'DEP20240319_002'),
('1b4e28ba-2fa1-11d2-883f-0016d3cca430', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 300000.00, 'FAILED', 'DEP20240319_003'),
('110ec58a-a0f2-4ac4-8393-c866d813b8d4', '110ec58a-a0f2-4ac4-8393-c866d813b8d1', 2000000.00, 'SUCCEED', 'DEP20240319_004'),
('7d793037-a124-486c-91f8-49a8b8b4f9dd', '7d793037-a124-486c-91f8-49a8b8b4f9da', 750000.00, 'CREATED', 'DEP20240319_005');

INSERT INTO deposit (deposit_id, customer_id, amount, status, code) VALUES
('2e4b28ba-3fa2-22d2-884f-0016d3cca431', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 3000000.00, 'SUCCEED', 'DEP20240319_006'),
('3f5e48ca-4fa3-33e3-995f-0026d3dda432', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 800000.00, 'SUCCEED', 'DEP20240319_007'),
('4a6f58db-5fa4-44f4-aa6f-0036d3eeb433', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 1000000.00, 'FAILED', 'DEP20240319_008');

INSERT INTO deposit (deposit_id,customer_id,amount,status,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('0196149c-def6-709c-a3e2-bcc6c11b85b0'::uuid,'7d793037-a124-486c-91f8-49a8b8b4f9da'::uuid,500000.00,'FAILED','DEPO31011089250409','2025-04-08 15:55:47.190109','2025-04-09 08:12:12.564623',false,false),
	 ('019614a5-6092-799a-a884-3afa3daa71b9'::uuid,'7d793037-a124-486c-91f8-49a8b8b4f9da'::uuid,500000.00,'FAILED','DEPO17934927250409','2025-04-08 16:05:04.658141','2025-04-09 08:12:12.564623',false,false),
	 ('019614ab-2a34-7716-8bae-f9de39546c12'::uuid,'7d793037-a124-486c-91f8-49a8b8b4f9da'::uuid,500000.00,'FAILED','DEPO84728077250409','2025-04-08 16:11:23.956724','2025-04-09 08:12:12.564623',false,false),
	 ('01961816-c62c-7d8f-b5ba-dd091a29e0b5'::uuid,'7d793037-a124-486c-91f8-49a8b8b4f9da'::uuid,500000.00,'SUCCEED','DEPO029438250904','2025-04-09 08:07:47.884342','2025-04-09 08:08:38.960886',false,false),
	 ('0196181b-b80d-722e-ba49-61c408ed7dc7'::uuid,'7d793037-a124-486c-91f8-49a8b8b4f9da'::uuid,500000.00,'SUCCEED','DEPO365933250904','2025-04-09 08:13:11.949343','2025-04-09 08:13:52.514428',false,false);
INSERT INTO wallet (customer_id, wallet_id, balance, priority, wallet_type) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'e2b7c3f9-5a44-4b1e-9b8d-7f3d2e1a6c75', 7500000.00, 0, 'MAIN'),
('6f9619ff-8b86-d011-b42d-00c04fc964ff', 'a8c1f2d3-7e5b-42f6-9a9c-1d4e8b3f6c27', 250000.00, 0, 'MAIN'),
('1b4e28ba-2fa1-11d2-883f-0016d3cca427', 'd4f8a2b9-3e7c-4a1d-8c5f-6b2e9f7a3c81', 100000.00, 0, 'MAIN'),
('110ec58a-a0f2-4ac4-8393-c866d813b8d1', 'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a', 750000.00, 0, 'MAIN');


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


INSERT INTO wallet (wallet_id,customer_id,balance,priority,wallet_type,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,'7d793037-a124-486c-91f8-49a8b8b4f9da'::uuid,0.00,1,'BONUS','2025-04-09 16:13:52.516254',NULL,'2025-04-09 08:08:38.986548','2025-04-09 10:06:54.666216',false,false),
	 ('9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,'7d793037-a124-486c-91f8-49a8b8b4f9da'::uuid,613300.00,0,'MAIN',NULL,NULL,'2025-04-08 15:41:57.024047','2025-04-09 10:14:54.67152',false,false);

INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('14905ae5-075d-4af6-b465-0dc7d1f1a20f'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,500000.00,'DEPOSIT','Deposit on 4/9/2025 8:08:39 AM',NULL,'01961816-c62c-7d8f-b5ba-dd091a29e0b5'::uuid,NULL,'2025-04-09 08:08:39.067308','2025-04-09 08:08:39.067308',false,false),
	 ('d0b51101-d121-4eae-a92f-e61612b7662d'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,72500.00,'DEPOSIT','Promotion Deposit on 4/9/2025 8:08:39 AM',NULL,'01961816-c62c-7d8f-b5ba-dd091a29e0b5'::uuid,NULL,'2025-04-09 08:08:39.037444','2025-04-09 08:08:39.037444',false,false),
	 ('93694623-e3d1-493b-b766-6cfed93d577a'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,500000.00,'DEPOSIT','Deposit on 4/9/2025 8:13:52 AM',NULL,'0196181b-b80d-722e-ba49-61c408ed7dc7'::uuid,NULL,'2025-04-09 08:13:52.516687','2025-04-09 08:13:52.516687',false,false),
	 ('c95609c8-a5b2-464b-ba99-06a50b644975'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,72500.00,'DEPOSIT','Promotion Deposit on 4/9/2025 8:13:52 AM',NULL,'0196181b-b80d-722e-ba49-61c408ed7dc7'::uuid,NULL,'2025-04-09 08:13:52.516261','2025-04-09 08:13:52.516261',false,false),
	 ('4463c597-7237-4487-b1f4-c4e954d643d1'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,-47700.00,'ORDER_DEDUCT','Payment for order 81e8d956-c09f-4df8-8fa5-1177342bcede Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by BONUS wallet 01961817-8dcc-73bf-ae11-781504cc77a5','81e8d956-c09f-4df8-8fa5-1177342bcede'::uuid,NULL,'WALL356599250409','2025-04-09 10:01:23.930107','2025-04-09 10:01:23.930107',false,false),
	 ('7b7b7eaf-3772-47f7-8a86-6f469a718589'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,-12900.00,'ORDER_DEDUCT','Payment for order 9ade6902-9aca-471f-811b-eb9fb121138d Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by BONUS wallet 01961817-8dcc-73bf-ae11-781504cc77a5','9ade6902-9aca-471f-811b-eb9fb121138d'::uuid,NULL,'WALL394977250409','2025-04-09 10:02:51.325157','2025-04-09 10:02:51.325157',false,false),
	 ('81d78650-8799-4e83-9b60-a6852ca11fa6'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,-19900.00,'ORDER_DEDUCT','Payment for order a51db88a-328c-4890-b029-4ea928e9bf15 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by BONUS wallet 01961817-8dcc-73bf-ae11-781504cc77a5','a51db88a-328c-4890-b029-4ea928e9bf15'::uuid,NULL,'WALL442216250409','2025-04-09 10:05:20.758047','2025-04-09 10:05:20.758047',false,false),
	 ('eaeeb273-2533-4673-9141-4643b1db5265'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,-11900.00,'ORDER_DEDUCT','Payment for order 27a79e7b-2c41-4ba9-9362-7d20ccf6d2ed Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by BONUS wallet 01961817-8dcc-73bf-ae11-781504cc77a5','27a79e7b-2c41-4ba9-9362-7d20ccf6d2ed'::uuid,NULL,'WALL375093250409','2025-04-09 10:06:14.212466','2025-04-09 10:06:14.212467',false,false),
	 ('83b821e9-be83-47a3-a4b7-d16fc5889d28'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,-11900.00,'ORDER_DEDUCT','Payment for order ccd7723c-e7bf-43b8-ab94-01e0643cbedf Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by BONUS wallet 01961817-8dcc-73bf-ae11-781504cc77a5','ccd7723c-e7bf-43b8-ab94-01e0643cbedf'::uuid,NULL,'WALL677230250409','2025-04-09 10:06:26.741376','2025-04-09 10:06:26.741376',false,false),
	 ('79c6c15f-2794-4fd1-bd24-650b6029a623'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,-19900.00,'ORDER_DEDUCT','Payment for order f1d7507f-6743-467b-a941-5243714f0e68 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by BONUS wallet 01961817-8dcc-73bf-ae11-781504cc77a5','f1d7507f-6743-467b-a941-5243714f0e68'::uuid,NULL,'WALL180537250409','2025-04-09 10:06:35.661533','2025-04-09 10:06:35.661533',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('91020974-d9c0-46de-a10f-8f30bf10b06a'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,-15900.00,'ORDER_DEDUCT','Payment for order 4c85443b-c880-487d-b271-93f6c97fbaf1 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by BONUS wallet 01961817-8dcc-73bf-ae11-781504cc77a5','4c85443b-c880-487d-b271-93f6c97fbaf1'::uuid,NULL,'WALL444387250409','2025-04-09 10:06:45.492319','2025-04-09 10:06:45.492319',false,false),
	 ('8b06b94e-e663-4b7f-8fcb-ca60efe47ba1'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-17800.00,'ORDER_DEDUCT','Payment for order 90ecead0-ae49-4717-b2ed-9e0d6329f734 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','90ecead0-ae49-4717-b2ed-9e0d6329f734'::uuid,NULL,'WALL301294250409','2025-04-09 10:06:54.666233','2025-04-09 10:06:54.666233',false,false),
	 ('f39547d2-772f-4e19-8c62-c9481507a604'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,-4900.00,'ORDER_DEDUCT','Payment for order 90ecead0-ae49-4717-b2ed-9e0d6329f734 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by BONUS wallet 01961817-8dcc-73bf-ae11-781504cc77a5','90ecead0-ae49-4717-b2ed-9e0d6329f734'::uuid,NULL,'WALL498783250409','2025-04-09 10:06:54.66562','2025-04-09 10:06:54.66562',false,false),
	 ('eca27b13-c13a-4c19-9a4a-a23cb45a49cf'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-12900.00,'ORDER_DEDUCT','Payment for order 7893d725-a670-4018-a56f-376c46fa70f6 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','7893d725-a670-4018-a56f-376c46fa70f6'::uuid,NULL,'WALL192459250409','2025-04-09 10:07:06.922986','2025-04-09 10:07:06.922986',false,false),
	 ('eda59365-1855-4ae5-9322-63dc3c35692b'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-36800.00,'ORDER_DEDUCT','Payment for order 49353c3b-7ef7-403e-af1d-9e7d6159ef50 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','49353c3b-7ef7-403e-af1d-9e7d6159ef50'::uuid,NULL,'WALL658575250409','2025-04-09 10:07:16.842481','2025-04-09 10:07:16.842481',false,false),
	 ('1acee8df-3212-48f9-9821-cc0674592797'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-38800.00,'ORDER_DEDUCT','Payment for order b31dd818-0948-4ed9-824e-4ca67aa34759 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','b31dd818-0948-4ed9-824e-4ca67aa34759'::uuid,NULL,'WALL771093250409','2025-04-09 10:07:40.395485','2025-04-09 10:07:40.395485',false,false),
	 ('8e515227-1b8b-4541-9378-8c7ffd800c3b'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-12900.00,'ORDER_DEDUCT','Payment for order 01dee123-4948-4c16-8d07-42fbe02a8da4 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','01dee123-4948-4c16-8d07-42fbe02a8da4'::uuid,NULL,'WALL169757250409','2025-04-09 10:09:30.078613','2025-04-09 10:09:30.078613',false,false),
	 ('667cf6fe-6cf3-4042-8c4c-5f43d1401c0c'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-37800.00,'ORDER_DEDUCT','Payment for order d6e8745f-f353-4ff5-b439-790a1e090e8a Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','d6e8745f-f353-4ff5-b439-790a1e090e8a'::uuid,NULL,'WALL865578250409','2025-04-09 10:09:40.210613','2025-04-09 10:09:40.210613',false,false),
	 ('277f3236-4116-44b0-990d-4d3131932bca'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-33800.00,'ORDER_DEDUCT','Payment for order 450e1abb-d4b4-4916-94a3-2fc688e2cfda Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','450e1abb-d4b4-4916-94a3-2fc688e2cfda'::uuid,NULL,'WALL691284250409','2025-04-09 10:10:50.686827','2025-04-09 10:10:50.686828',false,false),
	 ('7601471b-fbe3-41a5-acbb-7bd8b6f6e54a'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-19900.00,'ORDER_DEDUCT','Payment for order 2d5a3ccb-168c-428c-a42a-1538db744ca0 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','2d5a3ccb-168c-428c-a42a-1538db744ca0'::uuid,NULL,'WALL358476250409','2025-04-09 10:11:02.093951','2025-04-09 10:11:02.093951',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('7873dbe5-7c0d-4fa5-bdd0-000be2dc70fc'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-62600.00,'ORDER_DEDUCT','Payment for order 26d79d9c-8a22-4315-ace8-56780cf17110 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','26d79d9c-8a22-4315-ace8-56780cf17110'::uuid,NULL,'WALL479506250409','2025-04-09 10:12:11.332296','2025-04-09 10:12:11.332296',false,false),
	 ('bdf280cb-1e1a-4e16-84cf-ec72360314d3'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-18900.00,'ORDER_DEDUCT','Payment for order 11711d74-1de5-4ba3-9dae-b5ce81384213 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','11711d74-1de5-4ba3-9dae-b5ce81384213'::uuid,NULL,'WALL665158250409','2025-04-09 10:13:39.118519','2025-04-09 10:13:39.118519',false,false),
	 ('5daa7795-792f-40ca-85d4-ac3c2c20d6be'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-37800.00,'ORDER_DEDUCT','Payment for order 021145a7-918f-4278-b675-796760b1177d Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','021145a7-918f-4278-b675-796760b1177d'::uuid,NULL,'WALL690014250409','2025-04-09 10:13:54.247357','2025-04-09 10:13:54.247357',false,false),
	 ('4ace8974-c38c-4fe6-ba96-9d35e18860ee'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-36800.00,'ORDER_DEDUCT','Payment for order e87fe469-da67-4b66-b1b5-f79f737a78e9 Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','e87fe469-da67-4b66-b1b5-f79f737a78e9'::uuid,NULL,'WALL766614250409','2025-04-09 10:14:05.238681','2025-04-09 10:14:05.238681',false,false),
	 ('b2faa51f-390a-4788-970b-b63966add88d'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,-19900.00,'ORDER_DEDUCT','Payment for order b489d2db-c5fc-466b-888d-c38d7303d4de Using card e5f6a7b8-c9d0-4123-ef01-5678901234ef Pay by MAIN wallet 9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15','b489d2db-c5fc-466b-888d-c38d7303d4de'::uuid,NULL,'WALL011332250409','2025-04-09 10:14:54.671507','2025-04-09 10:14:54.671508',false,false);
INSERT INTO promotion (promotion_id, detail, "type", code, is_suspended) VALUES
	('550e8400-e29b-41d4-a716-446655440000', '{"Percentage":10.5,"BonusWalletLifeTimeInHours":10,"AppliedDayOfWeek":"MON"}', 'DEPOSIT_PROMO_V1', 'MON_SPR2025', false),
	('0f3e14a3-baa4-4c72-a912-3517ef6a8458',
	'{"Percentage":12.5,"BonusWalletLifeTimeInHours":9,"AppliedDayOfWeek":"TUE"}', 'DEPOSIT_PROMO_V1', 'TUE_SPR2025', false),
	('ba240d98-3570-418d-8916-81aaf51421cc',
	'{"Percentage":14.5,"BonusWalletLifeTimeInHours":8,"AppliedDayOfWeek":"WED"}', 'DEPOSIT_PROMO_V1', 'WED_SPR2025', false),
	('ef282a03-92db-45ca-86dc-f886bba99912',
	'{"Percentage":16.5,"BonusWalletLifeTimeInHours":7,"AppliedDayOfWeek":"THU"}', 'DEPOSIT_PROMO_V1', 'THU_SPR2025', false),
	('a301edce-9a41-4c93-a109-1572b46df4a3',
	'{"Percentage":17.5,"BonusWalletLifeTimeInHours":6,"AppliedDayOfWeek":"FRI"}', 'DEPOSIT_PROMO_V1', 'FRI_SPR2025', false),
	('550e8400-e29b-41d4-a716-446655440001', '{}', 'DEPOSIT_PROMO_V1', 'TEST_PROMOTION', true),
	('550e8400-e29b-41d4-a716-446655440002', '{}', 'DEPOSIT_PROMO_V1', 'PROMO789', true);INSERT INTO inventory_note (inventory_note_id,store_id,staff_id,"type",image_url,"description",code)
VALUES
	('69c89ae3-3d7f-44a1-bdcc-98df64f39486','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','d8d0e33a-a490-4fce-beee-fcad5eaef9a4','CHANGE','https://reinir.mooo.com/files/remi.jpg','Inventory change mock data','NOTE000000'),
	('46fb8481-a0b4-43f4-8758-355b0d1f3bc5','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','d8d0e33a-a490-4fce-beee-fcad5eaef9a4','AUDIT','https://reinir.mooo.com/files/food.jpg','Inventory audit mock data','NOTE000001'),
	('d911f814-ad30-4248-bc2d-ee09ac0668dd','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','0a5c236e-ff54-449e-834c-99c113b3b582','CHANGE','https://reinir.mooo.com/files/food.jpg','Inventory change mock data','NOTE000002'),
	('cc407916-b4b7-434f-b671-7dd18d9c7bdf','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','0a5c236e-ff54-449e-834c-99c113b3b582','AUDIT','https://reinir.mooo.com/files/food.jpg','Inventory change mock data','NOT000003'),
	('84c56a7c-7753-4a44-9b95-ac7278c7b24f','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','0a5c236e-ff54-449e-834c-99c113b3b582','CHANGE','https://reinir.mooo.com/files/food.jpg','Inventory change mock data','NOTE000004');
	
/*
INSERT INTO inventory_note_item
	
	(inventory_note_id,
	product_in_store_id,
	stock_change,
	before_change)

VALUES
	
	('69c89ae3-3d7f-44a1-bdcc-98df64f39486',
	'572d8467-2e33-416c-baa6-9da8b25ceedd',
	10,
	20),
	
	('69c89ae3-3d7f-44a1-bdcc-98df64f39486',
	'572d8467-2e33-416c-baa6-9da8b25ceedd',
	10,
	20),
*/
	
	
	
	COMMIT;
