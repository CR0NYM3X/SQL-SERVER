type = 'p' procedimiento almacenado
type = 'U' - Para buscar tablas.
type = 'V' - Para buscar vistas.
type = 'FN' - Para buscar Funciones escalares.
type = 'TF' - Para buscar Funciones de tabla.

SELECT TOP 10 *  FROM sys.objects WHERE object_id IN(983502295) -- type = 'V' --- 


 SELECT TOP 10 OBJECT_NAME(OBJECT_ID), * FROM sys.sql_modules
 WHERE OBJECT_NAME(OBJECT_ID) LIKE '%Proc_CambiodePrecio%'

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


