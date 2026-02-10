



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

EXECUTE AS SELF : 

¿Quién es el ejecutor?: El código se ejecuta como la persona que creó o modificó el procedimiento por última vez.
Vínculo dinámico: Si el usuario "Ana" crea el procedimiento, el código corre como "Ana". Si después "Pedro" modifica el procedimiento (ALTER), el contexto cambia automáticamente a "Pedro".
Uso común: Útil cuando quieres que el procedimiento siempre tenga los permisos de quien lo mantiene actualmente.


EXECUTE AS OWNER: 

¿Quién es el ejecutor?: El código se ejecuta como el propietario actual del procedimiento almacenado.
Estabilidad: A diferencia de SELF, si alguien más modifica el procedimiento (un ALTER), el contexto de ejecución no cambia, a menos que también cambies quién es el dueño del procedimiento.
Jerarquía: Normalmente, el propietario es el esquema (como dbo). Si el procedimiento pertenece a dbo, se ejecutará con los altísimos privilegios de dbo, sin importar quién lo haya alterado últimamente.

------------------------------------------------------------------------------------------------------------------------------------------------------


/*********** CREAMOS LAS BASE DE DATOS ***********\
USE [master]
GO
create database test_owner_db


/*********** CREAMOS LOS USUARIOS ***********\
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

ALTER SERVER ROLE [sysadmin] ADD MEMBER [user_test_b]
GO

USE [master]
GO
CREATE LOGIN [user_owner_db] WITH PASSWORD=N'123123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
USE [test_owner_db]
GO
CREATE USER [user_owner_db] FOR LOGIN [user_owner_db]
GO

ALTER SERVER ROLE [sysadmin] ADD MEMBER [user_owner_db]
GO




/*********** COLOCAMOS EL DUEÑO DE LA DB ***********\

-- @ nos conectamos a la db 
use test_owner_db 

--- @ No se puede asignar un dueño que tiene un USER en la DB 
ALTER AUTHORIZATION ON DATABASE::[test_owner_db] TO [user_owner_db]  ---> Msg 15110, Level 16, State 1, Line 45 The proposed new database owner is already a user or aliased in the database.

-- @ Eliminamos el user
drop user user_owner_db --> Commands completed successfully.


--@ Volvemos hacer dueño al usuario y si permite
ALTER AUTHORIZATION ON DATABASE::[test_owner_db] TO [user_owner_db]  --> Commands completed successfully.

-- @ Validamos y tampo deja crearle el usuario si ya lo hicimos dueño al usuario
CREATE USER [user_owner_db] FOR LOGIN [user_owner_db] ---> Msg 15063, Level 16, State 1, Line 52 The login already has an account under a different user name.


-- @ Validamos los usuarios en la base de datos , aqui solo debe de estar : user_test_a, user_test_b
select name from sys.database_principals where name in('user_owner_db','user_test_a','user_test_b')

 



####### CREAMOS EL PROCEDIMIENTO #######


--- tiene que estar activado si no va usar funcionaria el "WITH EXECUTE AS", no marca error solo no marca ejecuta las accciones 
ALTER DATABASE test_owner_db SET TRUSTWORTHY ON;


--- Validar si se activo 
select name,is_trustworthy_on from sys.databases where name = 'test_owner_db'


---	drop  PROCEDURE dbo.GetDisk 
CREATE PROCEDURE dbo.GetDisk
WITH EXECUTE AS OWNER -- al colocar el owner , este ejecutara el codigo con los permisos del owner del procedimiento , en caso de que no tenga owner, se ejecutara con los permisos del owner de la db 
-- WITH EXECUTE AS 'user_test_b'  -- Tambien puedes especificar el usuario, en caso de que no quieres que sea el owner de la del procedimiento o db  
AS
BEGIN
    SET NOCOUNT ON;

    -- Consulta para obtener los empleados
    SELECT SUSER_SNAME() AS USER_NAME,DB_NAME() AS DB_NAME ;

    exec xp_fixeddrives;
END;
GO 

-- Otorgamos  permisos a los usuarios  
grant execute on dbo.GetDisk to  user_test_a;


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
	and o.name = 'GetDisk'; --->  esto retorna : [ nombre_procedimiento GetDisk	, Esquema: dbo	, Propietario : NULL]
 


####### CAMBIAMOS DE USUARIO #######


EXECUTE AS USER = 'user_test_a';

 
	EXEC dbo.GetDisk;   ---> retorna : ( username: user_owner_db	, db_name test_owner_db ) y tambien retorna los discos drive , MB Free 
	
	
	
####### NOS REGRESAMOS AL USUARIO ORIGINAL #######
REVERT;



####### Cambiamos de propietarios  #######
ALTER AUTHORIZATION ON OBJECT::dbo.GetDisk TO  user_test_b

-- Volvemos a darle permisos al usuario user_test_a ya que se quitan los permisos 
grant execute on  dbo.GetDisk to user_test_a


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
	and o.name = 'GetDisk'; ---> GetDisk,	dbo	,user_test_b




####### Validamos  #######
EXECUTE AS USER = 'user_test_a';
	EXEC dbo.GetDisk; ---> user_test_b,	test_owner_db



####### nos regresamos, al usuario original ####### 
REVERT; 



####### AHORA DESACTIVAMOS EL TRUSTWORTHY ####### 
ALTER DATABASE test_owner_db SET TRUSTWORTHY off;


[nota]--- con esto vamos a validar que si desactivas el TRUSTWORTHY , el Proc GetDisk no podra ejecutar el Proc xp_fixeddrives ya que requiere sysadmin


####### Validamos  #######
EXECUTE AS USER = 'user_test_a';
	EXEC dbo.GetDisk; ---> user_test_b,	test_owner_db


####### nos regresamos, al usuario original ####### 
REVERT; 



####### Extra si quieres usarlo en el procedimiento ####### 


CREATE TABLE Empleados (
    ID INT PRIMARY KEY,
    Nombre NVARCHAR(100),
    Cargo NVARCHAR(100),
    Salario DECIMAL(10, 2),
    FechaContratacion DATE
);

INSERT INTO Empleados (ID, Nombre, Cargo, Salario, FechaContratacion)
VALUES 
(1, 'Juan Pérez', 'Gerente', 75000.00, '2021-01-15'),
(2, 'Ana Gómez', 'Desarrolladora', 55000.00, '2020-03-22'),
(3, 'Carlos López', 'Analista', 60000.00, '2019-07-30'),
(4, 'Marta Sánchez', 'Recursos Humanos', 50000.00, '2018-11-10');


---- Eliminar los objetos 

drop login user_test_a;
drop login user_test_b;
drop login user_owner_db;
drop database test_owner_db;

```



