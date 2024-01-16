Obtener el contenido de una view
```
SELECT 
    TABLE_NAME, 
    VIEW_DEFINITION
FROM 
    information_schema.views
WHERE 
    TABLE_NAME = 'NombreDeTuVista';
	
	
	
SELECT 
    definition
FROM 
    sys.sql_modules
WHERE 
    object_id = OBJECT_ID('NombreDeTuVista');



SELECT OBJECT_DEFINITION(OBJECT_ID('master.sys.server_principals')) AS CodigoDeLaVista;
	
	```
