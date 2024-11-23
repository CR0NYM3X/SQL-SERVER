



type = 'p' procedimiento almacenado
type = 'U' - Para buscar tablas.
type = 'V' - Para buscar vistas.
type = 'FN' - Para buscar Funciones escalares.
type = 'TF' - Para buscar Funciones de tabla.

SELECT TOP 10 *  FROM sys.objects WHERE object_id IN(983502295) -- type = 'V' --- 


 SELECT TOP 10 OBJECT_NAME(OBJECT_ID), * FROM sys.sql_modules
 WHERE OBJECT_NAME(OBJECT_ID) LIKE '%Proc_CambiodePrecio%'



-- Ver el codigo de los procesos almacenados 
EXEC SP_HELPTEXT Proc_CambiodePrecio

SELECT TOP 10 * FROM  syscomments


select distinct o.name Nombre, o.type_desc Tipo, o.create_date, o.modify_date
from sys.objects o
inner join syscomments c ON o.object_id = c.id
where c.text LIKE '%catalogos_articulos%'


SELECT name
FROM sys.objects
WHERE   name LIKE '%NombreDeLaFuncion%';




-- Ejecutar procedimientos Almacenados 

hacer una query para que le de permiso a todos los procedimientos almacenados 

 
select  top 50 * from sys.procedures; -- ver todos los proc que existen

--- dar permisos de ejecucion de proc
USE MaestroMuebles; 
GO  
grant execute on Proc_CCDetalladoAfectacionMaestros to [MYDOMINIO\andrea.lopez] 
GRANT EXECUTE ON SCHEMA::dbo TO sysDesarrolloMCCI; ---todas las funciones

use master 
SELECT  'GRANT EXECUTE ON [' + SCHEMA_NAME(schema_id) + '].[' + name + '] TO [TuRolOUsuario];' + CHAR(13)
FROM sys.procedures;





SELECT OBJECT_NAME(OBJECT_ID),
definition
FROM sys.sql_modules
WHERE definition LIKE '%' + 'BusinessEntityID' + '%'


SELECT DISTINCT OBJECT_NAME(OBJECT_ID),
object_definition(OBJECT_ID)
FROM sys.Procedures
WHERE object_definition(OBJECT_ID) LIKE '%' + 'BusinessEntityID' + '%'


``` sql
SELECT  type FROM sys.objects

U (Tabla de usuario): Representa una tabla creada por el usuario.
V (Vista): Representa una vista creada por el usuario.
P (Procedimiento almacenado): Representa un procedimiento almacenado.
FN (Función Escalar): Una función escalar toma uno o más valores de entrada y devuelve un solo valor como resultado. Por ejemplo, puedes crear una función escalar que calcule el área de un círculo dado su radio.
IF (Función en Línea) : Una función en línea también devuelve un solo valor, pero se diferencia en que se evalúa como parte de una consulta. Estas funciones son más eficientes en términos de rendimiento y se utilizan en expresiones dentro de SELECT, WHERE, HAVING y otras cláusulas.
TF (Función de Tabla) : Una función de tabla devuelve un conjunto de filas como resultado. Puedes pensar en ella como una vista que acepta parámetros. Las funciones de tabla se utilizan para encapsular lógica compleja y reutilizable.
TR (Desencadenador): Representa un desencadenador (trigger) creado por el usuario.
SN (Secuencia): Representa una secuencia creada por el usuario.
UQ (Restricción de clave única): Representa una restricción de clave única.
PK (Restricción de clave primaria): Representa una restricción de clave primaria.
```  

# Ejemplo de un procedimiento 
``` sql
CREATE PROCEDURE SumarNumeros
    @Numero1 INT,
    @Numero2 INT,
    @Resultado INT OUTPUT
AS
BEGIN
    SET @Resultado = @Numero1 + @Numero2;
END


DECLARE @SumaResultado INT;
EXEC SumarNumeros @Numero1 = 10, @Numero2 = 20, @Resultado = @SumaResultado OUTPUT;
SELECT @SumaResultado AS ResultadoSuma;

```


# Ejemplo de un funcion 
```sql
CREATE FUNCTION dbo.AddNumbers
(
    @Number1 INT,
    @Number2 INT
)
RETURNS INT
AS
BEGIN
    RETURN @Number1 + @Number2
END


SELECT dbo.AddNumbers(10, 20) AS Resultado
```





