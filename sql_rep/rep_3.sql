SELECT *
FROM HR.EMPLOYEES EM
WHERE EM.SALARY IN (SELECT MAX(EM.SALARY)
                FROM HR.EMPLOYEES EM
                WHERE EM.JOB_ID='SA_REP');