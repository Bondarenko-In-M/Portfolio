
/*Створити PL-SQL блок, який по employee_id визначає посаду спі вробі тника.
Деталі :
Завести змі нну v_employee_id з типом даних, як у стовпчика employee_id в таблиці hr.employees,
ві дразу присвоїти ці й змі нні й якесь значення (наприклад 110). Також завести
змі нну v_job_id типу даних, як стовпчик job_id в таблиці hr.employees та змі нну v_job_title
типу даних, як стовпчик job_title в таблиці hr.jobs. Далі в середині PL-SQL блоку, через
окремі два запити (без JOIN-ні в) визначити посаду. Ві дразу по v_employee_id знаходимо і д посади, 
значення через INTO записуємо в змі нну v_job_id. Наступним кроком по
v_job_id, знаходимо job_title і записуємо значення в змі нну v_job_title через оператор INTO. 
В кі нці PL-SQL блоку, виводимо і нформаці ю на екран і з змі ною v_job_title.
Зберегти PL-SQL блок у файл пі д назвою H_02_01_tvoji_inichialy.sql. Загрузити в LMS Moodle.*/
--Варіант 1
DECLARE
        v_employee_id NUMBER := 120;
        v_job_id VARCHAR2(10); 
        v_job_title VARCHAR2(35);
BEGIN
--виконати пошук job_id та записати у змінну v_job_id
        SELECT em.job_id
        INTO v_job_id
        FROM hr.employees em
        WHERE em.employee_id = v_employee_id; 
    --dbms_output.put_line(v_job_id);
-- виконати пошук job_title та записати у змінну v_job_title
        SELECT j.job_title
        INTO v_job_title
        FROM hr.jobs j
        WHERE j.job_id = v_job_id;
    dbms_output.put_line(v_job_title);
END;
/

-- Виконати перевірку
SELECT j.job_title
FROM hr.employees em
    JOIN hr.jobs j
    ON em.job_id = j.job_id
WHERE em.employee_id = 120;

/*Варіант 2*/

DECLARE
        v_employee_id hr.employees.employee_id%TYPE := 120;
        v_job_id hr.employees.job_id%TYPE; 
        v_job_title hr.jobs.job_title%TYPE;
BEGIN
--виконати пошук job_id та записати у змінну v_job_id
        SELECT em.job_id
        INTO v_job_id
        FROM hr.employees em
        WHERE em.employee_id = v_employee_id; 
    --dbms_output.put_line(v_job_id);
-- виконати пошук job_title та записати у змінну v_job_title
        SELECT j.job_title
        INTO v_job_title
        FROM hr.jobs j
        WHERE j.job_id = v_job_id;
    dbms_output.put_line(v_job_title);
END;
/
