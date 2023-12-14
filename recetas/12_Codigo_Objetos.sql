SET NOCOUNT ON;

/* 
		Consulta: BPD-Codigo Objetos
La ejecución extrae el código de los SP y Vistas que se tienen dentro de la base de datos, respetando su respectiva linea 
de codificación, consultando unicamente la capa de información propia de ésta. 
La consulta extrae la siguiente informacion: 
- Esquema
- Objeto
- Tipo_Objeto
- Numero_Linea
- Linea	

*/

DECLARE @TEXT              AS NVARCHAR(max)
DECLARE @USUARIO           AS VARCHAR(128)             
DECLARE @OBJETO            AS VARCHAR(128)            
DECLARE @TIPO              AS VARCHAR(2)              
DECLARE @LINEA             AS NVARCHAR(max)            
DECLARE @POS_INICIO        AS INT
DECLARE @POS_FIN           AS INT
DECLARE @CONT              AS INT
DECLARE @TABLA TABLE(Esquema varchar(20), Objeto varchar(150), Tipo_Objeto varchar(5), Numero_Linea int, Linea nvarchar(max))

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
			SELECT @LINEA = REPLACE(@LINEA, ',', ';')

			insert into @TABLA
			select @usuario as Usuario, @objeto AS Objeto, @TIPO as Tipo, @CONT as Numero_Linea, REPLACE(LTRIM(RTRIM(@LINEA)),CHAR(13),'') as Linea
     	   
			SET @TEXT = RIGHT(@TEXT,LEN(@TEXT)-PATINDEX('%'+char(10)+'%',@TEXT)) 
   
			END 
 
		FETCH NEXT FROM objetos INTO @USUARIO,@OBJETO,@TIPO,@TEXT
 
	END 
CLOSE objetos    
DEALLOCATE objetos

select * from @TABLA