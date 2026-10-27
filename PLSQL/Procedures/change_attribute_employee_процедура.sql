CREATE OR REPLACE PROCEDURE change_attribute_employee(p_employee_id    IN NUMBER,
                                      p_first_name     IN VARCHAR2 DEFAULT NULL,
                                      p_last_name      IN VARCHAR2 DEFAULT NULL,
                                      p_email          IN VARCHAR2 DEFAULT NULL,
                                      p_phone_number   IN VARCHAR2 DEFAULT NULL,
                                      p_job_id         IN VARCHAR2 DEFAULT NULL,
                                      p_salary         IN NUMBER DEFAULT NULL,
                                      p_commission_pct IN NUMBER DEFAULT NULL,
                                      p_manager_id     IN NUMBER DEFAULT NULL,
                                      p_department_id  IN NUMBER DEFAULT NULL) IS
                                      
                                                      
  v_table        VARCHAR2(1000) := 'employee';
  v_sql_dinamic  VARCHAR2(4000); 
  v_exists      NUMBER;

BEGIN
  -- Викликати процедуру log_utils.log_start

  log_utils.log_start(p_proc_name => 'change_attribute_employee',
                      p_text      => 'Старт логування, назва процесу = change_attribute_employee');

  SELECT COUNT(1)
   INTO v_exists
   FROM employee
   WHERE employee_id = p_employee_id;

   IF v_exists = 0 THEN
      raise_application_error(-20001,'Переданий співробітник не існує');
   END IF;
  

 /* BEGIN
    
    check_work_time;
    -- помилка
     
  EXCEPTION
    
    WHEN OTHERS THEN
      raise_application_error(-20001,'Ви можете оновлювати дані співробітника лише в робочий час');
    
  END;
  */
  -- перевіряємо, що хоча б один з параметрів не дорівнює NULL
  
  IF p_first_name IS NOT NULL OR p_last_name IS NOT NULL OR p_email IS NOT NULL OR 
     p_phone_number IS NOT NULL OR p_job_id IS NOT NULL OR p_salary IS NOT NULL OR p_commission_pct IS NOT NULL OR
     p_manager_id IS NOT NULL OR p_department_id IS NOT NULL THEN
     
     DBMS_OUTPUT.PUT_LINE('Хоча б один з параметрів заповнений');
     
     ELSE
       
  raise_application_error(-20001,'Параметри незаповнені');
  
  END IF;
  
  v_sql_dinamic := 'DECLARE
                        v1 VARCHAR2(255) := :p_first_name;
                        v2 VARCHAR2(255) := :p_last_name;
                        v3 VARCHAR2(255) := :p_email;
                        v4 VARCHAR2(255) := :p_phone_number;
                        v5 VARCHAR2(255) := :p_job_id;
                        v6 NUMBER        := :p_salary;
                        v7 NUMBER        := :p_commission_pct;
                        v8 NUMBER        := :p_manager_id;
                        v9 NUMBER        := :p_department_id;
                        v0 NUMBER        := :p_employee_id;
                      BEGIN
                        UPDATE ' || v_table || ' SET ';
  
   
  IF p_first_name IS NOT NULL THEN
   
  v_sql_dinamic := v_sql_dinamic || 'first_name = :p_first_name,';
  
  END IF;
  
  IF p_last_name IS NOT NULL THEN
   
  v_sql_dinamic := v_sql_dinamic || 'last_name = :p_last_name,';
  
  END IF;
  
  IF p_email IS NOT NULL THEN
   
  v_sql_dinamic := v_sql_dinamic || 'email = :p_email,';
  
  END IF;
  
  IF p_phone_number IS NOT NULL THEN
   
  v_sql_dinamic := v_sql_dinamic || 'phone_number = :p_phone_number,';
  
  END IF;
  
  IF p_job_id IS NOT NULL THEN
   
  v_sql_dinamic := v_sql_dinamic || 'job_id = :p_job_id,';
  
  END IF;
  
  IF p_salary IS NOT NULL THEN
   
  v_sql_dinamic := v_sql_dinamic || 'salary = :p_salary,';
  
  END IF;
  
  IF p_commission_pct IS NOT NULL THEN
   
  v_sql_dinamic := v_sql_dinamic || 'commission_pct = :p_commission_pct,';
  
  END IF;
  
  IF p_manager_id IS NOT NULL THEN
   
  v_sql_dinamic := v_sql_dinamic || 'manager_id = :p_manager_id,';
  
  END IF;
  
  IF p_department_id IS NOT NULL THEN
   
  v_sql_dinamic := v_sql_dinamic || 'department_id = :p_department_id,';
  
  END IF;
 
 -- Прибираємо зайву кому
   v_sql_dinamic := REGEXP_REPLACE(v_sql_dinamic, ',\s*$', '');
   v_sql_dinamic := v_sql_dinamic || ' WHERE employee_id = :p_employee_id; END;';  -- ЗМІНЕНО: ';' + END; закривають блок

   DBMS_OUTPUT.PUT_LINE('SQL = ' || v_sql_dinamic);

   EXECUTE IMMEDIATE v_sql_dinamic
      USING p_first_name, p_last_name, p_email,
            p_phone_number, p_job_id, p_salary,
            p_commission_pct, p_manager_id, p_department_id, p_employee_id;

    DBMS_OUTPUT.PUT_LINE('У співробітника ' || p_employee_id || ' успішно оновлені атрибути');

    COMMIT;

    log_utils.log_finish(p_proc_name => 'change_attribute_employee_v1',
                         p_text      => 'Завершення логування');
  EXCEPTION
    WHEN OTHERS THEN
      log_utils.log_error(p_proc_name => 'change_attribute_employee_v1',
                          p_text      => 'Помилка ' || SQLERRM,
                          p_sqlerrm   => SQLERRM);
      RAISE;  -- ЗМІНЕНО

   
END change_attribute_employee;
/
