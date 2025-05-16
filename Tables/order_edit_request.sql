CREATE TABLE order_edit_request (
    request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
	order_id UUID NOT NULL,
	replier_id UUID,
	request_content TEXT,
	reply_content TEXT,
	reply_date TIMESTAMP,
	STATUS VARCHAR(50) NOT NULL,
	CONSTRAINT fk_edit_request_of_customer FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id) ON DELETE CASCADE,
		CONSTRAINT fk_edit_request_for_order FOREIGN KEY (order_id)
        REFERENCES "order"(order_id) ON DELETE CASCADE,
	CONSTRAINT fk_staff_answer_edit_request FOREIGN KEY (replier_id)
        REFERENCES staff(staff_id) ON DELETE SET NULL,
    -- Common for all table
	code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_suspended BOOLEAN DEFAULT FALSE
);