## Prcedimientos con  WITH EXEC AS OWNER 
Asegura que el procedimiento se ejecute con los permisos del propietario, cuando creeas un objeto no se asigna automaticamente un propietario, tienes que agregarlo de manera manual , en caso de no asignarlo , este tomara  el usuario owner de la DB donde esta el objeto y usara sus permisos 
```sql

USE [master]
GO
create database test_owner_db




USE [master]
GO
CREATE LOGIN [user_test_a] WITH PASSWORD=N'123123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [test_owner_db]
GO
CREATE USER [user_test_a] FOR LOGIN [user_test_a]
GO


USE [master]
GO
CREATE LOGIN [user_test_b] WITH PASSWORD=N'123123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [test_owner_db]
GO
CREATE USER [user_test_b] FOR LOGIN [user_test_b]
GO


ALTER AUTHORIZATION ON DATABASE::[test_owner_db] TO [user_owner_db]  ---> Msg 15110, Level 16, State 1, Line 45 The proposed new database owner is already a user or aliased in the database.

drop user user_owner_db --> Commands completed successfully.

ALTER AUTHORIZATION ON DATABASE::[test_owner_db] TO [user_owner_db]  --> Commands completed successfully.

CREATE USER [user_owner_db] FOR LOGIN [user_owner_db] ---> Msg 15063, Level 16, State 1, Line 52 The login already has an account under a different user name.

select name from sys.database_principals where name in('user_owner_db','user_test_a','user_test_b')

 

####### CREAMOS EL PROCEDIMIENTO #######

---	drop  PROCEDURE dbo.ObtenerEmpleados 
CREATE PROCEDURE dbo.ObtenerEmpleados
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    -- Consulta para obtener los empleados
    SELECT SUSER_SNAME() AS USER_NAME,DB_NAME() AS DB_NAME ;
END;
GO 


####### VALIDAMOS QUIEN ES EL PROPIETARIO #######

SELECT 
    o.name AS nombre_procedimiento,
    s.name AS esquema,
    dp.name AS propietario
FROM 
    sys.objects o
LEFT JOIN 
    sys.schemas s ON o.schema_id = s.schema_id
LEFT JOIN 
    sys.database_principals dp ON o.principal_id = dp.principal_id
WHERE 
    o.type = 'P'
	and o.name = 'ObtenerEmpleados'; ---> ObtenerEmpleados	,dbo	,NULL


####### OTORGAMOS PERMISO #######  
grant execute on  dbo.ObtenerEmpleados to user_test_a;


####### CAMBIAMOS DE USUARIO #######


EXECUTE AS USER = 'user_test_a';

	SELECT SUSER_SNAME() AS USER_NAME,DB_NAME() AS DB_NAME ;  ---> user_test_a	test_owner_db 
	EXEC dbo.ObtenerEmpleados;   ---> user_owner_db	,test_owner_db 
	
	
####### NOS REGRESAMOS AL USUARIO ORIGINAL #######
REVERT;

####### NOS REGRESAMOS AL USUARIO ORIGINAL #######
ALTER AUTHORIZATION ON OBJECT::dbo.ObtenerEmpleados TO  user_test_b

-- Volvemos a darle permisos al usuario user_test_a ya que se quitan los permisos 
grant execute on  dbo.ObtenerEmpleados to user_test_a


####### VALIDAMOS QUIEN ES EL PROPIETARIO #######

SELECT 
    o.name AS nombre_procedimiento,
    s.name AS esquema,
    dp.name AS propietario
FROM 
    sys.objects o
LEFT JOIN 
    sys.schemas s ON o.schema_id = s.schema_id
LEFT JOIN 
    sys.database_principals dp ON o.principal_id = dp.principal_id
WHERE 
    o.type = 'P'
	and o.name = 'ObtenerEmpleados'; ---> ObtenerEmpleados,	dbo	,user_test_b




####### Validamos  #######
EXECUTE AS USER = 'user_test_a';
	EXEC dbo.ObtenerEmpleados; ---> user_test_b,	test_owner_db


####### nos regresamos ####### 
REVERT; 


---- Eliminar los objetos 

drop login user_test_a;
drop login user_test_b;
drop login user_owner_db;
drop database test_owner_db;

```



