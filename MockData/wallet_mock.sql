INSERT INTO wallet (customer_id, wallet_id, balance, priority, wallet_type) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'e2b7c3f9-5a44-4b1e-9b8d-7f3d2e1a6c75', 7500000.00, 0, 'MAIN'),
('6f9619ff-8b86-d011-b42d-00c04fc964ff', 'a8c1f2d3-7e5b-42f6-9a9c-1d4e8b3f6c27', 250000.00, 0, 'MAIN'),
('1b4e28ba-2fa1-11d2-883f-0016d3cca427', 'd4f8a2b9-3e7c-4a1d-8c5f-6b2e9f7a3c81', 100000.00, 0, 'MAIN'),
('110ec58a-a0f2-4ac4-8393-c866d813b8d1', 'b3f1c6d7-9a42-4bfb-89c8-8e4c1f52e23a', 750000.00, 0, 'MAIN'),
('7d793037-a124-486c-91f8-49a8b8b4f9da', '9f3d7b2a-5c8e-4f1d-6a2c-7e8b4a9f3c15', 850000.00, 0, 'MAIN');


INSERT INTO wallet (wallet_id, customer_id, balance, priority, wallet_type) VALUES
	('0195836d-7063-7e95-99bc-e59da39bb55e','65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 3800000.00, 0, 'MAIN'),
	('0195836d-7063-7e95-99bc-e59da39bb55f','65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 60000.00, 1, 'BONUS');

INSERT INTO wallet_transaction (wallet_id, amount, type, order_id, deposit_id, description, created_at, updated_at) VALUES
('0195836d-7063-7e95-99bc-e59da39bb55e', 3000000.00, 'DEPOSIT', NULL,'2e4b28ba-3fa2-22d2-884f-0016d3cca431','Deposit','2025-03-11 19:00:00', '2025-03-11 19:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', -1465100.00, 'ORDER_DEDUCT','24962082-ea1a-4829-8a9d-bb35118649a1',NULL,'Order', '2025-03-11 19:30:00', '2025-03-11 19:30:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', -1383200.00, 'ORDER_DEDUCT','ff718dc5-340c-4323-9b95-4391260b16d8',NULL,'Order', '2025-03-11 20:00:00', '2025-03-11 20:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', 800000.00, 'DEPOSIT',NULL,'3f5e48ca-4fa3-33e3-995f-0026d3dda432','Deposit', '2025-03-11 21:00:00', '2025-03-11 21:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55e', -75000.00, 'ORDER_ERROR','307506a4-87a9-418d-97a6-43829f58f90a',NULL,'Order error', '2025-03-11 22:00:00', '2025-03-11 22:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55f', 15000.00, 'DEPOSIT', NULL,'2e4b28ba-3fa2-22d2-884f-0016d3cca431','Deposit','2025-03-11 19:00:00', '2025-03-11 19:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55f', 8000.00, 'DEPOSIT', NULL,'3f5e48ca-4fa3-33e3-995f-0026d3dda432','Deposit','2025-03-11 19:00:00', '2025-03-11 19:00:00'),
('0195836d-7063-7e95-99bc-e59da39bb55f', -15000.00, 'ORDER_DEDUCT','24962082-ea1a-4829-8a9d-bb35118649a1',NULL,'Online shopping', '2025-03-11 19:30:00', '2025-03-11 19:30:00'),
('0195836d-7063-7e95-99bc-e59da39bb55f', -8000.00, 'ORDER_DEDUCT','ff718dc5-340c-4323-9b95-4391260b16d8',NULL,'Mobile recharge', '2025-03-11 20:00:00', '2025-03-11 20:00:00');