
### Hacer casting o conversióin de datos
```
SELECT CAST(@numero AS VARCHAR(50)) AS NumeroComoVarchar;
SELECT CONVERT(VARCHAR(50), @numero) AS NumeroComoVarchar;
```



### Ejecutar querys que se tienen guardadas en una variable usando funcion EXEC

```
DECLARE @str varchar(max)=''
DECLARE @param1 varchar(50) 

SET @param1 =  '10.16.32.209'
SET @str='SELECT * FROM  my_tabla_server where ipservidor = '+char(39)+  @param1 +char(39)

select @str
EXEC (@str)

--**********************************************************************************************

SELECT st.text, *
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
WHERE st.text like '%SELECT * FROM  my_tabla_server%' 
--**********************************************************************************************
```

### Ejecutar querys que se tienen guardadas en una variable usando funcion sp_executesql
```
DECLARE @param1 varchar(50) 
DECLARE @param2 varchar(50) 

SET @param1 =  '10.16.32.209'
SET @param2 =  '10.44.153.102'

EXEC sp_executesql N'SELECT * FROM  my_tabla_server where ipservidor in( @1, @2) order by ipservidor',N'@1 varchar(50),@2 varchar(50)'
,@param1,@param2
```

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

### Condicionales 
```
DECLARE @variable INT = 10;

IF @variable > 5
BEGIN
    PRINT 'La variable es mayor que 5.';
END
ELSE
BEGIN
    PRINT 'La variable no es mayor que 5.';
END
```

### Bucles 
- Ejemplo #1
```
DECLARE @contador INT = 1;

WHILE @contador <= 5
BEGIN
    PRINT 'Valor del contador: ' + CAST(@contador AS NVARCHAR(10));
    SET @contador = @contador + 1;
END


DECLARE @contador INT = 1;
BEGIN
    WHILE @contador <= 5
    BEGIN
        PRINT 'Valor del contador: ' + CAST(@contador AS NVARCHAR(10));
        SET @contador = @contador + 1;
    END
END
```

- Ejemplo #2
  Te imprime el nombre de todas las tablas 
```
DECLARE @tableName NVARCHAR(MAX);
DECLARE @tableList NVARCHAR(MAX) = '';

-- Declaración del cursor que obtiene los nombres de las tablas de la base de datos
DECLARE tableCursor CURSOR FOR
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE'; -- Solo tablas, sin vistas ni otros objetos

OPEN tableCursor; -- Abre el cursor para comenzar a recorrer los resultados

-- Obtiene la primera fila de resultados del cursor
FETCH NEXT FROM tableCursor INTO @tableName;

-- Comienza el bucle WHILE para recorrer todas las filas del cursor
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Concatena el nombre de la tabla al contenido de la variable @tableList
    SET @tableList = @tableList + @tableName + CHAR(10);

    -- Obtiene la siguiente fila de resultados del cursor
    FETCH NEXT FROM tableCursor INTO @tableName;
END

CLOSE tableCursor; -- Cierra el cursor
DEALLOCATE tableCursor; -- Libera los recursos asociados al cursor

-- Imprime los nombres de las tablas almacenados en la variable @tableList
PRINT 'Nombres de las tablas:';
PRINT @tableList;
```


### Bibliografía 
https://sql-listo.com/t-sql/exec-vs-sp_executesql/
