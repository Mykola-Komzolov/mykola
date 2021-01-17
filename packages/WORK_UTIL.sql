CREATE OR REPLACE PACKAGE WORK_UTIL AS

--Desc: Логирование действий
PROCEDURE TO_LOGS (
  P_APP_ID NUMBER,
  P_MESSAGE VARCHAR2,
  P_LOG_DATE DATE,
  P_RETURN_CODE NUMBER);

--Desc: Возврат зарплаты в зависимости от ид сотрудника 
FUNCTION GETSALARY(EMID IN NUMBER) RETURN NUMBER;

--Desc: Возврат системного времени в зависимости от параметра
PROCEDURE SYS_TIME_TEMPLATE(P_MODE IN VARCHAR2 DEFAULT 'DD');

--Desc: Удаление таблиц из заданного шаблона в параметре
PROCEDURE DROP_SELECTS_TBL(P_MODE IN VARCHAR2 DEFAULT 'VIEW', P_TABLES IN VARCHAR2);

--Desc: Обновление данных по клиенту
PROCEDURE ADD_NEW_EMP 
(P_FIRST_NAME VARCHAR2,
P_LAST_NAME VARCHAR2,
P_EMAIL VARCHAR2,
P_PHONE_NUMBER VARCHAR2,
P_HIRE_DATE DATE DEFAULT SYSDATE,
P_JOB_ID VARCHAR2,
P_SALARY NUMBER,
P_COMMISSION_PCT NUMBER DEFAULT NULL,
P_MANAGER_ID NUMBER DEFAULT 100,
P_DEPARTMENT_ID NUMBER);

END WORK_UTIL;

CREATE OR REPLACE PACKAGE BODY WORK_UTIL AS

/*******************************************
Author: Комзолов Н.О. / 17.01.2021
Desc:   Логирование действий
********************************************/
PROCEDURE TO_LOGS (
  P_APP_ID NUMBER,
  P_MESSAGE VARCHAR2,
  P_LOG_DATE DATE,
  P_RETURN_CODE NUMBER) IS
  
V_LOG_ID NUMBER;
PRAGMA AUTONOMOUS_TRANSACTION;
  
BEGIN
 
SELECT NVL(MAX(LOG_ID),0) +1 INTO V_LOG_ID FROM HR.SYS_LOGS;
 
INSERT INTO HR.SYS_LOGS (LOG_ID, APP_ID, MESSAGE, LOG_DATE, RETURN_CODE)  
VALUES (V_LOG_ID, P_APP_ID, P_MESSAGE, P_LOG_DATE, P_RETURN_CODE);  
COMMIT;  
END;  

/******************************************************
Author: Комзолов Н.О. / 17.01.2021
Desc:   Возврат зарплаты в зависимости от ид сотрудника
*******************************************************/
FUNCTION GETSALARY(EMID IN NUMBER) RETURN NUMBER
IS

V_SALARY NUMBER;

BEGIN

SELECT EM.SALARY INTO V_SALARY FROM HR.EMPLOYEES EM WHERE EM.EMPLOYEE_ID = EMID;

RETURN(V_SALARY);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('-999');
	RETURN(V_SALARY);
END GETSALARY;

/************************************************************
Author: Комзолов Н.О. / 17.01.2021
Desc:   Возврат системного времени в зависимости от параметра
*************************************************************/
PROCEDURE SYS_TIME_TEMPLATE
(P_MODE IN VARCHAR2 DEFAULT 'DD')IS

V_DATE DATE;

