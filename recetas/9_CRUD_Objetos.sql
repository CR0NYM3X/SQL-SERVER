SET NOCOUNT ON;

/* 
		Consulta: BPD-CRUD_Objetos
La ejecución muestra en listado el conteo de las sentencias CRUD, para obtener el número que estas sentencias son 
utilizadas, consultando unicamente la capa de información propia de ésta. 
La consulta extrae la siguiente informacion: 
- Esquema
- Objeto
- Tipo
- Lineas_Totales
- Lineas_Vacias
- Lineas_Comentadas
- Commits
- Rollbacks
- Selects	
- IFS	
- Selects2 (Select*)	
- Deletes	
- Updates	
- Inserts	
- Excepciones	
- Whiles	
- Fors	
- Loops	
- Cursores

*/

DECLARE @TEXT              AS NVARCHAR(max)
DECLARE @USUARIO           AS VARCHAR(128)             
DECLARE @OBJETO            AS VARCHAR(128)            
DECLARE @TIPO              AS VARCHAR(2)              
DECLARE @LINEA             AS NVARCHAR(max)            
DECLARE @POS_INICIO        AS INT
DECLARE @POS_FIN           AS INT
DECLARE @CONT              AS INT
DECLARE @TABLA TABLE(Usuario varchar(20), Objeto varchar(150), Tipo varchar(5), Numero_Linea int, Linea nvarchar(max))

DECLARE objetos CURSOR FOR  
	select c.name AS USUARIO, 
	b.name AS OBJETO,
	b.type AS TIPO,
	a.definition 
	from sys.sql_modules a, sys.objects b , sysusers c 
	where b.object_id = a.object_id
	AND b.type in ('FN','IF','P','TF','TR') 
	AND b.is_ms_shipped = 0
	AND b.object_id > 255 
	AND b.name not in ('sp_upgraddiagrams','sp_helpdiagrams','sp_helpdiagramdefinition','sp_creatediagram','sp_renamediagram','sp_alterdiagram','sp_dropdiagram','fn_diagramobjects','sysdiagrams')
	and c.uid = b.schema_id
	Order by b.name

OPEN objetos 
	FETCH NEXT FROM objetos INTO @USUARIO,@OBJETO,@TIPO,@TEXT
	WHILE(@@FETCH_STATUS = 0) 
	BEGIN 
  
		SET @CONT = 0  
		SET @TEXT = @TEXT+CHAR(10)

		WHILE PATINDEX('%'+char(10)+'%',@TEXT) > 0 
			BEGIN
   
			SET @CONT = @CONT + 1
			SET @POS_INICIO = 1
			SET @POS_FIN = PATINDEX('%'+char(10)+'%',@TEXT) 
			SET @LINEA = SUBSTRING(@TEXT,@POS_INICIO,@POS_FIN-1) 
   
			SELECT @LINEA = REPLACE(@LINEA,char(9),'')
			SELECT @LINEA = REPLACE(@LINEA,char(13),'')

			insert into @TABLA
			select @usuario as Usuario, @objeto AS Objeto, @TIPO as Tipo, @CONT as Numero_Linea, REPLACE(LTRIM(RTRIM(@LINEA)),CHAR(13),'') as Linea
     	   
			SET @TEXT = RIGHT(@TEXT,LEN(@TEXT)-PATINDEX('%'+char(10)+'%',@TEXT)) 
   
			END 
 
		FETCH NEXT FROM objetos INTO @USUARIO,@OBJETO,@TIPO,@TEXT
 
	END 
CLOSE objetos 
DEALLOCATE objetos

select
Usuario as Esquema, Objeto, Tipo, count(*) as Lineas_Totales,
sum(case when LEN(Linea) = 0 then 1 else 0 end) as Lineas_Vacias,
sum(case when Linea like '--%' then 1 else 0 end) as Lineas_Comentadas,
sum(case when UPPER(Linea) like 'COMMIT %' then 1 else 0 end) as Commits,
sum(case when UPPER(Linea) like 'ROLLBACK %' then 1 else 0 end) as Rollbacks,
sum(case when UPPER(Linea) like '%SELECT *%' then 1 else 0 end) as Selects,
sum(case when UPPER(Linea) like '%IF%' AND UPPER(Linea) not like '%END IF%'  then 1 else 0 end) as IFS,
sum(case when UPPER(Linea) like '%SELECT%' and UPPER(Linea) not like '%SELECT *%' then 1 else 0 end) as Selects2,
sum(case when UPPER(Linea) like '%DELETE %' then 1 else 0 end) as Deletes,
sum(case when UPPER(Linea) like '%UPDATE %' then 1 else 0 end) as Updates,
sum(case when UPPER(Linea) like '%INSERT %' then 1 else 0 end) as Inserts,
sum(case when UPPER(Linea) like '%EXCEPTION %' OR UPPER(Linea) like '%TRY%' then 1 else 0 end) as Excepciones,
sum(case when UPPER(Linea) like '%WHILE %' then 1 else 0 end) as Whiles,
sum(case when UPPER(Linea) like '%FOR %' then 1 else 0 end) as Fors,
sum(case when UPPER(Linea) like '%LOOP %' AND UPPER(Linea) not like '%END LOOP%'  then 1 else 0 end) as Loops,
sum(case when UPPER(Linea) like '%Cursor %' then 1 else 0 end) as Cursores
from @TABLA
group by usuario, objeto, tipo
ORDER BY 1, 3, 2