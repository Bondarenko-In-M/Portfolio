create or replace package log_utils is

 PROCEDURE log_start (p_proc_name IN VARCHAR2,
                     p_text IN VARCHAR2 DEFAULT NULL);
                     
PROCEDURE log_finish(p_proc_name IN VARCHAR2,
                     p_text      IN VARCHAR2 DEFAULT NULL);
                     
PROCEDURE log_error(p_proc_name IN VARCHAR2,
                    p_text      IN VARCHAR2 DEFAULT NULL,
                    p_sqlerrm   IN VARCHAR2);
PROCEDURE add_employee(p_first_name     IN VARCHAR2,
                       p_last_name      IN VARCHAR2,
                       p_email          IN VARCHAR2,
                       p_phone_number   IN VARCHAR2,
                       p_hire_date      IN DATE DEFAULT trunc(sysdate, 'dd'),
                       p_job_id         IN VARCHAR2, 
                       p_salary         IN NUMBER,
                       p_commission_pct IN VARCHAR2 DEFAULT NULL,
                       p_manager_id     IN NUMBER DEFAULT 100,
                       p_department_id  IN VARCHAR2);
  
  
end log_utils;




--log_utils body


create or replace package body log_utils as

PROCEDURE to_log(p_appl_proc IN VARCHAR2,
                 p_message   IN VARCHAR2) IS
    PRAGMA autonomous_transaction; -- процедура буде виконуватись незалежно від батьківської транзакції
BEGIN
    INSERT INTO logs(id, appl_proc, message)
    VALUES(log_seq.NEXTVAL, p_appl_proc, p_message);

COMMIT;

END to_log;


PROCEDURE log_start (p_proc_name IN VARCHAR2,
                     p_text      IN VARCHAR2 DEFAULT NULL) is
                                       
        v_text VARCHAR2(4000);
        
               
BEGIN
  
    IF p_text IS NULL THEN
      
       v_text  := 'Старт логування, назва процесу = ' || p_proc_name;
    ELSE
       v_text  := p_text;

    END IF;
    
    to_log(p_appl_proc => p_proc_name,
           p_message   => v_text);
    
    
END log_start;


PROCEDURE log_finish(p_proc_name IN VARCHAR2,
                     p_text      IN VARCHAR2 DEFAULT NULL) is
                                       
        v_text VARCHAR2(4000);
        
               
BEGIN
  
    IF p_text IS NULL THEN
      
       v_text  :='Завершення логування, назва процесу = '|| p_proc_name;
    ELSE
        v_text := p_text;

    END IF;
    
    to_log(p_appl_proc => p_proc_name,
           p_message   => v_text);
    
    
END log_finish;

PROCEDURE log_error(p_proc_name IN VARCHAR2,
                    p_text      IN VARCHAR2 DEFAULT NULL,
                    p_sqlerrm   IN VARCHAR2) is
                                       
       v_text VARCHAR2(4000);
        
               
BEGIN
  
    IF p_text IS NULL THEN
      
       v_text  :='В процедурі' || p_proc_name ||' сталася помилка. ' || p_sqlerrm;
    ELSE
        v_text := p_text;

    END IF;
    
    to_log(p_appl_proc => p_proc_name,
           p_message   => v_text);
    
    
END log_error;

PROCEDURE add_employee(p_first_name     IN VARCHAR2,
                       p_last_name      IN VARCHAR2,
                       p_email          IN VARCHAR2,
                       p_phone_number   IN VARCHAR2,
                       p_hire_date      IN DATE DEFAULT trunc(sysdate, 'dd'),
                       p_job_id         IN VARCHAR2, 
                       p_salary         IN NUMBER,
                       p_commission_pct IN VARCHAR2 DEFAULT NULL,
                       p_manager_id     IN NUMBER DEFAULT 100,
                       p_department_id  IN VARCHAR2) is
                                         
        
BEGIN
 
       log_utils.log_start (p_proc_name => 'add_employee',
                            p_text      => 'Старт логування, назва процесу = add_employee');
                                  
            
        FOR cc IN (SELECT 1
                   FROM jobs j
                   WHERE j.job_id = p_job_id
                   HAVING COUNT(1) = 0) 
    LOOP
               
          raise_application_error(-20001, 'Введено неіснуючий код посади');
                
END LOOP;

         FOR cc IN (SELECT 1
                    FROM departments dep
                    WHERE dep.department_id = p_department_id
                    HAVING COUNT(1) = 0) 
     LOOP
               
          raise_application_error(-20001, 'Введено неіснуючий ідентифікатор відділу');
          
END LOOP;


          FOR rec IN (SELECT 1
                      FROM jobs j
                      WHERE j.job_id = p_job_id
                      AND p_salary BETWEEN j.min_salary AND j.max_salary)
     LOOP
                -- Якщо запис знайдено, цикл виконається хоча б один раз
        RETURN; -- вихід із процедури без помилки
        
END LOOP;

    -- Якщо цикл не виконався жодного разу, значить записів немає
          raise_application_error(-20001, 'Введено неприпустиму заробітну плату для даного коду посади');

           
     IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') IN ('SAT', 'SUN')
            
     OR TO_CHAR(SYSDATE, 'HH24:MI') NOT BETWEEN '18:01' AND '07:59' THEN
           
         raise_application_error (-20001, 'Ви можете додавати нового співробітника лише в робочий час');
         
 END IF;

        INSERT INTO employee (employee_id, first_name, last_name,email,phone_number, hire_date,job_id,salary, commission_pct, manager_id,department_id)
        VALUES (emp_seq.NEXTVAL, p_first_name, p_last_name, p_email,p_phone_number,p_hire_date,p_job_id,p_salary,p_commission_pct,p_manager_id, p_department_id );     
             
      log_finish(p_proc_name => 'add_employee',
                 p_text      => 'Завершення логування, назва процесу = add_employee'); 
                            
                         
EXCEPTION
       WHEN OTHERS THEN
        -- виклик вашої процедури логування
      log_utils.log_error(p_proc_name => 'add_employee',
                          p_text      => 'В процедурі add_employee сталася помилка. ' || SQLERRM,
                          p_sqlerrm   =>SQLERRM);

        -- повторне підняття помилки, щоб користувач бачив її
        RAISE; 
                                  
END add_employee;
                           
END log_utils;
/
