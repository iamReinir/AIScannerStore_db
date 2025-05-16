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
	image_url VARCHAR(255),
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
);CREATE TABLE order_edit_request (
    request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
	order_id UUID NOT NULL,
	replier_id UUID,
	request_content TEXT,
	reply_content TEXT,
	reply_date TIMESTAMP,
	STATUS VARCHAR(50) NOT NULL,
	CONSTRAINT fk_edit_request_of_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id) ON DELETE CASCADE,
		CONSTRAINT fk_edit_request_for_order FOREIGN KEY (order_id)
        REFERENCES "order"(order_id) ON DELETE CASCADE,
	CONSTRAINT fk_staff_answer_edit_request FOREIGN KEY (replier_id)
        REFERENCES staff(staff_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);INSERT INTO category (category_id, category_name, category_description, code) VALUES
('f1a2b3c4-5678-90ab-cdef-123456789001', 'Bread & Pastries', 'A selection of freshly baked bread, croissants, and sandwiches.', 'CATE09877665523'),
('f1a2b3c4-5678-90ab-cdef-123456789002', 'Cakes & Desserts', 'Delicious cakes, muffins, and pastries for any occasion.', 'CATE012125125'),
('f1a2b3c4-5678-90ab-cdef-123456789003', 'Soft Drinks & Energy Drinks', 'Carbonated beverages and energy drinks for a refreshing boost.', 'CATE0987323223'),
('f1a2b3c4-5678-90ab-cdef-123456789004', 'Alcoholic Drinks', 'A variety of beers and other alcoholic beverages.', 'CATE0235365523'),
('f1a2b3c4-5678-90ab-cdef-123456789005', 'Bottled Water', 'Clean and refreshing bottled water for hydration.', 'CATE03532343'),
('f1a2b3c4-5678-90ab-cdef-123456789006', 'Packaging & Containers', 'Various drink packaging such as bottles and cans.', 'CATE098745233');


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
('a1b2c3d4-5678-90ab-cdef-123456789014', '1'),
('a1b2c3d4-5678-90ab-cdef-123456789015', '2'),
('a1b2c3d4-5678-90ab-cdef-123456789016', '3'),
('a1b2c3d4-5678-90ab-cdef-123456789017', '4'),
('a1b2c3d4-5678-90ab-cdef-123456789018', '5'),
('a1b2c3d4-5678-90ab-cdef-123456789019', '6'),
('a1b2c3d4-5678-90ab-cdef-123456789020', '7'),
('a1b2c3d4-5678-90ab-cdef-123456789021', '8'),
('a1b2c3d4-5678-90ab-cdef-123456789022', '9'),
('a1b2c3d4-5678-90ab-cdef-123456789023', '10'),
('a1b2c3d4-5678-90ab-cdef-123456789024', '11');

INSERT INTO store (
    store_id,
    store_name,
    store_location,
	code,
	image_url
) 
VALUES
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'SuperMart Downtown', '123 Main Street, Downtown', 'STOR000001', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'QuickShop Central', '456 Center Avenue, Central', 'STOR000002', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'MegaStore North', '789 North Road, Uptown', 'STOR000003', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444', 'BudgetMart East', '321 East Lane, Eastside', 'STOR000004', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('e5b3c2f1-2d75-4f3a-9a21-3b4a1c8f5555', 'ValueShop West', '654 West Street, Westend', 'STOR000005', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('f6c4e1a7-1b63-41c2-bf82-2f1c7a5b6666', 'Neighborhood Market', '987 South Avenue, Southside', 'STOR000006', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('a7d2b5c3-6f14-49c2-9f31-7a1c4b2f7777', 'FreshMart Hills', '159 Hills Road, Hilltop', 'STOR000007', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('b8e1c3f7-4a62-48d2-bf41-1c7a2b8f8888', 'GreenLeaf Organic', '753 Garden Street, Greenfield', 'STOR000008', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('c9f7a2d1-3b81-4e2a-bf24-4a1c5b7f9999', 'Urban Market', '246 City Center Blvd, Midtown', 'STOR000009', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('d0a5e4c8-2b17-4f3a-bc52-3f1a7c2f0000', 'Family Grocery', '369 Maple Avenue, Riverside', 'STOR000010', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('f47ac10b-58cc-4372-a567-0e02b2c3d479', 'Downtown Market', '123 Main Street, Downtown', 'STOR000011', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('9c858901-8a57-4791-81fe-4c455b099bc9', 'Uptown Grocery', '456 Elm Street, Uptown', 'STOR000012', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('3fa85f64-5717-4562-b3fc-2c963f66afa6', 'Central Plaza Store', '789 Oak Avenue, Central Plaza', 'STOR000013', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('16fd2706-8baf-433b-82eb-8c7fada847da', 'Riverside Mart', '321 River Road, Riverside', 'STOR000014', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png'),
    ('7c9e6679-7425-40de-944b-e07fc1f90ae7', 'Hilltop Supplies', '654 Pine Street, Hilltop', 'STOR000015', 'https://images2.thanhnien.vn/Uploaded/nthanhluan/2023_01_14/picture1-9615.png');

