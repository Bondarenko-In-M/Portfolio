
/*Створити функці ю яка буде повертати назву департаменту по спі вробі тнику
Деталі :
Створити функцію get_dep_name, яка (залежно від ІД співробітника), повертала би назву департаменту, це працює співробітник. 
Перед цим створити у своїй схемі копію таблиці HR.DEPARTMENTS.
Після створення функції, написати SQL запит з таблиці співробітників і замість 
полів JOB_ID, виводити назву посади за допомогою функці ї get_job_title (ми її вже створили на
практиці ), замість поля department_id виводити назву департаменту за допомогою функці ї get_dep_name.*/

CREATE table departments AS
SELECT *
FROM hr.departments;


create or replace FUNCTION get_dep_name(p_employee_id IN NUMBER) RETURN VARCHAR2 IS
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

-- виклик функції

BEGIN
dbms_output.put_line(get_dep_name(115));
END;
/


SELECT em.EMPLOYEE_ID, 
em.FIRST_NAME, 
em.LAST_NAME, 
em.EMAIL, 
em.PHONE_NUMBER, 
em.HIRE_DATE, 
get_job_title (p_employee_id => em.employee_id) as job_title, 
em.SALARY, 
em.COMMISSION_PCT,
em.MANAGER_ID,
get_dep_name(p_employee_id => em.employee_id) as dep_name 
FROM inna_dlw.employee em;

