


### concatenar 
t1.columna4 + ' ' + t2.columna4  

### hacer una sola  fila de una columna 
```
SELECT 
    STUFF((
        SELECT ', ' + columna1
        FROM miTabla
        WHERE condicion -- Añade una condición para seleccionar las filas que deseas combinar
        FOR XML PATH('')), 1, 2, '') AS nueva_columna1
```


### hacer el linke que no sea sensible a Mayúsculas o Minúsculas 
select * from sys.server_principals where  name  like '%sysprogsclx%' COLLATE SQL_Latin1_General_CP1_CI_AS

### variables 
Las variables son temporales y solo se pueden usar en la consulta que se ejecutan por ejemplo en este caso necesitas ejecutar todo junto si primero ejecutas la varibale y despues las segunda linea, no va servir
```
DECLARE @mi_variable INT; -- Declaración de una variable de tipo entero

SET @mi_variable = 10; -- Asignación de un valor a la variable

SELECT @mi_variable AS 'Valor de la variable'; 
```