INSERT INTO pos_device (device_id,store_id,hashed_token,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('0b75b5e2-444f-4b0d-8742-ccdb20ae2e0e'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEIVwvAMb4g3A11p5V5UYWqlsZh53mCqqUvx3Bg/zVrkQjaJnCTYVZplZ/7t46DgOMQ==','2025-05-08 10:12:24.948182','STORE1_DEV4','2025-04-08 10:09:51.619462','2025-04-08 10:12:05.611998',false,false),
	 ('3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEGEux9TAcCmeyB8Sq/TC/41kda4KrvKnJ3lVsnAhtP4NZJK1hSc0Mewx1hnUhXZtmA==','2025-05-08 10:28:51.850073','TEST_DEV_1','2025-04-04 11:59:46.41674','2025-04-08 10:28:51.850082',false,false),
	 ('543be31d-eb6e-43fa-be7c-f8b3dcde0f70'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEPOQfuw0KDXV/IUB7qGLXaQq3W0K7m9fk4B0D+hgcBOcrij1Ago7HoekGUrBsZz4aA==','2025-05-08 10:27:45.385024','STORE1_DEV1','2025-04-08 09:56:11.436709','2025-04-08 10:27:45.385189',false,false),
	 ('625f0c18-2248-4991-82ff-f7add17302d9'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEOOsqIZxmarEQfDV8jc6oD7Y1VMPXktJXHtmsufXnT7E2kwFuV+j5SEv+AuxGP3bbA==','2025-05-08 08:48:43.573576','TRUNG1','2025-04-08 08:37:06.335411','2025-04-08 08:48:43.573974',false,false),
	 ('e5de17a0-4754-4195-b14e-dfd3653a6139'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEEi9Gjzfv2fqR0lxnSWplsoiDXNLMPlzEVCX8cEpErjjO6W878N9peb5a3zvYz47Kg==','2025-05-08 10:32:42.363662','STORE1_DEV3','2025-04-08 10:08:43.527947','2025-04-08 10:32:42.363666',false,false),
	 ('3fa85f64-5717-4562-b3fc-2c963f66a002'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEOUSp+LCpmkU+M7jx41Zd2Z0IxANdL7rDgrD5GuEnrmR/gNN7IJe2UfLg/oKLMKNSw==','2025-05-08 10:32:52.573886','TEST_DEV_2','2025-04-04 11:59:46.41674','2025-04-08 10:32:52.5739',true,false),
	 ('4f03b994-3900-41ed-859a-2b913ade4dcb'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEIx7PQvTZ7QISAio7ms1Qz/FwIQIi326MqSkH/GwoFbzAEbbVgPbK5UiVFHQE6FwPQ==','2025-05-08 09:34:35.269049','TRUNG2','2025-04-08 09:22:06.630657','2025-04-08 09:34:35.269065',false,false),
	 ('3fa85f64-5717-4562-b3fc-2c963f66a003'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEPbVD/Idxlc/vu1z8doMpicImrJmH86k19FQiRDTwSNtcJaXs+f1BnCwTMaH+QjkzQ==','2025-05-08 10:32:55.725334','TEST_DEV_3','2025-04-04 11:59:46.41674','2025-04-08 10:32:55.725339',true,false),
	 ('b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'AQAAAAIAAYagAAAAEMIl/sG/7QChYsOkTm6wa4PnHz2qPr6cCBDVOZ3yHm5ZzdGvUb2ZEV7c7c5hIL5AkA==','2025-05-08 10:08:33.284367','STORE1_DEV2','2025-04-08 09:59:13.334279','2025-04-08 10:08:33.289',false,false),
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
	 
INSERT INTO pos_device (device_id,store_id,hashed_token,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('a33cfc20-a4b2-46b2-a00b-1e71b23b1d6a'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'AQAAAAIAAYagAAAAEGtDK2bVGIixDnaTXv/h1hNOP6oLwQXefytgBWnvAo4PEYCDru08mwpqt5DONsaWYw==','2025-05-22 00:02:47.464758','POS00000002','2025-04-22 00:02:47.321867','2025-04-22 00:02:47.464818',false,false);

INSERT INTO staff (staff_id, staff_name, staff_phone, staff_email, "role", password_hash, store_id, code) 
    VALUES
    ('0a5c236e-ff54-449e-834c-99c113b3b582', 'Alice Johnson', '123-456-7890', 'alice.johnson@example.com', 'STORE_MANAGER','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'f47ac10b-58cc-4372-a567-0e02b2c3d479', 'STAF092193842'),
    ('6d4b69f1-bc1f-41d1-b105-e12e0b45d7f0', 'Bob Smith', '987-654-3210', 'bob.smith@example.com', 'STAFF','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', '9c858901-8a57-4791-81fe-4c455b099bc9', 'STAF247757283'),
    ('86e3635b-f1d4-4e98-b30b-095c7d32b42b', 'Clara Lee', NULL, 'clara.lee@example.com', 'STAFF','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', '3fa85f64-5717-4562-b3fc-2c963f66afa6', 'STAF293829510'),
    ('4ce18af5-130c-44ed-ba84-38a4411fdf95', 'NghiaNT', NULL, 'nghiant@aistore.com', 'IT_HD', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'STAF293848292'),
    ('d8d0e33a-a490-4fce-beee-fcad5eaef9a3', 'TrungNX', NULL, 'trungnx@aistore.com', 'IT_HD', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'STAF222394028'),
	('d8d0e33a-a490-4fce-beee-fcad5eaef9a4', 'TrungNX', NULL, 'blackwhitenxt@gmail.com', 'STORE_MANAGER', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'STAF29382910')
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

INSERT INTO product_in_store (product_in_store_id,store_id,product_id,price,stock,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('7a2379ca-4556-4646-9030-9ad551a6f82e'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789002'::uuid,5000.00,29,'PROD822904250411','2025-04-11 14:17:00.444257','2025-04-11 15:02:24.225565',false,false),
	 ('038dafc0-21ca-4860-b8a4-c2d7ea1d778e'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,11400.00,28,'PROD492843250411','2025-04-11 14:20:01.647572','2025-04-11 15:02:37.533978',false,false),
	 ('4da7a14e-1f35-42b8-b570-82bd6ec4abf3'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789001'::uuid,13700.00,28,'PROD522484250411','2025-04-11 14:17:13.498711','2025-04-11 15:02:37.533997',false,false),
	 ('b2c0d70b-0add-4f87-baa1-a86798e3c2e3'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789010'::uuid,10000.00,29,'PROD822934250411','2025-04-11 14:16:47.052107','2025-04-11 15:02:59.641836',false,false),
	 ('4bf8b89c-fba4-4954-8ab9-cee059b97b1f'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789022'::uuid,12000.00,26,'PROD047228250411','2025-04-11 14:21:15.835049','2025-04-11 15:03:06.826839',false,false),
	 ('fe0136c7-7f19-4889-b5e9-965dde2ea6d9'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789005'::uuid,8000.00,27,'PROD358469250411','2025-04-11 14:19:13.66795','2025-04-11 15:03:06.826865',false,false),
	 ('83da7102-bb37-42f3-b14a-784b3d820c47'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789006'::uuid,10000.00,30,'PROD992458250411','2025-04-11 14:19:26.799202','2025-04-11 14:34:41.356942',false,false),
	 ('1067802d-ca9d-46c7-8301-0d1391fc4b5e'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,8700.00,28,'PROD730292250411','2025-04-11 14:21:30.719081','2025-04-11 15:03:12.147348',false,false),
	 ('821d7427-cc07-4d9b-9dde-dea596a1e54c'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789009'::uuid,10000.00,29,'PROD276831250411','2025-04-11 14:17:55.332977','2025-04-11 15:03:12.147326',false,false),
	 ('0c3b8981-1424-4541-9b19-a202b5db46d9'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789018'::uuid,11000.00,30,'PROD285634250411','2025-04-11 14:19:42.678896','2025-04-11 14:27:02.950077',false,false);
INSERT INTO product_in_store (product_in_store_id,store_id,product_id,price,stock,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('d4081bd7-9657-49d5-8b6a-27bb04fc3b3c'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789016'::uuid,14000.00,29,'PROD825399250411','2025-04-11 14:18:45.548971','2025-04-11 15:03:12.147352',false,false),
	 ('40cf7b34-71e9-4d46-af8c-bc1986f1449f'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789011'::uuid,9000.00,30,'PROD335206250411','2025-04-11 14:17:41.357232','2025-04-11 14:34:41.356969',false,false),
	 ('50205dbf-4ee3-47d3-a842-25f783edd435'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789013'::uuid,13000.00,30,'PROD143573250411','2025-04-11 14:16:35.829012','2025-04-11 14:34:41.35695',false,false),
	 ('58fedb73-b9ac-41b1-a8f9-d30575a00356'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789023'::uuid,15000.00,30,'PROD319308250411','2025-04-11 14:18:06.665998','2025-04-11 14:34:41.356975',false,false),
	 ('abb20deb-e6cd-499c-a10a-a09c0933c5e5'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,12200.00,30,'PROD567377250411','2025-04-11 14:18:36.446367','2025-04-11 14:34:41.356963',false,false),
	 ('abf8196e-6ee6-436a-8271-7d9448384f24'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789020'::uuid,15000.00,30,'PROD038796250411','2025-04-11 14:20:20.104552','2025-04-11 14:34:41.356977',false,false),
	 ('be0405d7-a77e-40ab-a559-5e77ea929052'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789019'::uuid,14000.00,30,'PROD053712250411','2025-04-11 14:20:12.974156','2025-04-11 14:34:41.356978',false,false),
	 ('e7908f0d-c961-44a4-9caa-7b2f46677226'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789004'::uuid,7500.00,30,'PROD964071250411','2025-04-11 14:19:05.134674','2025-04-11 14:34:41.356965',false,false),
	 ('fc8aec6a-39a7-4a27-8184-c49b6d833ac6'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789024'::uuid,7500.00,30,'PROD514901250411','2025-04-11 14:17:34.495824','2025-04-11 14:34:41.356795',false,false),
	 ('fc9f5e81-248b-4305-93b4-44908e300175'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789012'::uuid,12000.00,30,'PROD964474250411','2025-04-11 14:16:24.549981','2025-04-11 14:34:41.356958',false,false);
INSERT INTO product_in_store (product_in_store_id,store_id,product_id,price,stock,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('7080fe75-58f5-4e40-b5db-747f7ea5f0aa'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789021'::uuid,12100.00,28,'PROD236986250411','2025-04-11 14:20:34.110515','2025-04-11 14:50:10.192341',false,false),
	 ('d8f53197-ca00-44e8-a5ce-4402c1912c26'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789017'::uuid,13500.00,28,'PROD377475250411','2025-04-11 14:18:56.604038','2025-04-11 14:50:10.192346',false,false);
INSERT INTO customer (customer_id,customer_name,customer_phone,customer_email,image_url,password_hash,is_email_confirmed,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('550e8400-e29b-41d4-a716-446655440000'::uuid,'Alice Johnson','123-456-7890','alice@example.com','','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==',false,'CUST74829301','2025-04-09 14:22:44.906544','2025-04-09 14:22:44.906544',false,false),
	 ('6f9619ff-8b86-d011-b42d-00c04fc964ff'::uuid,'Bob Smith','987-654-3210','bob@example.com','','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==',false,'CUST91827364','2025-04-09 14:22:44.906544','2025-04-09 14:22:44.906544',false,false),
	 ('1b4e28ba-2fa1-11d2-883f-0016d3cca427'::uuid,'Charlie Brown','555-123-4567','charlie@example.com','','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==',false,'CUST50392718','2025-04-09 14:22:44.906544','2025-04-09 14:22:44.906544',false,false),
	 ('110ec58a-a0f2-4ac4-8393-c866d813b8d1'::uuid,'Diana Prince','444-555-6666','diana@example.com','','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==',false,'CUST37482019','2025-04-09 14:22:44.906544','2025-04-09 14:22:44.906544',false,false),
	 ('7d793037-a124-486c-91f8-49a8b8b4f9da'::uuid,'TrungNX','222-333-4444','trungphat555@gmail.com','','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==',false,'CUST83749202','2025-04-09 14:22:44.906544','2025-04-09 14:22:44.906544',false,false),
	 ('f81a5888-7036-4327-892c-68e0f3d47053'::uuid,'NghiaNT','333-555-4444','nghiant@mail.com','','AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==',false,'CUST812322202','2025-04-09 14:22:44.906544','2025-04-09 14:22:44.906544',false,false),
	 ('5aa7eaf8-11ac-4fb6-bab7-062f1dad7c77'::uuid,'Lily Chen','9238323','lily.chen@example.com','','AQAAAAIAAYagAAAAEPnIBCYTyrgrOzy4lB9JCQ9DoP9KGz3d9B9hmzbCYJuK+2Ck2J2MfU8LOc81B0ElXQ==',false,'CUST233530250411','2025-04-11 09:28:33.749368','2025-04-11 09:28:33.749368',false,false),
	 ('6a0e8ec8-2f1c-4ce9-88f1-b4b751e5800c'::uuid,'Marcus Alvarez','9238323','marcus.alvarez@example.com','','AQAAAAIAAYagAAAAEJtvAdwLtYS6H0V2iJ7S3EXwPcwX5nPiIsrorbJ9SnLODRKaZv7VpdzlbdVL5U3sCw==',false,'CUST249981250411','2025-04-11 09:28:55.289921','2025-04-11 09:28:55.289921',false,false),
	 ('ae5a0d4d-4fd2-483c-af80-58d15ff5189f'::uuid,'Priya Kapoor','9238323','priya.kapoor@example.com','','AQAAAAIAAYagAAAAEKqQYs2nDWKoOHpyFtJBySMz1sIUXVVCdA+HbUsRQDyyTVAfXdV1Ug+lriPCKN4Hmg==',false,'CUST142713250411','2025-04-11 09:29:08.123854','2025-04-11 09:29:08.123854',false,false),
	 ('f4c8bc39-d7fa-4909-9277-a131caba555a'::uuid,'Ethan Brooks','9238323','ethan.brooks@example.com','','AQAAAAIAAYagAAAAEPlsoM7irFG05KYp87dKhNf7XkjCrCpAGze3PUR4qvyA29FqUl0rasZJNb+f5LorpA==',false,'CUST672211250411','2025-04-11 09:29:22.408842','2025-04-11 09:29:22.408842',false,false),
	 ('e9191f72-5064-47c4-8e6e-6117cdac05f0'::uuid,'Sofia Romero','9238323','sofia.romero@example.com','','AQAAAAIAAYagAAAAECvl9yysvRt+tBml+p0CwusjG/rbkDO3FV9Da8vWaVGItVzkYa+p6qDs66XY+3WkAA==',false,'CUST302355250411','2025-04-11 09:29:38.27283','2025-04-11 09:29:38.272831',false,false);
INSERT INTO customer (customer_id,customer_name,customer_phone,customer_email,image_url,password_hash,is_email_confirmed,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('78a32ac7-daf4-4f3a-8ddb-74434332ad7e'::uuid,'Jamal Wright','9238323','jamal.wright@example.com','','AQAAAAIAAYagAAAAEB8ZKVhLyx8OBFpXt61QNqhTrOiA5iudca68z1MJvyBq6puwRkLqsgYsZ8RhpABtDQ==',false,'CUST667582250411','2025-04-11 09:29:52.856974','2025-04-11 09:29:52.856974',false,false),
	 ('37357c12-6b44-4630-a5c3-e3269fb3a55d'::uuid,'Naomi Tanaka','9238323','naomi.tanaka@example.com','','AQAAAAIAAYagAAAAEFvAzde/4aC64zx3nNKuRUP6WcU56HBoWCtxJqNaXAw1yptHu+1V+O0T6z4QoZ8IYw==',false,'CUST803038250411','2025-04-11 09:30:09.861437','2025-04-11 09:30:09.861437',false,false),
	 ('5182ce18-3bfd-4936-babb-88dc5fcbcd3a'::uuid,'Leo Müller','9238323','leo.mueller@example.com','','AQAAAAIAAYagAAAAELfLA+Br9TvCPpbm4A3tQDECX4A4j1RFEs70nHVmgQF79i+s3DNG6khFB4WTp46zeA==',false,'CUST802824250411','2025-04-11 09:30:25.704684','2025-04-11 09:30:25.704684',false,false),
	 ('b9795de5-220b-4523-936a-f7235a3b515c'::uuid,'Mateo Costa','9238323','mateo.costa@example.com','','AQAAAAIAAYagAAAAEOThw64EgnMDUSZcnhkcoHIrCYFcZOoL5nVx24v9Fz1zkpXfgDGbvZ1rnO9RNAJQkg==',false,'CUST846977250411','2025-04-11 09:31:01.869037','2025-04-11 09:31:01.869037',false,false),
	 ('00bd5bd5-7850-43d9-9b42-f1214a62e0d2'::uuid,'Clara Nguyen','9238323','clara.nguyen@example.com','','AQAAAAIAAYagAAAAED3DxrEdfbPuJFDcs+1Tw8vn7AAUFDLWCNhSKOInGUSMnFlypLG5hl1rFCytT1IXeQ==',false,'CUST423144250411','2025-04-11 09:33:55.398063','2025-04-11 09:33:55.398063',false,false),
	 ('419bd034-d4c6-4b61-8a0a-7a437334181a'::uuid,'Diego Morales','9238323','diego.morales@example.com','','AQAAAAIAAYagAAAAEL6uo7iCD/I2eNT8UKrElVHV9+TiQGMP8J2FF3/Jz124w901BPlsotptsTwWuQclJw==',false,'CUST227062250411','2025-04-11 09:34:15.797047','2025-04-11 09:34:15.797047',false,false),
	 ('d4ca3921-beb4-4f21-bab5-7c72c1352ca7'::uuid,'Hana Yamada','9238323','hana.yamada@example.com','','AQAAAAIAAYagAAAAEKGKJWNqNd+O3XTPdSnN0R/JlMHI8PukP6kp+KbE3zxM+QpFnWwpPadtmv+wb1hXWQ==',false,'CUST813692250411','2025-04-11 09:34:28.72363','2025-04-11 09:34:28.72363',false,false),
	 ('79092e99-4923-4abd-9850-95bfa3c71ccb'::uuid,'Thomas Dubois','9238323','thomas.dubois@example.com','','AQAAAAIAAYagAAAAEE3MTiWCDDkqW/URLJVpW44lhlFG8pc+6VY5qqHyVMS7fCSeW8qL2SoGAy89Csxs4g==',false,'CUST555741250411','2025-04-11 09:34:48.547534','2025-04-11 09:34:48.547534',false,false),
	 ('1d0430b9-d481-4e69-9daa-f6cc06b4590e'::uuid,'Fatima Ahmed','9238323','fatima.ahmed@example.com','','AQAAAAIAAYagAAAAELwHSgGYdTN1w6MScMSjTL3qU2VyLok62VZv85CSWyyTKz0WEdnNk9bdmej0SaOhRQ==',false,'CUST752676250411','2025-04-11 09:35:04.257623','2025-04-11 09:35:04.257624',false,false),
	 ('dfe46ca8-01ba-471f-b836-055664887607'::uuid,'Jasper Kim','9238323','jasper.kim@example.com','','AQAAAAIAAYagAAAAEJAfZkIPWw89bG8KJNzd1vRYjcXh5CHgGFOJIZSR4wGbeLo1Ejezex5eA/NLT2fzMQ==',false,'CUST852927250411','2025-04-11 09:35:20.503438','2025-04-11 09:35:20.503438',false,false);
INSERT INTO customer (customer_id,customer_name,customer_phone,customer_email,image_url,password_hash,is_email_confirmed,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('328e347e-ac69-422c-a331-145bc77fdd40'::uuid,'Isabella Russo','9238323','isabella.russo@example.com','','AQAAAAIAAYagAAAAEJtukado4RaCqUJzUpdFzUdsrhiRGjTQecd0ComF9vRFRBbR/P2/Omz9i8crOGmaAQ==',false,'CUST715765250411','2025-04-11 09:35:37.992956','2025-04-11 09:35:37.992956',false,false),
	 ('1aecf6f1-157b-40ca-8f26-8ffcd7eb4d1e'::uuid,'Nikhil Sharma','9238323','nikhil.sharma@example.com','','AQAAAAIAAYagAAAAEOaCE3xALO03zJ04A8X/9N44P5yBklFeWdLhxT6QVrKKX0eHrQB7fEFPIZpimr3dEQ==',false,'CUST364563250411','2025-04-11 09:39:31.746768','2025-04-11 09:39:31.746768',false,false),
	 ('2dc3e26a-23e5-4213-b14b-2afd096d7223'::uuid,'Zoe Carter','9238323','zoe.carter@example.com','','AQAAAAIAAYagAAAAEAbHclFb9paT7D2rEAETKo4MvNmMjRBMdmz36JdWEHq7snfBaxs9Tog1OJWr0jG4tA==',false,'CUST452799250411','2025-04-11 09:39:48.20288','2025-04-11 09:39:48.20288',false,false),
	 ('810b2ef1-ea52-45c6-bdff-ddc729132b80'::uuid,'Henrik Lindberg','9238323','henrik.lindberg@example.com','','AQAAAAIAAYagAAAAEKPAcYW3ZH7rLegGADNQLH+Po0QhyKtjFRuCEQc0qYWTREB/8KgvtGYAjphbGILSWQ==',false,'CUST236823250411','2025-04-11 09:40:01.667783','2025-04-11 09:40:01.667783',false,false);


INSERT INTO customer (customer_id, customer_name, customer_phone, customer_email, image_url, password_hash, code) VALUES
('65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 'Lợi Nguyễn', '1234567', 'dongloi2504@gmail.com', '', 'AQAAAAIAAYagAAAAEO4oH0xNjb5agvpL1sPzytxzqq0Yz1UxApqBWKzxgDyDvLNW4N+8HHH7JSQWfNykTw==', 'CUST29574382');INSERT INTO card (card_id, customer_id, expiration_date, "type")
VALUES 
    ('a1b2c3d4-e5f6-4789-abcd-1234567890ab', '550e8400-e29b-41d4-a716-446655440000', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('b2c3d4e5-f6a7-4890-bcde-2345678901bc', '6f9619ff-8b86-d011-b42d-00c04fc964ff', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('c3d4e5f6-a7b8-4901-cdef-3456789012cd', '1b4e28ba-2fa1-11d2-883f-0016d3cca427', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('d4e5f6a7-b8c9-4012-def0-4567890123de', '110ec58a-a0f2-4ac4-8393-c866d813b8d1', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('e5f6a7b8-c9d0-4123-ef01-5678901234ef', '7d793037-a124-486c-91f8-49a8b8b4f9da', '2026-01-01 00:00:00', 'VIRTUAL'),
    ('f6a7b8c9-d0e1-4234-f012-6789012345f0', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', '2026-01-01 00:00:00', 'VIRTUAL'),
	('9792d94a-6b63-465a-82f9-914d4a1bc583', 'f81a5888-7036-4327-892c-68e0f3d47053', '2026-01-01 00:00:00', 'VIRTUAL')
	;


INSERT INTO card (card_id, customer_id, expiration_date, "type")
VALUES 
    ('00020080-9900-401c-8990-000200809900', '7d793037-a124-486c-91f8-49a8b8b4f9da', '2026-01-01 00:00:00', 'PHYSICAL'),
	('00020081-1400-4010-8411-000200811400', '65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', '2026-01-01 00:00:00', 'PHYSICAL'),
	('00020082-3500-4014-8532-000200823500', 'f81a5888-7036-4327-892c-68e0f3d47053', '2026-01-01 00:00:00', 'PHYSICAL');INSERT INTO public."order" (order_id,card_id,device_id,staff_id,total,status, code) VALUES
	 ('24962082-ea1a-4829-8a9d-bb35118649a1','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', NULL,1480100.00,'PAID', 'ORDE908129837'),
	 ('ff718dc5-340c-4323-9b95-4391260b16d8','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', NULL,1391200.00,'FINISHED', 'ORDE90811232'),
	 ('67c10684-7479-4e6b-bcb0-1c7ac52b7475','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', '0a5c236e-ff54-449e-834c-99c113b3b582',1215300.00,'EDITED', 'ORDE908121232'),
	 ('307506a4-87a9-418d-97a6-43829f58f90a', NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001', '0a5c236e-ff54-449e-834c-99c113b3b582', 1305300.00,'STAFF_CANCELLED', 'ORDE91232878'),
	 ('3b7605ff-d7c0-4a04-bb2b-0117889f87c6','f6a7b8c9-d0e1-4234-f012-6789012345f0','3fa85f64-5717-4562-b3fc-2c963f66a001', NULL,961800.00,'CANCELLED', 'ORDE901239869'),
	 ('c49c3e2e-ceee-4732-9c5c-aea6fa7594b3', NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001', NULL, 1145500.00,'CREATED', 'ORDE23212916');

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
	 ('81e8d956-c09f-4df8-8fa5-1177342bcede'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,47700.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE282917250409','2025-04-06 00:00:00','2025-04-09 10:01:23.933081',false,false),
	 ('9ade6902-9aca-471f-811b-eb9fb121138d'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE382818250409','2025-03-28 00:00:00','2025-04-09 10:02:51.325177',false,false),
	 ('a51db88a-328c-4890-b029-4ea928e9bf15'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,19900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE792610250409','2025-04-01 00:00:00','2025-04-09 10:05:20.758077',false,false),
	 ('27a79e7b-2c41-4ba9-9362-7d20ccf6d2ed'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,11900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE841315250409','2025-04-05 00:00:00','2025-04-09 10:06:14.212588',false,false),
	 ('ccd7723c-e7bf-43b8-ab94-01e0643cbedf'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,11900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE022724250409','2025-03-24 00:00:00','2025-04-09 10:06:26.741392',false,false),
	 ('f1d7507f-6743-467b-a941-5243714f0e68'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,19900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE486682250409','2025-04-08 00:00:00','2025-04-09 10:06:35.661549',false,false),
	 ('b489d2db-c5fc-466b-888d-c38d7303d4de'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,19900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE741994250409','2025-04-02 00:00:00','2025-04-09 10:14:54.671523',false,false),
	 ('45348a2c-862f-4aa8-961a-2797d369291a'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'CANCELLED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE533020250409','2025-03-18 00:00:00','2025-04-10 00:00:34.779812',false,false),
	 ('0cdea66a-df3c-41c5-8ab8-4980bd55635d'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'CANCELLED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE115458250409','2025-03-23 00:00:00','2025-04-10 00:00:34.779812',false,false),
	 ('ff2e1cbf-cb54-460c-8008-c53105039802'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,41800.00,'CANCELLED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE007423250409','2025-03-31 00:00:00','2025-04-10 00:00:34.779812',false,false);
INSERT INTO "order" (order_id,card_id,device_id,staff_id,old_order_id,total,status,image1,image2,image3,is_flagged,is_correction,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('21241ecb-b14b-42a0-966f-8c13a1368acb'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,0.00,'CANCELLED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE464191250409','2025-03-16 00:00:00','2025-04-10 00:00:34.779812',false,false),
	 ('f90a7e14-22a6-48ae-852b-324cd11b448a'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,11900.00,'CANCELLED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE400546250409','2025-04-08 00:00:00','2025-04-10 00:00:34.779812',false,false),
	 ('5751a689-d04b-4063-b103-d0789f7e226a'::uuid,NULL,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'CANCELLED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE244298250409','2025-03-17 00:00:00','2025-04-10 00:00:34.779812',false,false),
	 ('8b17d112-fbc0-4918-88c3-6c006e9c85d9'::uuid,NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,NULL,NULL,17900.00,'CANCELLED','/images/3339516a-8b65-4826-9f19-88a8d887a271.jpg','/images/3339516a-8b65-4826-9f19-88a8d887a272.jpg','/images/3339516a-8b65-4826-9f19-88a8d887a273.jpg',false,false,'ORDE092475250409','2025-03-20 00:00:00','2025-04-10 00:00:34.779812',false,false),
	 ('809f9633-0e81-4dc4-a388-8c8c847d800a'::uuid,NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,NULL,NULL,47700.00,'CANCELLED','/images/3339516a-8b65-4826-9f19-88a8d887a271.jpg','/images/3339516a-8b65-4826-9f19-88a8d887a272.jpg','/images/3339516a-8b65-4826-9f19-88a8d887a273.jpg',false,false,'ORDE237666250409','2025-04-07 00:00:00','2025-04-11 00:00:34.772504',false,false),
	 ('653432c6-2de3-40c7-a626-af2297dd52a2'::uuid,NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,NULL,NULL,57700.00,'CANCELLED','/images/3339516a-8b65-4826-9f19-88a8d887a271.jpg','/images/3339516a-8b65-4826-9f19-88a8d887a272.jpg','/images/3339516a-8b65-4826-9f19-88a8d887a273.jpg',false,false,'ORDE871474250409','2025-03-23 00:00:00','2025-04-11 00:00:34.772504',false,false),
	 ('c25b85c7-8661-44b2-9100-2396e6c32c08'::uuid,NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,NULL,NULL,11900.00,'CANCELLED','temp/images/3339516a-8b65-4826-9f19-88a8d887a271.jpg','temp/images/3339516a-8b65-4826-9f19-88a8d887a272.jpg','temp/images/3339516a-8b65-4826-9f19-88a8d887a273.jpg',false,false,'ORDE892199250409','2025-03-19 00:00:00','2025-04-11 00:00:34.772504',false,false),
	 ('64f976b5-ff56-42d3-aa11-cbbe09de7ab8'::uuid,NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,NULL,NULL,19900.00,'CANCELLED','https://reinir.mooo.com/files/5311b250-a686-44ad-bbe6-d2c740987fda.jpg','','',false,false,'ORDE760517250409','2025-04-09 00:00:00','2025-04-11 00:00:34.772504',false,false),
	 ('0d685614-f4b8-4021-b09a-fe80097ae7d1'::uuid,NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,NULL,NULL,92500.00,'CANCELLED','https://reinir.mooo.com/files/food.jpg','https://reinir.mooo.com/files/food.jpg','https://reinir.mooo.com/files/food.jpg',false,false,'ORDE563248250409','2025-03-26 00:00:00','2025-04-11 00:00:34.772504',false,false),
	 ('e298b35f-424e-4132-96d4-7cfbef0c999d'::uuid,NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,NULL,NULL,92500.00,'CANCELLED','https://reinir.mooo.com/files/food.jpg','https://reinir.mooo.com/files/food.jpg','https://reinir.mooo.com/files/food.jpg',false,false,'ORDE755160250409','2025-03-29 00:00:00','2025-04-11 00:00:34.772504',false,false);
INSERT INTO "order" (order_id,card_id,device_id,staff_id,old_order_id,total,status,image1,image2,image3,is_flagged,is_correction,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('5e58eb40-1d3c-4348-bb8b-6c8e4c12bf67'::uuid,NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,NULL,NULL,92500.00,'CANCELLED','https://reinir.mooo.com/files/food.jpg','https://reinir.mooo.com/files/food.jpg','https://reinir.mooo.com/files/food.jpg',false,false,'ORDE019606250410','2025-03-22 00:00:00','2025-04-11 00:00:34.772504',false,false),
	 ('6a01b642-c668-4a0c-a1d3-9d9c96fb280a'::uuid,NULL,'3fa85f64-5717-4562-b3fc-2c963f66a001'::uuid,NULL,NULL,47700.00,'CANCELLED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE368601250410','2025-03-26 00:00:00','2025-04-11 00:00:34.772504',false,false),
	 ('4c85443b-c880-487d-b271-93f6c97fbaf1'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,15900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE829263250409','2025-03-25 00:00:00','2025-04-09 10:06:45.492335',false,false),
	 ('90ecead0-ae49-4717-b2ed-9e0d6329f734'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE462421250409','2025-03-23 00:00:00','2025-04-09 10:06:54.666255',false,false),
	 ('7893d725-a670-4018-a56f-376c46fa70f6'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE363499250409','2025-04-02 00:00:00','2025-04-09 10:07:06.923054',false,false),
	 ('49353c3b-7ef7-403e-af1d-9e7d6159ef50'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,36800.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE323669250409','2025-03-16 00:00:00','2025-04-09 10:07:16.842495',false,false),
	 ('b31dd818-0948-4ed9-824e-4ca67aa34759'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,38800.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE695350250409','2025-03-27 00:00:00','2025-04-09 10:07:40.395502',false,false),
	 ('01dee123-4948-4c16-8d07-42fbe02a8da4'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,12900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE126477250409','2025-04-06 00:00:00','2025-04-09 10:09:30.07863',false,false),
	 ('d6e8745f-f353-4ff5-b439-790a1e090e8a'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,37800.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE936620250409','2025-04-01 00:00:00','2025-04-09 10:09:40.210644',false,false),
	 ('450e1abb-d4b4-4916-94a3-2fc688e2cfda'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,33800.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE705039250409','2025-03-23 00:00:00','2025-04-09 10:10:50.686844',false,false);
INSERT INTO "order" (order_id,card_id,device_id,staff_id,old_order_id,total,status,image1,image2,image3,is_flagged,is_correction,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('2d5a3ccb-168c-428c-a42a-1538db744ca0'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,19900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE655914250409','2025-04-07 00:00:00','2025-04-09 10:11:02.093981',false,false),
	 ('26d79d9c-8a22-4315-ace8-56780cf17110'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,62600.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE712459250409','2025-03-23 00:00:00','2025-04-09 10:12:11.332312',false,false),
	 ('11711d74-1de5-4ba3-9dae-b5ce81384213'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,18900.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE179839250409','2025-03-14 00:00:00','2025-04-09 10:13:39.118534',false,false),
	 ('021145a7-918f-4278-b675-796760b1177d'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,37800.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE775606250409','2025-04-03 00:00:00','2025-04-09 10:13:54.247375',false,false),
	 ('e87fe469-da67-4b66-b1b5-f79f737a78e9'::uuid,'e5f6a7b8-c9d0-4123-ef01-5678901234ef'::uuid,'625f0c18-2248-4991-82ff-f7add17302d9'::uuid,NULL,NULL,36800.00,'FINISHED','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg',false,false,'ORDE269140250409','2025-03-31 00:00:00','2025-04-09 10:14:05.238705',false,false);


INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('602950f6-b72b-4905-8a3c-94c5e7f6c46a'::uuid,'81e8d956-c09f-4df8-8fa5-1177342bcede'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789017'::uuid,1,12900.00,'ORDE720145250409','2025-04-06 00:00:00','2025-04-09 10:01:08.952297',false,false),
	 ('89c58f9c-be9e-47dd-9ddc-6ea1b9f7189b'::uuid,'81e8d956-c09f-4df8-8fa5-1177342bcede'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789021'::uuid,1,18900.00,'ORDE673861250409','2025-04-06 00:00:00','2025-04-09 10:01:08.914071',false,false),
	 ('a83e6baa-16b0-42ca-8016-0ec2a9bc75ac'::uuid,'81e8d956-c09f-4df8-8fa5-1177342bcede'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789022'::uuid,1,15900.00,'ORDE665895250409','2025-04-06 00:00:00','2025-04-09 10:01:08.950766',false,false),
	 ('6e9ec237-186d-4b9d-bb72-40af50180ace'::uuid,'9ade6902-9aca-471f-811b-eb9fb121138d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,12900.00,'ORDE044307250409','2025-03-28 00:00:00','2025-04-09 10:02:10.5121',false,false),
	 ('07f99c0b-717b-40ca-9cab-bf5f841646e0'::uuid,'45348a2c-862f-4aa8-961a-2797d369291a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,12900.00,'ORDE417746250409','2025-03-18 00:00:00','2025-04-09 10:04:04.276026',false,false),
	 ('40d615f2-f634-42ae-952a-de3b5929812e'::uuid,'a51db88a-328c-4890-b029-4ea928e9bf15'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789005'::uuid,1,19900.00,'ORDE093190250409','2025-04-01 00:00:00','2025-04-09 10:04:21.235732',false,false),
	 ('529e2162-fe01-4d39-a743-be02c6186a27'::uuid,'27a79e7b-2c41-4ba9-9362-7d20ccf6d2ed'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,1,11900.00,'ORDE865204250409','2025-04-05 00:00:00','2025-04-09 10:06:10.682422',false,false),
	 ('fcc5b9d4-a87a-4d5d-ba26-244a86c3f599'::uuid,'ccd7723c-e7bf-43b8-ab94-01e0643cbedf'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,1,11900.00,'ORDE198888250409','2025-03-24 00:00:00','2025-04-09 10:06:20.861104',false,false),
	 ('4dbb4dc7-b19b-4f4e-8418-ac09509c0390'::uuid,'f1d7507f-6743-467b-a941-5243714f0e68'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789006'::uuid,1,19900.00,'ORDE665361250409','2025-04-08 00:00:00','2025-04-09 10:06:30.364668',false,false),
	 ('5d35c41d-481c-4e5a-a03b-a46e0c38740e'::uuid,'4c85443b-c880-487d-b271-93f6c97fbaf1'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789010'::uuid,1,15900.00,'ORDE609177250409','2025-03-25 00:00:00','2025-04-09 10:06:39.608044',false,false);
INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('fba18ced-add9-4717-a9db-40d275eb7bb9'::uuid,'90ecead0-ae49-4717-b2ed-9e0d6329f734'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789011'::uuid,1,12900.00,'ORDE020091250409','2025-03-23 00:00:00','2025-04-09 10:06:49.290331',false,false),
	 ('756d5ca9-81d5-4ee0-8b24-d502a0ea2f11'::uuid,'0cdea66a-df3c-41c5-8ab8-4980bd55635d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789011'::uuid,1,12900.00,'ORDE789993250409','2025-03-23 00:00:00','2025-04-09 10:06:59.173767',false,false),
	 ('7c1cbf69-0005-46a8-bee0-947a3fafd64c'::uuid,'7893d725-a670-4018-a56f-376c46fa70f6'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,12900.00,'ORDE884694250409','2025-04-02 00:00:00','2025-04-09 10:07:02.724945',false,false),
	 ('a922d1c5-29fa-487d-8901-6d7953a5b3f7'::uuid,'49353c3b-7ef7-403e-af1d-9e7d6159ef50'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789009'::uuid,1,17900.00,'ORDE199520250409','2025-03-16 00:00:00','2025-04-09 10:07:11.388794',false,false),
	 ('ee206561-c664-4460-bd03-d4869aaf1cb9'::uuid,'49353c3b-7ef7-403e-af1d-9e7d6159ef50'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,1,18900.00,'ORDE587213250409','2025-03-16 00:00:00','2025-04-09 10:07:11.388755',false,false),
	 ('ed375c4c-0e79-46b6-93db-6082c5e77683'::uuid,'ff2e1cbf-cb54-460c-8008-c53105039802'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789011'::uuid,1,12900.00,'ORDE979665250409','2025-03-31 00:00:00','2025-04-09 10:07:25.148952',false,false),
	 ('fc027a94-e035-4f05-9768-551f841855a3'::uuid,'ff2e1cbf-cb54-460c-8008-c53105039802'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789018'::uuid,1,28900.00,'ORDE815385250409','2025-03-31 00:00:00','2025-04-09 10:07:25.148906',false,false),
	 ('637b7e53-b1d3-467d-9ef6-e46d9f0ebc59'::uuid,'b31dd818-0948-4ed9-824e-4ca67aa34759'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789021'::uuid,1,18900.00,'ORDE345166250409','2025-03-27 00:00:00','2025-04-09 10:07:33.204274',false,false),
	 ('b70ae4c2-c47f-4b33-8c12-c425cb9e827c'::uuid,'b31dd818-0948-4ed9-824e-4ca67aa34759'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789001'::uuid,1,19900.00,'ORDE296569250409','2025-03-27 00:00:00','2025-04-09 10:07:33.204369',false,false),
	 ('79936223-930c-40e5-8be9-4568b771f285'::uuid,'01dee123-4948-4c16-8d07-42fbe02a8da4'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789011'::uuid,1,12900.00,'ORDE303690250409','2025-04-06 00:00:00','2025-04-09 10:09:22.167709',false,false);
INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('50e2f7cf-f6e5-42e2-9173-619b314892b5'::uuid,'d6e8745f-f353-4ff5-b439-790a1e090e8a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789020'::uuid,1,19900.00,'ORDE244678250409','2025-04-01 00:00:00','2025-04-09 10:09:34.642615',false,false),
	 ('8b5ee517-82cb-4539-a7be-8d36d8be81a0'::uuid,'d6e8745f-f353-4ff5-b439-790a1e090e8a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789009'::uuid,1,17900.00,'ORDE687584250409','2025-04-01 00:00:00','2025-04-09 10:09:34.642717',false,false),
	 ('2c4486d3-3c86-4f21-9d17-f03b49535fde'::uuid,'450e1abb-d4b4-4916-94a3-2fc688e2cfda'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789011'::uuid,1,12900.00,'ORDE710588250409','2025-03-23 00:00:00','2025-04-09 10:10:43.775242',false,false),
	 ('5cb6956f-5c66-45f2-aaa7-4f93eb8ebb70'::uuid,'450e1abb-d4b4-4916-94a3-2fc688e2cfda'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789002'::uuid,1,20900.00,'ORDE225600250409','2025-03-23 00:00:00','2025-04-09 10:10:43.77537',false,false),
	 ('d1d2c0be-0f4a-495f-a40e-582c31e56922'::uuid,'2d5a3ccb-168c-428c-a42a-1538db744ca0'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789006'::uuid,1,19900.00,'ORDE497239250409','2025-04-07 00:00:00','2025-04-09 10:10:56.060286',false,false),
	 ('dc2c747e-dcfe-4251-b2c6-3b77ec6f3512'::uuid,'f90a7e14-22a6-48ae-852b-324cd11b448a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,1,11900.00,'ORDE552483250409','2025-04-08 00:00:00','2025-04-09 10:12:02.205548',false,false),
	 ('3960aeaf-c068-461a-9cd3-1444cbef62ea'::uuid,'26d79d9c-8a22-4315-ace8-56780cf17110'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789020'::uuid,1,19900.00,'ORDE737107250409','2025-03-23 00:00:00','2025-04-09 10:12:06.01449',false,false),
	 ('6e8db141-2f16-4feb-886c-b4d726d3a0ff'::uuid,'26d79d9c-8a22-4315-ace8-56780cf17110'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,2,11900.00,'ORDE128123250409','2025-03-23 00:00:00','2025-04-09 10:12:06.014577',false,false),
	 ('9844a29b-0a5f-45de-a286-ed4dcb3831ec'::uuid,'26d79d9c-8a22-4315-ace8-56780cf17110'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,1,18900.00,'ORDE563952250409','2025-03-23 00:00:00','2025-04-09 10:12:06.0146',false,false),
	 ('a44dcd41-81d0-4e6c-aa98-c2e23fc051e2'::uuid,'11711d74-1de5-4ba3-9dae-b5ce81384213'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,1,18900.00,'ORDE653300250409','2025-03-14 00:00:00','2025-04-09 10:13:22.618646',false,false);
INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('d4f54bcf-77ed-48e1-b239-9cad83aaf2ea'::uuid,'021145a7-918f-4278-b675-796760b1177d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789001'::uuid,1,19900.00,'ORDE152870250409','2025-04-03 00:00:00','2025-04-09 10:13:48.308413',false,false),
	 ('e31aed38-dae5-450e-9e53-65d3c9446b7a'::uuid,'021145a7-918f-4278-b675-796760b1177d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789009'::uuid,1,17900.00,'ORDE439592250409','2025-04-03 00:00:00','2025-04-09 10:13:48.308451',false,false),
	 ('52b24104-18e4-449d-bf6f-27108b72e8e9'::uuid,'e87fe469-da67-4b66-b1b5-f79f737a78e9'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789009'::uuid,1,17900.00,'ORDE424402250409','2025-03-31 00:00:00','2025-04-09 10:13:58.676879',false,false),
	 ('be014357-a9dc-45de-b951-f1810d7bd4d9'::uuid,'e87fe469-da67-4b66-b1b5-f79f737a78e9'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,1,18900.00,'ORDE502903250409','2025-03-31 00:00:00','2025-04-09 10:13:58.676929',false,false),
	 ('a200cd11-2654-44c9-aff2-d5561d9ba77f'::uuid,'5751a689-d04b-4063-b103-d0789f7e226a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,12900.00,'ORDE785255250409','2025-03-17 00:00:00','2025-04-09 10:14:40.16116',false,false),
	 ('63a2e637-dd10-4e02-98b8-7eda4b8f67a8'::uuid,'b489d2db-c5fc-466b-888d-c38d7303d4de'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789006'::uuid,1,19900.00,'ORDE192149250409','2025-04-02 00:00:00','2025-04-09 10:14:48.911137',false,false),
	 ('ceac2ef5-74ce-4cdc-8603-3b3d9f1b867f'::uuid,'8b17d112-fbc0-4918-88c3-6c006e9c85d9'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789009'::uuid,1,17900.00,'ORDE031326250409','2025-03-20 00:00:00','2025-04-09 22:13:20.324788',false,false),
	 ('38e454f9-d942-4604-a35e-74cb53251413'::uuid,'809f9633-0e81-4dc4-a388-8c8c847d800a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789010'::uuid,1,15900.00,'ORDE186726250409','2025-04-07 00:00:00','2025-04-10 06:23:05.913954',false,false),
	 ('92e772de-4ac7-4cc5-94a4-ad01c86650fb'::uuid,'809f9633-0e81-4dc4-a388-8c8c847d800a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789010'::uuid,2,15900.00,'ORDE678041250409','2025-04-07 00:00:00','2025-04-10 06:23:05.91374',false,false),
	 ('3d68d2b9-ffd0-461f-ba45-2472e56aaf36'::uuid,'653432c6-2de3-40c7-a626-af2297dd52a2'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789001'::uuid,1,19900.00,'ORDE587694250409','2025-03-23 00:00:00','2025-04-10 06:28:48.100554',false,false);
INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('6d213866-edcb-47da-9468-d0e17fea2f63'::uuid,'653432c6-2de3-40c7-a626-af2297dd52a2'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,2,18900.00,'ORDE928524250409','2025-03-23 00:00:00','2025-04-10 06:28:48.100491',false,false),
	 ('04b638c1-7dd3-4f63-a430-1f33ba2b0fc5'::uuid,'c25b85c7-8661-44b2-9100-2396e6c32c08'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,1,11900.00,'ORDE375767250409','2025-03-19 00:00:00','2025-04-10 06:34:04.565029',false,false),
	 ('e5af0be9-8a06-4b0d-836a-96d472f9e3d9'::uuid,'64f976b5-ff56-42d3-aa11-cbbe09de7ab8'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789005'::uuid,1,19900.00,'ORDE446183250409','2025-04-09 00:00:00','2025-04-10 06:44:57.829657',false,false),
	 ('2e007658-5a64-4be2-9db3-269498fb47ab'::uuid,'0d685614-f4b8-4021-b09a-fe80097ae7d1'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789001'::uuid,1,19900.00,'ORDE727235250409','2025-03-26 00:00:00','2025-04-10 06:52:33.806248',false,false),
	 ('58c8d599-d0ef-438e-b616-e275f706e086'::uuid,'0d685614-f4b8-4021-b09a-fe80097ae7d1'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,1,18900.00,'ORDE097250250409','2025-03-26 00:00:00','2025-04-10 06:52:33.80635',false,false),
	 ('72e8ef1d-a15a-4f07-9dbc-488fd59363b4'::uuid,'0d685614-f4b8-4021-b09a-fe80097ae7d1'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789002'::uuid,1,20900.00,'ORDE924478250409','2025-03-26 00:00:00','2025-04-10 06:52:33.806297',false,false),
	 ('8d82ca17-0963-41d1-a4aa-f2a85a210c68'::uuid,'0d685614-f4b8-4021-b09a-fe80097ae7d1'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789005'::uuid,1,19900.00,'ORDE989889250409','2025-03-26 00:00:00','2025-04-10 06:52:33.806961',false,false),
	 ('bae426ca-35c4-4424-aaf8-fb0a2d0ac418'::uuid,'0d685614-f4b8-4021-b09a-fe80097ae7d1'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,12900.00,'ORDE067346250409','2025-03-26 00:00:00','2025-04-10 06:52:33.806168',false,false),
	 ('1e46ee74-4014-40c7-b6ca-d5cdf2238aa3'::uuid,'e298b35f-424e-4132-96d4-7cfbef0c999d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,1,18900.00,'ORDE501878250409','2025-03-29 00:00:00','2025-04-10 06:59:31.483666',false,false),
	 ('51616c0c-6bbc-42ed-b7ac-8b0063a1dfb6'::uuid,'e298b35f-424e-4132-96d4-7cfbef0c999d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789001'::uuid,1,19900.00,'ORDE060758250409','2025-03-29 00:00:00','2025-04-10 06:59:31.483582',false,false);
INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('6ae9e42c-a2fc-4fda-a691-35ea09ad09b8'::uuid,'e298b35f-424e-4132-96d4-7cfbef0c999d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,12900.00,'ORDE371766250409','2025-03-29 00:00:00','2025-04-10 06:59:31.483501',false,false),
	 ('71d4cb56-19ef-4789-9470-9c28e544b27d'::uuid,'e298b35f-424e-4132-96d4-7cfbef0c999d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789002'::uuid,1,20900.00,'ORDE569236250409','2025-03-29 00:00:00','2025-04-10 06:59:31.483628',false,false),
	 ('88463022-55bc-4e1c-8a55-19a329f731aa'::uuid,'e298b35f-424e-4132-96d4-7cfbef0c999d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789005'::uuid,1,19900.00,'ORDE672891250409','2025-03-29 00:00:00','2025-04-10 06:59:31.483698',false,false),
	 ('c67ea29f-b0b9-4371-b994-d264ef083ef6'::uuid,'5e58eb40-1d3c-4348-bb8b-6c8e4c12bf67'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789002'::uuid,1,20900.00,'ORDE930498250410','2025-03-22 00:00:00','2025-04-10 07:05:10.076113',false,false),
	 ('cb9952cb-883c-4164-832d-bece139a7aca'::uuid,'5e58eb40-1d3c-4348-bb8b-6c8e4c12bf67'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789005'::uuid,1,19900.00,'ORDE922237250410','2025-03-22 00:00:00','2025-04-10 07:05:10.076177',false,false),
	 ('e07fcccd-cc64-43b2-98bc-f562254ebce9'::uuid,'5e58eb40-1d3c-4348-bb8b-6c8e4c12bf67'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,12900.00,'ORDE166781250410','2025-03-22 00:00:00','2025-04-10 07:05:10.076037',false,false),
	 ('f002c5ec-5cbd-4b3f-925c-3e24f7416683'::uuid,'5e58eb40-1d3c-4348-bb8b-6c8e4c12bf67'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789001'::uuid,1,19900.00,'ORDE758783250410','2025-03-22 00:00:00','2025-04-10 07:05:10.076088',false,false),
	 ('fce2a395-452e-482d-a222-8cd40155d571'::uuid,'5e58eb40-1d3c-4348-bb8b-6c8e4c12bf67'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789003'::uuid,1,18900.00,'ORDE634280250410','2025-03-22 00:00:00','2025-04-10 07:05:10.076151',false,false),
	 ('789239c9-dc2c-4765-91f5-01b5e10a156e'::uuid,'6a01b642-c668-4a0c-a1d3-9d9c96fb280a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789017'::uuid,1,12900.00,'ORDE251614250410','2025-03-26 00:00:00','2025-04-10 07:11:59.258637',false,false),
	 ('acdcf10b-e13b-4bd2-80a9-ed863c99be15'::uuid,'6a01b642-c668-4a0c-a1d3-9d9c96fb280a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789021'::uuid,1,18900.00,'ORDE102514250410','2025-03-26 00:00:00','2025-04-10 07:11:59.258551',false,false);
INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('fc06567f-4c9f-4d2f-ba2c-8f01af4d4348'::uuid,'6a01b642-c668-4a0c-a1d3-9d9c96fb280a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789022'::uuid,1,15900.00,'ORDE553314250410','2025-03-26 00:00:00','2025-04-10 07:11:59.258607',false,false);
	 

INSERT INTO "order" (order_id,card_id,device_id,staff_id,old_order_id,total,status,image1,image2,image3,is_flagged,is_correction,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('d1b0c705-05bf-4c83-a393-1adb3b92a988'::uuid,NULL,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,0.00,'CANCELLED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE655089250411','2025-04-11 01:31:48.406863','2025-04-11 14:46:12.999744',false,false),
	 ('c4401406-bbdd-4d5f-b514-1e84c59f777f'::uuid,NULL,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,0.00,'CANCELLED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE408535250411','2025-04-03 00:44:23.20357','2025-04-11 14:46:34.734052',false,false),
	 ('0af071ed-47b5-4de6-973c-883ba149f7ba'::uuid,NULL,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,0.00,'CANCELLED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE891507250411','2025-04-11 05:56:04.218602','2025-04-11 14:46:48.356447',false,false),
	 ('624818b3-333a-4772-af3a-81af05399f4b'::uuid,NULL,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,0.00,'CANCELLED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE184750250411','2025-04-08 01:53:30.341643','2025-04-11 14:47:14.122404',false,false),
	 ('e9d065e8-5138-4180-98cd-d872dea4cc8a'::uuid,NULL,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,0.00,'CANCELLED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE989988250411','2025-04-01 21:35:06.976689','2025-04-11 14:51:49.152218',false,false),
	 ('d6bd9df9-1d0d-4697-8ae6-06be6458ab9b'::uuid,NULL,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,0.00,'CANCELLED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE671537250411','2025-04-04 23:25:19.989096','2025-04-11 14:59:32.858794',false,false),
	 ('b5e48bac-00a5-4da1-974b-d652a5d75ce1'::uuid,NULL,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,0.00,'CANCELLED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE569702250411','2025-04-02 00:42:51.335254','2025-04-11 15:02:14.678575',false,false),
	 ('3ec45e22-7f8a-4786-b81f-e9ecad66ce89'::uuid,'d4e5f6a7-b8c9-4012-def0-4567890123de'::uuid,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,37600.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE498874250411','2025-04-11 05:56:37.431784','2025-04-11 14:49:55.421233',false,false),
	 ('6e78b3f4-c3fc-43b6-80bf-1b4a326892a2'::uuid,'d4e5f6a7-b8c9-4012-def0-4567890123de'::uuid,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,37600.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE793261250411','2025-04-09 13:59:38.62841','2025-04-11 14:50:10.138672',false,false),
	 ('6dfdda94-6d67-413a-9984-bf390008257d'::uuid,'d4e5f6a7-b8c9-4012-def0-4567890123de'::uuid,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,12000.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE447480250411','2025-04-04 23:58:12.380259','2025-04-11 15:02:10.172968',false,false);
INSERT INTO "order" (order_id,card_id,device_id,staff_id,old_order_id,total,status,image1,image2,image3,is_flagged,is_correction,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('9d3156aa-95ea-48f7-8848-8dd6c59a381f'::uuid,'d4e5f6a7-b8c9-4012-def0-4567890123de'::uuid,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,13000.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE428859250411','2025-04-03 15:20:41.329491','2025-04-11 15:02:24.170396',false,false),
	 ('86d4e542-61b6-48c3-82ae-6b28dc46876e'::uuid,'d4e5f6a7-b8c9-4012-def0-4567890123de'::uuid,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,11400.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE424145250411','2025-04-02 13:41:04.24858','2025-04-11 15:02:31.29671',false,false),
	 ('20fe8fff-27be-43ef-a666-6988a2e18be1'::uuid,'d4e5f6a7-b8c9-4012-def0-4567890123de'::uuid,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,38800.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE333150250411','2025-04-05 14:54:00.104725','2025-04-11 15:02:37.476625',false,false),
	 ('ca6933ad-2578-4962-96e9-5621d5b68a1a'::uuid,'d4e5f6a7-b8c9-4012-def0-4567890123de'::uuid,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,8000.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE253233250411','2025-04-04 15:19:37.784345','2025-04-11 15:02:43.46938',false,false),
	 ('d0c8deaa-ade6-4f90-8505-4cb5024770c0'::uuid,'d4e5f6a7-b8c9-4012-def0-4567890123de'::uuid,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,8700.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE953626250411','2025-04-02 06:31:25.195396','2025-04-11 15:02:53.102934',false,false),
	 ('6dbef0e1-0105-4184-9ea0-d8ac03ee5a59'::uuid,'d4e5f6a7-b8c9-4012-def0-4567890123de'::uuid,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,10000.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE879994250411','2025-04-06 15:16:59.612259','2025-04-11 15:02:59.590588',false,false),
	 ('61a64bb2-c7ed-43fd-8cd7-130d15915b10'::uuid,'d4e5f6a7-b8c9-4012-def0-4567890123de'::uuid,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,20000.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE605825250411','2025-04-04 11:16:30.315592','2025-04-11 15:03:06.783959',false,false),
	 ('cbd56508-5d09-4d80-939e-973f4a258252'::uuid,'d4e5f6a7-b8c9-4012-def0-4567890123de'::uuid,'b91c0b17-5b2c-4cc1-89bd-43eb0d7eedd0'::uuid,NULL,NULL,32700.00,'FINISHED','https://reinir.mooo.com/files/d9e025cd1b92a8ccf183.jpg','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','https://reinir.mooo.com/files/aa06332b0d74be2ae765.jpg',false,false,'ORDE296618250411','2025-04-04 18:59:42.040826','2025-04-11 15:03:12.104851',false,false);

INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('1d86aa71-65b4-4d79-89d9-ec38f8a63504'::uuid,'3ec45e22-7f8a-4786-b81f-e9ecad66ce89'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789021'::uuid,1,12100.00,'ORDE668551250411','2025-04-11 05:56:37.431784','2025-04-11 14:48:08.207268',false,false),
	 ('8643437b-3cbd-4380-b6ae-161f9bee94db'::uuid,'3ec45e22-7f8a-4786-b81f-e9ecad66ce89'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789022'::uuid,1,12000.00,'ORDE015415250411','2025-04-11 05:56:37.431784','2025-04-11 14:48:08.244561',false,false),
	 ('abf843a4-6e29-474e-92c1-dd740bbd9493'::uuid,'3ec45e22-7f8a-4786-b81f-e9ecad66ce89'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789017'::uuid,1,13500.00,'ORDE523488250411','2025-04-11 05:56:37.431784','2025-04-11 14:48:08.24476',false,false),
	 ('9e2bbf2a-1a8a-417a-93ad-6cce9d394659'::uuid,'6e78b3f4-c3fc-43b6-80bf-1b4a326892a2'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789017'::uuid,1,13500.00,'ORDE365989250411','2025-04-09 13:59:38.62841','2025-04-11 14:50:06.914637',false,false),
	 ('c1b0e8a7-f45b-427b-a5b3-595f847c5fe8'::uuid,'6e78b3f4-c3fc-43b6-80bf-1b4a326892a2'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789021'::uuid,1,12100.00,'ORDE399549250411','2025-04-09 13:59:38.62841','2025-04-11 14:50:06.914457',false,false),
	 ('f01f96eb-c9f8-426b-8da9-ccf207a01f70'::uuid,'6e78b3f4-c3fc-43b6-80bf-1b4a326892a2'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789022'::uuid,1,12000.00,'ORDE188971250411','2025-04-09 13:59:38.62841','2025-04-11 14:50:06.914584',false,false),
	 ('15083f4d-3779-49e8-a16c-ba48a303de9d'::uuid,'6dfdda94-6d67-413a-9984-bf390008257d'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789022'::uuid,1,12000.00,'ORDE470664250411','2025-04-04 23:58:12.380259','2025-04-11 15:02:03.893513',false,false),
	 ('5900a5dc-9cab-42f9-bc69-a333e7620590'::uuid,'9d3156aa-95ea-48f7-8848-8dd6c59a381f'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789005'::uuid,1,8000.00,'ORDE135178250411','2025-04-03 15:20:41.329491','2025-04-11 15:02:20.6406',false,false),
	 ('7f832c6f-3394-48f7-87ff-b3daf1cd1d6a'::uuid,'9d3156aa-95ea-48f7-8848-8dd6c59a381f'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789002'::uuid,1,5000.00,'ORDE902465250411','2025-04-03 15:20:41.329491','2025-04-11 15:02:20.640349',false,false),
	 ('ba2abdac-c13c-4cba-b97c-64cab048f9bf'::uuid,'86d4e542-61b6-48c3-82ae-6b28dc46876e'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,11400.00,'ORDE912825250411','2025-04-02 13:41:04.24858','2025-04-11 15:02:27.351908',false,false);
INSERT INTO order_item (order_item_id,order_id,product_id,count,unit_price,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('084428f6-ba62-48cc-a2d5-40d2ed534862'::uuid,'20fe8fff-27be-43ef-a666-6988a2e18be1'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789007'::uuid,1,11400.00,'ORDE018793250411','2025-04-05 14:54:00.104725','2025-04-11 15:02:34.211587',false,false),
	 ('12639d51-299a-45a3-8286-207c216e6c7c'::uuid,'20fe8fff-27be-43ef-a666-6988a2e18be1'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789001'::uuid,2,13700.00,'ORDE004762250411','2025-04-05 14:54:00.104725','2025-04-11 15:02:34.211531',false,false),
	 ('5776330a-3156-4629-8913-7e4940827bec'::uuid,'ca6933ad-2578-4962-96e9-5621d5b68a1a'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789005'::uuid,1,8000.00,'ORDE945762250411','2025-04-04 15:19:37.784345','2025-04-11 15:02:39.834467',false,false),
	 ('16145eac-647d-48f5-8246-29c81c05dd37'::uuid,'d0c8deaa-ade6-4f90-8505-4cb5024770c0'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,1,8700.00,'ORDE907362250411','2025-04-02 06:31:25.195396','2025-04-11 15:02:46.570934',false,false),
	 ('6e8ce180-7153-4439-9d10-093855104e21'::uuid,'6dbef0e1-0105-4184-9ea0-d8ac03ee5a59'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789010'::uuid,1,10000.00,'ORDE701672250411','2025-04-06 15:16:59.612259','2025-04-11 15:02:57.121473',false,false),
	 ('da2bc5f5-e460-42d3-b63d-41f9b3c41518'::uuid,'61a64bb2-c7ed-43fd-8cd7-130d15915b10'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789005'::uuid,1,8000.00,'ORDE255567250411','2025-04-04 11:16:30.315592','2025-04-11 15:03:02.989159',false,false),
	 ('ebf821b2-67c0-4d7e-b4ae-a4dba9c078c9'::uuid,'61a64bb2-c7ed-43fd-8cd7-130d15915b10'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789022'::uuid,1,12000.00,'ORDE205157250411','2025-04-04 11:16:30.315592','2025-04-11 15:03:02.989',false,false),
	 ('4010f7ac-2be0-4132-baa0-38c5f16d8993'::uuid,'cbd56508-5d09-4d80-939e-973f4a258252'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789009'::uuid,1,10000.00,'ORDE742039250411','2025-04-04 18:59:42.040826','2025-04-11 15:03:09.16041',false,false),
	 ('418b2a1f-3959-458c-b8db-d2c2ca9f121f'::uuid,'cbd56508-5d09-4d80-939e-973f4a258252'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789008'::uuid,1,8700.00,'ORDE686143250411','2025-04-04 18:59:42.040826','2025-04-11 15:03:09.160433',false,false),
	 ('a50b3202-8990-4573-b3e2-211150eed81b'::uuid,'cbd56508-5d09-4d80-939e-973f4a258252'::uuid,'a1b2c3d4-5678-90ab-cdef-123456789016'::uuid,1,14000.00,'ORDE471218250411','2025-04-04 18:59:42.040826','2025-04-11 15:03:09.160341',false,false);


INSERT INTO inventory_note (inventory_note_id,store_id,staff_id,"type",image_url,description,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('e4f539f0-d2ba-432a-bcc2-db02961971b9'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'6e9bac05-802d-46c3-9f58-5ce37cfc038e'::uuid,'ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 3ec45e22-7f8a-4786-b81f-e9ecad66ce89','INVE938739250411','2025-04-01 15:22:07.441464','2025-04-11 14:49:55.733002',false,false),
	 ('78274a92-820e-45c8-8be7-b128d09eedb7'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'6e9bac05-802d-46c3-9f58-5ce37cfc038e'::uuid,'ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 6e78b3f4-c3fc-43b6-80bf-1b4a326892a2','INVE383205250411','2025-04-06 20:13:54.179032','2025-04-11 14:50:10.192031',false,false),
	 ('246c94dd-31a4-4948-973b-72e5978af0d5'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'6e9bac05-802d-46c3-9f58-5ce37cfc038e'::uuid,'ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 6dfdda94-6d67-413a-9984-bf390008257d','INVE552521250411','2025-04-07 07:10:52.813136','2025-04-11 15:02:10.222117',false,false),
	 ('9923f581-32cb-48bc-af30-c17e04a61ba0'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'6e9bac05-802d-46c3-9f58-5ce37cfc038e'::uuid,'ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 9d3156aa-95ea-48f7-8848-8dd6c59a381f','INVE507865250411','2025-04-09 19:00:53.367644','2025-04-11 15:02:24.225531',false,false),
	 ('cbc1d5d9-ea79-4418-b9dd-beb695feefbc'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'6e9bac05-802d-46c3-9f58-5ce37cfc038e'::uuid,'ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 86d4e542-61b6-48c3-82ae-6b28dc46876e','INVE833179250411','2025-04-09 03:05:37.35483','2025-04-11 15:02:31.340293',false,false),
	 ('b7fe0188-fc1a-4bc3-a2a8-e10f63a0f504'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'6e9bac05-802d-46c3-9f58-5ce37cfc038e'::uuid,'ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 20fe8fff-27be-43ef-a666-6988a2e18be1','INVE252015250411','2025-04-02 00:49:39.889745','2025-04-11 15:02:37.533866',false,false),
	 ('da2784f3-47cf-4b97-a973-aa3148890e9e'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'6e9bac05-802d-46c3-9f58-5ce37cfc038e'::uuid,'ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order ca6933ad-2578-4962-96e9-5621d5b68a1a','INVE285313250411','2025-04-04 09:48:10.263347','2025-04-11 15:02:43.51636',false,false),
	 ('58d1b2d5-7522-4971-a16e-c060f8d77a27'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'6e9bac05-802d-46c3-9f58-5ce37cfc038e'::uuid,'ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order d0c8deaa-ade6-4f90-8505-4cb5024770c0','INVE027700250411','2025-04-03 12:29:23.60419','2025-04-11 15:02:53.139258',false,false),
	 ('ae442c64-9889-4b8f-be82-f670a4a83f55'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'6e9bac05-802d-46c3-9f58-5ce37cfc038e'::uuid,'ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 6dbef0e1-0105-4184-9ea0-d8ac03ee5a59','INVE724741250411','2025-04-02 07:50:59.314026','2025-04-11 15:02:59.641771',false,false),
	 ('985ac588-5ae6-48f9-be20-756c3cc93919'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'6e9bac05-802d-46c3-9f58-5ce37cfc038e'::uuid,'ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order 61a64bb2-c7ed-43fd-8cd7-130d15915b10','INVE757128250411','2025-04-06 03:22:25.810191','2025-04-11 15:03:06.826768',false,false);
INSERT INTO inventory_note (inventory_note_id,store_id,staff_id,"type",image_url,description,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('e2db2e81-f173-4c50-a44c-aa0e375925ee'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'6e9bac05-802d-46c3-9f58-5ce37cfc038e'::uuid,'ORDER','https://reinir.mooo.com/files/12388714b94b0a15535a.jpg','Deduction for order cbd56508-5d09-4d80-939e-973f4a258252','INVE041916250411','2025-04-05 17:11:39.430197','2025-04-11 15:03:12.147166',false,false);

INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('45f5e103-c812-4e17-a4f9-9be21a6b21c0'::uuid,'e4f539f0-d2ba-432a-bcc2-db02961971b9'::uuid,'4bf8b89c-fba4-4954-8ab9-cee059b97b1f'::uuid,-1,30,'INVE245264250411','2025-04-01 15:22:07.441464','2025-04-11 14:49:55.741241',false,false),
	 ('72d93144-7015-4515-a2bc-e35bc137cfd0'::uuid,'e4f539f0-d2ba-432a-bcc2-db02961971b9'::uuid,'d8f53197-ca00-44e8-a5ce-4402c1912c26'::uuid,-1,30,'INVE303725250411','2025-04-01 15:22:07.441464','2025-04-11 14:49:55.742275',false,false),
	 ('d810613f-d89e-4324-852a-5928894b598d'::uuid,'e4f539f0-d2ba-432a-bcc2-db02961971b9'::uuid,'7080fe75-58f5-4e40-b5db-747f7ea5f0aa'::uuid,-1,30,'INVE106021250411','2025-04-01 15:22:07.441464','2025-04-11 14:49:55.742264',false,false),
	 ('316ac17e-3ef6-4e66-b0aa-b0cd8672c59f'::uuid,'78274a92-820e-45c8-8be7-b128d09eedb7'::uuid,'d8f53197-ca00-44e8-a5ce-4402c1912c26'::uuid,-1,29,'INVE288181250411','2025-04-06 20:13:54.179032','2025-04-11 14:50:10.192344',false,false),
	 ('6847843d-7212-4262-aee4-bb63e2e59635'::uuid,'78274a92-820e-45c8-8be7-b128d09eedb7'::uuid,'7080fe75-58f5-4e40-b5db-747f7ea5f0aa'::uuid,-1,29,'INVE601696250411','2025-04-06 20:13:54.179032','2025-04-11 14:50:10.192335',false,false),
	 ('ecb24711-e157-4267-bc46-0f6013fc3e32'::uuid,'78274a92-820e-45c8-8be7-b128d09eedb7'::uuid,'4bf8b89c-fba4-4954-8ab9-cee059b97b1f'::uuid,-1,29,'INVE749453250411','2025-04-06 20:13:54.179032','2025-04-11 14:50:10.192322',false,false),
	 ('84c63c2f-311c-4b4c-8dcc-7e3f6adbc3bc'::uuid,'246c94dd-31a4-4948-973b-72e5978af0d5'::uuid,'4bf8b89c-fba4-4954-8ab9-cee059b97b1f'::uuid,-1,28,'INVE203972250411','2025-04-07 07:10:52.813136','2025-04-11 15:02:10.222173',false,false),
	 ('3d51ab46-5414-49ab-866a-25eab0737dab'::uuid,'9923f581-32cb-48bc-af30-c17e04a61ba0'::uuid,'7a2379ca-4556-4646-9030-9ad551a6f82e'::uuid,-1,30,'INVE444696250411','2025-04-09 19:00:53.367644','2025-04-11 15:02:24.225561',false,false),
	 ('bdbd283c-6416-41cc-8daa-fa82dc207ff4'::uuid,'9923f581-32cb-48bc-af30-c17e04a61ba0'::uuid,'fe0136c7-7f19-4889-b5e9-965dde2ea6d9'::uuid,-1,30,'INVE983909250411','2025-04-09 19:00:53.367644','2025-04-11 15:02:24.225567',false,false),
	 ('5db2f79c-c3f4-419f-b1bd-8cf6643a5c0a'::uuid,'cbc1d5d9-ea79-4418-b9dd-beb695feefbc'::uuid,'038dafc0-21ca-4860-b8a4-c2d7ea1d778e'::uuid,-1,30,'INVE768138250411','2025-04-09 03:05:37.35483','2025-04-11 15:02:31.340333',false,false);
INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('6922c917-f9ad-4bab-8034-29737bce308a'::uuid,'b7fe0188-fc1a-4bc3-a2a8-e10f63a0f504'::uuid,'038dafc0-21ca-4860-b8a4-c2d7ea1d778e'::uuid,-1,29,'INVE668379250411','2025-04-02 00:49:39.889745','2025-04-11 15:02:37.533966',false,false),
	 ('d9416150-1d6e-4b76-a98c-673e0664b971'::uuid,'b7fe0188-fc1a-4bc3-a2a8-e10f63a0f504'::uuid,'4da7a14e-1f35-42b8-b570-82bd6ec4abf3'::uuid,-2,30,'INVE396705250411','2025-04-02 00:49:39.889745','2025-04-11 15:02:37.533992',false,false),
	 ('3a8c991d-e1e5-4259-aa80-ea1ef93167b0'::uuid,'da2784f3-47cf-4b97-a973-aa3148890e9e'::uuid,'fe0136c7-7f19-4889-b5e9-965dde2ea6d9'::uuid,-1,29,'INVE850588250411','2025-04-04 09:48:10.263347','2025-04-11 15:02:43.516424',false,false),
	 ('efc67e3c-aaf1-4323-a5e0-12c40a19a807'::uuid,'58d1b2d5-7522-4971-a16e-c060f8d77a27'::uuid,'1067802d-ca9d-46c7-8301-0d1391fc4b5e'::uuid,-1,30,'INVE661526250411','2025-04-03 12:29:23.60419','2025-04-11 15:02:53.139298',false,false),
	 ('f0695fff-8ea3-4363-9cd7-09a5e5dd8d72'::uuid,'ae442c64-9889-4b8f-be82-f670a4a83f55'::uuid,'b2c0d70b-0add-4f87-baa1-a86798e3c2e3'::uuid,-1,30,'INVE679423250411','2025-04-02 07:50:59.314026','2025-04-11 15:02:59.641828',false,false),
	 ('1986afcd-7c4a-4180-9d74-0c660e3d4306'::uuid,'985ac588-5ae6-48f9-be20-756c3cc93919'::uuid,'4bf8b89c-fba4-4954-8ab9-cee059b97b1f'::uuid,-1,27,'INVE043527250411','2025-04-06 03:22:25.810191','2025-04-11 15:03:06.826826',false,false),
	 ('b1d641a4-5fc6-4276-81b9-acbc38b4b407'::uuid,'985ac588-5ae6-48f9-be20-756c3cc93919'::uuid,'fe0136c7-7f19-4889-b5e9-965dde2ea6d9'::uuid,-1,28,'INVE219030250411','2025-04-06 03:22:25.810191','2025-04-11 15:03:06.826856',false,false),
	 ('81e58241-ad32-46fb-b4ab-90e9b6280a82'::uuid,'e2db2e81-f173-4c50-a44c-aa0e375925ee'::uuid,'1067802d-ca9d-46c7-8301-0d1391fc4b5e'::uuid,-1,29,'INVE098838250411','2025-04-05 17:11:39.430197','2025-04-11 15:03:12.147341',false,false),
	 ('8813cb04-5a5c-4995-b093-dbec178688ad'::uuid,'e2db2e81-f173-4c50-a44c-aa0e375925ee'::uuid,'821d7427-cc07-4d9b-9dde-dea596a1e54c'::uuid,-1,30,'INVE355279250411','2025-04-05 17:11:39.430197','2025-04-11 15:03:12.147313',false,false),
	 ('d3d5c595-f2c5-43f4-acb9-9ce7974397a3'::uuid,'e2db2e81-f173-4c50-a44c-aa0e375925ee'::uuid,'d4081bd7-9657-49d5-8b6a-27bb04fc3b3c'::uuid,-1,30,'INVE150297250411','2025-04-05 17:11:39.430197','2025-04-11 15:03:12.147351',false,false);
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
	INSERT INTO wallet (customer_id, wallet_id, balance, priority, wallet_type, expire_at) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'e2b7c3f9-5a44-4b1e-9b8d-7f3d2e1a6c75', 7500000.00, 0, 'MAIN', null),
('6f9619ff-8b86-d011-b42d-00c04fc964ff', 'a8c1f2d3-7e5b-42f6-9a9c-1d4e8b3f6c27', 250000.00, 0, 'MAIN', null),
('1b4e28ba-2fa1-11d2-883f-0016d3cca427', 'd4f8a2b9-3e7c-4a1d-8c5f-6b2e9f7a3c81', 100000.00, 0, 'MAIN', null),
('110ec58a-a0f2-4ac4-8393-c866d813b8d1', 'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a', 750000.00, 0, 'MAIN', null),
('f81a5888-7036-4327-892c-68e0f3d47053', '571f7c5b-81e0-40ba-aed3-73d8b49f88ae', 5000.00, 0,  'MAIN', null),
('f81a5888-7036-4327-892c-68e0f3d47053', '6cbbb1f0-ea3d-4d3c-8edf-2b8a4595fa77', 0.00, 1,  'BONUS', NOW() + INTERVAL '6 hours')
;



INSERT INTO wallet (wallet_id,customer_id,balance,priority,wallet_type,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,'5aa7eaf8-11ac-4fb6-bab7-062f1dad7c77'::uuid,0.00,0,'MAIN',NULL,'WALL879401250411','2025-04-11 09:28:35.001906','2025-04-11 09:28:35.001906',false,false),
	 ('019622ad-747f-7ba3-a727-63baaa61f81a'::uuid,'5aa7eaf8-11ac-4fb6-bab7-062f1dad7c77'::uuid,0.00,1,'BONUS',NULL,'WALL454036250411','2025-04-11 09:28:35.002197','2025-04-11 09:28:35.002197',false,false),
	 ('019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,'6a0e8ec8-2f1c-4ce9-88f1-b4b751e5800c'::uuid,0.00,0,'MAIN',NULL,'WALL554993250411','2025-04-11 09:28:55.581726','2025-04-11 09:28:55.581726',false,false),
	 ('019622ad-c49e-7f4b-a771-690d5e6445f8'::uuid,'6a0e8ec8-2f1c-4ce9-88f1-b4b751e5800c'::uuid,0.00,1,'BONUS',NULL,'WALL587808250411','2025-04-11 09:28:55.58175','2025-04-11 09:28:55.58175',false,false),
	 ('019622ad-f707-734a-b182-2c3c42493d63'::uuid,'ae5a0d4d-4fd2-483c-af80-58d15ff5189f'::uuid,0.00,1,'BONUS',NULL,'WALL751480250411','2025-04-11 09:29:08.487015','2025-04-11 09:29:08.487015',false,false),
	 ('019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,'ae5a0d4d-4fd2-483c-af80-58d15ff5189f'::uuid,0.00,0,'MAIN',NULL,'WALL813830250411','2025-04-11 09:29:08.486993','2025-04-11 09:29:08.486993',false,false),
	 ('019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,'f4c8bc39-d7fa-4909-9277-a131caba555a'::uuid,0.00,0,'MAIN',NULL,'WALL713997250411','2025-04-11 09:29:22.743584','2025-04-11 09:29:22.743584',false,false),
	 ('019622ae-2eb8-7ecf-89d0-338dcdac7e29'::uuid,'f4c8bc39-d7fa-4909-9277-a131caba555a'::uuid,0.00,1,'BONUS',NULL,'WALL041084250411','2025-04-11 09:29:22.743646','2025-04-11 09:29:22.743646',false,false),
	 ('019622ae-6ca6-73a0-aa4b-5b47d954818d'::uuid,'e9191f72-5064-47c4-8e6e-6117cdac05f0'::uuid,0.00,1,'BONUS',NULL,'WALL074321250411','2025-04-11 09:29:38.598779','2025-04-11 09:29:38.598779',false,false),
	 ('019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,'e9191f72-5064-47c4-8e6e-6117cdac05f0'::uuid,0.00,0,'MAIN',NULL,'WALL011209250411','2025-04-11 09:29:38.598743','2025-04-11 09:29:38.598743',false,false);
INSERT INTO wallet (wallet_id,customer_id,balance,priority,wallet_type,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('019622ae-a59c-736b-a2ee-00334492e43a'::uuid,'78a32ac7-daf4-4f3a-8ddb-74434332ad7e'::uuid,0.00,0,'MAIN',NULL,'WALL544775250411','2025-04-11 09:29:53.180578','2025-04-11 09:29:53.180578',false,false),
	 ('019622ae-a59c-7f39-8eb9-0a55100ea032'::uuid,'78a32ac7-daf4-4f3a-8ddb-74434332ad7e'::uuid,0.00,1,'BONUS',NULL,'WALL740604250411','2025-04-11 09:29:53.180601','2025-04-11 09:29:53.180601',false,false),
	 ('019622ae-e822-77d0-a300-267c67f7c076'::uuid,'37357c12-6b44-4630-a5c3-e3269fb3a55d'::uuid,0.00,1,'BONUS',NULL,'WALL918508250411','2025-04-11 09:30:10.210412','2025-04-11 09:30:10.210412',false,false),
	 ('019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,'37357c12-6b44-4630-a5c3-e3269fb3a55d'::uuid,0.00,0,'MAIN',NULL,'WALL639350250411','2025-04-11 09:30:10.210389','2025-04-11 09:30:10.210389',false,false),
	 ('019622af-2609-71d6-89e2-2ce0af22728c'::uuid,'5182ce18-3bfd-4936-babb-88dc5fcbcd3a'::uuid,0.00,0,'MAIN',NULL,'WALL290769250411','2025-04-11 09:30:26.057088','2025-04-11 09:30:26.057088',false,false),
	 ('019622af-2609-7a4e-bbbe-849ce77152b5'::uuid,'5182ce18-3bfd-4936-babb-88dc5fcbcd3a'::uuid,0.00,1,'BONUS',NULL,'WALL856985250411','2025-04-11 09:30:26.057143','2025-04-11 09:30:26.057143',false,false),
	 ('019622af-b355-7c15-862a-341ce10ab202'::uuid,'b9795de5-220b-4523-936a-f7235a3b515c'::uuid,0.00,1,'BONUS',NULL,'WALL496473250411','2025-04-11 09:31:02.229464','2025-04-11 09:31:02.229464',false,false),
	 ('019622af-b355-7cd7-bca6-ab4724bbdb72'::uuid,'b9795de5-220b-4523-936a-f7235a3b515c'::uuid,0.00,0,'MAIN',NULL,'WALL493938250411','2025-04-11 09:31:02.22942','2025-04-11 09:31:02.22942',false,false),
	 ('019622b2-58fe-77bd-b71c-e81b7038bab8'::uuid,'00bd5bd5-7850-43d9-9b42-f1214a62e0d2'::uuid,0.00,0,'MAIN',NULL,'WALL319598250411','2025-04-11 09:33:55.710449','2025-04-11 09:33:55.710449',false,false),
	 ('019622b2-58ff-7351-b627-944e5fb8fdac'::uuid,'00bd5bd5-7850-43d9-9b42-f1214a62e0d2'::uuid,0.00,1,'BONUS',NULL,'WALL548069250411','2025-04-11 09:33:55.710475','2025-04-11 09:33:55.710475',false,false);
INSERT INTO wallet (wallet_id,customer_id,balance,priority,wallet_type,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('019622b2-a8b7-7281-ba31-e9e614f580a8'::uuid,'419bd034-d4c6-4b61-8a0a-7a437334181a'::uuid,0.00,0,'MAIN',NULL,'WALL520556250411','2025-04-11 09:34:16.119475','2025-04-11 09:34:16.119475',false,false),
	 ('019622b2-a8b8-7159-b87b-4bf9c89e211d'::uuid,'419bd034-d4c6-4b61-8a0a-7a437334181a'::uuid,0.00,1,'BONUS',NULL,'WALL815962250411','2025-04-11 09:34:16.1195','2025-04-11 09:34:16.1195',false,false),
	 ('019622b2-db4c-723a-be6c-fe01dc8641e8'::uuid,'d4ca3921-beb4-4f21-bab5-7c72c1352ca7'::uuid,0.00,1,'BONUS',NULL,'WALL462239250411','2025-04-11 09:34:29.068006','2025-04-11 09:34:29.068006',false,false),
	 ('019622b2-db4c-74ff-8d58-1715a8348b96'::uuid,'d4ca3921-beb4-4f21-bab5-7c72c1352ca7'::uuid,0.00,0,'MAIN',NULL,'WALL469290250411','2025-04-11 09:34:29.067982','2025-04-11 09:34:29.067982',false,false),
	 ('019622b3-28fb-7925-b908-874cc5e5f8ee'::uuid,'79092e99-4923-4abd-9850-95bfa3c71ccb'::uuid,0.00,0,'MAIN',NULL,'WALL408852250411','2025-04-11 09:34:48.955454','2025-04-11 09:34:48.955454',false,false),
	 ('019622b3-28fb-7fc7-a995-a52ab22a045c'::uuid,'79092e99-4923-4abd-9850-95bfa3c71ccb'::uuid,0.00,1,'BONUS',NULL,'WALL993577250411','2025-04-11 09:34:48.955477','2025-04-11 09:34:48.955478',false,false),
	 ('019622b3-6636-7219-895c-a3ec0cae26d4'::uuid,'1d0430b9-d481-4e69-9daa-f6cc06b4590e'::uuid,0.00,0,'MAIN',NULL,'WALL036881250411','2025-04-11 09:35:04.63003','2025-04-11 09:35:04.63003',false,false),
	 ('019622b3-6636-7b77-a988-148118524e2d'::uuid,'1d0430b9-d481-4e69-9daa-f6cc06b4590e'::uuid,0.00,1,'BONUS',NULL,'WALL624650250411','2025-04-11 09:35:04.630054','2025-04-11 09:35:04.630054',false,false),
	 ('019622b3-a58a-74a1-9e14-e41c0063f8ef'::uuid,'dfe46ca8-01ba-471f-b836-055664887607'::uuid,0.00,0,'MAIN',NULL,'WALL466758250411','2025-04-11 09:35:20.842882','2025-04-11 09:35:20.842882',false,false),
	 ('019622b3-a58b-7351-86cd-27792fa13ff1'::uuid,'dfe46ca8-01ba-471f-b836-055664887607'::uuid,0.00,1,'BONUS',NULL,'WALL755923250411','2025-04-11 09:35:20.842899','2025-04-11 09:35:20.842899',false,false);
INSERT INTO wallet (wallet_id,customer_id,balance,priority,wallet_type,expire_at,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('019622b3-e9a0-71c1-9a05-6c4adafa1f82'::uuid,'328e347e-ac69-422c-a331-145bc77fdd40'::uuid,0.00,0,'MAIN',NULL,'WALL913381250411','2025-04-11 09:35:38.272182','2025-04-11 09:35:38.272182',false,false),
	 ('019622b3-e9a0-7856-9619-244a4e51baf5'::uuid,'328e347e-ac69-422c-a331-145bc77fdd40'::uuid,0.00,1,'BONUS',NULL,'WALL553666250411','2025-04-11 09:35:38.272201','2025-04-11 09:35:38.272202',false,false),
	 ('019622b7-7ad2-77d7-ab4c-02ca97c5685d'::uuid,'1aecf6f1-157b-40ca-8f26-8ffcd7eb4d1e'::uuid,0.00,0,'MAIN',NULL,'WALL917419250411','2025-04-11 09:39:32.050754','2025-04-11 09:39:32.050754',false,false),
	 ('019622b7-7ad3-7155-b16b-8e33ad0e9525'::uuid,'1aecf6f1-157b-40ca-8f26-8ffcd7eb4d1e'::uuid,0.00,1,'BONUS',NULL,'WALL064076250411','2025-04-11 09:39:32.050789','2025-04-11 09:39:32.05079',false,false),
	 ('019622b7-bb43-7bc4-aad2-f7af25f1bedb'::uuid,'2dc3e26a-23e5-4213-b14b-2afd096d7223'::uuid,0.00,1,'BONUS',NULL,'WALL230671250411','2025-04-11 09:39:48.54692','2025-04-11 09:39:48.54692',false,false),
	 ('019622b7-bb43-7d83-900b-e0bc83171c21'::uuid,'2dc3e26a-23e5-4213-b14b-2afd096d7223'::uuid,0.00,0,'MAIN',NULL,'WALL463604250411','2025-04-11 09:39:48.546891','2025-04-11 09:39:48.546891',false,false),
	 ('019622b7-efc2-7d26-b162-7675025c4dd2'::uuid,'810b2ef1-ea52-45c6-bdff-ddc729132b80'::uuid,0.00,0,'MAIN',NULL,'WALL175001250411','2025-04-11 09:40:01.986326','2025-04-11 09:40:01.986326',false,false),
	 ('019622b7-efc2-7e72-8e74-865e89cf66d3'::uuid,'810b2ef1-ea52-45c6-bdff-ddc729132b80'::uuid,0.00,1,'BONUS',NULL,'WALL831596250411','2025-04-11 09:40:01.986346','2025-04-11 09:40:01.986346',false,false);



INSERT INTO wallet (wallet_id, customer_id, balance, priority, wallet_type, expire_at) VALUES
	('0195836d-7063-7e95-99bc-e59da39bb55e','65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 3800000.00, 0, 'MAIN', null),
	('0195836d-7063-7e95-99bc-e59da39bb55f','65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 60000.00, 1, 'BONUS', NOW() + INTERVAL '6 hours');

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
	 
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('6caff0b9-eb21-42d1-af78-38fe88c7e405'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,3000000.00,'DEPOSIT','Initial deposit',NULL,NULL,'TXN001','2025-03-20 09:10:40.784905','2025-04-11 11:08:37.506387',false,false),
	 ('ae31a67a-deb2-48dd-84c7-9efe95faa3a8'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,-450000.00,'ORDER_DEDUCT','Purchase: Office lunch',NULL,NULL,'TXN002','2025-04-09 21:56:12.161139','2025-04-11 11:08:37.506387',false,false),
	 ('7433607d-295d-4884-90eb-aa21338b4b68'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,-120000.00,'ORDER_DEDUCT','Coffee break charge',NULL,NULL,'TXN003','2025-03-16 21:45:46.868819','2025-04-11 11:08:37.506387',false,false),
	 ('851a8a62-0a16-4cd4-a597-95bdee408ace'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,1500000.00,'DEPOSIT','Monthly allowance',NULL,NULL,'TXN004','2025-03-17 09:22:12.595122','2025-04-11 11:08:37.506387',false,false),
	 ('6727bbf6-d8ce-41c8-aecb-b988247cdb5d'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,-80000.00,'ORDER_DEDUCT','Bánh mì and tea',NULL,NULL,'TXN005','2025-03-28 09:27:57.700416','2025-04-11 11:08:37.506387',false,false),
	 ('d3505d56-0df4-4f1a-b5c1-2f16d7b39fcb'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,-220000.00,'ORDER_DEDUCT','Grab ride',NULL,NULL,'TXN006','2025-04-08 00:53:40.690566','2025-04-11 11:08:37.506387',false,false),
	 ('5667e354-5a01-412c-872d-a59286425b96'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,500000.00,'DEPOSIT','Team reward',NULL,NULL,'TXN007','2025-04-01 20:05:00.500946','2025-04-11 11:08:37.506387',false,false),
	 ('c920a7fb-827c-4bd6-9920-e6d94ca27706'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,-95000.00,'ORDER_DEDUCT','Late night snack',NULL,NULL,'TXN008','2025-04-05 13:16:31.248458','2025-04-11 11:08:37.506387',false,false),
	 ('bcfc934d-9e27-4350-9569-2ad1eaeb4344'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,-180000.00,'ORDER_DEDUCT','Shopee groceries',NULL,NULL,'TXN009','2025-04-04 18:18:08.477659','2025-04-11 11:08:37.506387',false,false),
	 ('d7c65090-3a2b-4aee-9ccd-fddaad5ac064'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,200000.00,'DEPOSIT','Cashback credit',NULL,NULL,'TXN010','2025-04-05 19:47:31.94356','2025-04-11 11:08:37.506387',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('62a4be54-52d0-43b7-9066-9e27f0753730'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,-300000.00,'ORDER_DEDUCT','Team dinner',NULL,NULL,'TXN011','2025-03-26 10:08:40.795912','2025-04-11 11:08:37.506387',false,false),
	 ('9e1c9695-cd94-426b-b518-54ac4e2c8c16'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,1000000.00,'DEPOSIT','Top-up via MOMO',NULL,NULL,'TXN012','2025-03-27 18:13:48.381381','2025-04-11 11:08:37.506387',false,false),
	 ('b85c6434-4744-483a-aa5b-2d32cd6e44a2'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,-150000.00,'ORDER_DEDUCT','Bookstore purchase',NULL,NULL,'TXN013','2025-03-16 12:00:54.592181','2025-04-11 11:08:37.506387',false,false),
	 ('d839b948-dc00-4b64-89c1-464c61c183fc'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,-200000.00,'ORDER_DEDUCT','Laundry service',NULL,NULL,'TXN014','2025-03-26 14:05:32.520559','2025-04-11 11:08:37.506387',false,false),
	 ('36e6a050-1ea7-4750-9780-7e8c8ea61d4d'::uuid,'019622ad-743e-7263-a1d3-62e691ec4d9c'::uuid,-100000.00,'ORDER_DEDUCT','Café meeting',NULL,NULL,'TXN015','2025-03-15 19:04:58.565273','2025-04-11 11:08:37.506387',false,false),
	 ('0e108b72-43ea-47f2-ba26-3a4ede74586b'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,2500000.00,'DEPOSIT','Initial wallet top-up',NULL,NULL,'TXN101','2025-04-06 13:48:55.901873','2025-04-11 11:13:41.86961',false,false),
	 ('ed882f07-a70f-4221-905b-9d01ded9fded'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,-300000.00,'ORDER_DEDUCT','GrabFood order',NULL,NULL,'TXN102','2025-03-23 10:59:57.7741','2025-04-11 11:13:41.86961',false,false),
	 ('9924315a-0f48-4fca-830a-83c157d00ba6'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,-90000.00,'ORDER_DEDUCT','Milk tea & pastry',NULL,NULL,'TXN103','2025-03-20 13:01:53.978342','2025-04-11 11:13:41.86961',false,false),
	 ('c69843d9-9c95-4301-ae42-c8ed27785280'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,1000000.00,'DEPOSIT','Performance bonus',NULL,NULL,'TXN104','2025-03-19 14:30:15.342783','2025-04-11 11:13:41.86961',false,false),
	 ('e2b9f5f9-2ae9-43f5-ad09-5028f4d02c22'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,-120000.00,'ORDER_DEDUCT','Office supplies',NULL,NULL,'TXN105','2025-04-05 21:15:39.226896','2025-04-11 11:13:41.86961',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('cf926ca7-7e6c-4cf3-8890-e0f830ec97f1'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,-150000.00,'ORDER_DEDUCT','ZaloPay recharge',NULL,NULL,'TXN106','2025-03-25 11:31:43.292888','2025-04-11 11:13:41.86961',false,false),
	 ('b2da4ee3-2db6-4bb7-9e94-1ca2e595d27e'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,500000.00,'DEPOSIT','Referral reward',NULL,NULL,'TXN107','2025-04-09 01:54:37.106396','2025-04-11 11:13:41.86961',false,false),
	 ('6bc0d0ff-6584-45e5-9737-9b03ccc5c02f'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,-45000.00,'ORDER_DEDUCT','Afternoon snack',NULL,NULL,'TXN108','2025-03-26 03:02:28.95655','2025-04-11 11:13:41.86961',false,false),
	 ('9f811cef-fa70-4ebb-b598-6e85751712e6'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,-220000.00,'ORDER_DEDUCT','Book order',NULL,NULL,'TXN109','2025-03-26 10:50:24.309585','2025-04-11 11:13:41.86961',false,false),
	 ('cebb07f8-486a-4b7d-87f9-13cac6acc108'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,300000.00,'DEPOSIT','Mini top-up',NULL,NULL,'TXN110','2025-03-18 23:11:19.425495','2025-04-11 11:13:41.86961',false,false),
	 ('25f3a4c2-4cd3-4b50-a612-5f8a7d170bc0'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,-100000.00,'ORDER_DEDUCT','Lunch delivery',NULL,NULL,'TXN111','2025-03-18 15:48:45.889076','2025-04-11 11:13:41.86961',false,false),
	 ('b2bdd7c1-374e-498b-bb0b-0fa4b19e0084'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,750000.00,'DEPOSIT','Wallet credit from event',NULL,NULL,'TXN112','2025-03-30 08:15:56.72515','2025-04-11 11:13:41.86961',false,false),
	 ('cecd7374-684c-443c-8635-c7f107a6c544'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,-270000.00,'ORDER_DEDUCT','Dinner for two',NULL,NULL,'TXN113','2025-03-13 03:49:24.320843','2025-04-11 11:13:41.86961',false,false),
	 ('71e5f1b2-4815-4d90-8759-453693a3c632'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,-110000.00,'ORDER_DEDUCT','Bánh cuốn & nước mía',NULL,NULL,'TXN114','2025-03-18 00:24:09.105537','2025-04-11 11:13:41.86961',false,false),
	 ('b73d2cdf-e07c-4948-b063-31b9e5a553d5'::uuid,'019622ad-c49d-7a03-bb0c-f22ecf67bcb6'::uuid,-50000.00,'ORDER_DEDUCT','Parking fee',NULL,NULL,'TXN115','2025-04-06 07:39:57.213079','2025-04-11 11:13:41.86961',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('2518ac3d-f66c-4257-b874-50883d3bf3a2'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,1800000.00,'DEPOSIT','New wallet funding',NULL,NULL,'TXN201','2025-04-01 22:29:21.762368','2025-04-11 11:15:44.343509',false,false),
	 ('2c325725-5565-4494-9102-1c4c4d8d798d'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-200000.00,'ORDER_DEDUCT','Dinner with friends',NULL,NULL,'TXN202','2025-03-24 12:55:17.798303','2025-04-11 11:15:44.343509',false,false),
	 ('0a2e11f7-55c5-48d2-bfed-3ca2a0406f46'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-75000.00,'ORDER_DEDUCT','Milk tea',NULL,NULL,'TXN203','2025-03-27 21:11:08.977039','2025-04-11 11:15:44.343509',false,false),
	 ('a8c39f9e-f994-4da1-9d5f-604840ebcc29'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,1200000.00,'DEPOSIT','Monthly bonus',NULL,NULL,'TXN204','2025-03-18 16:11:20.252636','2025-04-11 11:15:44.343509',false,false),
	 ('726fa475-d874-4b0c-be73-79a756941c67'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-180000.00,'ORDER_DEDUCT','Taxi trip',NULL,NULL,'TXN205','2025-03-21 21:31:03.816695','2025-04-11 11:15:44.343509',false,false),
	 ('cd1e3536-c0bf-4dd2-ad55-8f58aba3c1da'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-100000.00,'ORDER_DEDUCT','Cafe order',NULL,NULL,'TXN206','2025-03-22 13:09:04.358933','2025-04-11 11:15:44.343509',false,false),
	 ('64124be9-896a-440c-baae-587ef8b2b5f0'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,300000.00,'DEPOSIT','Survey reward',NULL,NULL,'TXN207','2025-03-30 20:49:00.260318','2025-04-11 11:15:44.343509',false,false),
	 ('9c920717-da7e-4cf8-b3be-a3f0b5ae5b21'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-120000.00,'ORDER_DEDUCT','Lunch',NULL,NULL,'TXN208','2025-04-09 16:51:29.196145','2025-04-11 11:15:44.343509',false,false),
	 ('67df1a9d-d9b2-4539-ba7a-302b1cc92518'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-150000.00,'ORDER_DEDUCT','Shopee sale',NULL,NULL,'TXN209','2025-03-17 23:05:35.989996','2025-04-11 11:15:44.343509',false,false),
	 ('2e050083-2612-480a-bea7-66060d31dc57'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,800000.00,'DEPOSIT','MOMO top-up',NULL,NULL,'TXN210','2025-03-20 10:14:20.948665','2025-04-11 11:15:44.343509',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('74db5835-7f30-48b0-bfaa-3724ea732b39'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-50000.00,'ORDER_DEDUCT','Bread & yogurt',NULL,NULL,'TXN211','2025-03-17 22:15:10.361253','2025-04-11 11:15:44.343509',false,false),
	 ('12ff882a-7950-4275-aac5-a1c07fb280f0'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-110000.00,'ORDER_DEDUCT','Haircut',NULL,NULL,'TXN212','2025-04-01 02:19:17.367596','2025-04-11 11:15:44.343509',false,false),
	 ('6bee1250-c541-4147-8dae-c03753397a95'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-300000.00,'ORDER_DEDUCT','Groceries',NULL,NULL,'TXN213','2025-03-22 08:19:24.934685','2025-04-11 11:15:44.343509',false,false),
	 ('89acae86-4cda-4933-9f4e-97dce20628f1'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,100000.00,'DEPOSIT','Promo credit',NULL,NULL,'TXN214','2025-03-16 11:35:25.779749','2025-04-11 11:15:44.343509',false,false),
	 ('8e771bc6-b749-497e-9e29-374b1cd7df41'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-85000.00,'ORDER_DEDUCT','Street food',NULL,NULL,'TXN215','2025-04-06 04:28:10.992787','2025-04-11 11:15:44.343509',false,false),
	 ('a56cc80f-1186-4c44-9b57-54c8f8642290'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,1800000.00,'DEPOSIT','New wallet funding',NULL,NULL,'TXN201','2025-04-07 22:45:48.257961','2025-04-11 11:15:46.786845',false,false),
	 ('994582a9-1281-475a-8e18-3b2feff5d82f'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-200000.00,'ORDER_DEDUCT','Dinner with friends',NULL,NULL,'TXN202','2025-03-14 08:14:27.850994','2025-04-11 11:15:46.786845',false,false),
	 ('c9b2dc20-80d9-44b3-8d43-b394aba6fe94'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-75000.00,'ORDER_DEDUCT','Milk tea',NULL,NULL,'TXN203','2025-03-12 19:31:40.957955','2025-04-11 11:15:46.786845',false,false),
	 ('7c6b33e7-1247-4ed1-9f64-cd6c1135657d'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,1200000.00,'DEPOSIT','Monthly bonus',NULL,NULL,'TXN204','2025-03-19 04:43:25.335772','2025-04-11 11:15:46.786845',false,false),
	 ('cdfff499-ba81-4c9f-9fe7-ac3da833c128'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-180000.00,'ORDER_DEDUCT','Taxi trip',NULL,NULL,'TXN205','2025-03-18 12:59:17.952626','2025-04-11 11:15:46.786845',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('3f3a5069-54ba-4708-820b-b94e20e042dd'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-100000.00,'ORDER_DEDUCT','Cafe order',NULL,NULL,'TXN206','2025-04-08 02:35:28.573204','2025-04-11 11:15:46.786845',false,false),
	 ('fa2395f4-4f59-4429-81c6-b3dcbc6eb794'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,300000.00,'DEPOSIT','Survey reward',NULL,NULL,'TXN207','2025-03-28 22:26:04.159541','2025-04-11 11:15:46.786845',false,false),
	 ('5bb5f709-7ffb-4374-a7c7-3c416a0709f2'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-120000.00,'ORDER_DEDUCT','Lunch',NULL,NULL,'TXN208','2025-03-29 00:55:44.027285','2025-04-11 11:15:46.786845',false,false),
	 ('c9b09b11-21d6-4622-8d1a-97f356a4a1a3'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-150000.00,'ORDER_DEDUCT','Shopee sale',NULL,NULL,'TXN209','2025-03-12 15:25:51.330997','2025-04-11 11:15:46.786845',false,false),
	 ('6479b543-82e9-4764-a5cc-3ffd49c69ee4'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,800000.00,'DEPOSIT','MOMO top-up',NULL,NULL,'TXN210','2025-03-14 06:27:22.475288','2025-04-11 11:15:46.786845',false,false),
	 ('87997db7-ac8e-426e-88e5-82b2dfb476d6'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-50000.00,'ORDER_DEDUCT','Bread & yogurt',NULL,NULL,'TXN211','2025-03-22 14:02:50.44908','2025-04-11 11:15:46.786845',false,false),
	 ('b671805d-47ae-4b52-bd51-b052a5dd4d9f'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-110000.00,'ORDER_DEDUCT','Haircut',NULL,NULL,'TXN212','2025-04-10 06:59:49.253299','2025-04-11 11:15:46.786845',false,false),
	 ('1d1c4b2f-5107-4d83-9137-2abd3d9d42c8'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-300000.00,'ORDER_DEDUCT','Groceries',NULL,NULL,'TXN213','2025-03-25 14:32:00.499331','2025-04-11 11:15:46.786845',false,false),
	 ('c7a4a41d-c171-4026-be6f-de05bccf9b3d'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,100000.00,'DEPOSIT','Promo credit',NULL,NULL,'TXN214','2025-03-16 13:30:24.103239','2025-04-11 11:15:46.786845',false,false),
	 ('0137f160-9ada-4117-988e-496caf4a7b21'::uuid,'019622ad-f707-7d3a-8726-75fb9f8c9fcc'::uuid,-85000.00,'ORDER_DEDUCT','Street food',NULL,NULL,'TXN215','2025-03-15 18:47:26.004669','2025-04-11 11:15:46.786845',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('833269b8-70c5-4c27-b6e2-6fdc38f31b97'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,2000000.00,'DEPOSIT','First top-up',NULL,NULL,'TXN301','2025-03-21 19:11:12.130208','2025-04-11 11:16:37.527625',false,false),
	 ('517aa666-b62c-41e3-a4b8-11d4c483dd9f'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,-150000.00,'ORDER_DEDUCT','GrabFood dinner',NULL,NULL,'TXN302','2025-04-04 20:45:46.898892','2025-04-11 11:16:37.527625',false,false),
	 ('e56b8e90-2e9b-4359-96a6-55449992bab9'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,-90000.00,'ORDER_DEDUCT','Cafe breakfast',NULL,NULL,'TXN303','2025-04-04 08:22:06.230966','2025-04-11 11:16:37.527625',false,false),
	 ('0a548719-1cd2-4905-8d5b-11ca419b5fb2'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,1000000.00,'DEPOSIT','Performance reward',NULL,NULL,'TXN304','2025-03-16 06:21:16.685476','2025-04-11 11:16:37.527625',false,false),
	 ('961d5367-8b45-4036-b40d-3298ab1e6d4a'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,-200000.00,'ORDER_DEDUCT','Shopee order',NULL,NULL,'TXN305','2025-04-02 22:02:20.557555','2025-04-11 11:16:37.527625',false,false),
	 ('31cefab8-816d-4880-9b47-f6bf2a988262'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,-120000.00,'ORDER_DEDUCT','Lunch set',NULL,NULL,'TXN306','2025-03-29 13:37:00.522915','2025-04-11 11:16:37.527625',false,false),
	 ('fb0beace-2120-472d-b342-14efe216ad3d'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,400000.00,'DEPOSIT','Referral bonus',NULL,NULL,'TXN307','2025-04-01 09:58:21.196554','2025-04-11 11:16:37.527625',false,false),
	 ('78b81f5d-26b5-46ae-9886-7f323e40fe99'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,-80000.00,'ORDER_DEDUCT','Boba tea',NULL,NULL,'TXN308','2025-04-02 22:29:13.331945','2025-04-11 11:16:37.527625',false,false),
	 ('d9e05da3-ac3a-4e30-b328-907d89af96aa'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,-180000.00,'ORDER_DEDUCT','Grab ride',NULL,NULL,'TXN309','2025-04-03 04:25:56.048954','2025-04-11 11:16:37.527625',false,false),
	 ('64b52499-46e9-48b3-bc56-e92522caf1de'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,300000.00,'DEPOSIT','Top-up credit',NULL,NULL,'TXN310','2025-03-12 11:57:10.052381','2025-04-11 11:16:37.527625',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('ffe7b888-baaa-475b-adff-d47400d6fd86'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,-100000.00,'ORDER_DEDUCT','Bakery purchase',NULL,NULL,'TXN311','2025-03-20 16:42:30.974746','2025-04-11 11:16:37.527625',false,false),
	 ('0f2d7a6c-9304-4ff7-bba8-01396216cfae'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,750000.00,'DEPOSIT','Special bonus',NULL,NULL,'TXN312','2025-04-01 17:13:01.064926','2025-04-11 11:16:37.527625',false,false),
	 ('a9ff028e-f3d7-42b7-ae35-782897b056a8'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,-250000.00,'ORDER_DEDUCT','Electronics',NULL,NULL,'TXN313','2025-03-26 21:26:59.461912','2025-04-11 11:16:37.527625',false,false),
	 ('0b8436a6-c7ff-4efa-a06b-3ddd7990f1bd'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,-50000.00,'ORDER_DEDUCT','Parking',NULL,NULL,'TXN314','2025-03-21 23:55:05.791647','2025-04-11 11:16:37.527625',false,false),
	 ('8e6095cc-cfc8-4dec-80cf-30597335b351'::uuid,'019622ae-2eb7-70e0-906a-08c0e55ecdce'::uuid,-130000.00,'ORDER_DEDUCT','Laundry',NULL,NULL,'TXN315','2025-03-22 04:06:40.362101','2025-04-11 11:16:37.527625',false,false),
	 ('5ee7b3b7-3b93-4552-859e-4b34c0b64e32'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,2200000.00,'DEPOSIT','Initial funding',NULL,NULL,'TXN401','2025-03-16 18:56:22.254174','2025-04-11 11:17:33.621178',false,false),
	 ('46f2ed11-5499-4f78-84ab-05b487bb8d99'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,-180000.00,'ORDER_DEDUCT','Pho & coffee',NULL,NULL,'TXN402','2025-03-12 17:26:27.336709','2025-04-11 11:17:33.621178',false,false),
	 ('1368423c-d37b-44b8-8c40-aabd76acb383'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,-120000.00,'ORDER_DEDUCT','Ride to work',NULL,NULL,'TXN403','2025-04-03 06:25:01.384562','2025-04-11 11:17:33.621178',false,false),
	 ('e20e2640-12b3-4578-b090-5e0770d92227'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,1500000.00,'DEPOSIT','Company incentive',NULL,NULL,'TXN404','2025-03-13 02:13:16.593041','2025-04-11 11:17:33.621178',false,false),
	 ('b6328dfc-b07e-46a5-8b2f-611c390addca'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,-90000.00,'ORDER_DEDUCT','Snacks & soda',NULL,NULL,'TXN405','2025-03-17 11:06:41.478856','2025-04-11 11:17:33.621178',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('ede3e1aa-b460-4de5-901e-1bc5143d3561'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,-50000.00,'ORDER_DEDUCT','Fast food lunch',NULL,NULL,'TXN406','2025-04-07 14:25:14.415948','2025-04-11 11:17:33.621178',false,false),
	 ('420a043c-1d44-456d-8431-19f19738b6cc'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,600000.00,'DEPOSIT','Top-up gift card',NULL,NULL,'TXN407','2025-04-04 19:12:50.239201','2025-04-11 11:17:33.621178',false,false),
	 ('77ec1b7b-5781-46c5-905f-8ead6e26f9c1'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,-110000.00,'ORDER_DEDUCT','Online groceries',NULL,NULL,'TXN408','2025-03-26 22:28:25.414591','2025-04-11 11:17:33.621178',false,false),
	 ('0c6b7017-7ec2-47e9-be71-37dc5f27d46d'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,-200000.00,'ORDER_DEDUCT','Movie tickets',NULL,NULL,'TXN409','2025-03-28 21:52:03.659616','2025-04-11 11:17:33.621178',false,false),
	 ('a41398b7-b1e8-4c46-b420-a01e948eafda'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,350000.00,'DEPOSIT','Friend transfer',NULL,NULL,'TXN410','2025-03-28 05:40:23.853727','2025-04-11 11:17:33.621178',false,false),
	 ('efe456f3-a058-44f3-8af4-fdceedb1d473'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,-75000.00,'ORDER_DEDUCT','Coffee shop',NULL,NULL,'TXN411','2025-04-07 17:17:52.731687','2025-04-11 11:17:33.621178',false,false),
	 ('54676b29-8ce0-4c2a-8190-f3392411a23b'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,500000.00,'DEPOSIT','Mid-month top-up',NULL,NULL,'TXN412','2025-03-14 11:44:37.559153','2025-04-11 11:17:33.621178',false,false),
	 ('b1da8b5a-23e5-4116-9e13-5dd548239851'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,-170000.00,'ORDER_DEDUCT','Bookstore visit',NULL,NULL,'TXN413','2025-04-11 06:25:03.026646','2025-04-11 11:17:33.621178',false,false),
	 ('43234be7-5cdc-4db6-8522-312e62ff33ba'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,-95000.00,'ORDER_DEDUCT','Smoothie bowl',NULL,NULL,'TXN414','2025-04-06 04:30:40.229763','2025-04-11 11:17:33.621178',false,false),
	 ('089d24f7-555b-4485-903b-8cc51c1a858c'::uuid,'019622ae-6ca6-7af9-93ad-6ef4ca2f02b9'::uuid,-40000.00,'ORDER_DEDUCT','Gym locker fee',NULL,NULL,'TXN415','2025-03-13 22:45:12.597815','2025-04-11 11:17:33.621178',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('0be1f120-c6ac-4834-938f-783d1cf8ab41'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,2500000.00,'DEPOSIT','Initial deposit',NULL,NULL,'TXN501','2025-04-03 18:59:45.596893','2025-04-11 11:18:15.305064',false,false),
	 ('416d6650-7d7a-489b-aa3a-668b52a990dc'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,-200000.00,'ORDER_DEDUCT','Grab ride',NULL,NULL,'TXN502','2025-04-03 04:08:39.719786','2025-04-11 11:18:15.305064',false,false),
	 ('24b39671-e769-4d89-b391-b7c15713e6a5'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,-150000.00,'ORDER_DEDUCT','Lunch with coworkers',NULL,NULL,'TXN503','2025-04-03 06:21:46.938768','2025-04-11 11:18:15.305064',false,false),
	 ('5f7bd3ea-3b97-48a0-abac-362978956115'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,1300000.00,'DEPOSIT','Monthly bonus',NULL,NULL,'TXN504','2025-04-08 18:25:22.494593','2025-04-11 11:18:15.305064',false,false),
	 ('f9899e2e-1266-4a1e-8d76-8e51f7e28011'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,-180000.00,'ORDER_DEDUCT','Online purchase',NULL,NULL,'TXN505','2025-03-27 00:02:23.525377','2025-04-11 11:18:15.305064',false,false),
	 ('02a794f2-5bef-4201-b837-361b10c8fc6e'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,-100000.00,'ORDER_DEDUCT','Fast food',NULL,NULL,'TXN506','2025-04-04 16:57:14.616386','2025-04-11 11:18:15.305064',false,false),
	 ('cc34580c-2ce4-4341-9053-5538f83103b8'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,450000.00,'DEPOSIT','Cashback reward',NULL,NULL,'TXN507','2025-03-19 00:38:43.939786','2025-04-11 11:18:15.305064',false,false),
	 ('0da652a2-f020-4b00-b969-b50cd6ca3781'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,-125000.00,'ORDER_DEDUCT','Movie night',NULL,NULL,'TXN508','2025-03-28 17:34:30.490005','2025-04-11 11:18:15.305064',false,false),
	 ('c07948d3-5f55-474e-9ed1-012b733d64f5'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,-140000.00,'ORDER_DEDUCT','Takeout dinner',NULL,NULL,'TXN509','2025-03-21 16:03:42.738545','2025-04-11 11:18:15.305064',false,false),
	 ('785ac91d-a2ca-472a-8e0f-c7bf270fcbdb'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,300000.00,'DEPOSIT','Transfer from friend',NULL,NULL,'TXN510','2025-03-20 08:35:45.336025','2025-04-11 11:18:15.305064',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('db5537ab-453d-4a79-993d-0f3ad6716428'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,-95000.00,'ORDER_DEDUCT','Smoothie & wrap',NULL,NULL,'TXN511','2025-03-20 01:21:11.256293','2025-04-11 11:18:15.305064',false,false),
	 ('1efa210c-6889-4d18-bb18-e8ee1d076a5b'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,500000.00,'DEPOSIT','Top-up card',NULL,NULL,'TXN512','2025-03-29 09:16:41.571046','2025-04-11 11:18:15.305064',false,false),
	 ('84802448-3889-4c8f-8fc6-f7662db17212'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,-220000.00,'ORDER_DEDUCT','Grocery haul',NULL,NULL,'TXN513','2025-04-01 18:56:58.625019','2025-04-11 11:18:15.305064',false,false),
	 ('29899428-7074-40ff-86d9-5b82305c7a07'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,-80000.00,'ORDER_DEDUCT','Bakery snacks',NULL,NULL,'TXN514','2025-03-29 23:10:37.386243','2025-04-11 11:18:15.305064',false,false),
	 ('21594974-0ace-42cc-83ad-d3643bf5faf3'::uuid,'019622ae-a59c-736b-a2ee-00334492e43a'::uuid,-50000.00,'ORDER_DEDUCT','Convenience store',NULL,NULL,'TXN515','2025-03-25 02:58:37.751278','2025-04-11 11:18:15.305064',false,false),
	 ('bd9affe4-3109-4129-b4a7-f81d888c0574'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,2700000.00,'DEPOSIT','Opening balance',NULL,NULL,'TXN601','2025-03-26 10:08:49.22935','2025-04-11 11:19:10.810998',false,false),
	 ('0db9a050-4150-463c-a839-ac971edb326c'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,-175000.00,'ORDER_DEDUCT','Grab ride to airport',NULL,NULL,'TXN602','2025-03-19 07:42:55.448567','2025-04-11 11:19:10.810998',false,false),
	 ('9b2ea2a5-ab9a-4a4e-a80d-af4d84177cc0'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,-145000.00,'ORDER_DEDUCT','Late night food delivery',NULL,NULL,'TXN603','2025-03-25 14:31:31.055222','2025-04-11 11:19:10.810998',false,false),
	 ('454ef64b-97a9-46b7-8e6e-2008bc719ea6'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,1000000.00,'DEPOSIT','Company reimbursement',NULL,NULL,'TXN604','2025-03-18 23:42:54.170621','2025-04-11 11:19:10.810998',false,false),
	 ('fec5302e-3628-48ec-80cc-2e6fe400637b'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,-120000.00,'ORDER_DEDUCT','Mobile accessories',NULL,NULL,'TXN605','2025-04-08 18:53:34.704803','2025-04-11 11:19:10.810998',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('5715a1c1-2969-496d-8562-d8232e94d3d2'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,-105000.00,'ORDER_DEDUCT','Brunch special',NULL,NULL,'TXN606','2025-03-19 10:49:25.67617','2025-04-11 11:19:10.810998',false,false),
	 ('ccddaf11-cb54-464a-8c82-33380fa8c8e1'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,550000.00,'DEPOSIT','Referral earnings',NULL,NULL,'TXN607','2025-04-02 22:05:04.712243','2025-04-11 11:19:10.810998',false,false),
	 ('fc4f4ec8-6f39-4aad-8ca8-c66eab3dec42'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,-180000.00,'ORDER_DEDUCT','Gift purchase',NULL,NULL,'TXN608','2025-03-14 10:03:28.290362','2025-04-11 11:19:10.810998',false,false),
	 ('0df2d15e-4ec8-44f8-9182-e382900f7edb'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,-95000.00,'ORDER_DEDUCT','Stationery',NULL,NULL,'TXN609','2025-03-14 11:52:26.723683','2025-04-11 11:19:10.810998',false,false),
	 ('8fa1b9ae-dd43-46fd-a49a-067b5348aab5'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,300000.00,'DEPOSIT','Extra credit top-up',NULL,NULL,'TXN610','2025-03-13 16:37:26.765737','2025-04-11 11:19:10.810998',false,false),
	 ('db47899e-49e3-4360-9576-8a537f5db93e'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,-85000.00,'ORDER_DEDUCT','Grab bike fare',NULL,NULL,'TXN611','2025-04-10 16:26:34.848696','2025-04-11 11:19:10.810998',false,false),
	 ('37982b78-503d-4838-9f66-993fa9de36d8'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,480000.00,'DEPOSIT','Top-up via bank',NULL,NULL,'TXN612','2025-04-09 17:03:41.364301','2025-04-11 11:19:10.810998',false,false),
	 ('0aed1554-39f2-4559-a52b-2c2f21daf536'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,-100000.00,'ORDER_DEDUCT','Food court meal',NULL,NULL,'TXN613','2025-03-29 20:53:42.682901','2025-04-11 11:19:10.810998',false,false),
	 ('1c81024e-90b7-4903-a411-85e6c8fe885c'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,-70000.00,'ORDER_DEDUCT','Ice cream & coffee',NULL,NULL,'TXN614','2025-04-08 21:30:51.567195','2025-04-11 11:19:10.810998',false,false),
	 ('f5d0e896-ffd3-4d11-b5c7-9520038fa7f3'::uuid,'019622ae-e822-7b29-9e64-26757ab1a1cd'::uuid,-130000.00,'ORDER_DEDUCT','Delivery tip & fee',NULL,NULL,'TXN615','2025-03-27 22:10:08.274362','2025-04-11 11:19:10.810998',false,false);

INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('d427dc37-e534-431e-b680-458ef052f992'::uuid,'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a'::uuid,-37600.00,'ORDER_DEDUCT','Payment for order 3ec45e22-7f8a-4786-b81f-e9ecad66ce89 Using card d4e5f6a7-b8c9-4012-def0-4567890123de Pay by MAIN wallet b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a','3ec45e22-7f8a-4786-b81f-e9ecad66ce89'::uuid,NULL,'WALL601782250411','2025-04-11 05:56:37.431784','2025-04-11 14:49:55.419636',false,false),
	 ('0b7eb67c-7b83-4f4b-8fdc-b503a40b490f'::uuid,'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a'::uuid,-37600.00,'ORDER_DEDUCT','Payment for order 6e78b3f4-c3fc-43b6-80bf-1b4a326892a2 Using card d4e5f6a7-b8c9-4012-def0-4567890123de Pay by MAIN wallet b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a','6e78b3f4-c3fc-43b6-80bf-1b4a326892a2'::uuid,NULL,'WALL979002250411','2025-04-09 13:59:38.62841','2025-04-11 14:50:10.138576',false,false),
	 ('2a61adb3-dfd5-4afc-87e3-97853f5f4dcc'::uuid,'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a'::uuid,-12000.00,'ORDER_DEDUCT','Payment for order 6dfdda94-6d67-413a-9984-bf390008257d Using card d4e5f6a7-b8c9-4012-def0-4567890123de Pay by MAIN wallet b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a','6dfdda94-6d67-413a-9984-bf390008257d'::uuid,NULL,'WALL750158250411','2025-04-04 23:58:12.380259','2025-04-11 15:02:10.17285',false,false),
	 ('e35ae55e-b2bf-41bb-96bf-ebd2a996281f'::uuid,'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a'::uuid,-13000.00,'ORDER_DEDUCT','Payment for order 9d3156aa-95ea-48f7-8848-8dd6c59a381f Using card d4e5f6a7-b8c9-4012-def0-4567890123de Pay by MAIN wallet b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a','9d3156aa-95ea-48f7-8848-8dd6c59a381f'::uuid,NULL,'WALL846575250411','2025-04-03 15:20:41.329491','2025-04-11 15:02:24.170383',false,false),
	 ('8226aec0-163c-49b8-8a63-d5c6b6bf0e16'::uuid,'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a'::uuid,-11400.00,'ORDER_DEDUCT','Payment for order 86d4e542-61b6-48c3-82ae-6b28dc46876e Using card d4e5f6a7-b8c9-4012-def0-4567890123de Pay by MAIN wallet b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a','86d4e542-61b6-48c3-82ae-6b28dc46876e'::uuid,NULL,'WALL329578250411','2025-04-02 13:41:04.24858','2025-04-11 15:02:31.296697',false,false),
	 ('1bf7a3e8-2c2e-4794-829d-814fc057a30d'::uuid,'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a'::uuid,-38800.00,'ORDER_DEDUCT','Payment for order 20fe8fff-27be-43ef-a666-6988a2e18be1 Using card d4e5f6a7-b8c9-4012-def0-4567890123de Pay by MAIN wallet b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a','20fe8fff-27be-43ef-a666-6988a2e18be1'::uuid,NULL,'WALL218895250411','2025-04-05 14:54:00.104725','2025-04-11 15:02:37.476605',false,false),
	 ('d8eb4017-4bef-435d-ba0d-8e22023254ad'::uuid,'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a'::uuid,-8000.00,'ORDER_DEDUCT','Payment for order ca6933ad-2578-4962-96e9-5621d5b68a1a Using card d4e5f6a7-b8c9-4012-def0-4567890123de Pay by MAIN wallet b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a','ca6933ad-2578-4962-96e9-5621d5b68a1a'::uuid,NULL,'WALL314521250411','2025-04-04 15:19:37.784345','2025-04-11 15:02:43.469348',false,false),
	 ('f4edaaae-889b-428f-94b2-3ecdeabeab3f'::uuid,'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a'::uuid,-8700.00,'ORDER_DEDUCT','Payment for order d0c8deaa-ade6-4f90-8505-4cb5024770c0 Using card d4e5f6a7-b8c9-4012-def0-4567890123de Pay by MAIN wallet b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a','d0c8deaa-ade6-4f90-8505-4cb5024770c0'::uuid,NULL,'WALL094040250411','2025-04-02 06:31:25.195396','2025-04-11 15:02:53.102657',false,false),
	 ('8701145e-d332-40fa-9523-a33e213b3aa2'::uuid,'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a'::uuid,-10000.00,'ORDER_DEDUCT','Payment for order 6dbef0e1-0105-4184-9ea0-d8ac03ee5a59 Using card d4e5f6a7-b8c9-4012-def0-4567890123de Pay by MAIN wallet b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a','6dbef0e1-0105-4184-9ea0-d8ac03ee5a59'::uuid,NULL,'WALL176367250411','2025-04-06 15:16:59.612259','2025-04-11 15:02:59.590567',false,false),
	 ('36fbf53b-8ddf-4660-a893-ae231dd95e6f'::uuid,'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a'::uuid,-20000.00,'ORDER_DEDUCT','Payment for order 61a64bb2-c7ed-43fd-8cd7-130d15915b10 Using card d4e5f6a7-b8c9-4012-def0-4567890123de Pay by MAIN wallet b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a','61a64bb2-c7ed-43fd-8cd7-130d15915b10'::uuid,NULL,'WALL925957250411','2025-04-04 11:16:30.315592','2025-04-11 15:03:06.783937',false,false);
INSERT INTO wallet_transaction (wallet_transaction_id,wallet_id,amount,"type",description,order_id,deposit_id,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('7e2e5d7a-682f-4668-aab4-bb6c2965e0d3'::uuid,'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a'::uuid,-32700.00,'ORDER_DEDUCT','Payment for order cbd56508-5d09-4d80-939e-973f4a258252 Using card d4e5f6a7-b8c9-4012-def0-4567890123de Pay by MAIN wallet b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a','cbd56508-5d09-4d80-939e-973f4a258252'::uuid,NULL,'WALL742674250411','2025-04-04 18:59:42.040826','2025-04-11 15:03:12.104816',false,false);INSERT INTO promotion (promotion_id, detail, "type", code, is_suspended) VALUES
	('550e8400-e29b-41d4-a716-446655440000', '{"Percentage":10.5,"BonusWalletLifeTimeInHours":10,"AppliedDayOfWeek":"MON"}', 'DEPOSIT_PROMO_V1', 'MON_SPR2025', false),
	('0f3e14a3-baa4-4c72-a912-3517ef6a8458',
	'{"Percentage":12.5,"BonusWalletLifeTimeInHours":9,"AppliedDayOfWeek":"TUE"}', 'DEPOSIT_PROMO_V1', 'TUE_SPR2025', false),
	('ba240d98-3570-418d-8916-81aaf51421cc',
	'{"Percentage":14.5,"BonusWalletLifeTimeInHours":8,"AppliedDayOfWeek":"WED"}', 'DEPOSIT_PROMO_V1', 'WED_SPR2025', false),
	('ef282a03-92db-45ca-86dc-f886bba99912',
	'{"Percentage":16.5,"BonusWalletLifeTimeInHours":7,"AppliedDayOfWeek":"THU"}', 'DEPOSIT_PROMO_V1', 'THU_SPR2025', false),
	('a301edce-9a41-4c93-a109-1572b46df4a3',
	'{"Percentage":17.5,"BonusWalletLifeTimeInHours":6,"AppliedDayOfWeek":"FRI"}', 'DEPOSIT_PROMO_V1', 'FRI_SPR2025', false),
	('4c5606c9-35e2-4427-a528-e16fa801027b','{"Percentage":15,"BonusWalletLifeTimeInHours":6,"AppliedDayOfWeek":"SAT"}', 'DEPOSIT_PROMO_V1', 'SAT_SPR2025', false),
	('2b62f99c-118d-4c84-80dc-4cfa64a9f5da','{"Percentage":15,"BonusWalletLifeTimeInHours":6,"AppliedDayOfWeek":"SUN"}', 'DEPOSIT_PROMO_V1', 'SUN_SPR2025', false),
	('550e8400-e29b-41d4-a716-446655440001', '{}', 'DEPOSIT_PROMO_V1', 'TEST_PROMOTION', true),
	('550e8400-e29b-41d4-a716-446655440002', '{}', 'DEPOSIT_PROMO_V1', 'PROMO789', true);INSERT INTO inventory_note (inventory_note_id,store_id,staff_id,"type",image_url,"description",code)
VALUES
	('69c89ae3-3d7f-44a1-bdcc-98df64f39486','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','d8d0e33a-a490-4fce-beee-fcad5eaef9a4','CHANGE','https://reinir.mooo.com/files/remi.jpg','Inventory change mock data','NOTE000000'),
	('46fb8481-a0b4-43f4-8758-355b0d1f3bc5','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','d8d0e33a-a490-4fce-beee-fcad5eaef9a4','AUDIT','https://reinir.mooo.com/files/food.jpg','Inventory audit mock data','NOTE000001'),
	('d911f814-ad30-4248-bc2d-ee09ac0668dd','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','0a5c236e-ff54-449e-834c-99c113b3b582','CHANGE','https://reinir.mooo.com/files/food.jpg','Inventory change mock data','NOTE000002'),
	('cc407916-b4b7-434f-b671-7dd18d9c7bdf','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','0a5c236e-ff54-449e-834c-99c113b3b582','AUDIT','https://reinir.mooo.com/files/food.jpg','Inventory change mock data','NOT000003'),
	('84c56a7c-7753-4a44-9b95-ac7278c7b24f','a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111','0a5c236e-ff54-449e-834c-99c113b3b582','CHANGE','https://reinir.mooo.com/files/food.jpg','Inventory change mock data','NOTE000004');
	
	
INSERT INTO inventory_note (inventory_note_id,store_id,staff_id,"type",image_url,description,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111'::uuid,'03485000-6353-4e33-b878-32328d89ba51'::uuid,'CHANGE','https://reinir.mooo.com/files/dde0b19f-d669-437a-90a9-e074d7fea78b.jpg','',NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false);

INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('08771eff-e5e2-4ef2-bc67-44c648deb714'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'6c2b5115-ae28-44de-8f05-e6f796947d09'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('1430b82f-7266-42db-a01a-8984fca423b1'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'cc544259-6cc3-48d0-ba1b-da22715c6f2b'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('225271cb-76c2-4739-9086-204977442056'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'963c6740-5e92-4b5c-9c9a-d8bed451e429'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('2a30db35-d6ea-44a2-9f3b-a6a214756ecf'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'d64fbd56-f9b3-4788-a6e9-f3e5a480e6f8'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('2f8a50d7-d6a2-4ebd-9640-715933ab53b6'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'cdc6f452-bb70-4c86-9e4f-7a49fc335f17'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('367a4754-6e29-4393-965f-a2cd27c5edfb'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'953c8077-a15e-431a-a238-64966ff0a414'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('58d6633b-5cda-4644-8de4-469535b76e2e'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'a8698aa1-b1ad-4d15-a23c-acd0300e9c00'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('616acc1e-1546-4206-8ad0-0a6e140ca66d'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'fffc5db9-dc6e-43e8-9b29-8b500791f35f'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('6e903c93-405f-4404-bb7b-ac122da5ee58'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'003e474d-e5e6-47fd-ab3d-95ac358560da'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('74741e7b-38a2-4d2f-bee0-85e62a791051'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'a6a3d453-de6d-4905-940d-f4d2ad2cd7f4'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false);
INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('854332e6-f304-4975-800b-3b156dedfbbb'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'572d8467-2e33-416c-baa6-9da8b25ceedd'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('91468c21-68ee-479f-8148-b2442c02ad64'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'01dfcc2c-c7c0-4a40-bab9-7e5d49be7ef9'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('99584ead-0c68-4aec-9105-829c8634aa3b'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'347f8b62-1bb0-495f-998d-0ffeee470d0a'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('9b261778-b62b-449a-84e8-bcb42359ab78'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'aa923b69-5fdb-40fe-ab56-decda440330f'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('a4692ef6-6007-4bcf-b61b-cffd72f24487'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'864e02dd-eb66-4af3-9873-e7606d9ccdde'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('a63a48c1-058c-437e-af84-5ed7adc55faa'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'81bb0fc4-039c-464d-a744-8f2267458e36'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('a6961ca6-4fad-4ce3-b486-479b347f773d'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'a9d09d7e-e7f9-440b-a7aa-fe023d8730fb'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('a8fc30b2-e3a5-47f2-b02d-6c224ec9bdcb'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'1566d6e1-0c10-4794-886b-f15cb1a7a74d'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('c005ba2c-0128-4ffc-a9ea-9d83c274479d'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'aab9c027-b1e2-490c-9d73-29f845d4671f'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('da6ff367-d612-4c08-8b1e-27eca40109d0'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'4d60e994-87cf-445f-9015-0951998157df'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false);
INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('ebec6fbc-60e1-4189-8e3e-44bb3b39ada6'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'c4612c3a-e977-4597-bf6d-9ca23a60fdd5'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('eef92adb-e466-4d08-8f30-4dab8d5fe7bb'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'c1acbd31-f1f9-4e71-bcd7-3984ff849738'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('f86c9309-6ec9-4917-9ff7-30abc8a1e631'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'ad9c2c20-8da2-47a0-831d-94a69cc424c2'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false),
	 ('f9038e9d-a454-4d1c-80c9-dbf900dc3c30'::uuid,'8c4ea06a-8c72-4272-a836-7518dddc142a'::uuid,'bbb3df82-488a-41ea-8e76-ab69f3b1e75e'::uuid,30,0,NULL,'2025-04-08 00:00:00','2025-04-08 00:00:00',false,false);


INSERT INTO inventory_note (inventory_note_id,store_id,staff_id,"type",image_url,description,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('4d3fe7b6-e35f-4d53-8cbd-be248ecf2a25'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'03485000-6353-4e33-b878-32328d89ba51'::uuid,'CHANGE','https://reinir.mooo.com/files/61fd01e4-edce-4609-892f-3ec8e9253ecb.jpg','','INVE271970250411','2025-04-10 15:11:07.372162','2025-04-11 14:22:59.602531',false,false),
	 ('4e633829-951f-431f-abd7-01fa0eb14abe'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'03485000-6353-4e33-b878-32328d89ba51'::uuid,'CHANGE','https://reinir.mooo.com/files/d327f5bd-28f3-42d9-b7da-000469e27ab9.png','','INVE594867250411','2025-04-10 20:42:52.924355','2025-04-11 14:23:33.21435',false,false),
	 ('22464b74-efe7-456a-9f0e-6167afcbd523'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'03485000-6353-4e33-b878-32328d89ba51'::uuid,'CHANGE','https://reinir.mooo.com/files/0254b81e-d0c8-4224-9bce-dbb44c528bc9.png','','INVE790059250411','2025-04-08 01:30:55.058472','2025-04-11 14:26:00.456593',false,false),
	 ('93e539b9-a487-4975-bac7-ec44f7e95a3c'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'03485000-6353-4e33-b878-32328d89ba51'::uuid,'CHANGE','https://reinir.mooo.com/files/ebc56232-cc21-4733-9d81-4bef91824b75.png','','INVE293489250411','2025-04-07 22:19:37.065362','2025-04-11 14:27:02.95004',false,false),
	 ('4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'7c9e6679-7425-40de-944b-e07fc1f90ae7'::uuid,'03485000-6353-4e33-b878-32328d89ba51'::uuid,'AUDIT','https://reinir.mooo.com/files/adbc4af4-cd7c-4919-9461-0069da815773.jpg','Audit from frontend','INVE041866250411','2025-04-11 14:34:41.355835','2025-04-11 14:34:41.355835',false,false);


INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('39cd2b1d-fbdc-4171-b2b4-8d7511ffbaf7'::uuid,'4d3fe7b6-e35f-4d53-8cbd-be248ecf2a25'::uuid,'d8f53197-ca00-44e8-a5ce-4402c1912c26'::uuid,20,0,'INVE760048250411','2025-04-11 14:22:59.605945','2025-04-11 14:22:59.605945',false,false),
	 ('e5cf1889-091b-45cb-bb5d-e95f2029ff27'::uuid,'4d3fe7b6-e35f-4d53-8cbd-be248ecf2a25'::uuid,'d4081bd7-9657-49d5-8b6a-27bb04fc3b3c'::uuid,20,0,'INVE424810250411','2025-04-11 14:22:59.605942','2025-04-11 14:22:59.605942',false,false),
	 ('e7f6902b-ea53-4bda-9371-112de65b1d49'::uuid,'4d3fe7b6-e35f-4d53-8cbd-be248ecf2a25'::uuid,'50205dbf-4ee3-47d3-a842-25f783edd435'::uuid,20,0,'INVE236137250411','2025-04-11 14:22:59.605933','2025-04-11 14:22:59.605933',false,false),
	 ('faf5fe40-c9d8-434b-b9b6-db929b859a34'::uuid,'4d3fe7b6-e35f-4d53-8cbd-be248ecf2a25'::uuid,'fc9f5e81-248b-4305-93b4-44908e300175'::uuid,20,0,'INVE653488250411','2025-04-11 14:22:59.605496','2025-04-11 14:22:59.605496',false,false),
	 ('b2f454f5-6a38-4b88-8276-8cc9225b4afe'::uuid,'4e633829-951f-431f-abd7-01fa0eb14abe'::uuid,'7a2379ca-4556-4646-9030-9ad551a6f82e'::uuid,40,0,'INVE280466250411','2025-04-11 14:23:33.214602','2025-04-11 14:23:33.214602',false,false),
	 ('b3bee012-1467-46ed-ae58-f300bbfbf8c9'::uuid,'4e633829-951f-431f-abd7-01fa0eb14abe'::uuid,'4da7a14e-1f35-42b8-b570-82bd6ec4abf3'::uuid,40,0,'INVE601619250411','2025-04-11 14:23:33.214619','2025-04-11 14:23:33.214619',false,false),
	 ('beaaf90d-5389-47d5-93ce-51c6399fa286'::uuid,'4e633829-951f-431f-abd7-01fa0eb14abe'::uuid,'abb20deb-e6cd-499c-a10a-a09c0933c5e5'::uuid,40,0,'INVE927188250411','2025-04-11 14:23:33.214629','2025-04-11 14:23:33.214629',false,false),
	 ('f5a262f9-a69b-4d35-8a2f-55d5bf17a158'::uuid,'4e633829-951f-431f-abd7-01fa0eb14abe'::uuid,'e7908f0d-c961-44a4-9caa-7b2f46677226'::uuid,40,0,'INVE177499250411','2025-04-11 14:23:33.214633','2025-04-11 14:23:33.214634',false,false),
	 ('429a036d-f431-40c4-846c-258f22abc1b6'::uuid,'22464b74-efe7-456a-9f0e-6167afcbd523'::uuid,'40cf7b34-71e9-4d46-af8c-bc1986f1449f'::uuid,20,0,'INVE635982250411','2025-04-11 14:26:00.456611','2025-04-11 14:26:00.456611',false,false),
	 ('50f5d2fa-8d19-488c-9654-941713b7b13d'::uuid,'22464b74-efe7-456a-9f0e-6167afcbd523'::uuid,'be0405d7-a77e-40ab-a559-5e77ea929052'::uuid,20,0,'INVE874675250411','2025-04-11 14:26:00.456622','2025-04-11 14:26:00.456622',false,false);
INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('687f1188-28c9-4778-a72c-be742da4f5b4'::uuid,'22464b74-efe7-456a-9f0e-6167afcbd523'::uuid,'1067802d-ca9d-46c7-8301-0d1391fc4b5e'::uuid,20,0,'INVE056340250411','2025-04-11 14:26:00.456626','2025-04-11 14:26:00.456626',false,false),
	 ('8db160b0-4066-4170-bec6-47d3387fc6b1'::uuid,'22464b74-efe7-456a-9f0e-6167afcbd523'::uuid,'abf8196e-6ee6-436a-8271-7d9448384f24'::uuid,50,0,'INVE097631250411','2025-04-11 14:26:00.456624','2025-04-11 14:26:00.456624',false,false),
	 ('c3a61217-67ad-415b-aa9e-ad6c7aeec69f'::uuid,'22464b74-efe7-456a-9f0e-6167afcbd523'::uuid,'58fedb73-b9ac-41b1-a8f9-d30575a00356'::uuid,50,0,'INVE230643250411','2025-04-11 14:26:00.456618','2025-04-11 14:26:00.456618',false,false),
	 ('eb90ef9c-8d5a-4917-9d1a-116224228a41'::uuid,'22464b74-efe7-456a-9f0e-6167afcbd523'::uuid,'821d7427-cc07-4d9b-9dde-dea596a1e54c'::uuid,20,0,'INVE344408250411','2025-04-11 14:26:00.456628','2025-04-11 14:26:00.456628',false,false),
	 ('a1fc1198-5b2a-48b1-acb0-1c8781386c7a'::uuid,'93e539b9-a487-4975-bac7-ec44f7e95a3c'::uuid,'0c3b8981-1424-4541-9b19-a202b5db46d9'::uuid,30,0,'INVE240322250411','2025-04-11 14:27:02.950076','2025-04-11 14:27:02.950076',false,false),
	 ('aea61b78-d767-4992-a5c2-9404f93f8689'::uuid,'93e539b9-a487-4975-bac7-ec44f7e95a3c'::uuid,'b2c0d70b-0add-4f87-baa1-a86798e3c2e3'::uuid,40,0,'INVE048896250411','2025-04-11 14:27:02.950064','2025-04-11 14:27:02.950064',false,false),
	 ('b5077e29-9a4c-43bb-b999-fb8360a282c5'::uuid,'93e539b9-a487-4975-bac7-ec44f7e95a3c'::uuid,'fe0136c7-7f19-4889-b5e9-965dde2ea6d9'::uuid,20,0,'INVE290815250411','2025-04-11 14:27:02.950073','2025-04-11 14:27:02.950073',false,false),
	 ('e8ad501e-c93b-4d02-85b2-df4cced89b75'::uuid,'93e539b9-a487-4975-bac7-ec44f7e95a3c'::uuid,'821d7427-cc07-4d9b-9dde-dea596a1e54c'::uuid,50,20,'INVE761043250411','2025-04-11 14:27:02.950079','2025-04-11 14:27:02.950079',false,false),
	 ('17fbc052-efef-49cd-8bb7-96c380bfac01'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'fe0136c7-7f19-4889-b5e9-965dde2ea6d9'::uuid,10,20,'INVE673730250411','2025-04-11 14:34:41.356984','2025-04-11 14:34:41.356984',false,false),
	 ('2c411af3-e0f5-4596-b83d-8b61acdde6e9'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'038dafc0-21ca-4860-b8a4-c2d7ea1d778e'::uuid,30,0,'INVE462782250411','2025-04-11 14:34:41.356943','2025-04-11 14:34:41.356944',false,false);
INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('38d19120-f996-49b3-add2-73a6366fe137'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'d4081bd7-9657-49d5-8b6a-27bb04fc3b3c'::uuid,10,20,'INVE023209250411','2025-04-11 14:34:41.356952','2025-04-11 14:34:41.356952',false,false),
	 ('39901182-7d34-43e7-ba15-e0a3fcc24936'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'fc9f5e81-248b-4305-93b4-44908e300175'::uuid,10,20,'INVE978355250411','2025-04-11 14:34:41.356957','2025-04-11 14:34:41.356957',false,false),
	 ('4679539f-0657-44d6-b6d7-058333ccc895'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'be0405d7-a77e-40ab-a559-5e77ea929052'::uuid,10,20,'INVE206007250411','2025-04-11 14:34:41.356978','2025-04-11 14:34:41.356978',false,false),
	 ('59240048-6ced-41eb-9d52-fc2bf3fc03a3'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'50205dbf-4ee3-47d3-a842-25f783edd435'::uuid,10,20,'INVE441242250411','2025-04-11 14:34:41.35695','2025-04-11 14:34:41.35695',false,false),
	 ('5b370a2b-1071-43ba-80e9-6df332898789'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'d8f53197-ca00-44e8-a5ce-4402c1912c26'::uuid,10,20,'INVE748567250411','2025-04-11 14:34:41.356954','2025-04-11 14:34:41.356954',false,false),
	 ('66aa8465-8052-4114-8115-80b2d0a3d26f'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'4da7a14e-1f35-42b8-b570-82bd6ec4abf3'::uuid,-10,40,'INVE529890250411','2025-04-11 14:34:41.356959','2025-04-11 14:34:41.356959',false,false),
	 ('70415ddb-b859-4d2e-a8b0-f841cca4e7cb'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'58fedb73-b9ac-41b1-a8f9-d30575a00356'::uuid,-20,50,'INVE845661250411','2025-04-11 14:34:41.356971','2025-04-11 14:34:41.356971',false,false),
	 ('74a0e343-9dbc-41af-b3c9-c1237ba1b593'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'83da7102-bb37-42f3-b14a-784b3d820c47'::uuid,30,0,'INVE723004250411','2025-04-11 14:34:41.356937','2025-04-11 14:34:41.356937',false,false),
	 ('79c0a221-0b80-4f32-be5a-c7d490b22037'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'e7908f0d-c961-44a4-9caa-7b2f46677226'::uuid,-10,40,'INVE600054250411','2025-04-11 14:34:41.356965','2025-04-11 14:34:41.356965',false,false),
	 ('928cf89b-ba31-4f39-be87-48349d3fe51d'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'abf8196e-6ee6-436a-8271-7d9448384f24'::uuid,-20,50,'INVE784796250411','2025-04-11 14:34:41.356976','2025-04-11 14:34:41.356976',false,false);
INSERT INTO inventory_note_item (inventory_note_item_id,inventory_note_id,product_in_store_id,stock_change,before_change,code,created_at,updated_at,is_deleted,is_suspended) VALUES
	 ('92a0e63c-9534-41ae-986c-9e37024fe5a9'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'4bf8b89c-fba4-4954-8ab9-cee059b97b1f'::uuid,30,0,'INVE864995250411','2025-04-11 14:34:41.356948','2025-04-11 14:34:41.356948',false,false),
	 ('975a49fb-80c0-425d-b02f-787e25c4a301'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'fc8aec6a-39a7-4a27-8184-c49b6d833ac6'::uuid,30,0,'INVE864303250411','2025-04-11 14:34:41.356785','2025-04-11 14:34:41.356785',false,false),
	 ('ab6dd684-0a18-4258-98c8-327336b8e02e'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'40cf7b34-71e9-4d46-af8c-bc1986f1449f'::uuid,10,20,'INVE693173250411','2025-04-11 14:34:41.356968','2025-04-11 14:34:41.356968',false,false),
	 ('b0b188a7-60e9-4613-8c7b-8984709d0b2c'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'b2c0d70b-0add-4f87-baa1-a86798e3c2e3'::uuid,-10,40,'INVE637415250411','2025-04-11 14:34:41.356982','2025-04-11 14:34:41.356982',false,false),
	 ('c98dd50d-2d0c-4b5c-9f64-e11e5249eadc'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'abb20deb-e6cd-499c-a10a-a09c0933c5e5'::uuid,-10,40,'INVE341753250411','2025-04-11 14:34:41.356963','2025-04-11 14:34:41.356963',false,false),
	 ('d549e4af-9dfe-4d1d-bdcf-45285b245497'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'7a2379ca-4556-4646-9030-9ad551a6f82e'::uuid,-10,40,'INVE732069250411','2025-04-11 14:34:41.356961','2025-04-11 14:34:41.356961',false,false),
	 ('d5a8539c-c07d-4e5a-99db-3168c3e94c1c'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'1067802d-ca9d-46c7-8301-0d1391fc4b5e'::uuid,10,20,'INVE257353250411','2025-04-11 14:34:41.356966','2025-04-11 14:34:41.356966',false,false),
	 ('e4e5ab85-a0a3-4e93-bc81-2cb65bd96eb1'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'821d7427-cc07-4d9b-9dde-dea596a1e54c'::uuid,-40,70,'INVE031019250411','2025-04-11 14:34:41.35698','2025-04-11 14:34:41.35698',false,false),
	 ('fa9f8870-494c-446a-810d-600d7bab1b6e'::uuid,'4041d74c-5eb8-4a88-9d9a-180e3921ec92'::uuid,'7080fe75-58f5-4e40-b5db-747f7ea5f0aa'::uuid,30,0,'INVE816131250411','2025-04-11 14:34:41.356946','2025-04-11 14:34:41.356946',false,false);

COMMIT;
