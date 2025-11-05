 

### 📊 Tabla de conceptos del plan de ejecución en SQL Server

| **Concepto** | **Descripción** | **Importancia para el DBA** |
|--------------|------------------|------------------------------|
| **Estimated Cost** | Costo estimado de la operación en porcentaje. | Ayuda a identificar las operaciones más costosas. |
| **Actual Rows / Estimated Rows** | Número real vs estimado de filas procesadas. | Detecta problemas de estimación de cardinalidad. |
| **Execution Mode (Row / Batch)** | Modo de ejecución: fila por fila o por lotes. | Batch es más eficiente en Columnstore. |
| **Operator (e.g., Index Seek, Table Scan)** | Tipo de operación realizada. | Identifica si se usan índices correctamente. |
| **Index Seek** | Búsqueda eficiente en un índice. | Ideal para rendimiento óptimo. |
| **Index Scan** | Escaneo completo de un índice. | Menos eficiente que Seek. |
| **Table Scan** | Escaneo completo de la tabla. | Indica falta de índice o mal diseño. |
| **Key Lookup** | Búsqueda adicional en la tabla base tras usar un índice. | Puede ser costoso si ocurre muchas veces. |
| **Nested Loops** | Método de combinación de datos entre tablas. | Bueno para pocos datos, pero puede escalar mal. |
| **Hash Match** | Combina datos usando hash. | Eficiente para grandes volúmenes. |
| **Merge Join** | Combina datos ordenados. | Muy eficiente si los datos ya están ordenados. |
| **Sort** | Ordena datos antes de otra operación. | Puede ser costoso si no hay índice adecuado. |
| **Compute Scalar** | Calcula valores escalares (por ejemplo, expresiones). | Normalmente bajo costo, pero puede acumularse. |
| **Parallelism** | Divide la operación entre varios núcleos. | Mejora rendimiento, pero puede causar sobrecarga. |
| **Repartition Streams** | Redistribuye datos entre hilos en ejecución paralela. | Necesario para balancear carga en paralelo. |
| **Filter** | Aplica condiciones tipo `WHERE`. | Útil para reducir filas procesadas. |
| **Top** | Limita el número de filas. | Reduce carga si se usa correctamente. |
| **Concatenation** | Une resultados de múltiples ramas. | Común en consultas con `UNION`. |
| **Stream Aggregate** | Agrupa datos en flujo. | Eficiente para agregaciones simples. |
| **Hash Aggregate** | Agrupa datos usando hash. | Mejor para grandes volúmenes. |
| **RID Lookup** | Similar a Key Lookup pero en tablas sin clustered index. | Indica posible necesidad de índice clustered. |
| **Predicate** | Condición evaluada en una operación. | Ayuda a entender filtros aplicados. |
| **Warnings (e.g., Missing Index)** | Alertas sobre problemas potenciales. | Clave para optimización. |
| **Estimated Subtree Cost** | Costo total estimado de una rama del plan. | Ayuda a identificar cuellos de botella. |

