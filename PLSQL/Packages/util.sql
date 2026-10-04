CREATE OR REPLACE PACKAGE util AS

        gc_min_salary CONSTANT NUMBER := 2000; -- еонстанти оголошуютьсязверху
        c_percent_of_min_salary CONSTANT NUMBER := 1.5;

        TYPE rec_value_list IS RECORD (value_list VARCHAR2(100)); -- оголошуємо Тип типу рекорд
        TYPE tab_value_list IS TABLE OF rec_value_list;
        
        TYPE rec_exchange IS RECORD (r030 NUMBER,
                                     txt VARCHAR2(100),
                                     rate NUMBER,
                                     cur VARCHAR2(100),
                                     exchangedate DATE );
        TYPE tab_exchange IS TABLE OF rec_exchange;
        
        TYPE rec_region IS RECORD (region_id NUMBER,
                                   region_name VARCHAR2(100),
                                   employee_counte NUMBER );


        TYPE tab_region IS TABLE OF rec_region;

        
        FUNCTION get_currency(p_currency     IN VARCHAR2 DEFAULT 'USD',
                      p_exchangedate IN DATE DEFAULT SYSDATE) RETURN tab_exchange PIPELINED;

        
        FUNCTION table_from_list (p_list_val IN VARCHAR2,
                                  p_separator IN VARCHAR2 DEFAULT ',') RETURN tab_value_list PIPELINED;
                                  
       FUNCTION get_region_cnt_emp (p_department_id IN VARCHAR2 default null
                                    ) RETURN tab_region PIPELINED;                           


        FUNCTION add_years(p_date IN DATE DEFAULT SYSDATE,
                           p_year IN NUMBER) RETURN DATE; 
                           
        FUNCTION get_dep_name(p_employee_id IN NUMBER) RETURN VARCHAR2;
        
        FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR2;
        
        FUNCTION get_sum_price_sales (p_table IN VARCHAR2) RETURN NUMBER;
                              
                           
        PROCEDURE add_new_jobs(p_job_id     IN VARCHAR2,
                              p_job_title  IN VARCHAR2,
                              p_min_salary IN NUMBER,
                              p_max_salary IN NUMBER DEFAULT NULL, -- процедура відпрацює і повернене те що вкажемо
                              po_err       OUT VARCHAR2);
                              
         PROCEDURE del_jobs (p_job_id     IN VARCHAR2,
                            po_result    OUT VARCHAR2);
                            
         PROCEDURE update_balance(p_employee_id IN NUMBER,
                                  p_balance     IN NUMBER);
                                  
         PROCEDURE add_employee( p_first_name     IN VARCHAR2,
                                 p_last_name      IN VARCHAR2,
                                 p_email          IN VARCHAR2,
                                 p_phone_number   IN VARCHAR2,
                                 p_hire_date      IN DATE DEFAULT trunc(sysdate, 'dd'),
                                 p_job_id         IN VARCHAR2, 
                                 p_salary         IN NUMBER,
                                 p_commission_pct IN VARCHAR2 DEFAULT NULL,
                                 p_manager_id     IN NUMBER DEFAULT 100,
                                 p_department_id  IN VARCHAR2);
                                      
END util;

/
        
CREATE OR REPLACE PACKAGE body util AS

        
FUNCTION table_from_list (p_list_val IN VARCHAR2,
                          p_separator IN VARCHAR2 DEFAULT ',') RETURN tab_value_list PIPELINED IS

    out_rec tab_value_list := tab_value_list();  -- ініціалізація змінної
    l_cur SYS_REFCURSOR;

BEGIN

   OPEN l_cur FOR
   
        SELECT TRIM(REGEXP_SUBSTR(p_list_val, '[^'||p_separator||']+', 1, LEVEL)) AS cur_value
        FROM dual
        CONNECT BY LEVEL <= REGEXP_COUNT(p_list_val, p_separator) + 1;
        
        
        BEGIN
        LOOP
            EXIT WHEN l_cur%NOTFOUND;
            FETCH l_cur BULK COLLECT -- для обробки великих данних
                INTO out_rec; 
                FOR i IN 1 .. out_rec.count LOOP
                     PIPE ROW(out_rec(i));
                 END LOOP;
        END LOOP;
        CLOSE l_cur;
        
        EXCEPTION
          WHEN OTHERS THEN
            IF (l_cur%ISOPEN) THEN
            CLOSE l_cur;
            RAISE;
           ELSE
        RAISE;
    END IF;
END;
    
END table_from_list;


FUNCTION get_currency(p_currency     IN VARCHAR2 DEFAULT 'USD',
                      p_exchangedate IN DATE DEFAULT SYSDATE) RETURN tab_exchange PIPELINED IS

    out_rec tab_exchange := tab_exchange();  -- ініціалізація змінної
    l_cur SYS_REFCURSOR;

