                       
BEGIN
  
log_utils.add_employee(
                       p_first_name     => 'Inna',
                       p_last_name      => 'Bondarenko',
                       p_email          => 'bondik_in2017@gmail.com',
                       p_phone_number   => '0800500206',
                       p_hire_date      => TRUNC(SYSDATE, 'DD'),
                       p_job_id         => 'IT_PROG',
                       p_salary         => 9000,
                       p_commission_pct => NULL,
                       p_manager_id     => 103,
                       p_department_id  => '100'
                  );
                                   
dbms_output.put_line('Employee added successfully');

END;

/



SELECT * FROM employee em
