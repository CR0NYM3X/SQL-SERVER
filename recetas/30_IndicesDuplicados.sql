/*
###########################################################################################################
		I D E N T I F I C A R		Í N D I C E S		D U P L I C A D O S		E N		BDD
###########################################################################################################
		
		Instrucciones:
			1- Conectarse a una base de datos.
			2- Ejecutar.

		Resultados:
		El script devolverá todos aquellos índices que sean idénticos en estructura a pesar de que
		tengan nombres diferentes. Se identifican los duplicados en base a las columnnas indexadas, include y en where.

			- Table_Name:		Nombre de la Tabla.
			- Index_Name:		Nombre del índice.
			- Key_Columns:		Columna principal indexada.
			- Include_Columns:	Columnas complementarias al índice.
			- Where_Columns:	Columnas en cláusula where.

*/

WITH IndexColumns AS (
    SELECT
        t.name AS table_name,
        ind.name AS index_name,
        col.name AS column_name,
        ic.is_included_column,
        ind.filter_definition 
    FROM
        sys.indexes ind
        INNER JOIN sys.index_columns ic ON ind.object_id = ic.object_id AND ind.index_id = ic.index_id
        INNER JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
        INNER JOIN sys.tables t ON ind.object_id = t.object_id
	--WHERE
	--	t.name = 'alumnos'
),
IndexColumnGroups AS (
    SELECT
        table_name,
        index_name,
        STRING_AGG(CASE WHEN is_included_column = 0 THEN column_name ELSE NULL END, ', ') WITHIN GROUP (ORDER BY column_name) AS key_columns,
        STRING_AGG(CASE WHEN is_included_column = 1 THEN column_name ELSE NULL END, ', ') WITHIN GROUP (ORDER BY column_name) AS include_columns,
        COALESCE(filter_definition,NULL) AS where_columns
    FROM
        IndexColumns
    GROUP BY
        table_name, index_name, filter_definition
),
DuplicatedIndexes AS (
    SELECT
        a.table_name,
        a.index_name AS index_name_a,
        b.index_name AS index_name_b,
        a.key_columns,
        a.include_columns,
        a.where_columns
    FROM
        IndexColumnGroups a
        INNER JOIN IndexColumnGroups b ON a.table_name = b.table_name 
        AND a.key_columns = b.key_columns 
        AND COALESCE(a.include_columns, '') = COALESCE(b.include_columns, '')
        AND COALESCE(a.where_columns, '') = COALESCE(b.where_columns, '')
        AND a.index_name <> b.index_name
)
SELECT DISTINCT
    table_name,
    index_name_a AS index_name,
    key_columns,
    include_columns,
    where_columns
FROM
    DuplicatedIndexes
ORDER BY
    table_name, index_name;