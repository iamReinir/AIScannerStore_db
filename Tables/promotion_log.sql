CREATE TABLE promotion_log (
    promotion_log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	promotion_id UUID NOT NULL,
	applied_id UUID,
	applied_entity VARCHAR(255),
	CONSTRAINT fk_log_of_promotion FOREIGN KEY (promotion_id)
        REFERENCES promotion(promotion_id) ON DELETE CASCADE,
    -- Common for all table    
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);