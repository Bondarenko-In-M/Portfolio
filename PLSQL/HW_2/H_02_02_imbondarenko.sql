
/*Створити PL-SQL блок, який по department_id=80 виводить і м?я та прі звище, через крапку з комою виводить прибавку до зарплати і через крапку з комою опис процента
(мі ні мальний, середні й або максимальний). Для прикладу, повинно вийти так: "Спі вробі тник - Ellen Abel; процент до зарплати - 30%; опис процента - середні й"
Деталі :
Завести змі нну v_def_percent типу даних VARCHAR2(30) та змі нну v_percent типу даних VARCHAR2(5).
В середині PL-SQL блоку, через цикл FOR обробити кожен рядок з таблиці
спі вробі тникі в (зробити сортування по і мені ) з департаменту 80 таким чином:
В селекті створити стовпчик percent_of_salary (це буде прибавка до зарплати),
по такі й формулі - commission_pct*100
В селекті створити об?єднаний стовпчик emp_name - first_name + last_name
Далі в середині LOOP зробити перше розгалуження через IF, таким чином:
Якщо manager_id = 100, тоді вивести текст в такому форматі - "Спі вробі тник - <emp_name>, процент до зарплати на зараз заборонений", та завершити поточну і тераці ю
Зробити друге розгалуження через IF, таким чином:
--Якщо percent_of_salary в і нтервалі мі ж 10 та 20, тоді змі нні й v_def_percent присвоїти значення "мі ні мальний"
--Якщо percent_of_salary в і нтервалі мі ж 25 та 30, тоді змі нні й v_def_percent присвоїти значення "середні й"
--Якщо percent_of_salary в і нтервалі мі ж 35 та 40, тоді змі нні й v_def_percent присвоїти значення "максимальний"
--Змі нні й v_percent присвоїти значення, по такі й формулі - CONCAT(percent_of_salary, '%')
--Вивести текст в такому форматі : "Спі вробі тник - <emp_name>; процент до зарплати - <v_percent>; опис процента - <v_def_percent>"*/

DECLARE
    v_def_percent VARCHAR2(30);
    v_percent     VARCHAR2(10); 
BEGIN
    FOR cc IN (
        SELECT 
            em.first_name || ' ' || em.last_name AS emp_name,
            em.manager_id,
            em.commission_pct,
            (em.commission_pct * 100) AS percent_of_salary
        FROM hr.employees em
        WHERE em.department_id = 80) LOOP
        IF cc.manager_id = 100 THEN 
            DBMS_OUTPUT.PUT_LINE('Співробітник - ' || cc.emp_name ||', процент до зарплати на зараз заборонений');
        END IF;        

        IF cc.percent_of_salary BETWEEN 10 AND 20 THEN
            v_def_percent := 'мінімальний';
        ELSIF cc.percent_of_salary BETWEEN 25 AND 30 THEN
            v_def_percent := 'середній';
        ELSIF cc.percent_of_salary BETWEEN 35 AND 40 THEN
            v_def_percent := 'максимальний';
        
        END IF;        

        v_percent := CONCAT(cc.percent_of_salary, '%');

            DBMS_OUTPUT.PUT_LINE('Співробітник - ' || cc.emp_name ||'; процент до зарплати - ' || v_percent ||'; опис процента - ' || v_def_percent);
    END LOOP;      
END;
/