BEGIN
IF UPPER(P_MODE) = UPPER('YYYY') THEN EXECUTE IMMEDIATE 'SELECT TRUNC(TO_DATE(sysdate), '''||P_MODE||''')  FROM DUAL' INTO V_DATE;
ELSIF UPPER(P_MODE) = UPPER('DD') THEN EXECUTE IMMEDIATE 'SELECT TRUNC(TO_DATE(sysdate), '''||P_MODE||''') FROM DUAL' INTO V_DATE;
ELSIF UPPER(P_MODE) = UPPER('MM') THEN EXECUTE IMMEDIATE 'SELECT TRUNC(TO_DATE(sysdate), '''||P_MODE||''') FROM DUAL' INTO V_DATE;
ELSE DBMS_OUTPUT.PUT_LINE('Передано некорректное значение');
END IF;

DBMS_OUTPUT.PUT_LINE(V_DATE);

END;

/*******************************************************
Author: Комзолов Н.О. / 17.01.2021
Desc:   Удаление таблиц из заданного шаблона в параметре
********************************************************/
PROCEDURE DROP_SELECTS_TBL(P_MODE IN VARCHAR2 DEFAULT 'VIEW', P_TABLES IN VARCHAR2) IS
V_MARK  BOOLEAN := FALSE;
BEGIN

FOR CC2 IN (SELECT TABLE_NAME
            FROM ALL_TABLES 
            WHERE TABLE_NAME LIKE '%'||P_TABLES||'%')
LOOP

IF P_MODE = 'DELETE' THEN EXECUTE IMMEDIATE 'drop table '||CC2.TABLE_NAME|| ' purge';
ELSIF P_MODE = 'VIEW' THEN DBMS_OUTPUT.PUT_LINE(CC2.TABLE_NAME);
END IF;

V_MARK := TRUE;

END LOOP;

IF V_MARK = FALSE THEN
DBMS_OUTPUT.PUT_LINE('There are no tables with this mask. Try again.');
END IF;

END;

/*******************************************
Author: Комзолов Н.О. / 17.01.2021
Desc:   Обновление данных по клиенту
********************************************/
PROCEDURE ADD_NEW_EMP 
(P_FIRST_NAME VARCHAR2,
P_LAST_NAME VARCHAR2,
P_EMAIL VARCHAR2,
P_PHONE_NUMBER VARCHAR2,
P_HIRE_DATE DATE DEFAULT SYSDATE,
P_JOB_ID VARCHAR2,
P_SALARY NUMBER,
P_COMMISSION_PCT NUMBER DEFAULT NULL,
P_MANAGER_ID NUMBER DEFAULT 100,
P_DEPARTMENT_ID NUMBER) IS

V_APP_ID NUMBER := 10001;
V_GOOD NUMBER := 1;
V_BAD NUMBER := 2;
V_EMP_ID NUMBER;

BEGIN

FOR CC1 IN (SELECT 1
            FROM HR.JOBS JS
            WHERE P_JOB_ID = JS.JOB_ID
            HAVING COUNT(*) = 0)
LOOP

TO_LOGS(
P_APP_ID => V_APP_ID,
P_MESSAGE => 'Введен несуществующий код должности.',
P_LOG_DATE => SYSDATE,
P_RETURN_CODE => V_BAD);

RAISE_APPLICATION_ERROR(-20001,'Введен несуществующий код должности.');

END LOOP;

TO_LOGS(
P_APP_ID => V_APP_ID,
P_MESSAGE => 'Проверка: существует ли передаваемый код должности - успешно.',
P_LOG_DATE => SYSDATE,
P_RETURN_CODE => V_GOOD);

FOR CC2 IN (SELECT 1
            FROM HR.DEPARTMENTS DP
            WHERE P_DEPARTMENT_ID = DP.DEPARTMENT_ID
            HAVING COUNT(*) = 0)
LOOP

TO_LOGS(
P_APP_ID => V_APP_ID,
P_MESSAGE => 'Введен несуществующий ид департамента.',
P_LOG_DATE => SYSDATE,
P_RETURN_CODE => V_BAD);

RAISE_APPLICATION_ERROR(-20001,'Введен несуществующий ид департамента.');

END LOOP;

TO_LOGS(
P_APP_ID => V_APP_ID,
P_MESSAGE => 'Проверка: существует ли передаваемый ид департамента - успешно.',
P_LOG_DATE => SYSDATE,
P_RETURN_CODE => V_GOOD);

FOR CC3 IN (SELECT 1
            FROM HR.JOBS JS
            WHERE P_JOB_ID = JS.JOB_ID AND P_SALARY > JS.MIN_SALARY AND P_SALARY < JS.MAX_SALARY
            HAVING COUNT(*) = 0)
LOOP

TO_LOGS(
P_APP_ID => V_APP_ID,
P_MESSAGE => 'Введена недопустимая зарплата для данного кода должности.',
P_LOG_DATE => SYSDATE,
P_RETURN_CODE => V_BAD);

RAISE_APPLICATION_ERROR(-20001,'Введена недопустимая зарплата для данного кода должности.');

END LOOP;

TO_LOGS(
P_APP_ID => V_APP_ID,
P_MESSAGE => 'Проверка передаваемой зарплаты на корректность по коду должности - успешно',
P_LOG_DATE => SYSDATE,
P_RETURN_CODE => V_GOOD);

IF P_EMAIL LIKE '%@%' THEN 

TO_LOGS(
P_APP_ID => V_APP_ID,
P_MESSAGE => 'Для параметра P_EMAIL, нужно вводить только логин.',
P_LOG_DATE => SYSDATE,
P_RETURN_CODE => V_BAD);

RAISE_APPLICATION_ERROR(-20001,'Для параметра P_EMAIL, нужно вводить только логин.');

END IF;

TO_LOGS(
P_APP_ID => V_APP_ID,
P_MESSAGE => 'Проверка передаваемого логина почты на корректность ввода - успешно.',
P_LOG_DATE => SYSDATE,
P_RETURN_CODE => V_GOOD);

EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_LANGUAGE= ''AMERICAN''';

IF TO_CHAR(SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN

TO_LOGS(
P_APP_ID => V_APP_ID,
P_MESSAGE => 'Вы можете добавлять нового сотрудника только в рабочее время.',
P_LOG_DATE => SYSDATE,
P_RETURN_CODE => V_BAD);

RAISE_APPLICATION_ERROR(-20001,'Вы можете добавлять нового сотрудника только в рабочее время.');

END IF;

TO_LOGS(
P_APP_ID => V_APP_ID,
P_MESSAGE => 'Проверка передаваемой даты и время принятия сотрудника на работу - успешно.',
P_LOG_DATE => SYSDATE,
P_RETURN_CODE => V_GOOD);

SELECT NVL(MAX(EMPLOYEE_ID),0) +1 INTO V_EMP_ID FROM HR.EMPLOYEES_COPY;

INSERT INTO HR.EMPLOYEES
(
EMPLOYEE_ID
,FIRST_NAME
,LAST_NAME
,EMAIL
,PHONE_NUMBER
,HIRE_DATE
,JOB_ID
,SALARY
,COMMISSION_PCT
,MANAGER_ID
,DEPARTMENT_ID)
VALUES (
V_EMP_ID,
P_FIRST_NAME
, P_LAST_NAME
, P_EMAIL
, P_PHONE_NUMBER
, P_HIRE_DATE
, P_JOB_ID
, P_SALARY
, P_COMMISSION_PCT
, P_MANAGER_ID
, P_DEPARTMENT_ID);

COMMIT;

DBMS_OUTPUT.PUT_LINE('Сотрудник' || ' ' || P_FIRST_NAME || ' ' || P_LAST_NAME || ' ' || P_JOB_ID || ' ' ||P_DEPARTMENT_ID || ' ' || 'успешно добавлен.');
END;

END WORK_UTIL;
