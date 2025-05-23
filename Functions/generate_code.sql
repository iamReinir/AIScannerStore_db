CREATE OR REPLACE FUNCTION generate_code(prefix TEXT)
RETURNS TEXT AS $$
DECLARE
    random_number INT;
	today CHAR(7);
BEGIN
    -- Generate a random 6-digit number
    SELECT FLOOR(RANDOM() * 900000000 + 100000000) INTO random_number;
    SELECT TO_CHAR(NOW(), 'YYMMDD') INTO today;
    -- Concatenate the prefix with the random number
    RETURN prefix || random_number || today;
END;
$$ LANGUAGE plpgsql;