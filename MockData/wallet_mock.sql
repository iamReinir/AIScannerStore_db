INSERT INTO wallet (customer_id, wallet_id, balance) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'e2b7c3f9-5a44-4b1e-9b8d-7f3d2e1a6c75', 7500000),
('6f9619ff-8b86-d011-b42d-00c04fc964ff', 'a8c1f2d3-7e5b-42f6-9a9c-1d4e8b3f6c27', 250000),
('1b4e28ba-2fa1-11d2-883f-0016d3cca427', 'd4f8a2b9-3e7c-4a1d-8c5f-6b2e9f7a3c81', 100000),
('110ec58a-a0f2-4ac4-8393-c866d813b8d1', 'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a', 750000),
('7d793037-a124-486c-91f8-49a8b8b4f9da', '9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15', 50000);

INSERT INTO wallet
	(wallet_id, customer_id, balance, priority, wallet_type)
VALUES('0195836d-7063-7e95-99bc-e59da39bb55e','65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 3000000, 0, 'MAIN');

INSERT INTO wallet
	(wallet_id, customer_id, balance, priority, wallet_type)
VALUES('0195836d-7063-7e95-99bc-e59da39bb55f','65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 60000, 1, 'PROMO');

INSERT INTO wallet_transaction (wallet_id, amount, status, type, description, created_at, updated_at) VALUES
('0195836d-7063-7e95-99bc-e59da39bb55e', 150000.00, 'SUCCESS', 'DEPOSIT', 'Salary deposit', '2025-03-11 19:00:00', '2025-03-11 19:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', -50000.00, 'SUCCESS', 'AI_NORMAL', 'Online shopping', '2025-03-11 19:30:00', '2025-03-11 19:30:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', -10000.00, 'PENDING', 'AI_NORMAL', 'Mobile recharge', '2025-03-11 20:00:00', '2025-03-11 20:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', 200000.00, 'SUCCESS', 'DEPOSIT', 'Freelance payment', '2025-03-11 21:00:00', '2025-03-11 21:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', -75000.00, 'FAILED', 'ORDER_ERROR', 'Restaurant bill', '2025-03-11 22:00:00', '2025-03-11 22:00:00');



INSERT INTO wallet_transaction (wallet_id, amount, status, type, description, created_at, updated_at) VALUES
('e2b7c3f9-5a44-4b1e-9b8d-7f3d2e1a6c75', 50000.00, 'SUCCESS', 'DEPOSIT', 'Deposit for account top-up', '2025-03-10 12:00:00', '2025-03-10 12:00:00'),
('e2b7c3f9-5a44-4b1e-9b8d-7f3d2e1a6c75', -20000.00, 'SUCCESS', 'AI_NORMAL', 'AI-detected transaction deduction', '2025-03-10 12:05:00', '2025-03-10 12:05:00'),
('a8c1f2d3-7e5b-42f6-9a9c-1d4e8b3f6c27', -5000.00, 'FAILED', 'AI_NORMAL', 'Failed AI transaction deduction', '2025-03-10 12:10:00', '2025-03-10 12:10:00'),
('a8c1f2d3-7e5b-42f6-9a9c-1d4e8b3f6c27', 10000.00, 'SUCCESS', 'DEPOSIT', 'Successful deposit', '2025-03-10 12:15:00', '2025-03-10 12:15:00'),
('d4f8a2b9-3e7c-4a1d-8c5f-6b2e9f7a3c81', 1500.00, 'FAILED', 'ORDER_ERROR', 'Failed order transaction', '2025-03-10 12:20:00', '2025-03-10 12:20:00'),
('d4f8a2b9-3e7c-4a1d-8c5f-6b2e9f7a3c81', -2500.00, 'SUCCESS', 'ORDER_ERROR', 'Successful order refund', '2025-03-10 12:25:00', '2025-03-10 12:25:00'),
('b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a', 75000.00, 'SUCCESS', 'DEPOSIT', 'Wallet funded via bank transfer', '2025-03-10 12:30:00', '2025-03-10 12:30:00'),
('b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a', -30000.00, 'FAILED', 'AI_NORMAL', 'Failed AI transaction deduction', '2025-03-10 12:35:00', '2025-03-10 12:35:00'),
('9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15', -10000.00, 'SUCCESS', 'AI_NORMAL', 'AI transaction processed successfully', '2025-03-10 12:40:00', '2025-03-10 12:40:00'),
('9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15', 20000.00, 'FAILED', 'DEPOSIT', 'Deposit failed due to bank error', '2025-03-10 12:45:00', '2025-03-10 12:45:00'),
('e2b7c3f9-5a44-4b1e-9b8d-7f3d2e1a6c75', -5000.00, 'SUCCESS', 'ORDER_ERROR', 'Order refund processed successfully', '2025-03-10 12:50:00', '2025-03-10 12:50:00'),
('a8c1f2d3-7e5b-42f6-9a9c-1d4e8b3f6c27', 18000.00, 'SUCCESS', 'DEPOSIT', 'Successful deposit from card', '2025-03-10 12:55:00', '2025-03-10 12:55:00'),
('d4f8a2b9-3e7c-4a1d-8c5f-6b2e9f7a3c81', -7000.00, 'FAILED', 'AI_NORMAL', 'AI transaction failed due to insufficient funds', '2025-03-10 13:00:00', '2025-03-10 13:00:00'),
('b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a', 55000.00, 'SUCCESS', 'DEPOSIT', 'Large deposit via wire transfer', '2025-03-10 13:05:00', '2025-03-10 13:05:00'),
('9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15', -5000.00, 'SUCCESS', 'ORDER_ERROR', 'Refund processed', '2025-03-10 13:10:00', '2025-03-10 13:10:00'),
('e2b7c3f9-5a44-4b1e-9b8d-7f3d2e1a6c75', -25000.00, 'FAILED', 'ORDER_ERROR', 'Order error due to processing failure', '2025-03-10 13:15:00', '2025-03-10 13:15:00'),
('a8c1f2d3-7e5b-42f6-9a9c-1d4e8b3f6c27', 30000.00, 'SUCCESS', 'DEPOSIT', 'New balance top-up', '2025-03-10 13:20:00', '2025-03-10 13:20:00'),
('d4f8a2b9-3e7c-4a1d-8c5f-6b2e9f7a3c81', -10000.00, 'FAILED', 'AI_NORMAL', 'AI transaction detected as fraudulent', '2025-03-10 13:25:00', '2025-03-10 13:25:00'),
('b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a', 50000.00, 'SUCCESS', 'DEPOSIT', 'Direct deposit from employer', '2025-03-10 13:30:00', '2025-03-10 13:30:00'),
('9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15', -7000.00, 'FAILED', 'ORDER_ERROR', 'Failed refund request', '2025-03-10 13:35:00', '2025-03-10 13:35:00');
