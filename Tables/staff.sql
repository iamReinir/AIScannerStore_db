CREATE TABLE staff (
    staff_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    staff_name VARCHAR(255) NOT NULL,
    staff_phone VARCHAR(20),
    staff_email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    "role" varchar(50),
    store_id UUID,
    -- Common for all table
	code VARCHAR(255),
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
	'ADMIN');