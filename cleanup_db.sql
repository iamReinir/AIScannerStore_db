BEGIN;

UPDATE "order" o 
SET 
	status='CANCELLED',
	updated_at = NOW()
WHERE  
	o.status='CREATED'
	AND created_at < NOW() - INTERVAL '1 hour';

COMMIT;