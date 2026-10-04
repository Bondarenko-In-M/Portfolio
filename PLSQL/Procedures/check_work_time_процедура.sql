CREATE OR REPLACE PROCEDURE check_work_time IS

  v_day  VARCHAR2(3);
  v_time VARCHAR2(5);

BEGIN
  -- Присвоєння змінній знаяення дня тижня - перетворює поточну дату. Перетворює поточну дати у трилітерний код MON, TUE....
  v_day := to_char(SYSDATE,'DY','NLS_DATE_LANGUAGE = AMERICAN');
  -- Присвоєння значення змінній часу - повертає час уформаті години хвилини.
  v_time := to_char(SYSDATE,'HH24:MI');
  --визначаємо день
  IF v_day IN ('SAT','SUN')
    -- визначаємо чи час знаходиться поза межами робочого       
     OR v_time NOT BETWEEN '08:00' AND '18:00' THEN
  
    raise_application_error(-20001,'Порушено робочий час або робочий день');
  
  END IF;

END check_work_time;
/
