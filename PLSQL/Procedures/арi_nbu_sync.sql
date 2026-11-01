--SET DEFINE OFF; -- один раз запустити


CREATE OR REPLACE PROCEDURE api_nbu_sync IS
  v_list_currencies VARCHAR2(200);
BEGIN

  log_utils.log_start(p_proc_name => 'api_nbu_sync',
                      p_text      => 'Старт логування api_nbu_sync');
  -- Отримуємо список валют із sys_params
  SELECT value_text
    INTO v_list_currencies
    FROM sys_params
   WHERE раrаm_name = 'list_currencies';

  dbms_output.put_line('Значення параметра: ' || v_list_currencies);

  -- Прокручуємо в циклі всі валюти через util.table_from_list
  FOR cc IN (SELECT value_list AS curr
               FROM TABLE(util.table_from_list(p_list_val => v_list_currencies))) LOOP
    -- Виконання інсерту при кожній ітерації з util.get_currency
    INSERT INTO cur_exchange (r030,
                              txt,
                              rate,
                              cur,
                              exchangedate)
      
      SELECT t.r030,
             t.txt,
             t.rate,
             t.cur,
             to_date(t.exchangedate,'dd.mm.yyyy')
        FROM TABLE(util.get_currency(p_currency => cc.curr)) t;
  END LOOP;

  -- Завершення логування
  log_utils.log_finish(p_proc_name => 'api_nbu_sync');

  --В нших випадках викликаємо помилку
EXCEPTION
  WHEN OTHERS THEN
    log_utils.log_error(p_proc_name => 'api_nbu_sync',
                        p_text      => 'В процедурі api_nbu_sync сталася помилка. ' || SQLERRM,
                        p_sqlerrm   => SQLERRM);
  
END api_nbu_sync;
/
