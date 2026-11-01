
SELECT *
FROM all_scheduler_jobs sj;


SELECT *
FROM all_scheduler_job_run_details l;


BEGIN
  DBMS_SCHEDULER.RUN_JOB(job_name => 'API_NBU_SYNC_');
END;
/

SELECT *
FROM all_scheduler_job_run_details l;


BEGIN
dbms_scheduler.disable(name=>'API_NBU_SYNC_', force => TRUE);
END;
/
