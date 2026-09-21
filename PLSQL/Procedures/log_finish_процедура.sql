CREATE OR REPLACE PROCEDURE log_finish(p_proc_name IN VARCHAR2,
                                       p_text      IN VARCHAR2 DEFAULT NULL) is
                                       
        v_text VARCHAR2(4000);
        
               
BEGIN
  
    IF p_text IS NULL THEN
      
       v_text  :='Завершення логування, назва процесу = '|| p_proc_name;
    ELSE
        v_text := p_text;

    END IF;
    
    to_log(p_appl_proc => p_proc_name,
           p_message   => v_text);
    
    
END log_finish;
/
