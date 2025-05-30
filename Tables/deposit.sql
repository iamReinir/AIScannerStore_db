CREATE TABLE deposit (
    deposit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    amount NUMERIC(20,2),
	status VARCHAR(50),
	applied_promotion UUID,
    CONSTRAINT fk_deposit_of_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
    -- Common for all table
	code VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE    
);

