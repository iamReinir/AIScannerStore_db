BEGIN;


-- Change all CREATED orders older than 1 hour to CANCELLED
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
	AND created_at < NOW() - INTERVAL '7 days';
	

-- Change all CREATED deposits older than 1 hour to FAILED
UPDATE DEPOSIT o 
SET 
	status='FAILED',
	updated_at = NOW()
WHERE  
	o.status='CREATED'
	AND created_at < NOW() - INTERVAL '1 hour';

COMMIT;