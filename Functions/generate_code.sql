CREATE OR REPLACE FUNCTION generate_code(prefix TEXT)
RETURNS TEXT AS $$
DECLARE
    random_number INT;
BEGIN
    -- Generate a random 6-digit number
    SELECT FLOOR(RANDOM() * 90000000 + 10000000) INTO random_number;
    
    -- Concatenate the prefix with the random number
    RETURN prefix || random_number;
END;
$$ LANGUAGE plpgsql;