BEGIN

   OPEN l_cur FOR
   
        SELECT tt.r030, tt.txt, tt.rate, tt.cur, TO_DATE(tt.exchangedate, 'dd.mm.yyyy') AS exchangedate
               FROM (SELECT get_needed_curr(p_valcode => p_currency,p_date => p_exchangedate) AS json_value FROM dual)
               CROSS JOIN json_table
        (
        json_value, '$[*]'
          COLUMNS
        (
        r030 NUMBER PATH '$.r030',
        txt VARCHAR2(100) PATH '$.txt',
        rate NUMBER PATH '$.rate',
        cur VARCHAR2(100) PATH '$.cc',
        exchangedate VARCHAR2(100) PATH '$.exchangedate'
        )
  ) TT;
        
        BEGIN
        LOOP
            EXIT WHEN l_cur%NOTFOUND;
            FETCH l_cur BULK COLLECT -- для обробки великих данних
                INTO out_rec; 
                FOR i IN 1 .. out_rec.count LOOP
                     PIPE ROW(out_rec(i));
                 END LOOP;
        END LOOP;
        CLOSE l_cur;
        
        EXCEPTION
          WHEN OTHERS THEN
            IF (l_cur%ISOPEN) THEN
            CLOSE l_cur;
            RAISE;
           ELSE
        RAISE;
    END IF;
END;
    
END get_currency;


FUNCTION get_region_cnt_emp (p_department_id IN VARCHAR2 default null
                             ) RETURN tab_region PIPELINED IS
    
    out_rec tab_region := tab_region();
    
    
    l_region SYS_REFCURSOR;
    
BEGIN

    OPEN l_region FOR 
    
        SELECT r.region_id,
               r.region_name,
               COUNT(em.employee_id) AS employee_count
        FROM inna_dlw.regions r
        JOIN inna_dlw.countries c
         ON r.region_id = c.region_id
        JOIN inna_dlw.locations l 
         ON c.country_id = l.country_id
        JOIN inna_dlw.departments d
         ON l.location_id = d.location_id
        JOIN inna_dlw.employee em
         ON d.department_id = em.department_id   
        WHERE (em.department_id = p_department_id or p_department_id is null)
        GROUP BY r.region_id, r.region_name;
        
     BEGIN
     LOOP
       EXIT WHEN l_region%NOTFOUND;
       FETCH l_region BULK COLLECT
       
           INTO out_rec;
           FOR i IN 1 .. out_rec.count LOOP
               PIPE ROW(out_rec(i));
               END LOOP;
           END LOOP;
           
           CLOSE l_region;
           
           EXCEPTION
             WHEN OTHERS THEN
                IF (l_region%ISOPEN) THEN
                CLOSE l_region;
                RAISE;
              ELSE
            RAISE;
        END IF;
    END;
END get_region_cnt_emp;


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

FUNCTION get_sum_price_sales (p_table IN VARCHAR2) RETURN NUMBER 
 IS

        v_dynamic_sql VARCHAR2(500);
        v_sum NUMBER;

BEGIN

    IF p_table NOT IN ('products_old', 'products') THEN
    
    to_log ( p_appl_proc => 'get_sum_price_sales',
             p_message => 'Неприпустиме значення! Очі кується products або products_old');
    
    raise_application_error (-20001, 'Неприпустиме значення! Очікується products або products_old');
    
END IF;
 
v_dynamic_sql := 'SELECT SUM(p.price_sales) FROM hr.'||p_table||' p';
--dbms_output.put_line(v_dynamic_sql);


EXECUTE IMMEDIATE v_dynamic_sql INTO v_sum;

--dbms_output.put_line(v_sum);

RETURN NVL(v_sum,0);

END get_sum_price_sales;



PROCEDURE add_new_jobs(p_job_id     IN VARCHAR2,
                       p_job_title  IN VARCHAR2,
                       p_min_salary IN NUMBER,
                       p_max_salary IN NUMBER DEFAULT NULL, -- процедура відпрацює і повернене те що вкажемо
                       po_err       OUT VARCHAR2) IS
    v_max_salary jobs.max_salary%TYPE; -- змінні пишуться в процедурі після блоку з параметрами
    salary_err EXCEPTION;
    
BEGIN

    BEGIN
    check_work_time;      
END;
    
    IF p_max_salary IS NULL THEN
        v_max_salary := p_min_salary * c_percent_of_min_salary;
    ELSE
        v_max_salary := p_max_salary;

    END IF;
    
BEGIN    
    IF ( p_min_salary < gc_min_salary OR p_max_salary < gc_min_salary ) THEN
          raise salary_err;
   
    ELSE
        INSERT INTO jobs (job_id,job_title,min_salary,max_salary)
        VALUES (p_job_id,p_job_title,p_min_salary,v_max_salary);
COMMIT;
        po_err := 'Посада '||p_job_id||' успішно додана';

    END IF;
    
    EXCEPTION
    
    WHEN salary_err THEN
        raise_application_error(-20001, 'Передана зарплата менша за 2000');
    WHEN dup_val_on_index THEN
        raise_application_error(-20002, 'Посада '||p_job_id||' вже існує');
    WHEN OTHERS THEN
        raise_application_error(-20003, 'Виникла помилка при додаванні нової посади. '|| SQLERRM);

 END;
 
