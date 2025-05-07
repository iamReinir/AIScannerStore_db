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

INSERT INTO product_in_store (
	product_in_store_id,
	store_id,
	product_id,
	price,
	stock)
VALUES
    ('572d8467-2e33-416c-baa6-9da8b25ceedd', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789001', 19900, 30),
    ('963c6740-5e92-4b5c-9c9a-d8bed451e429', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789002', 20900, 30),
    ('01dfcc2c-c7c0-4a40-bab9-7e5d49be7ef9', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789003', 18900, 30),
    ('fffc5db9-dc6e-43e8-9b29-8b500791f35f', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789004', 19900, 30),
    ('d64fbd56-f9b3-4788-a6e9-f3e5a480e6f8', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789005', 19900, 30),
    ('1566d6e1-0c10-4794-886b-f15cb1a7a74d', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789006', 19900, 30),
    ('a9d09d7e-e7f9-440b-a7aa-fe023d8730fb', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789007', 12900, 30),
    ('347f8b62-1bb0-495f-998d-0ffeee470d0a', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789008', 11900, 30),
    ('4d60e994-87cf-445f-9015-0951998157df', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789009', 17900, 30),
    ('a6a3d453-de6d-4905-940d-f4d2ad2cd7f4', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789010', 15900, 30),
    ('6c2b5115-ae28-44de-8f05-e6f796947d09', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789011', 12900, 30),
    ('003e474d-e5e6-47fd-ab3d-95ac358560da', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789012', 19900, 30),
    ('c4612c3a-e977-4597-bf6d-9ca23a60fdd5', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789013', 25900, 30),
    ('953c8077-a15e-431a-a238-64966ff0a414', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789014', 14900, 30),
    ('aab9c027-b1e2-490c-9d73-29f845d4671f', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789015', 10900, 30),
    ('a8698aa1-b1ad-4d15-a23c-acd0300e9c00', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789016', 11900, 30),
    ('81bb0fc4-039c-464d-a744-8f2267458e36', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789017', 12900, 30),
    ('aa923b69-5fdb-40fe-ab56-decda440330f', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789018', 28900, 30),
    ('cc544259-6cc3-48d0-ba1b-da22715c6f2b', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789019', 17900, 30),
    ('864e02dd-eb66-4af3-9873-e7606d9ccdde', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789020', 19900, 30),
    ('ad9c2c20-8da2-47a0-831d-94a69cc424c2', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789021', 18900, 30),
    ('bbb3df82-488a-41ea-8e76-ab69f3b1e75e', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789022', 15900, 30),
    ('c1acbd31-f1f9-4e71-bcd7-3984ff849738', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789023', 20900, 30),
    ('cdc6f452-bb70-4c86-9e4f-7a49fc335f17', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'a1b2c3d4-5678-90ab-cdef-123456789024', 17900, 30);


INSERT INTO product_in_store (
	product_in_store_id,
	store_id,
	product_id,
	price,
	stock)
VALUES
    ('ac59681b-71e3-47f2-b77e-4ddc2fe2e0c4', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789001', 16900, 30),
    ('8b3ca2b2-3e30-4b4a-994c-84c1e4a916c9', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789002', 16900, 30),
    ('05ec7896-a8e4-4a74-99fe-51e81ab12a3d', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789003', 15900, 30),
    ('1e623b3b-5581-48d3-86f4-a27f8907846a', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789004', 10900, 30),
    ('a0a11812-fcf5-4ca2-b6cc-7621d9221262', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789005', 17900, 30),
    ('1e2363ad-4b23-44a7-84cb-87dd1e269819', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789006', 18900, 30),
    ('6361db86-aa32-439d-8916-9528a9fc532c', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789007', 13900, 30),
    ('258c55ea-46c1-486f-a69c-dc32b331b361', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789008', 12900, 30),
    ('343ace46-1312-4e03-8eee-d85cc412b288', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789009', 14900, 30),
    ('abf396de-0f69-46c6-88e3-a0d45bac9109', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789010', 14900, 30),
    ('0de0f1fb-31ee-4941-b65e-ec5a2b18542e', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789011', 13900, 30),
    ('eb7f09a8-af0e-460b-aae0-00d48f31b4d8', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789012', 10900, 30),
    ('75425f53-c4c3-4b5b-9cd0-8532279a74be', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789013', 26900, 30),
    ('7828b3dc-a23f-4fb2-ada6-cd4e1f484792', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789014', 13900, 30),
    ('5e05a556-a638-41f1-a53f-a60e81612ef0', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789015', 11900, 30),
    ('20d87da2-005e-4108-b773-974ee924ece8', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789016', 12900, 30),
    ('ce6811b5-0060-4926-8c70-a23b6c5524ad', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789017', 11900, 30),
    ('1c96f3b3-6552-4208-9619-1173c53829eb', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789018', 20900, 30),
    ('c5b30347-1f7c-476c-8cc9-5b3ec4771894', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789019', 18900, 30),
    ('c933ef2a-bfee-4830-ad45-cf280a7844b3', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789020', 30900, 30),
    ('4d542f81-000c-469e-8404-bcc770ac1ca6', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789021', 19900, 30),
    ('e2dcd193-5d5b-4f02-bec6-406aae98ccb6', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789022', 26900, 30),
    ('98ce05b5-a214-4ede-86ca-293f5a79b03b', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789023', 21900, 30),
    ('bf61e311-a78d-440b-9250-642f263ecf89', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'a1b2c3d4-5678-90ab-cdef-123456789024', 28900, 30);

INSERT INTO product_in_store (
	product_in_store_id,
	store_id,
	product_id,
	price,
	stock)
VALUES
    ('b1ec4776-2858-4c6e-9f00-ac151720038c', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789001', 27900, 30),
    ('51dcdb35-5ff5-4bcb-8c7b-daea75553501', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789002', 19900, 30),
    ('6a9c6e15-d136-4fb1-8e1e-cd39aa5d314a', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789003', 17900, 30),
    ('314630ec-1543-451a-aee9-5310331843fe', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789004', 18900, 30),
    ('75c07dc1-46f1-4ab9-a5a9-113059924c75', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789005', 18900, 30),
    ('9b584d2c-61f2-4618-855e-51f5cefc0598', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789006', 16900, 30),
    ('ec580d71-68fc-4476-806c-edcf47f21f45', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789007', 21900, 30),
    ('d7ba5c75-979a-4e87-85ac-7f2e787e25af', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789008', 20900, 30),
    ('8179ac3b-91eb-4bd3-a3a6-391c48a63c87', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789009', 35900, 30),
    ('71e1297c-8a25-4f25-9040-34439ba81bd1', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789010', 14900, 30),
    ('7b09061c-ff4d-43eb-9540-8d3cd16b36f9', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789011', 11900, 30),
    ('b38782f6-9ec5-47a8-966b-a5ae02f146fd', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789012', 28900, 30),
    ('003b2606-7e90-4e43-b688-b848cac7be1d', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789013', 25900, 30),
    ('16b22e21-399f-4c10-8832-84a2e90942ac', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789014', 32900, 30),
    ('5b6acece-51b1-432b-8b23-b472b48524f0', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789015', 30900, 30),
    ('b85b515e-df14-49e9-b19c-c3b3cdb7329c', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789016', 31900, 30),
    ('060eff79-093f-4ef0-89c4-79b34fc1fbd4', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789017', 30900, 30),
    ('6d0e10ca-51f4-4c0c-8fec-c5cf5161affc', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789018', 28900, 30),
    ('55340c2d-07af-4de3-98e4-f61ec67fae82', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789019', 26900, 30),
    ('b71df378-4d40-4047-88bd-d9a51bb05b1a', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789020', 18900, 30),
    ('a7d3b610-fd37-459f-bab8-19a2dfaea15a', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789021', 27900, 30),
    ('1cb5afb4-34de-465e-8723-ce77a7cadd0c', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789022', 24900, 30),
    ('3c442843-d5cd-4f31-a0cb-9af7b3c8f086', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789023', 29900, 30),
    ('f05774a6-a890-49e1-928c-d4bcf9578743', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'a1b2c3d4-5678-90ab-cdef-123456789024', 27900, 30);


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
	 ('f85c2313-bde6-49db-9251-e9b3c90ffe0f','24962082-ea1a-4829-8a9d-bb35118649a1','a1b2c3d4-5678-90ab-cdef-123456789016',2,31900.00,'2025-03-10 19:01:58.029044','2025-03-10 19:01:58.029044',false,false);INSERT INTO deposit (deposit_id, customer_id, amount, status, code) VALUES
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
	 ('01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,'7d793037-a124-486c-91f8-49a8b8b4f9da'::uuid,145000.00,1,'BONUS','2025-04-09 16:13:52.516254',NULL,'2025-04-09 08:08:38.986548','2025-04-09 08:13:52.516677',false,false),
	 ('9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,'7d793037-a124-486c-91f8-49a8b8b4f9da'::uuid,1000000.00,0,'MAIN',NULL,NULL,'2025-04-08 15:41:57.024047','2025-04-09 08:13:52.5167',false,false);


INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('14905ae5-075d-4af6-b465-0dc7d1f1a20f'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,500000.00,'DEPOSIT','Deposit on 4/9/2025 8:08:39 AM',NULL,'01961816-c62c-7d8f-b5ba-dd091a29e0b5'::uuid,NULL,'2025-04-09 08:08:39.067308','2025-04-09 08:08:39.067308',false,false),
	 ('d0b51101-d121-4eae-a92f-e61612b7662d'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,72500.00,'DEPOSIT','Promotion Deposit on 4/9/2025 8:08:39 AM',NULL,'01961816-c62c-7d8f-b5ba-dd091a29e0b5'::uuid,NULL,'2025-04-09 08:08:39.037444','2025-04-09 08:08:39.037444',false,false),
	 ('93694623-e3d1-493b-b766-6cfed93d577a'::uuid,'9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15'::uuid,500000.00,'DEPOSIT','Deposit on 4/9/2025 8:13:52 AM',NULL,'0196181b-b80d-722e-ba49-61c408ed7dc7'::uuid,NULL,'2025-04-09 08:13:52.516687','2025-04-09 08:13:52.516687',false,false),
	 ('c95609c8-a5b2-464b-ba99-06a50b644975'::uuid,'01961817-8dcc-73bf-ae11-781504cc77a5'::uuid,72500.00,'DEPOSIT','Promotion Deposit on 4/9/2025 8:13:52 AM',NULL,'0196181b-b80d-722e-ba49-61c408ed7dc7'::uuid,NULL,'2025-04-09 08:13:52.516261','2025-04-09 08:13:52.516261',false,false);
	 
INSERT INTO vnp_transaction (vnp_transaction_id,deposit_id,ref_payment_id,is_success,description,"timestamp",ref_vnpay_transaction_id,payment_method,vnp_payment_response_code,bank_transaction_status_code,bank_code,bank_transaction_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('f4e127b7-374f-4045-8111-1019b0fe27bc'::uuid,'01961816-c62c-7d8f-b5ba-dd091a29e0b5'::uuid,'638797828678844438',true,'01961816-c62c-7d8f-b5ba-dd091a29e0b5','2025-04-09 08:08:42','14896686','ATM','Code_00.Giao dịch thành công','Code_00.Giao dịch thành công','NCB','VNP14896686',NULL,'2025-04-09 08:08:38.906219','2025-04-09 08:08:38.906221',false,false),
	 ('3732401f-fa2e-4893-b6dd-829cff7539ce'::uuid,'0196181b-b80d-722e-ba49-61c408ed7dc7'::uuid,'638797831919494934',true,'0196181b-b80d-722e-ba49-61c408ed7dc7','2025-04-09 08:13:57','14896690','ATM','Code_00.Giao dịch thành công','Code_00.Giao dịch thành công','NCB','VNP14896690',NULL,'2025-04-09 08:13:52.511164','2025-04-09 08:13:52.511166',false,false);

	 
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
