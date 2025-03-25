CREATE TABLE product_in_store (
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
