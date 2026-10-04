CREATE TABLE employees_history (
                                employee_id    NUMBER,
                                first_name     VARCHAR2(50),
                                last_name      VARCHAR2(50),
                                email          VARCHAR2(50),
                                phone_number   VARCHAR2(50),
                                salary         NUMBER,
                                commission_pct NUMBER,
                                manager_id     NUMBER,
                                job_id         VARCHAR2(20),
                                department_id  NUMBER,
                                hire_date      DATE,
                                deleted_date   DATE DEFAULT SYSDATE);
