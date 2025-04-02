CREATE TABLE password_reset_attempt (
    attempt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
	token TEXT NOT NULL,
    expire_time TIMESTAMP NOT NULL DEFAULT NOW() + INTERVAL '15 minutes',
    CONSTRAINT fk_attempt_of_customer FOREIGN KEY (customer_id)
    REFERENCES customer(customer_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE   
);