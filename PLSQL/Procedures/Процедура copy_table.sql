CREATE OR REPLACE PROCEDURE copy_table(p_source_scheme IN VARCHAR2,
                                       p_target_scheme IN VARCHAR2 DEFAULT USER,
                                       p_list_table    IN VARCHAR2,
                                       p_copy_data     IN BOOLEAN DEFAULT FALSE,
                                       po_result       OUT VARCHAR2) IS
  v_count NUMBER;
  v_sql   CLOB;
  
BEGIN
  log_utils.log_start(p_proc_name => 'copy_table',
                     p_text      => 'Старт логування copy_table');
/*Знайти потрібні дані про таблиці в системній view all_tab_columns. 
Значення з параметру p_list_table (очікується через кому без пробілів) 
передати у WHERE до стовпчика all_tab_columns.table_name через розроблену раніше PIPELINED функцію table_from_list. 
Значення з параметру p_source_scheme передати у поле all_tab_columns.owner. 
Запит в середині виконує пошук таблиць таблицьта даних, якібудуть передані в перенесесену таблицю
Зовнішній запит виконує створення таблиці та генерує DDL код для існуючих таблиць
LISTAGG - збирає всістовпців один рядок і розділяє їх комлю.*/     

  FOR rec IN (SELECT table_name AS table_name,'CREATE TABLE ' || table_name || ' (' || listagg(column_name || ' ' || data_type || count_symbol ,', ') within GROUP(ORDER BY column_id) || ')' AS ddl_code
                FROM (SELECT table_name,
                             column_name,
                             data_type,
                             CASE
                               WHEN data_type IN ('VARCHAR2','CHAR') THEN'(' || data_length || ')'
                               WHEN data_type = 'NUMBER' THEN
                               REPLACE('(' || data_precision || ',' || data_scale || ')','(,)',NULL)
                               ELSE
                                NULL
                             END AS count_symbol, column_id 
                        FROM all_tab_columns
                       WHERE owner = upper(p_source_scheme)
                         AND table_name IN (SELECT value_list
                                              FROM TABLE(util.table_from_list(p_list_table)))
                       ORDER BY table_name,column_id)
               GROUP BY table_name) LOOP
    BEGIN
-- Виконати перевірку існування таблиці 
      SELECT COUNT(*)
        INTO v_count
        FROM all_tables
       WHERE owner = upper(p_target_scheme)
         AND table_name = upper(rec.table_name);
-- Якщо таблиця вже існує виводимо помилку       
      IF v_count > 0 THEN
        dbms_output.put_line('Таблиця вже існує');
      ELSE
        BEGIN
          EXECUTE IMMEDIATE rec.ddl_code;
--Копіювання даних у перенесену таблицю з використанням динамічного SQl        
          IF p_copy_data THEN
            SELECT 'INSERT INTO ' || p_target_scheme || '.' || rec.table_name || ' (' ||
                   listagg(column_name,', ') within GROUP(ORDER BY column_id) || ')' || ' SELECT ' || listagg(column_name, ', ') within GROUP(ORDER BY column_id) || ' FROM ' || p_source_scheme || '.' || rec.table_name
             INTO v_sql
             FROM all_tab_columns
             WHERE owner = upper(p_source_scheme)
             AND table_name = upper(rec.table_name);
          
            EXECUTE IMMEDIATE v_sql;
          END IF;
        
        
        EXCEPTION
          WHEN OTHERS THEN
            
 -- У разі неуспішності виконужмо логування  
            log_utils.log_error(p_proc_name => 'copy_table'
                               ,p_text      => 'В процедурі copy_table сталася помилка. ' || SQLERRM
                               ,p_sqlerrm   => SQLERRM);
            CONTINUE;
        END;
      END IF;
    END;
  END LOOP;

  po_result := 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
    po_result := 'ERROR: ' || SQLERRM;
END copy_table;


--Наступним кроком згенерувати динамічним селектом вставку даних в таблицю яку створили, кроком назад.

--Крок №4 обвернути в IF p_copy_data = TRUE, тілько тоді виконуємо крок №4.

--Крок №3 обвернути в BEGIN..END i якщо наступить будь-який EXCEPTION то записати це в лог (процедурою to_log. Текст довільний) та запустити команду переходу до наступної ітерації циклу (CONTINUE).

 -- Перед END LООР записувати кожну ітерацію в логи (процедурою to_log. Текст довільний).
 
/
