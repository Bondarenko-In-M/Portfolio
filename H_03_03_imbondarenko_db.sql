
/*Опис:
Видалити потрібні об?єкти з корня своєї схеми та перед цим перенести їх в пакет UTIL.
Деталі :
Оголосити функці ї get_job_title, get_dep_name та процедуру del_jobs в спеці фі каці ї та ті ла пакета UTIL. 
Потім ці 3 об?єкта які оголосили в пакеті - видалити в корні своєї схеми.
Докласти виклик процедури та функції (які вже в пакеті ) і з домашнього завдання.*/


--Специфікація
create or replace PACKAGE util AS

        gc_min_salary CONSTANT NUMBER := 2000; -- еонстанти оголошуються зверху

        FUNCTION add_years(p_date IN DATE DEFAULT SYSDATE,
                           p_year IN NUMBER) RETURN DATE; 
                           
        FUNCTION get_dep_name(p_employee_id IN NUMBER) RETURN VARCHAR2;
        
        FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR2;
                              
                           
        PROCEDURE add_new_jobs(p_job_id     IN VARCHAR2,
                              p_job_title  IN VARCHAR2,
                              p_min_salary IN NUMBER,
                              p_max_salary IN NUMBER DEFAULT NULL, -- процедура відпрацює і повернене те що вкажемо
                              po_err       OUT VARCHAR2);
                              
         PROCEDURE del_jobs (p_job_id     IN VARCHAR2,
                            po_result    OUT VARCHAR2);
                                      
END util;

-- Body
create or replace PACKAGE body util AS

        c_percent_of_min_salary CONSTANT NUMBER := 1.5;

FUNCTION add_years(p_date IN DATE DEFAULT SYSDATE,
                                     p_year IN NUMBER) RETURN DATE IS
        v_date DATE;
        v_year NUMBER := p_year*12;
BEGIN
        SELECT add_months(p_date, v_year)
        INTO v_date
        FROM dual;
        
        RETURN v_date;
END add_years;

FUNCTION get_dep_name(p_employee_id IN NUMBER) RETURN VARCHAR2 IS
    v_dep_name inna_dlw.departments.department_name%TYPE;
BEGIN
    SELECT d.department_name
    INTO v_dep_name
    FROM inna_dlw.departments d
    JOIN inna_dlw.employee em
    ON d.department_id = em.department_id
    WHERE em.employee_id = p_employee_id;
    RETURN  v_dep_name;

END get_dep_name;


FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR2 IS
    v_job_title inna_dlw.jobs.job_title%TYPE;
BEGIN
    SELECT j.job_title
    INTO v_job_title
    FROM inna_dlw.employee em
    JOIN inna_dlw.jobs j
    ON em.job_id = j.job_id
    WHERE em.employee_id = p_employee_id;

    RETURN v_job_title;

END get_job_title;


PROCEDURE add_new_jobs(p_job_id     IN VARCHAR2,
                       p_job_title  IN VARCHAR2,
                       p_min_salary IN NUMBER,
                       p_max_salary IN NUMBER DEFAULT NULL, -- процедура відпрацює і повернене те що вкажемо
                       po_err       OUT VARCHAR2) IS
    v_max_salary jobs.max_salary%TYPE; -- змінні пишуться в процедурі після блоку з параметрами
    v_is_exist_job NUMBER;
    
BEGIN
    IF p_max_salary IS NULL THEN
        v_max_salary := p_min_salary * c_percent_of_min_salary;
    ELSE
        v_max_salary := p_max_salary;

    END IF;
    
    SELECT COUNT(j.job_id)
    INTO v_is_exist_job
    FROM jobs j
    WHERE j.job_id = p_job_id;

    IF ( p_min_salary < gc_min_salary OR p_max_salary < gc_min_salary ) THEN
         po_err := 'Передана зарплата менша за 2000';
    ELSIF v_is_exist_job >=1 THEN
        po_err := 'Посада '||p_job_id||' вже і снує';
    ELSE
        INSERT INTO jobs (job_id,job_title,min_salary,max_salary)
        VALUES (p_job_id,p_job_title,p_min_salary,v_max_salary);
COMMIT;
        po_err := 'Посада '||p_job_id||' успішно додана';

    END IF;

END add_new_jobs;

PROCEDURE del_jobs (p_job_id     IN VARCHAR2,
                                      po_result    OUT VARCHAR2) IS
                                      
        v_count_job_id NUMBER;

BEGIN

    SELECT COUNT(*)
    INTO v_count_job_id
    FROM inna_dlw.jobs 
    WHERE job_id = p_job_id;


    IF v_count_job_id = 0 THEN
        po_result := 'Посада ' || p_job_id || ' не і снує';

   ELSE

        DELETE from inna_dlw.jobs
        WHERE job_id = p_job_id;
        po_result := 'Посада ' || p_job_id || ' успішно видалена';


   END IF;

END del_jobs;


END util;



--виклик

DECLARE
v_result VARCHAR2(100);

BEGIN
dbms_output.put_line(util.get_job_title(115));
dbms_output.put_line(util.get_dep_name(115));

util.del_jobs('AD_VP', v_result);
    DBMS_OUTPUT.PUT_LINE(v_result);
    
END;
/


