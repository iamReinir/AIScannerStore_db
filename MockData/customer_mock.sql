INSERT INTO customer (customer_id, customer_name, customer_email, customer_phone, image_url, password_hash) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'Alice Johnson', 'alice@example.com', '123-456-7890', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg=='),
('6f9619ff-8b86-d011-b42d-00c04fc964ff', 'Bob Smith', 'bob@example.com', '987-654-3210', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg=='),
('1b4e28ba-2fa1-11d2-883f-0016d3cca427', 'Charlie Brown', 'charlie@example.com', '555-123-4567', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg=='),
('110ec58a-a0f2-4ac4-8393-c866d813b8d1', 'Diana Prince', 'diana@example.com', '444-555-6666', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg=='),
('7d793037-a124-486c-91f8-49a8b8b4f9da', 'Edward Nigma', 'edward@example.com', '222-333-4444', '', 'AQAAAAIAAYagAAAAEDeblKGnP3xHJN4TpGfQGq24utN+HlV3/X9i7CMzZ5lPohJJHUZbjvOK+mJ+bfIhZg==');

INSERT INTO customer(customer_id, customer_name, customer_phone, customer_email, image_url, password_hash, created_at, updated_at, is_deleted, is_suspended)
VALUES('65e7ae60-1e61-4ef9-88c2-e6f3b3bc2f21', 'Lợi Nguyễn', '1234567', 'dongloi2504@gmail.com', '', 'AQAAAAIAAYagAAAAEO4oH0xNjb5agvpL1sPzytxzqq0Yz1UxApqBWKzxgDyDvLNW4N+8HHH7JSQWfNykTw==', '2025-03-11 17:16:09.723', '2025-03-11 17:16:09.732', false, false);