CREATE TABLE inventory_log_item (
    inventory_log_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_log_id UUID NOT NULL,
    product_id UUID,
    product_name varchar(255),
    change_amount int,
    CONSTRAINT fk_inventory_log_item FOREIGN KEY (inventory_log_id) 
    REFERENCES inventory_log(inventory_log_id) ON DELETE CASCADE,
    CONSTRAINT fk_inv_log_product FOREIGN KEY (product_id) 
    REFERENCES product(product_id) ON DELETE SET NULL,
    -- Common for all table    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE   
);
