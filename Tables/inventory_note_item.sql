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
);