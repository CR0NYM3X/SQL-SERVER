 
## ✅ **¿Qué es la compresión en SQL Server?**

La compresión en SQL Server es una característica que reduce el tamaño físico de los datos almacenados en tablas e índices mediante técnicas como:

*   **Row Compression**: Minimiza el espacio usado por cada fila eliminando bytes innecesarios.
*   **Page Compression**: Es el nivel más agresivo e incluye la Compresión de Filas. Agrega dos técnicas a nivel de página de datos: Reduce redundancias dentro de una página (8 KB) usando algoritmos como *prefix* y *dictionary*.

Se aplica a:

*   Tablas (heap o con índices clustered)
*   Índices (clustered y non-clustered)
*   Particiones específicas
 
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
 
