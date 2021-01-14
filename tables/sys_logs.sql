CREATE TABLE hr.sys_logs
   (    
  log_id NUMBER,
  app_id number,
  message VARCHAR2(1000),
  log_date date,
  return_code number
   )
  PARTITION BY RANGE (log_date) INTERVAL (NUMTOYMINTERVAL (1, 'MONTH'))
  (PARTITION init_p0 VALUES LESS THAN (TO_DATE('01-01-1991', 'DD-MM-YYYY')));
  CREATE INDEX HR.APP_ID_IDX ON HR.sys_logs (app_id) local;
  CREATE INDEX HR.LOG_ID_IDX ON HR.sys_logs (log_id) local;
