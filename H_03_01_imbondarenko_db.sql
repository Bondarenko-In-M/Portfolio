
/*Cтворити процедуру пі д назвою DEL_JOBS, з двома параметрами, вхі дний - P_JOB_ID, та вихі дний параметр - PO_RESULT. Процедура повинна переві рити і снування посади, що
передається в параметрі P_JOB_ID, якщо посади немає, то записуємо текст у вихі дний параметр PO_RESULT = "Посада <p_job_id> не і снує" і зупиняємо подальші ді ї, а і накше
видаляємо посаду з таблиці JOBS і з значенням з вхі дного параметра P_JOB_ID та записуємо текст у вихі дний параметр 
PO_RESULT = "Посада <p_job_id> успі шно видалена".
Зберегти код для створення процедури у файл пі д назвою H_03_01_tvoji_inichialy.sql. Загрузити в LMS Moodle*/

create or replace PROCEDURE del_jobs (p_job_id     IN VARCHAR2,
                                      po_result    OUT VARCHAR2) IS
                                      
        v_count_job_id NUMBER;

BEGIN

    SELECT COUNT(*)
    INTO v_count_job_id
    FROM inna_dlw.jobs 
    WHERE job_id = p_job_id;


    IF v_count_job_id = 0 THEN
        po_result := 'Посада ' || p_job_id || ' не існує';

   ELSE

        DELETE from inna_dlw.jobs
        WHERE job_id = p_job_id;
        po_result := 'Посада ' || p_job_id || ' успішно видалена';


   END IF;

END del_jobs;
/

-- Виклик процедури

DECLARE
    v_result VARCHAR2(100);
BEGIN
    del_jobs (p_job_id  =>' R_VP',
              po_result => v_result);
                  
    dbms_output.put_line (v_result); 

END;
/





