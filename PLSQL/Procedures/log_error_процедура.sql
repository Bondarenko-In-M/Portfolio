CREATE OR REPLACE PROCEDURE log_error(p_proc_name IN VARCHAR2,
                                      p_text      IN VARCHAR2 := NULL,
                                      p_sqlerrm   IN VARCHAR2) is
                                       
       v_text VARCHAR2(4000);
        
               
BEGIN
  
    IF p_text IS NULL THEN
      
       v_text  :=''В процедурі' || p_proc_name ||' сталася помилка. ' || p_sqlerrm;
    ELSE
        v_text := p_text;

    END IF;
    
    to_log(p_appl_proc => p_proc_name,
           p_message   => v_text);
    
    
END log_error;
/
