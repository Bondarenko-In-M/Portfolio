

/*Зробити механізм який буде оновлювати кожний день в БД, Український 
індекс мі жбанкі вських ставок овернайт.
Деталі :
Для того щоб побачити Український і ндекс мі жбанкі вських ставок овернайт, використовуємо API 
ві д НБУ:
https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json
Далі створюємо таблиці interbank_index_ua_history в БД пі д структуру відпові ді JSON структури. 
Створюємо view interbank_index_ua_v на
основі виклику API через функці ю SYS.GET_NBU. 
View interbank_index_ua_v повинна ві дразу парсити JSON структуру в окремі стовпчики з
потрі бним типом даних. Далі створюємо процедуру download_ibank_index_ua, яка повинна
вставляти дані з view interbank_index_ua_v в
таблицю interbank_index_ua_history.
Процедуру download_ibank_index_ua ставимо на шедулер з і нтервалом кожен день в 9 ранку
Зберегти код створення всі х об?єкті в, у файл пі д назвою H_06_01_tvoji_inichialy.sql. 
Загрузити в LMS Moodle.*/


--SET DEFINE OFF; -- один раз запустити

SELECT SYS.GET_NBU(p_url => 'https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json') AS res
FROM dual;

--створюємо таблиці interbank_index_ua_history в БД пі д структуру відпові ді JSON структури


CREATE TABLE interbank_index_ua_history
    (dt DATE,
     id_api VARCHAR2(100),
     value NUMBER,
     special VARCHAR2(100));
    
    
SELECT * FROM interbank_index_ua_history;

/*Створюємо view interbank_index_ua_v на
основі виклику API через функці ю SYS.GET_NBU.*/

CREATE OR REPLACE view interbank_index_ua_v AS
SELECT TO_DATE( j.dt, 'dd.mm.yyyy') AS dt, j.id_api, j.value, j.special
        FROM (SELECT SYS.GET_NBU(p_url => 'https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json') AS json_value FROM dual) t
CROSS JOIN    
    json_table(
    t.json_value,
    '$[*]'
    COLUMNS (
        dt       VARCHAR2(20) PATH '$.dt',
        id_api   VARCHAR2(50) PATH '$.id_api',
        value    NUMBER       PATH '$.value',
        special  VARCHAR2(50) PATH '$.special'
    )
) j;

/*створюємо процедуру download_ibank_index_ua, яка повинна
вставляти дані з view interbank_index_ua_v в
таблицю interbank_index_ua_history.*/


CREATE OR REPLACE PROCEDURE download_ibank_index_ua IS

BEGIN

    INSERT INTO interbank_index_ua_history (dt, id_api, value, special)
    SELECT TO_DATE( j.dt, 'dd.mm.yyyy') AS dt, j.id_api, j.value, j.special
        FROM (SELECT SYS.GET_NBU(p_url => 'https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json') AS json_value FROM dual) t
CROSS JOIN    
    json_table(
    t.json_value,
    '$[*]'
    COLUMNS (
        dt       VARCHAR2(20) PATH '$.dt',
        id_api   VARCHAR2(50) PATH '$.id_api',
        value    NUMBER       PATH '$.value',
        special  VARCHAR2(50) PATH '$.special'
    )
) j;
    
COMMIT;

END download_ibank_index_ua;
/


BEGIN
    download_ibank_index_ua;
END;
/

select * from interbank_index_ua_history;


-- Процедуру download_ibank_index_ua ставимо на шедулер з і нтервалом кожен день в 9 ранку


begin download_ibank_index_ua; end;

BEGIN
sys.dbms_scheduler.create_job(job_name => 'download_ibank_index',
                job_type               => 'PLSQL_BLOCK',
                job_action             => 'begin download_ibank_index_ua(); end;',
                start_date             => SYSDATE,
                repeat_interval        => 'FREQ=DAILY;BYHOUR=09;BYMINUTE=00',
                end_date               => TO_DATE(NULL),
                job_class              => 'DEFAULT_JOB_CLASS',
                enabled                => TRUE,
                auto_drop              => FALSE,
                comments               => 'Оновлення Українського індексу міжбанківських ставок овернайт');
END;
/


SELECT *
FROM all_scheduler_jobs sj;


SELECT *
FROM all_scheduler_job_run_details l;


BEGIN
  DBMS_SCHEDULER.RUN_JOB(job_name => 'download_ibank_index');
END;
/

SELECT *
FROM all_scheduler_job_run_details l;


BEGIN
dbms_scheduler.disable(name=>'download_ibank_index', force => TRUE);
END;
/
