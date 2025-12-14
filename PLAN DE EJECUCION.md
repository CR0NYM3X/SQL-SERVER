 

### 📊 Tabla de conceptos del plan de ejecución en SQL Server

| **Concepto** | **Descripción** | **Importancia para el DBA** |
|--------------|------------------|------------------------------|
| **Estimated Cost** | Costo estimado de la operación en porcentaje. | Ayuda a identificar las operaciones más costosas. |
| **Estimated Subtree Cost** | Costo total estimado de una rama del plan. | Ayuda a identificar cuellos de botella. |
| **Actual Rows / Estimated Rows** | Número real vs estimado de filas procesadas. | Detecta problemas de estimación de cardinalidad. |
| **Execution Mode (Row / Batch)** | Modo de ejecución: fila por fila o por lotes. | Batch es más eficiente en Columnstore. |
| **Operator (e.g., Index Seek, Table Scan)** | Tipo de operación realizada. | Identifica si se usan índices correctamente. |
| **Index Seek** | Búsqueda eficiente en un índice. | Ideal para rendimiento óptimo. |
| **Index Scan** | Recorre todo el índice para encontrar las filas que necesita. Puede ser un índice clustered o non-clustered, uando la consulta no puede usar una búsqueda específica (por ejemplo, no hay filtro selectivo o el índice no cubre la consulta). | Menos eficiente que Seek. |
| **Table Spool**                  | Operador que guarda temporalmente datos en el spool para reutilizarlos.         | Puede indicar operaciones repetitivas o falta de optimización; útil pero costoso si mal usado.|
| **Table Scan** |  recorre toda la tabla directamente, sin usar ningún índice. ocurre en tablas sin índice clustered (heap). | Indica falta de índice o mal diseño y Puede ser muy costoso en tablas grandes.|
| **Nested Loops Join** | Método de combinación de datos entre tablas. | Bueno para pocos datos, pero puede escalar mal. |
| **Merge Join** | Combina datos ordenados. | Muy eficiente si los datos ya están ordenados. |
| **Hash Join**                    | Algoritmo de unión que usa una tabla hash para unir grandes conjuntos de datos. | Eficiente para unir tablas grandes sin índices o sin orden se usa la tempdb, pero puede consumir mucha memoria y cpu.          |
| **Hash Aggregate**             | Se usa cuando los datos no están ordenados; crea una tabla hash en memoria para agrupar.        | Puede consumir más memoria y generar spills a disco si hay muchos datos.  | **Agregación con hash** (ideal para datos desordenados).                 |
| **Stream Aggregate**           | Se usa cuando los datos ya están ordenados por la clave de agrupación.                          | Más eficiente porque evita ordenar y estructuras complejas.               | **Agregación ordenada** (ej. `GROUP BY` con índice adecuado).            |
| **Hash Match** | Combina datos usando hash. | Eficiente para grandes volúmenes. |
| **Sort** | Ordena datos antes de otra operación. | Puede ser costoso si no hay índice adecuado. |
| **Compute Scalar** | Calcula valores escalares (por ejemplo, expresiones). | Normalmente bajo costo, pero puede acumularse. |
| **Parallelism** | Divide la operación entre varios núcleos. | Mejora rendimiento, pero puede causar sobrecarga. |
| **Repartition Streams** | Redistribuye datos entre hilos en ejecución paralela. | Necesario para balancear carga en paralelo. |
| **Filter** | Aplica condiciones tipo `WHERE`. | Útil para reducir filas procesadas. |
| **Top** | Limita el número de filas. | Reduce carga si se usa correctamente. |
| **Concatenation** | Une resultados de múltiples ramas. | Común en consultas con `UNION`. |
| **Key Lookup** | La consulta usa un índice no cubriente (el índice no contiene todas las columnas que se necesitan en el SELECT) SQL Server hace un Index Seek para encontrar las filas por la clave de búsqueda, pero luego necesita columnas adicionales que no están en el índice. Para obtener esas columnas, va a la tabla base (clustered index) usando la clave primaria → eso es el Key Lookup | Puede ser costoso. |
| **RID Lookup** | Similar a Key Lookup pero en tablas sin clustered index. | Indica posible necesidad de índice clustered. |
| **Predicate** | Condición evaluada en una operación. | Ayuda a entender filtros aplicados. |
| **Warnings (e.g., Missing Index)** | Alertas sobre problemas potenciales. | Clave para optimización. |
| **Partial / Final Aggregate**  | Divide el trabajo en varias partes (paralelismo) y luego combina resultados.                    | Mejora el rendimiento en consultas paralelas.                             | **Agregación paralela** (en planes con múltiples threads).               |
| **Scalar Aggregate**           | Cuando no hay `GROUP BY` y se calcula un agregado sobre todo el conjunto (ej. `COUNT(*)`).      | Útil para cálculos globales sobre la tabla completa.                      | **Agregación escalar** (sin agrupación, resultado único).                |


# Extra

### Aggregation
significa que el motor está realizando una operación para agrupar o resumir datos.
