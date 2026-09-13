/*Зробити потрі бний зві т і сформувати CSV файл на диску.
Деталі :
Зробити зві т на основі CSV файлу PROJECTS.csv (у файлі три рядка, тобто три 
проєкти), 
файл знаходиться у директорі ї FILES_FROM_SERVER, структура: project_id NUMBER,
project_name
VARCHAR2, department_id NUMBER). Необхі дний групований зві т в рамках трьох
проєкті в, де треба показати назву департаменті в, кі лькі сть спі вробі тникі
в, кі лькі сть уні кальних менеджері в та
сумарна зарплата. SQL запит який формує остаточний зві т, треба завернути у 
VIEW rep_project_dep_v і в середині цикла FOR, обов?язково використовувати 
запит з rep_project_dep_v
(просто селект в середині FOR через механі зм "FROM EXTERNAL" в середині
PL-SQL блока буде сприйматися як синтаксична помилка. А через оболонку 
VIEW - НІ). Отриманий зві т треба
завантажити в директорі ю FILES_FROM_SERVER пі д назвою 
TOTAL_PROJ_INDEX_tvoji_inichialy.csv*/

CREATE TABLE projects_ext (
    project_id     NUMBER,
    project_name   VARCHAR2(100),
    department_id  NUMBER
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY FILES_FROM_SERVER
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('PROJECTS.CSV')
)
REJECT LIMIT UNLIMITED;

CREATE TABLE rep_project_dep AS
SELECT project_id, project_name, department_id
FROM projects_ext;

CREATE VIEW rep_project_dep_v AS
select dep.department_name, 
       count (em.employee_id) AS count_emp,
       count (DISTINCT em.manager_id) AS count_man,
       sum (em.salary) sum_sal
from employee em
INNER JOIN departments dep
ON em.department_id = dep.department_id
INNER JOIN rep_project_dep rpd
ON dep.department_id = rpd.department_id
GROUP BY dep.department_name;


CREATE OR REPLACE PROCEDURE WRITE_FILE_TO_DISK IS
        file_handle UTL_FILE.FILE_TYPE;
        file_location VARCHAR2(200) := 'FILES_FROM_SERVER'; -- Íàçâà ñòâîðåíî¿ äèðåêòîð³ ¿
        file_name VARCHAR2(200) := 'TOTAL_PROJ_INDEX__BIM.csv'; -- ²ì'ÿ ôàéëó, ÿêèé áóäå çàïèñàíèé
        file_content VARCHAR2(4000); -- Âì³ñò ôàéëó
        
BEGIN
-- Отримати вміст файлу з бази даних
    FOR cc IN (select dep.department_name ||','|| count (em.employee_id) || ','||
       count (DISTINCT em.manager_id) || ','||
       sum (em.salary) AS  file_content
from employee em
INNER JOIN departments dep
ON em.department_id = dep.department_id
INNER JOIN rep_project_dep rpd
ON dep.department_id = rpd.department_id
GROUP BY dep.department_name)LOOP
    file_content := file_content || cc.file_content||CHR(10); -- CHR(10) перенесення на новий рядок
    
    END LOOP;
    --Відкрити файл для запису
    file_handle := UTL_FILE.FOPEN(file_location, file_name, 'W'); --W операція -записати
    -- Записати вмі ст файлу в файл на диск
    utl_file.put_raw(file_handle, UTL_RAW.CAST_TO_RAW(file_content));
    -- Закрити файл
    utl_file.fclose(file_handle);
    
EXCEPTION

    WHEN OTHERS THEN
-- Обробка помилок, якщо необхі дно

        RAISE;

END WRITE_FILE_TO_DISK;

BEGIN
write_file_to_disk;
END;



--Більш правильний варіант  коду


CREATE VIEW total_proj_index_v AS
SELECT ext_fl.project_id,
ext_fl.project_name ,
ext_fl.department_id,
d.department_name,
COUNT(DISTINCT e.employee_id) AS employee_count,
COUNT(DISTINCT e.manager_id) AS unique_managers,
SUM(e.salary) AS total_salary
FROM EXTERNAL ((project_id NUMBER,
project_name VARCHAR2(100),
department_id NUMBER)
TYPE oracle_loader DEFAULT DIRECTORY FILES_FROM_SERVER
ACCESS PARAMETERS(records delimited by newline
nologfile
nobadfile
fields terminated by ','
missing field values are null)
LOCATION('PROJECTS.csv')
REJECT LIMIT UNLIMITED ) ext_fl
JOIN employees e ON e.department_id = ext_fl.department_id
JOIN departments d ON d.department_id = ext_fl.department_id
GROUP BY ext_fl.project_id, ext_fl.project_name, ext_fl.department_id, d.department_name;



create or replace PROCEDURE WRITE_FILE_TO_DISK2 IS
file_handle UTL_FILE.FILE_TYPE;
file_location VARCHAR2(200) := 'FILES_FROM_SERVER';
file_name VARCHAR2(200) := 'TOTAL_PROJ_INDEX_HD.csv';
file_content VARCHAR2(4000);

BEGIN

FOR cc IN (SELECT project_id ||','||
project_name ||','||
department_id ||','||
department_name ||','||
employee_count ||','||
unique_managers ||','||
total_salary file_content
FROM total_proj_index_v) LOOP

file_content := file_content || cc.file_content || CHR(10);

END LOOP;

file_handle := utl_file.fopen(file_location, file_name, 'w');

utl_file.put_raw(file_handle, UTL_RAW.CAST_TO_RAW(file_content));

utl_file.fclose(file_handle);

EXCEPTION
WHEN OTHERS THEN
raise;

END;
