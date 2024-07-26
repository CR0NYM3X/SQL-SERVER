 WITH EXEC AS OWNER asegura que el procedimiento se ejecute con los permisos del propietario



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
