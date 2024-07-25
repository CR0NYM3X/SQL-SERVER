
### CONSULTAR SECUENCIAS 
```sql
SELECT
    SCHEMA_NAME(schema_id) AS schema_name,
    name AS name_sequence,
    start_value ,
    increment  ,
    current_value  
	create_date,
	modify_date
FROM sys.sequences; 
```


### CREAR SECUENCIAS
```SQL
CREATE SEQUENCE MiSecuencia
    AS INT
    START WITH 1
    INCREMENT BY 1;
```
