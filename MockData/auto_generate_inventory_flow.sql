DO $$
DECLARE
    i INTEGER := 1;
	j INTEGER := 1;
	img VARCHAR(255) := 'https://reinir.mooo.com/files/104b9d37-f1ae-4d51-b193-bec7c3cf41d0.jpg';
	rand_date DATE;
	rand_card UUID;
	rand_device UUID;
	rand_prod UUID;
	prod_price DECIMAL(20,2);
	default_price DECIMAL(20,2);
	totl DECIMAL(20,2);
	prod_count INTEGER;
	item_count INTEGER;
	new_order_id UUID;
	rand_code VARCHAR(50);
	
BEGIN
    WHILE i <= 18000 LOOP
		-- Randomize day.
		j := 1;
		WHILE j <= 10 LOOP
            rand_date := CURRENT_DATE - (FLOOR(RANDOM() * 60 + 1))::int;
            EXIT WHEN EXTRACT(DOW FROM rand_date) BETWEEN 1 AND 5;
            -- 0 = Sunday, 6 = Saturday; keep only 1–5 (Mon–Fri)
			j := j + 1;
        END LOOP;
		
		-- Too many order and some will have duplicated code
		LOOP
            rand_code := generate_code('ORDE');
            EXIT WHEN NOT EXISTS (
				SELECT 1 FROM "order" WHERE code = rand_code
			);
        END LOOP;
		
		-- Get random card
		SELECT card_id into rand_card
		FROM card c 
		WHERE c.is_deleted = false 
		ORDER BY RANDOM() LIMIT 1;
		
		-- Get random device
		SELECT device_id INTO rand_device
		FROM pos_device d WHERE d.is_deleted = false
		ORDER BY RANDOM() LIMIT 1;
		
		INSERT INTO "order" (
			card_id,
			device_id,
			status,
			total,
			image1,
			image2,
			image3,
			created_at,
			code)
		VALUES (
			rand_card,
			rand_device,
			'FINISHED',
			0,
			img,
			img,
			img,
			rand_date,
			rand_code)
		RETURNING order_id 
		INTO new_order_id;
		
		totl := 0;
			
		prod_count := FLOOR(RANDOM() * 3 + 1)::int;
		
		WHILE prod_count > 0 LOOP
			-- Get random product
			SELECT 
				p.product_id, 
				pis.price 
			INTO
				rand_prod,
				prod_price
			FROM 
				product p 
				JOIN product_in_store pis ON p.product_id = pis.product_id
				JOIN pos_device pos ON pis.store_id = pos.store_id
			WHERE 
				p.is_deleted = false 
				AND pos.device_id = rand_device
			ORDER BY 
				RANDOM() LIMIT 1;
			
			-- Sometime, device/store dont have product or price
			IF rand_prod IS NULL THEN
				SELECT 
					p.product_id, 
					p.base_price
				INTO
					rand_prod,
					prod_price
				FROM 
					product p 
				WHERE 
					p.is_deleted = false 
				ORDER BY 
					RANDOM() LIMIT 1;
			END IF;
			
			item_count := FLOOR(RANDOM() * 2 + 1)::int;
			totl := totl + item_count * prod_price;
			
			-- Add order item
			INSERT INTO order_item 
				(order_id,
				product_id,
				count,
				unit_price,
				created_at)
			VALUES
				(new_order_id,
				rand_prod,
				item_count,
				prod_price,
				rand_date);
			-- Counter
			prod_count := prod_count - 1;
		END LOOP;
		

		UPDATE "order" SET total = totl WHERE order_id = new_order_id;

        i := i + 1;
    END LOOP;
END $$;
