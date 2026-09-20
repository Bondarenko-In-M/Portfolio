create or replace package log_utils is

 PROCEDURE log_start (p_proc_name IN VARCHAR2,
                     p_text IN VARCHAR2 := NULL);
                     
PROCEDURE log_finish(p_proc_name IN VARCHAR2,
                     p_text      IN VARCHAR2 := NULL);
                     
PROCEDURE log_error(p_proc_name IN VARCHAR2,
                    p_text      IN VARCHAR2 := NULL,
                    p_sqlerrm   IN VARCHAR2);
  
  
end log_utils;




--log_utils body


create or replace package body log_utils as

PROCEDURE to_log(p_appl_proc IN VARCHAR2,
                        p_message   IN VARCHAR2) IS
    PRAGMA autonomous_transaction; -- процедура буде виконуватись незалежно від батьківської транзакції
BEGIN
    INSERT INTO logs(id, appl_proc, message)
    VALUES(log_seq.NEXTVAL, p_appl_proc, p_message);

COMMIT;

END to_log;


PROCEDURE log_start (p_proc_name IN VARCHAR2,
                     p_text IN VARCHAR2 := NULL) is
                                       
        v_text VARCHAR2(4000);
        
               
BEGIN
  
    IF p_text IS NULL THEN
      
       v_text  := 'Старт логування, назва процесу = ' || p_proc_name;
    ELSE
       v_text  := p_text;

    END IF;
    
    to_log(p_appl_proc => p_proc_name,
           p_message   => v_text);
    
    
END log_start;


PROCEDURE log_finish(p_proc_name IN VARCHAR2,
                                       p_text      IN VARCHAR2 := NULL) is
                                       
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

PROCEDURE log_error(p_proc_name IN VARCHAR2,
                                      p_text      IN VARCHAR2 := NULL,
                                      p_sqlerrm   IN VARCHAR2) is
                                       
       v_text VARCHAR2(4000);
        
               
BEGIN
  
    IF p_text IS NULL THEN
      
       v_text  :='В процедурі' || p_proc_name ||' сталася помилка. ' || p_sqlerrm;
    ELSE
        v_text := p_text;

    END IF;
    
    to_log(p_appl_proc => p_proc_name,
           p_message   => v_text);
    
    
END log_error;
                            

END log_utils;
/
