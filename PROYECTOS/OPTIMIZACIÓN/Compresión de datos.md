 
## ✅ **¿Qué es la compresión en SQL Server?**

La compresión en SQL Server es una característica que reduce el tamaño físico de los datos almacenados en tablas e índices mediante técnicas como:

*   **Row Compression**: para indices y tablas rowstore -  Minimiza el espacio usado por cada fila eliminando bytes innecesarios. Menor impacto en CPU que PAGE. Ahorro de espacio menor.
*   **Page Compression**:  para indices y tablas rowstore - Es el nivel más agresivo e incluye la Compresión de Filas. Agrega dos técnicas a nivel de página de datos: Reduce redundancias dentro de una página (8 KB) usando algoritmos como *prefix* y *dictionary*. Consume más CPU que ROW Compression. Reduce significativamente el tamaño en disco y mejora el rendimiento de lectura.
* COLUMNSTORE → Índice columnstore no clustered ,  para indices y tablas COLUMNSTORE.
*  COLUMNSTORE_ARCHIVE → Versión más agresiva de compresión (para datos históricos).Si ves ROW o PAGE, eso es compresión tradicional por filas o páginas.  ,  para indices y tablas COLUMNSTORE.


## Consideraciones: 
- El COLUMNSTORE se puede crear en indices CLUSTERED y NONCLUSTERED
- No se pueden crear más de un indice columnstore , marca error 'Multiple columnstore indexes are not supported.'
- Se puede crear  INDEX COLUMNSTORE y despues crear indices no-clusteres rowstore
- Se puede crear un indice NONCLUSTERED COLUMNSTORE y agregar más NONCLUSTERED ROWSTORE

Se aplica a:

*   Tablas (heap o con índices clustered)
*   Índices (clustered y non-clustered)
*   Particiones específicas


## ✅ **1. Rowstore (almacenamiento por filas)**

*   **Formato tradicional** usado por tablas heap o con índices clustered.
*   **Unidad básica:** **Página de 8 KB**.
*   **Estructura interna:**
    *   Cada página contiene **filas completas** (todas las columnas de la fila).
    *   Las filas se almacenan secuencialmente dentro de la página.
    *   Si una fila es muy grande, puede usar páginas adicionales (overflow).
*   **Flujo semántico:**
    1.  **Tabla → Índice clustered → Páginas → Extents → Disco**.
    2.  Cada página tiene un **header**, espacio para filas y un **slot array** para localizarlas.
*   **Acceso:** Consultas OLTP son rápidas porque se leen pocas páginas para una fila específica.

**Ejemplo visual:**

    Página 1: [Fila1 | Fila2 | Fila3]
    Página 2: [Fila4 | Fila5 | Fila6]

***

## ✅ **2. Columnstore (almacenamiento por columnas)**

*   **Formato columnar** optimizado para análisis.
*   **Unidad básica:** **Segmentos de columna** (≈ 1 millón de filas por segmento).
*   **Estructura interna:**
    *   Cada columna se divide en **segmentos** y se comprime independientemente.
    *   Los segmentos se agrupan en **rowgroups** (conjunto de columnas para un rango de filas).
    *   Cada segmento se almacena en páginas, pero **solo contiene datos de una columna**.
*   **Flujo semántico:**
    1.  **Tabla → Rowgroups → Segmentos → Páginas → Disco**.
    2.  Cada rowgroup tiene metadatos y diccionarios para compresión.
*   **Acceso:** Consultas analíticas son rápidas porque se leen solo las columnas necesarias.

**Ejemplo visual:**

    Rowgroup 1:
      Columna Producto → [Página con valores Producto]
      Columna Cantidad → [Página con valores Cantidad]
      Columna Precio   → [Página con valores Precio]

***

### **Comparación semántica**

| Aspecto       | Rowstore              | Columnstore                        |
| ------------- | --------------------- | ---------------------------------- |
| Unidad lógica | Fila completa         | Columna segmentada                 |
| Página        | Contiene varias filas | Contiene datos de una sola columna |
| Ideal para    | OLTP (transacciones)  | OLAP (análisis masivo)             |
| Compresión    | ROW/PAGE              | Columnstore (diccionario, RLE)     |


## ✅ **Ventajas**

1.  **Reducción de espacio en disco**
    *   Menor tamaño de base de datos → ahorro en almacenamiento.
2.  **Mejor uso de memoria y caché**
    *   Más datos caben en buffer pool → menos I/O.
