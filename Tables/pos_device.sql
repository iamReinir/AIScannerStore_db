CREATE TABLE pos_device (
    device_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),    
	store_id UUID,
	hashed_token TEXT,
	expire_at TIMESTAMP DEFAULT NULL,
    CONSTRAINT fk_pos_of_store FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);