CREATE TABLE payment (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    wallet_id UUID,
    amount MONEY,
    "status" VARCHAR(50),
    CONSTRAINT fk_payment_from_wallet FOREIGN KEY (wallet_id) REFERENCES "wallet"(wallet_id) ON DELETE SET NULL,
    CONSTRAINT fk_payment_of_order FOREIGN KEY (order_id) REFERENCES "order"(order_id) ON DELETE CASCADE,
    -- Common for all table    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE    
);