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
);