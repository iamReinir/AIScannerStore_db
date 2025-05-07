CREATE TABLE wallet_transaction (
    wallet_transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),    
	wallet_id UUID NOT NULL,
    amount decimal(20,2),
	"type" varchar(50),
	description TEXT,
	order_id UUID,
	deposit_id UUID,
    CONSTRAINT fk_transaction_of_wallet FOREIGN KEY (wallet_id) REFERENCES wallet(wallet_id) ON DELETE CASCADE,
	CONSTRAINT fk_transaction_of_order FOREIGN KEY (order_id) REFERENCES "order"(order_id) ON DELETE SET NULL,
	CONSTRAINT fk_transaction_of_deposit FOREIGN KEY (deposit_id) REFERENCES deposit(deposit_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);