DECLARE

v_result VARCHAR2(4000);


BEGIN

  util.fire_an_employee(p_employee_id => 205, 
                        p_result      => v_result);

  dbms_output.put_line(v_result);

END;



select * from employees_history emh;
