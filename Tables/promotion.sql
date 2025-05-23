CREATE TABLE promotion (
    promotion_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	detail JSONB,
	"type" varchar(50) DEFAULT 'UNKNOWN',
	start_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	end_at TIMESTAMP DEFAULT NULL,
	applied_customer_id UUID DEFAULT NULL,
	priority INTEGER NOT NULL DEFAULT 0,
	description TEXT,
	CONSTRAINT fk_promo_of_customer FOREIGN KEY (applied_customer_id)
        REFERENCES customer(customer_id) ON DELETE SET NULL,
    -- Common for all table    
	code VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);