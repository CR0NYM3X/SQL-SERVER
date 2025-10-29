
# [**SQL Server Performance: Uso de `ORDER BY`**](https://www.youtube.com/watch?v=JZDq0GTFSnI&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=2)

Se realizaron pruebas de estrés utilizando herramientas gratuitas como **SentryOne Explorer**, **SQLQueryStress** y el **plan de ejecución de SQL Server**.  
Los resultados demostraron que el uso de `ORDER BY` en consultas **sin `TOP`** o **sin un índice en la columna utilizada para el ordenamiento** puede incrementar significativamente el costo (CPU + I/O), afectando el rendimiento general de la consulta.



--- 


# [**Webinar: T-SQL Tips para Mejorar el Rendimiento**](https://www.youtube.com/watch?v=UnZ2Sc_MUmM&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=3)

### **Principales recomendaciones:**

1. **Elección correcta de tipos de datos**  
   - Es fundamental seleccionar tipos de datos adecuados para las tablas.  
   - Ejemplo: Comparación entre tablas con `NVARCHAR` y `BIGINT` vs. `VARCHAR` e `INT`.  
   - Se demostró que una mala elección puede aumentar el costo de consultas y transacciones.  
   - Evitar `CHAR` cuando no sea necesario y preferir `INT` en tablas con pocos registros en lugar de `SMALLINT`.

2. **Evitar funciones en columnas indexadas**  
   - Ejemplo: `YEAR(OrderDate)` en el `WHERE` no utilizará el índice.  
   - Recomendación: aplicar filtros sin funciones para aprovechar los índices.

3. **Uso de `UNION` vs. `OR`**  
   - En algunos casos, `UNION` puede ser más eficiente que múltiples condiciones con `OR`, dependiendo de los índices.

4. **`ORDER BY` solo en columnas indexadas**  
   - Preferir columnas que ya tengan índices y coincidan con el ordenamiento requerido.

5. **Conversión implícita (`CONVERT_IMPLICIT`)**  
   - Ocurre cuando se comparan columnas con tipos de datos diferentes.  
   - Ejemplo: `IDNumber (VARCHAR) = 123123` genera conversión implícita.  
   - Solución: usar `IDNumber = '123123'` o forzar el tipo correcto en procedimientos almacenados.

6. **`JOIN` vs. `EXISTS`**  
   - No siempre es óptimo usar muchos `JOIN`.  
   - En algunos casos, `EXISTS` mejora el rendimiento.  
   - Validar siempre con el plan de ejecución.

7. **Parameter Sniffing**  
   - Los procedimientos almacenados se compilan y se guardan en caché, lo que puede afectar consultas posteriores.  
   - Soluciones:  
     - `sp_recompile` para recompilar el procedimiento.  
     - Usar `OPTION (RECOMPILE)` en consultas específicas.

8. **Operaciones masivas (`DELETE` o `UPDATE`)**  
   - Pueden bloquear la tabla y llenar el archivo LDF.  
   - Recomendación: realizar operaciones en bloques y usar `DBCC TRACEON(1224)` para evitar bloqueos completos.  
   - Validar bloqueos con la vista `sys.dm_tran_locks`.

9. **Uso de CTE (Common Table Expressions)**  
   - Ayuda a eliminar `Table Spool` y mejora el rendimiento.
   - Table Spool es un operador que aparece en el plan de ejecución cuando el motor necesita almacenar temporalmente filas en memoria (o en disco) para reutilizarlas más adelante en la misma consulta. Se genera cuando el optimizador decide que es más eficiente guardar resultados intermedios en un área temporal en lugar de recalcularlos.

10. **Precaución con vistas complejas**  
    - Evitar usar vistas sin conocer su lógica interna.  
    - Pueden incluir múltiples `JOIN` innecesarios, aumentando el costo.  
    - Si solo se necesita información de una o dos tablas, es mejor escribir la consulta manualmente.
 




--- 


# [**Cómo evitar el crecimiento del Transaction Log (TLOG) durante el mantenimiento de índices en SQL Server**](https://www.youtube.com/watch?v=z_ciYzcWeUQ&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=4)