-- COMMIT; 

END add_new_jobs;

PROCEDURE del_jobs (
             p_job_id     IN VARCHAR2,
             po_result    OUT VARCHAR2) IS
             
     v_delete_no_data_found EXCEPTION;
                                      
BEGIN

        DELETE from inna_dlw.jobs
        WHERE job_id = p_job_id;
        
        IF (SQL%ROWCOUNT = 0) THEN
        RAISE v_delete_no_data_found;
    ELSE
        po_result := 'Посада ' || p_job_id || ' успішно видалена';
        
END IF;
 

EXCEPTION

        WHEN v_delete_no_data_found THEN
        raise_application_error(-20004, 'Посада '||p_job_id||' неіснує');
        

END del_jobs;

PROCEDURE update_balance(p_employee_id IN NUMBER,
                         p_balance IN NUMBER) IS
                         
    v_balance_new balance.balance%TYPE;
    v_balance_old balance.balance%TYPE;
    v_message logs.message%TYPE;
    
BEGIN
        SELECT balance
        INTO v_balance_old
        FROM balance b
        WHERE b.employee_id = p_employee_id
        FOR UPDATE; -- Блокуємо рядок для оновлення
        
        IF v_balance_old >= p_balance THEN
            UPDATE balance b
            SET b.balance = v_balance_old - p_balance
            WHERE employee_id = p_employee_id
            RETURNING b.balance INTO v_balance_new; -- щоб не робити новий SELECT INTO
        ELSE
        v_message := 'Employee_id = '||p_employee_id||'. Недостатньо кошті в на рахунку. Поточний баланс '||v_balance_old||', спроба зняття '||p_balance||'';
        raise_application_error(-20001, v_message);
END IF;

        v_message := 'Employee_id = '||p_employee_id||'. Кошти успі шно зняті з рахунку. Було '||v_balance_old||', стало '||v_balance_new||'';
        dbms_output.put_line(v_message);
        to_log(p_appl_proc => 'util.update_balance', p_message => v_message);

/*
IF 1=0 THEN -- зі мі туємо непередбачену помилку
        v_message := 'Непередбачена помилка';
        raise_application_error(-20001, v_message);
END IF;*/

COMMIT; -- збері гаємо новий баланс та зні маємо блокування в поточні й транзакці ї


EXCEPTION 
    WHEN OTHERS THEN
        to_log(p_appl_proc => 'util.update_balance', p_message => NVL(v_message, 'Employee_id = '||p_employee_id||'. ' ||SQLERRM));
        ROLLBACK; -- Ві дмі няємо транзакці ю у разі виникнення помилки
        raise_application_error(-20001, NVL(v_message, 'Не ві дома помилка'));

END update_balance;

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

        v_count NUMBER;
                                              
BEGIN
 
       log_utils.log_start (p_proc_name => 'add_employee',
                            p_text      => 'Старт логування, назва процесу = add_employee');
                                  
            
        FOR cc IN (SELECT 1
                   FROM jobs j
                   WHERE j.job_id = p_job_id
                   HAVING COUNT(1) = 0) LOOP
               
          raise_application_error(-20001, 'Введено неіснуючий код посади');
                
       END LOOP;

         FOR cc IN (SELECT 1
                    FROM departments dep
                    WHERE dep.department_id = p_department_id
                    HAVING COUNT(1) = 0) LOOP
               
          raise_application_error(-20001, 'Введено неіснуючий ідентифікатор відділу');
          
        END LOOP;


          SELECT COUNT(*)
          INTO v_count
          FROM jobs j
          WHERE j.job_id = p_job_id
          AND p_salary BETWEEN j.min_salary AND j.max_salary;

      IF v_count = 0 THEN
              
          raise_application_error(-20001, 'Введено неприпустиму заробітну плату для даного коду посади');

      END IF;

               
     IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') IN ('SAT', 'SUN')
            
     OR TO_CHAR(SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00' THEN
           
         raise_application_error (-20001, 'Ви можете додавати нового співробітника лише в робочий час');
         
     END IF;

        INSERT INTO employee (employee_id, first_name, last_name,email,phone_number, hire_date,job_id,salary, commission_pct, manager_id,department_id)
        VALUES (emp_seq.NEXTVAL, p_first_name, p_last_name, p_email,p_phone_number,p_hire_date,p_job_id,p_salary,p_commission_pct,p_manager_id, p_department_id );     
             
      log_utils.log_finish(p_proc_name => 'add_employee',
                           p_text      => 'Завершення логування, назва процесу = add_employee'); 
                            
                         
EXCEPTION
       WHEN OTHERS THEN
        -- виклик процедури логування
      log_utils.log_error(p_proc_name => 'add_employee',
                          p_text      => 'В процедурі add_employee сталася помилка. ' || SQLERRM,
                          p_sqlerrm   =>SQLERRM);

        -- повторне підняття помилки, щоб користувач бачив її
        RAISE; 
                                  
END add_employee;
               


END util;
/
