CREATE TABLE promotion_mock (
    promotion_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	detail JSONB,
	"type" varchar(50) DEFAULT 'UNKNOWN',
    -- Common for all table    
	code VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);