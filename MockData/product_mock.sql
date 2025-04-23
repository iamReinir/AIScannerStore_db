INSERT INTO category (category_id, category_name, category_description, code) VALUES
('f1a2b3c4-5678-90ab-cdef-123456789001', 'Bread & Pastries', 'A selection of freshly baked bread, croissants, and sandwiches.', 'CATE09877665523'),
('f1a2b3c4-5678-90ab-cdef-123456789002', 'Cakes & Desserts', 'Delicious cakes, muffins, and pastries for any occasion.', 'CATE012125125'),
('f1a2b3c4-5678-90ab-cdef-123456789003', 'Soft Drinks & Energy Drinks', 'Carbonated beverages and energy drinks for a refreshing boost.', 'CATE0987323223'),
('f1a2b3c4-5678-90ab-cdef-123456789004', 'Alcoholic Drinks', 'A variety of beers and other alcoholic beverages.', 'CATE0235365523'),
('f1a2b3c4-5678-90ab-cdef-123456789005', 'Bottled Water', 'Clean and refreshing bottled water for hydration.', 'CATE03532343'),
('f1a2b3c4-5678-90ab-cdef-123456789006', 'Packaging & Containers', 'Various drink packaging such as bottles and cans.', 'CATE098745233');


INSERT INTO product (product_id, product_name, product_description, category_id, code, base_price) VALUES
('a1b2c3d4-5678-90ab-cdef-123456789001', 'Butter Sugar Bread', 'A soft and sweet bread topped with butter and sugar.', 'f1a2b3c4-5678-90ab-cdef-123456789001', 'BSB001', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789002', 'Chicken Floss Bread', 'A fluffy bread topped with savory chicken floss.', 'f1a2b3c4-5678-90ab-cdef-123456789001', 'CFB002', 18000),
('a1b2c3d4-5678-90ab-cdef-123456789003', 'Chicken Floss Sandwich', 'A sandwich filled with rich and flavorful chicken floss.', 'f1a2b3c4-5678-90ab-cdef-123456789001', 'CFS003', 20000),
('a1b2c3d4-5678-90ab-cdef-123456789004', 'Cream Puff', 'A light and airy pastry filled with creamy custard.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'CP004', 12000),
('a1b2c3d4-5678-90ab-cdef-123456789005', 'Croissant', 'A flaky and buttery French pastry.', 'f1a2b3c4-5678-90ab-cdef-123456789001', 'CR005', 25000),
('a1b2c3d4-5678-90ab-cdef-123456789006', 'Donut', 'A soft and sweet deep-fried treat with various toppings.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'DN006', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789007', 'Muffin', 'A moist and fluffy baked treat, perfect for any time of the day.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'MF007', 20000),
('a1b2c3d4-5678-90ab-cdef-123456789008', 'Salted Egg Sponge Cake', 'A soft sponge cake infused with rich salted egg flavor.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'SESC008', 22000),
('a1b2c3d4-5678-90ab-cdef-123456789009', 'Sandwich', 'A classic combination of bread and filling for a satisfying meal.', 'f1a2b3c4-5678-90ab-cdef-123456789001', 'SW009', 20000),
('a1b2c3d4-5678-90ab-cdef-123456789010', 'Sponge Cake', 'A light and airy cake with a delicate texture.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'SC010', 18000),
('a1b2c3d4-5678-90ab-cdef-123456789011', 'Tiramisu', 'A classic Italian dessert with layers of coffee-soaked sponge and mascarpone.', 'f1a2b3c4-5678-90ab-cdef-123456789002', 'TM011', 30000),
('a1b2c3d4-5678-90ab-cdef-123456789012', 'Beer Tiger', 'A popular beer brand with a refreshing taste.', 'f1a2b3c4-5678-90ab-cdef-123456789004', 'BT012', 25000),
('a1b2c3d4-5678-90ab-cdef-123456789013', 'Boncha', 'A fizzy and refreshing flavored soft drink.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'BC013', 20000),
('a1b2c3d4-5678-90ab-cdef-123456789014', 'Bottle', 'A standard drink bottle container.', 'f1a2b3c4-5678-90ab-cdef-123456789006', 'BTL014', 5000),
('a1b2c3d4-5678-90ab-cdef-123456789015', 'Can', 'A convenient canned drink packaging.', 'f1a2b3c4-5678-90ab-cdef-123456789006', 'CAN015', 5000),
('a1b2c3d4-5678-90ab-cdef-123456789016', 'CocaCola', 'The world-famous cola soft drink.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'CC016', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789017', 'CocaCola Light', 'A low-calorie version of the classic CocaCola.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'CCL017', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789018', 'Green Tea', 'A refreshing bottled green tea beverage.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'GT018', 12000),
('a1b2c3d4-5678-90ab-cdef-123456789019', 'Pepsi', 'A bold and refreshing cola beverage.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'PP019', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789020', 'Red Bull', 'A popular energy drink that gives you wings.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'RB020', 15000),
('a1b2c3d4-5678-90ab-cdef-123456789021', 'Revive Lemon Salt', 'A hydrating sports drink with a lemon-salt flavor.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'RLS021', 12000),
('a1b2c3d4-5678-90ab-cdef-123456789022', 'Revive Regular', 'An electrolyte drink for hydration and energy.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'RR022', 12000),
('a1b2c3d4-5678-90ab-cdef-123456789023', 'Strawberry Sting', 'A strawberry-flavored energy drink.', 'f1a2b3c4-5678-90ab-cdef-123456789003', 'SS023', 12000),
('a1b2c3d4-5678-90ab-cdef-123456789024', 'Vinh Hao Water', 'Premium bottled mineral water for daily hydration.', 'f1a2b3c4-5678-90ab-cdef-123456789005', 'VHW024', 10000);

-- Food Mappings
INSERT INTO food_mapping (food_product_id, map_code) VALUES
('a1b2c3d4-5678-90ab-cdef-123456789001', '0'),
('a1b2c3d4-5678-90ab-cdef-123456789002', '1'),
('a1b2c3d4-5678-90ab-cdef-123456789003', '2'),
('a1b2c3d4-5678-90ab-cdef-123456789004', '3'),
('a1b2c3d4-5678-90ab-cdef-123456789005', '4'),
('a1b2c3d4-5678-90ab-cdef-123456789006', '5'),
('a1b2c3d4-5678-90ab-cdef-123456789007', '6'),
('a1b2c3d4-5678-90ab-cdef-123456789008', '7'),
('a1b2c3d4-5678-90ab-cdef-123456789009', '8'),
('a1b2c3d4-5678-90ab-cdef-123456789010', '9'),
('a1b2c3d4-5678-90ab-cdef-123456789011', '10');

-- Drink Mappings
INSERT INTO drink_mapping (drink_product_id, map_code) VALUES
('a1b2c3d4-5678-90ab-cdef-123456789012', '0'),
('a1b2c3d4-5678-90ab-cdef-123456789014', '1'),
('a1b2c3d4-5678-90ab-cdef-123456789015', '2'),
('a1b2c3d4-5678-90ab-cdef-123456789016', '3'),
('a1b2c3d4-5678-90ab-cdef-123456789017', '4'),
('a1b2c3d4-5678-90ab-cdef-123456789018', '5'),
('a1b2c3d4-5678-90ab-cdef-123456789019', '6'),
('a1b2c3d4-5678-90ab-cdef-123456789020', '7'),
('a1b2c3d4-5678-90ab-cdef-123456789021', '8'),
('a1b2c3d4-5678-90ab-cdef-123456789022', '9'),
('a1b2c3d4-5678-90ab-cdef-123456789023', '10'),
('a1b2c3d4-5678-90ab-cdef-123456789024', '11');
