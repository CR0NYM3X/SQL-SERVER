


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
