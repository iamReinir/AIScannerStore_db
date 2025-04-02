INSERT INTO inventory_note (
	inventory_note_id,
	store_id,
	staff_id,
	"type",
	image_url,
	"description",
	code)
VALUES

	('69c89ae3-3d7f-44a1-bdcc-98df64f39486',
	'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111',
	'd8d0e33a-a490-4fce-beee-fcad5eaef9a4',
	'CHANGE',
	'https://reinir.mooo.com/files/remi.jpg',
	'Inventory change mock data',
	'NOTE000000'),
	
	('46fb8481-a0b4-43f4-8758-355b0d1f3bc5',
	'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111',
	'd8d0e33a-a490-4fce-beee-fcad5eaef9a4',
	'AUDIT',
	'https://reinir.mooo.com/files/food.jpg',
	'Inventory audit mock data'
	'NOTE000001'),
	
	('69c89ae3-3d7f-44a1-bdcc-98df64f39486',
	'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111',
	'0a5c236e-ff54-449e-834c-99c113b3b582',
	'CHANGE',
	'https://reinir.mooo.com/files/food.jpg',
	'Inventory change mock data',
	'NOTE000002'),
	
	('cc407916-b4b7-434f-b671-7dd18d9c7bdf',
	'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111',
	'0a5c236e-ff54-449e-834c-99c113b3b582',
	'AUDIT',
	'https://reinir.mooo.com/files/food.jpg',
	'Inventory change mock data',
	'NOT000003'),
	
	('84c56a7c-7753-4a44-9b95-ac7278c7b24f',
	'a1e2f8c4-4c1b-4f2a-bf71-1f3c7a1b1111',
	'0a5c236e-ff54-449e-834c-99c113b3b582',
	'CHANGE',
	'https://reinir.mooo.com/files/food.jpg',
	'Inventory change mock data',
	'NOTE000004');
	
/*
INSERT INTO inventory_note_item
	
	(inventory_note_id,
	product_in_store_id,
	stock_change,
	before_change)

VALUES
	
	('69c89ae3-3d7f-44a1-bdcc-98df64f39486',
	'572d8467-2e33-416c-baa6-9da8b25ceedd',
	10,
	20),
	
	('69c89ae3-3d7f-44a1-bdcc-98df64f39486',
	'572d8467-2e33-416c-baa6-9da8b25ceedd',
	10,
	20),
*/
	
	
	
	