BEGIN;

UPDATE "order" o 
SET 
	status='CANCELLED',
	updated_at = NOW()
WHERE  
	o.status='CREATED'
	AND created_at < NOW() - INTERVAL '1 hour';

UPDATE "order" o 
SET 
	status='FINISHED',
	updated_at = NOW()
WHERE  
	o.status='PAID'
	AND created_at < NOW() - INTERVAL '3 days';

COMMIT;