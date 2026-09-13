/*Опис:
Створити pipelined функці ю get_region_cnt_emp
Деталі :
Отримати список регі оні в та кі лькі сть спі вробі тникі в у кожному регі оні . Коли буде повні стю готовий SQL запит, зробити такий хитрий фі льтр where (em.department_id = null or null is null). Далі в
пакеті util створити pipelined функці ю get_region_cnt_emp з потрі бними типами RECORD та TABLE. Зробити вхі дний параметр p_department_id default null і в середині функці ї передати цей
параметр в SQL запит - where (em.department_id = p_department_id or p_department_id is null). Таким чином якщо функці ю викликати без значення у параметрі p_department_id, функці ю
повинна повернути дані по всі м департаментом і нфу, а якщо передамо конкретне значення у p_department_id, тоді функці ю повинна повернути дані по переданому департаменту.*/

--Створеннятаблиць яких не було на власній схемі
create table inna_dlw.regions as
select *
from hr.regions reg

create table inna_dlw.countries as
select *
from hr.countries c;

create table inna_dlw.locations as
select *
from hr.locations loc;

--виклик функції
SELECT *
FROM TABLE(util.get_region_cnt_emp());

-- -- оголошення типів  RECORD та TABLE - оголошубться в пакеті. На створенняпотрібні окремі права. Права на оголошення та 
-- створення видає ДБА адмін

TYPE rec_region IS RECORD (region_id NUMBER,
                                   region_name VARCHAR2(100),
                                   employee_counte NUMBER );

TYPE tab_region IS TABLE OF rec_region;


--Створення пейплайн функції

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