3.  **Mejor rendimiento en consultas intensivas en lectura**
    *   Menos páginas que leer → consultas más rápidas.
4.  **Menor costo en backups y replicación**
    *   Archivos más pequeños → operaciones más rápidas.

***

## ⚠️ **Desventajas**

1.  **Mayor consumo de CPU**
    *   Se necesita procesar compresión/descompresión en cada operación.
2.  **Impacto en operaciones de escritura**
    *   Insert, Update y Delete pueden ser más lentos.
3.  **No siempre reduce espacio significativamente**
    *   Si los datos ya son pequeños o muy variados, el beneficio es mínimo.
4.  **Licenciamiento**
    *   Disponible solo en ediciones **Enterprise** (y algunas características en Standard).

 

## ✅ **Consideraciones antes de aplicar**
Se Recomienda Comprimir (Especialmente Compresión de Página)

*   **Analizar el patrón de uso**
    *   Si la tabla tiene muchas lecturas y pocas escrituras → compresión es ideal.
*   **Evaluar el tipo de datos**
    *   Columnas con valores repetitivos → Page Compression es más efectiva.
*   **Probar con `sp_estimate_data_compression_savings`**
    *   Estima el ahorro antes de aplicar.
*   **Impacto en CPU**
    *   Si el servidor ya está al límite de CPU, puede no ser recomendable.
    



## ✅ **¿Cuándo se debe comprimir?**

* **Tablas e Índices Grandes:** Cuando las estructuras de datos tienen un tamaño significativo y la I/O es un cuello de botella.
* **Datos de Historial/Archivo:** Tablas que se consultan con frecuencia (lectura), pero que rara vez se modifican (escritura).
* **Entornos con I/O Restringida:** Sistemas donde la velocidad del disco es un factor limitante para el rendimiento.
* **Sistemas de Almacenamiento de Datos (Data Warehousing):** Son entornos con cargas de trabajo intensivas en lectura (OLAP).

***

## ❌ **¿Cuándo NO se debe comprimir?**



* **Tablas con Alto Tráfico de Escritura (OLTP):** Tablas que experimentan inserciones, eliminaciones y actualizaciones constantes, ya que el costo adicional de CPU puede anular el beneficio de la I/O.
* **Entornos con CPU Restringida:** Si el servidor ya está cerca del 100% de uso de CPU, la compresión solo empeorará el rendimiento.
* **Tablas Pequeñas:** El beneficio de espacio es mínimo y el costo de CPU para mantener la compresión no se justifica.
* **Índices Clustered o Non-Clustered con Columnas `GUID`:** El valor aleatorio de un `GUID` dificulta que la Compresión de Página encuentre patrones repetitivos, haciendo que la compresión sea ineficaz.
*   Datos que ya son compactos (por ejemplo, enteros pequeños).

### ✅ **1. Estimar el ahorro antes de aplicar**

SQL Server tiene el procedimiento `sp_estimate_data_compression_savings` para calcular cuánto espacio se ahorraría.

```sql
USE [TuBaseDeDatos];
GO

EXEC sp_estimate_data_compression_savings
    @schema_name = 'dbo',
    @object_name = 'TuTabla',
    @index_id = NULL,  -- NULL = todos los índices
    @partition_number = NULL,  -- NULL = todas las particiones
    @data_compression = 'PAGE';  -- Opciones: ROW o PAGE
```

**Resultado:**

*   `size_with_current_compression_setting` → tamaño actual
*   `size_with_requested_compression_setting` → tamaño estimado con compresión
*   `sample_size_with_current_compression_setting` → muestra usada

***


### ✅ **¿Cómo revisar si hay tablas comprimidas en SQL Server?**

Puedes consultar la vista del sistema `sys.partitions` junto con `sys.objects` y `sys.indexes` para ver el tipo de compresión aplicado:

```sql
SELECT 
    p.data_compression_desc AS TipoCompresion,
    count(*) as cnt_compres
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.tables t ON i.object_id = t.object_id
group by p.data_compression_desc


SELECT 
    o.name AS Tabla,
    i.name AS Indice,
    p.partition_number,
    p.data_compression_desc AS TipoCompresion
FROM sys.partitions p
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
WHERE o.type = 'U'  -- Solo tablas de usuario
AND  p.data_compression_desc <> 'NONE' 
ORDER BY o.name;
```

**Resultado:**

