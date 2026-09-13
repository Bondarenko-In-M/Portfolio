
/*Опис:
Доробити і снуючу процедуру util.del_jobs через використання EXCEPTION-ні в.
Деталі :
Шматок коду з DELETE обернути в BEGIN .. EXCEPTION .. END. Оголосити змі нну v_delete_no_data_found 
типу даних EXCEPTION. Ві дразу пі сля виконання DELETE, зробити якщо
SQL%ROWCOUNT = 0 тоді запускати RAISE v_delete_no_data_found. В блоці EXCEPTION написати якщо наступила
наша користувацька помилка v_delete_no_data_found, тоді
генерувати помилку (через raise_application_error) "Посада <p_job_id> не і снує" (код помилки -20004).
В конструкці ї через EXCEPTION, нам НЕ потрі бна змі нна v_is_exist_job
та SELECT INTO, де ми записуємо в цю змі нну кі лькі сть. Також в пі дсумку НЕ потрі бен IF..ELSE 
де ми шось шукали в змі нні й v_is_exist_job. Тобто все НЕ потрібне треба
прибрати. В пі ддсумку, якщо посада видалена успі шно, залишити як і було запис тексту
"Посада <p_job_id> успі шно видалена" у вихі дний параметр po_result.
Також перед блоком з видаленням посади, з початку треба переві рити чи робочий сьогодні день. 
Це зробити просто за допомогою виклику процедури check_work_time.
Зберегти код доробленої оголошеної функці ї у файл пі д назвою H_04_02_tvoji_inichialy.sql. 
Загрузити в LMS Moodle.
3О*/


CREATE OR REPLACE PROCEDURE del_jobs (
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
        raise_application_error(-20004, 'Посада '||p_job_id||' не і снує');
        

END del_jobs;
/

/*ВИКЛИК*/

DECLARE
    v_result VARCHAR2(100);
BEGIN
    del_jobs('AD_PRES', v_result);
    dbms_output.put_line(v_result);
END;
/


/***********************************************************
СИТАРА ПРОЦЕДУРА
***********************************************************/


PROCEDURE del_jobs (p_job_id     IN VARCHAR2,
                                      po_result    OUT VARCHAR2) IS
                                      
        v_count_job_id NUMBER;

BEGIN

    SELECT COUNT(*)
    INTO v_count_job_id
    FROM inna_dlw.jobs 
    WHERE job_id = p_job_id;


    IF v_count_job_id = 0 THEN
        po_result := 'Посада ' || p_job_id || ' не і снує';

   ELSE

        DELETE from inna_dlw.jobs
        WHERE job_id = p_job_id;
        po_result := 'Посада ' || p_job_id || ' успішно видалена';


   END IF;

END del_jobs;



