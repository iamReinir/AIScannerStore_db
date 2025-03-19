CREATE TABLE inventory_log_item (
    inventory_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inventory_note_id UUID NOT NULL,
    product_id UUID,
    product_name varchar(255),
    change_amount int,
    CONSTRAINT fk_inventory_log_item FOREIGN KEY (inventory_note_id) 
    REFERENCES inventory_note(inventory_note_id) ON DELETE CASCADE,
    CONSTRAINT fk_inv_log_product FOREIGN KEY (product_id) 
    REFERENCES product(product_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE   
);
