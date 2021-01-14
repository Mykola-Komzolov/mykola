CREATE OR REPLACE TRIGGER DELETE_AS_DATE
BEFORE INSERT ON HR.SYS_LOGS
FOR EACH ROW
WHEN (NEW.LOG_DATE IS NOT NULL)
DECLARE

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

DELETE FROM HR.SYS_LOGS WHERE LOG_DATE < TRUNC(SYSDATE, 'DD') - 45;

COMMIT;

END DELETE_AS_DATE;
