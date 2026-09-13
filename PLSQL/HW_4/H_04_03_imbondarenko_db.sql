/*На основі першого PL-SQL блоку з практики по темі "Динамі чний SQL", написати функці ю в пакеті util, яка б повертала суму зі схеми HR,
з таблиці products або products_old.
Деталі :
Створити функці ю util.get_sum_price_sales з одним вхі дним параметром p_table (цей параметр повинен працювати ті льки і з
значеннями - products або products_old) - якщо передати в параметр
p_table, будь-яке і нше значення, яке ві дрі зняється ві д products або products_old, тоді ві дразу генерувати помилку 
з текстом "Неприпустиме значення! Очі кується products або products_old" (код помилки
-20001). Якщо переві рка пройшла, тоді функці я повинна вивести суму по полю price_sales з потрі бної таблиці .
Також, якщо переві рка не пройшла, перед викликом raise_application_error, викликати процедуру to_log для запису в лог про 
не успі шний виклик функці ї. В параметр p_message передати точно такий же
текст як і в raise_application_error.
Зберегти код оголошеної функці ї у файл пі д назвою H_04_03_tvoji_inichialy.sql. Загрузити в LMS Moodle.*/

create or replace FUNCTION get_sum_price_sales (
                           p_table IN VARCHAR2) RETURN NUMBER 
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
/


SELECT get_sum_price_sales (p_table => 'jobs') AS sum_sales
     FROM dual;



