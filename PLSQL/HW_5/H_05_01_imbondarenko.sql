/*Створі ть тригер, який автоматично оновлює поле EMPLOYEES.HIRE_DATE.
Деталі :
Створі ть тригер (поді я - BEFORE UPDATE) hire_date_update, який автоматично 
оновлює поле "HIRE_DATE" 
в таблиці "EMPLOYEES", якщо значення поля "JOB_ID" змі нюється (:OLD.job_id !=
:NEW.job_id). Нове значення "HIRE_DATE" має бути поточною датою усі чене до дня. 
Для змі ни старого значення в полі "HIRE_DATE" НЕ вийди використовувати 
звичайний UPDATE,
тому, що буде помилка "ORA-00060: deadlock detected while waiting for resource" 
і це нормально 
поведі нка транзакці йної БД, так як ми одночасно пробуємо змі нити значення
в одні й
таблиці в двох рі зних стовпчиках. Для змі ни старого значення в полі 
"HIRE_DATE треба 
використовувати функці онал тригера, через присвоєння новому значенню, ось так -
:NEW.hire_date := TRUNC(SYSDATE). Переві рити роботу тригера.
Зберегти код створення тригера, у файл пі д назвою H_05_01_tvoji_inichialy.sql.
Загрузити в LMS Moodle.*/

CREATE OR REPLACE TRIGGER hire_date_update

    BEFORE UPDATE ON employee
    FOR EACH ROW
    
DECLARE
    
    PRAGMA autonomous_transaction;
    
BEGIN

    IF:OLD.job_id != :NEW.job_id  THEN
    :NEW.hire_date := TRUNC(SYSDATE); 
    END IF;

COMMIT;

END hire_date_update;


UPDATE employee em
SET em.job_id = 'AC_MGR' -- MK_REP AC_MGR
WHERE em.employee_id = 106;
COMMIT;

select * from employee em
where em.employee_id = 106; 