### **Contexto**
Cuando se realiza una **reconstrucción completa (REBUILD)** de todos los índices en una base de datos con **modo de recuperación FULL**, el archivo de log (LDF) puede crecer significativamente, afectando el rendimiento y el espacio en disco.

 

### **Pruebas y hallazgos**
- **Modo SIMPLE**:  
  - Reduce el tiempo de reconstrucción y disminuye el tamaño del LDF.  
  - **No recomendado en producción**, ya que afecta la estrategia de respaldo y recuperación.

- **Modo BULK_LOGGED**:  
  - Compatible con entornos que usan **FULL Recovery**.  
  - Disminuye el crecimiento del LDF durante operaciones masivas.  
  - **Recomendación**: cambiar temporalmente de **FULL** a **BULK_LOGGED** durante el mantenimiento y luego regresar a **FULL**.  
  - Este cambio **no implica pérdida de datos** y es seguro para entornos con **Always On**.
 
### **Recomendaciones clave**
1. **Preferir `REORGANIZE` sobre `REBUILD`**  
   - `REORGANIZE` no provoca un crecimiento significativo del LDF.  
   - `REBUILD` es más costoso porque reconstruye el índice completo, actualiza estadísticas y otras operaciones internas.

2. **Evitar reconstrucciones innecesarias**  
   - Analizar el nivel de fragmentación antes de decidir entre `REORGANIZE` y `REBUILD`.  
   - Umbral sugerido:  
     - Fragmentación **< 30%** → usar `REORGANIZE`.  
     - Fragmentación **≥ 30%** → considerar `REBUILD`.

3. **Planificar el cambio de modo de recuperación**  
   - Antes del mantenimiento:  
     ```sql
     ALTER DATABASE [NombreBD] SET RECOVERY BULK_LOGGED;
     ```
   - Después del mantenimiento:  
     ```sql
     ALTER DATABASE [NombreBD] SET RECOVERY FULL;
     ```

4. **Monitorear el crecimiento del LDF**  
   - Validar espacio disponible antes de iniciar el mantenimiento.  
   - Usar vistas como `sys.dm_db_log_space_usage` para seguimiento.




---



 

# [**SQL Server Performance Monitor**](https://www.youtube.com/watch?v=qEBT0nk8pLE&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=6)

### **¿Qué son los Performance Counters?**
Los **Contadores de Rendimiento (Performance Counters)** son métricas proporcionadas por el sistema operativo y aplicaciones como SQL Server para medir el rendimiento en tiempo real.  
Se utilizan para:
- **Monitoreo** del estado del servidor.
- **Diagnóstico** de problemas de rendimiento.
- **Ajuste** y optimización de recursos.

 

### **Cómo acceder a los Performance Counters**
1. **En SQL Server**  
   - Vista dinámica:  
     ```sql
     SELECT * FROM sys.dm_os_performance_counters;
     ```
   - Permite consultar métricas internas como uso de CPU, memoria, I/O, bloqueos, etc.

2. **En Windows**  
   - Herramienta: **Performance Monitor (perfmon.exe)**  
   - Permite agregar contadores específicos de SQL Server y del sistema operativo.

3. **Extended Events en SQL Server**  
   - Para capturar eventos detallados y correlacionarlos con métricas de rendimiento.

4. **Herramienta `relog.exe`**  
   - Convierte archivos de log en diferentes formatos.  
   - Permite enviar los datos a una tabla en SQL Server para análisis histórico.

 

### **Recomendación práctica**
- Configurar un monitoreo continuo con **Performance Monitor** y almacenar métricas críticas en SQL Server mediante `relog.exe` para análisis y alertas.
- Combinar con **Extended Events** para obtener trazas detalladas cuando se detecten anomalías.



---

# Cosas extras 
```
Herramientas gratuitas sql -> https://blogs.triggerdb.com/herramientas-gratuitas-sql/

CTE (Common Table Expressions).
Operaciones recursivas.
Subconsultas correlacionadas.
Operaciones que requieren múltiples accesos a los mismos datos.

SQL Assessment en SQL Server es una funcionalidad (API y herramientas) diseñada para evaluar la configuración de una instancia de SQL Server y verificar si cumple con las mejores prácticas recomendadas por Microsoft.
```
