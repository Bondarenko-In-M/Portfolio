CREATE OR REPLACE PROCEDURE fire_an_employee(p_employee_id IN NUMBER, 
                                             p_result      OUT VARCHAR2) IS
  -- оголошення змінної з типом данних як у однойменного стовпця таблиці

  v_first_name    employee.first_name%TYPE;
  v_last_name     employee.last_name%TYPE;
  v_job_id        employee.job_id%TYPE;
  v_department_id employee.department_id%TYPE;

BEGIN
  -- Викликати процедуру log_utils.log_start
  log_utils.log_start(p_proc_name => 'fire_an_employee',
                      p_text      => 'Старт логування, назва процесу = fire_an_employee');

  -- Перевіряємо чи існує employee_id

  FOR cc IN (SELECT 1 -- Запит повертає просто число 1 - умовний маркер. важливо знати чи є хоч 1рядок
             FROM employee em
             WHERE em.employee_id = p_employee_id HAVING COUNT(1) = 0) LOOP
  
    raise_application_error(-20001,'Переданий співробітник нe існує');
  
  END LOOP;


  -- виклик процедури перевірки робочого часу та дня тижня
  BEGIN
    check_work_time;
    -- помилка 
  EXCEPTION
  
    WHEN OTHERS THEN
      raise_application_error(-20001,'Ви можете видаляти співробітника лише в робочий час');
  END;
  
  -- отримуємо дані співробітника і записуємо у змінні для виведення їх у параметрі p_result
  
   SELECT first_name,
          last_name,
          job_id,
          department_id
   
     INTO v_first_name,
          v_last_name,
          v_job_id,
          v_department_id
     FROM employee em
    WHERE em.employee_id = p_employee_id;
  -- видаляємо дані співробітника 

  DELETE FROM inna_dlw.employee em
  WHERE em.employee_id = p_employee_id;

  p_result := 'Співробітник ' || v_first_name || ' ' || v_last_name || ', 
               Код посади: ' || v_job_id || ', 
               ID департаменту: ' || v_department_id || 'успішно видалений';

EXCEPTION

  WHEN OTHERS THEN
  
    -- виклик процедури логування
    log_utils.log_error(p_proc_name => 'fire_an_employee',
                        p_text      => 'В процедурі fire_an_employee сталася помилка. ' || SQLERRM,
                        p_sqlerrm   => SQLERRM);
  
    -- повторне підняття помилки, щоб користувач бачив її
    RAISE;
  
  
    --Записати дані в історичну таблицю employees_history. Архітектуру таблиці employees_history продумати самостійно.
  
    log_utils.log_finish(p_proc_name => 'fire_an_employee',
                         p_text      => 'Завершення логування, назва процесу = fire_an_employee');
  

END fire_an_employee;
/
