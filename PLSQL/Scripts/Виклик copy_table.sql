

DECLARE
   v_result VARCHAR2(4000);
BEGIN
util.copy_table(
      p_source_scheme => 'HR',
      p_target_scheme => USER,  
      p_list_table    => 'SALES,PRODUCTS_OLD', --'PRODUCTS',
      p_copy_data     => TRUE,  
      po_result       => v_result
   );

   DBMS_OUTPUT.PUT_LINE(v_result);
END;


/



SELECT * FROM hr.sales sl
 
SELECT * FROM sales s


SELECT * FROM hr.products_old po

select * from products_old p
