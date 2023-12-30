### Hacer un begin y un rollback

```sql
BEGIN TRANSACTION; -- empieza la transaccion 

select top 10   * from MY_TABLA1(nolock) WHERE ID=6
UPDATE MY_TABLA1 SET NOMBRE = '------JOEL ANTONIO888' WHERE ID=7
delete  MY_TABLA1  WHERE ID=7

COMMIT TRANSACTION; -- esto si esta todo bien y realizara los cambios hechos  
ROLLBACK TRANSACTION;  -- esto si no queremos que realice los cambios realizados 
```

### Colocar tiempo para que se ejecute una consulta 
```
WAITFOR DELAY '00:00:05';
```

### Ejecutar una consulta en todas las base de datos  
```
execute SYS.sp_MSforeachdb 'use [?];  select @@version;'
```

### Hacer casting o conversióin de datos
```
cast( 5000 as  decimal(10,2))
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
**IF**
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

**WHEN CASE**
```
SELECT 
    CASE
        WHEN condición_1 THEN resultado_1
        WHEN condición_2 THEN resultado_2
        ELSE resultado_por_defecto
    END AS nombre_columna_resultado
FROM tu_tabla;
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
 usando cursores   Te imprime el nombre de todas las tablas 
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

- Ejemplo #3 usando cursores 
```
DECLARE @name_ NVARCHAR(100), @type_desc_ NVARCHAR(100), @create_date_ NVARCHAR(100)
DECLARE @dbRoleMembers CURSOR

SET @dbRoleMembers = CURSOR FOR
select name,type_desc,create_date from sys.database_principals

OPEN @dbRoleMembers
FETCH NEXT FROM @dbRoleMembers INTO @name_, @type_desc_, @create_date_

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Nombre: ' + @name_ + ', Tipo: ' + @type_desc_ + ', Fecha: ' + @create_date_
    FETCH NEXT FROM @dbRoleMembers INTO @name_, @type_desc_, @create_date_
END

CLOSE @dbRoleMembers
DEALLOCATE @dbRoleMembers
```


### trabajando con columnas 
```
SELECT value AS Valor
FROM (
    VALUES 
        (10), 
        (25),
		(23)
) AS ArrayDatos(value);


DECLARE @cadena VARCHAR(100) = 'uno,dos,tres,cuatro';

SELECT value AS Valor
FROM STRING_SPLIT(@cadena, ',');
```


#  paginación de resultados.
```
SELECT *
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY firstname) AS RowNum
    FROM [Employees]
) AS SubQuery
```

### Bibliografía 
https://sql-listo.com/t-sql/exec-vs-sp_executesql/
