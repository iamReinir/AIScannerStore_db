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
