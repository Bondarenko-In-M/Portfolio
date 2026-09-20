
DECLARE
    v_text VARCHAR2(4000);
BEGIN
    
    log_finish (p_proc_name => 'TEST_PROC',
               p_text      => NULL);
                                   
    dbms_output.put_line (v_text); 

END;
/
