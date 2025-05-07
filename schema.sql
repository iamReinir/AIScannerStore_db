CREATE TABLE store (
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

CREATE TABLE category (
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
);