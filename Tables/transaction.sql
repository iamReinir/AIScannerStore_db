CREATE TABLE "transaction" (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID,
    wallet_id UUID,
    amount NUMERIC(10,2),
    "status" VARCHAR(50),
    "type" VARCHAR(50),
    category_id UUID,
    CONSTRAINT fk_transaction_of_wallet FOREIGN KEY (wallet_id) REFERENCES wallet(wallet_id) ON DELETE SET NULL,
    CONSTRAINT fk_transaction_of_payment FOREIGN KEY (payment_id) REFERENCES payment(payment_id) ON DELETE SET NULL,
    -- Common for all table    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);