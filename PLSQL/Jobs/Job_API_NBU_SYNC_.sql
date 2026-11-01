begin api_nbu_sync; end;

BEGIN
sys.dbms_scheduler.create_job(job_name               => 'API_NBU_SYNC_',
                              job_type               => 'PLSQL_BLOCK',
                              job_action             => 'begin api_nbu_sync(); end;',
                              start_date             => SYSDATE,
                              repeat_interval        => 'FREQ=DAILY;BYHOUR=06;BYMINUTE=00',
                              end_date               => TO_DATE(NULL),
                              job_class              => 'DEFAULT_JOB_CLASS',
                              enabled                => TRUE,
                              auto_drop              => FALSE,
                              comments               => 'Оновлення курсів валют по курсу НБУ');
END;
/


