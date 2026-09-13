/*
Опис:
Зробити потрі бний зві т і ві дправити його собі на пошту, знайшовши 
при цьому свою пошту в таблиці employees.
Деталі :
Зробити собі в схемі копію таблиці hr.employees та додати себе в 
цю таблицю, де в поле EMAIL треба додати свій реальний логін 
ві д своєї пошти. Далі зробити звіт про кількість працівників в
розрізі департаменту. Результат цього звіту відправити поштою 
у виді таблиці, де буде два стовпчика - "Ід департаменту" та 
"Кі лькі сть спі вробі тникі в". Ві дправник повинен автоматично
вичитуватися з таблиці employees твоєї схеми де, по EMPLOYEE_ID 
треба знайти сві й логі н і далі при контактувати сві й домен пошти 
(наприклад @GMAIL.COM)*/


DECLARE
v_recipient VARCHAR2(50);
v_subject VARCHAR2(50) := 'test_subject';
v_mes VARCHAR2(5000)   := 'Вітаю шановний! </br> Ось звіт з нашої компанії: </br></br>';
BEGIN
        SELECT
           v_mes||'<!DOCTYPE html>
           <html>
             <head>
               <title></title>
                <style>
                    table, th, td {border: 1px solid;}
                    .center{text-align: center;}
                </style>
             </head>
             <body>
                <table border=1 cellspacing=0 cellpadding=2 rules=GROUPS frame=HSIDES>
                    <thead>
                      <tr align=left>
                      <th>Ід Департаменту</th>
                      <th>Кількість співробі тників</th>
                   </tr>
                 </thead>
                  <tbody>
                  '|| list_html || '
                  </tbody>
                </table>
            </body>
          </html>' AS html_table
          
INTO v_mes
    FROM (SELECT LISTAGG('<tr align=left>
          <td>' || department_id || '</td>' || '
          <td class=''center''> ' || cnt_empl||'</td>
          </tr>', '<tr>')
    WITHIN GROUP(ORDER BY cnt_empl) AS list_html
    
    FROM ( SELECT department_id, COUNT(1) AS cnt_empl
           FROM employee
           GROUP BY department_id
           HAVING COUNT(1) > 2 ));
           
    v_mes := v_mes || '</br></br> З повагою, Inna';

        SELECT em.email 
        INTO v_recipient
        FROM  employee em
        WHERE em.employee_id = 208;

    v_recipient := v_recipient || '@gmail.com';

sys.SENDMAIL(
        p_recipient => v_recipient, -- 'innabondarenkowork@gmail.com',
        p_subject   => v_subject,
        p_message   => v_mes
    );
END;
/



SELECT em.email || '@gmail.com' AS sender_email
FROM  employee em
WHERE em.employee_id = 208;