*   `NONE` → Sin compresión
*   `ROW` → Compresión por fila
*   `PAGE` → Compresión por página


### ✅ **2. Aplicar compresión a una tabla completa**

Para comprimir una tabla (incluyendo índices clustered):

```sql
ALTER TABLE dbo.TuTabla
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = PAGE);  -- Opciones: ROW o PAGE
```

> ⚠️ **Nota:** El comando `REBUILD` requiere suficiente espacio en disco para construir la nueva estructura comprimida **además** de la estructura original, temporalmente. Es una operación intensiva en recursos.

***

### ✅ **3. Aplicar compresión a un índice específico**

```sql
ALTER INDEX IX_TuIndice ON dbo.TuTabla
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = ROW);  -- Opciones: ROW o PAGE
```

***

### ✅ **4. Comprimir solo una partición**

```sql
-- Aplicar compresión de filas a la tabla 'Ventas.Facturas'
ALTER TABLE dbo.TuTabla
REBUILD PARTITION = 1
-- REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = PAGE);
```

***

### ✅ **5. Verificar compresión aplicada**

```sql
SELECT
    OBJECT_NAME(object_id) AS Tabla,
    index_id,
    partition_number,
    data_compression_desc
FROM sys.partitions
WHERE object_id = OBJECT_ID('dbo.TuTabla');
```

***

### 🔍 **Recomendación práctica**

*   **ROW** → mejor para tablas con muchas actualizaciones (menos CPU).
*   **PAGE** → mejor para tablas grandes con datos repetitivos (más ahorro, más CPU).

---

# Ejemplos 
```sql

 --  drop table dbo.TablaRow
-- Crear tabla de ejemplo ROW
CREATE TABLE dbo.TablaRow (
    ID INT IDENTITY(1,1),
    Nombre VARCHAR(100),
    Valor DECIMAL(10,2)
);


-- Crear índice clustered con compresión ROW
ALTER TABLE dbo.TablaRow
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = ROW);

 
--  drop table dbo.TablaPage
-- Crear tabla de ejemplo PAGE
CREATE TABLE dbo.TablaPage (
    ID INT IDENTITY(1,1),
    Descripcion VARCHAR(200),
    Precio DECIMAL(10,2)
);


-- Crear índice clustered con compresión PAGE
ALTER TABLE dbo.TablaPage
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = PAGE);


--- drop table dbo.TablaColumnstore
-- Crear tabla de ejemplo COLUMNSTORE
CREATE TABLE dbo.TablaColumnstore (
    ID INT IDENTITY(1,1),
    Producto VARCHAR(100),
    Cantidad INT,
    Total DECIMAL(10,2)
);


--  DROP INDEX IX_Columnstore ON  dbo.TablaColumnstore
--  (CCI): COLUMNSTORE -  Crear índice columnstore clustered (convierte la tabla)
-- COLUMNSTORE → Índice columnstore no clustered.
-- COLUMNSTORE_ARCHIVE → Versión más agresiva de compresión (para datos históricos).Si ves ROW o PAGE, eso es compresión tradicional por filas o páginas.

CREATE CLUSTERED COLUMNSTORE INDEX IX_Columnstore
ON dbo.TablaColumnstore;

-- (NCCI) -  rowstore - DROP INDEX IX_Ventas_Columnstore ON  dbo.TablaColumnstore;
CREATE NONCLUSTERED  INDEX IX_Ventas_Columnstore
ON dbo.TablaColumnstore (Producto, Cantidad);

-- Insertar 1000 registros de ejemplo en TablaColumnstore
INSERT INTO dbo.TablaColumnstore (Producto, Cantidad, Total)
SELECT TOP 1000
    CONCAT('Producto_', CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10))) AS Producto,
    ABS(CHECKSUM(NEWID())) % 100 + 1 AS Cantidad,  -- Valores entre 1 y 100
    CAST((ABS(CHECKSUM(NEWID())) % 5000) / 100.0 AS DECIMAL(10,2)) AS Total  -- Valores entre 0 y 50.00
FROM sys.objects AS o1
CROSS JOIN sys.objects AS o2;


-- This is not a valid data compression setting for a columnstore index. Please choose COLUMNSTORE or COLUMNSTORE_ARCHIVE compression.
-- ALTER TABLE dbo.TablaColumnstore REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);

 
 select  * from dbo.TablaColumnstore where Producto = 'Producto_6' and cantidad = 89
```
