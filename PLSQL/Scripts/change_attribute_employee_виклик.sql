DECLARE 
p_employee_id NUMBER := 102;

BEGIN
  
util.change_attribute_employee(p_employee_id    => p_employee_id,
                               p_first_name     => NULL,
                               p_last_name      => NULL,
                               p_email          => 'Lex@mail.com',
                               p_phone_number   => NULL,
                               p_job_id         => NULL,
                               p_salary         => 18000.00,
                               p_commission_pct => NULL,
                               p_manager_id     => NULL,
                               p_department_id  => NULL);
                                   
 DBMS_OUTPUT.PUT_LINE('У співробітника ' || p_employee_id || ' успішно оновлені атрибути');

END;


select * from employee em
where em.employee_id = 102;
