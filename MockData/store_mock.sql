
INSERT INTO store (
    store_id,
    store_name,
    store_location 
) 
VALUES
    ('a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'SuperMart Downtown', '123 Main Street, Downtown'),
    ('b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'QuickShop Central', '456 Center Avenue, Central'),
    ('c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'MegaStore North', '789 North Road, Uptown'),
    ('d4a6b9e2-7c14-44e2-8b71-5f2c3a1c4444', 'BudgetMart East', '321 East Lane, Eastside'),
    ('e5b3c2f1-2d75-4f3a-9a21-3b4a1c8f5555', 'ValueShop West', '654 West Street, Westend'),
    ('f6c4e1a7-1b63-41c2-bf82-2f1c7a5b6666', 'Neighborhood Market', '987 South Avenue, Southside'),
    ('a7d2b5c3-6f14-49c2-9f31-7a1c4b2f7777', 'FreshMart Hills', '159 Hills Road, Hilltop'),
    ('b8e1c3f7-4a62-48d2-bf41-1c7a2b8f8888', 'GreenLeaf Organic', '753 Garden Street, Greenfield'),
    ('c9f7a2d1-3b81-4e2a-bf24-4a1c5b7f9999', 'Urban Market', '246 City Center Blvd, Midtown'),
    ('d0a5e4c8-2b17-4f3a-bc52-3f1a7c2f0000', 'Family Grocery', '369 Maple Avenue, Riverside'),
    ('f47ac10b-58cc-4372-a567-0e02b2c3d479', 'Downtown Market', '123 Main Street, Downtown'),
    ('9c858901-8a57-4791-81fe-4c455b099bc9', 'Uptown Grocery', '456 Elm Street, Uptown'),
    ('3fa85f64-5717-4562-b3fc-2c963f66afa6', 'Central Plaza Store', '789 Oak Avenue, Central Plaza'),
    ('16fd2706-8baf-433b-82eb-8c7fada847da', 'Riverside Mart', '321 River Road, Riverside'),
    ('7c9e6679-7425-40de-944b-e07fc1f90ae7', 'Hilltop Supplies', '654 Pine Street, Hilltop');

INSERT INTO pos_device (device_id, store_id, code) VALUES
('3fa85f64-5717-4562-b3fc-2c963f66a001', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'TEST_DEV_1'),
('3fa85f64-5717-4562-b3fc-2c963f66a002', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'TEST_DEV_2'),
('3fa85f64-5717-4562-b3fc-2c963f66a003', 'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111', 'TEST_DEV_3'),

('3fa85f64-5717-4562-b3fc-2c963f66a004', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'TEST_DEV_4'),
('3fa85f64-5717-4562-b3fc-2c963f66a005', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'TEST_DEV_5'),
('3fa85f64-5717-4562-b3fc-2c963f66a006', 'b2c7e1d3-8a2c-46c3-9f21-4c2a7b1b2222', 'TEST_DEV_6'),

('3fa85f64-5717-4562-b3fc-2c963f66a007', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'TEST_DEV_7'),
('3fa85f64-5717-4562-b3fc-2c963f66a008', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'TEST_DEV_8'),
('3fa85f64-5717-4562-b3fc-2c963f66a009', 'c3f1a8b7-9d41-4e2a-bf13-2a1c4b7b3333', 'TEST_DEV_9');
