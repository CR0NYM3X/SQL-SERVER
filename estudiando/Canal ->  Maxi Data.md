
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

# [**Optimizando SQL Server - Tipos de datos**](https://www.youtube.com/watch?v=FYdu5id05_w&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=10)

**Contexto**  
La elección correcta de tipos de datos en SQL Server impacta directamente en el rendimiento y el uso de espacio en disco. Un tipo de dato inadecuado puede generar consultas más costosas y mayor consumo de recursos.

 

**Pruebas y hallazgos**  
- **Tipos numéricos**: Entero, bigint y decimal tienen diferentes tamaños en bytes. Enteros ocupan menos espacio que bigint y decimal.  
- **Espacio en disco**: Tras insertar 1 millón de registros en tablas con distintos tipos, se observan diferencias significativas en el tamaño ocupado.  
- **Impacto en performance**: Tipos más grandes implican más lecturas/escrituras y mayor uso de CPU, afectando los planes de ejecución.  

 

**Índices y consultas**  
- Se crean índices en columnas de cada tabla y se ejecutan consultas idénticas.  
- El costo de ejecución varía según el tipo de dato: columnas con tipos más pesados generan planes más costosos.  

 
**Comparación CHAR vs VARCHAR**  
- **CHAR**: Espacio fijo, mayor costo en consultas.  
- **VARCHAR**: Espacio variable, menor uso de disco y mejor rendimiento.  
- Pruebas con 1 millón de registros confirman que VARCHAR es más eficiente en tiempo y espacio.  

 
**Pruebas de estrés**  
- Con SQL Query Stress, las consultas sobre VARCHAR se ejecutan más rápido que las de CHAR, evidenciando el impacto en escenarios de alta carga.  

 

**Recomendaciones clave**  
- Elegir tipos de datos que minimicen el espacio sin comprometer la precisión.  
- Preferir VARCHAR sobre CHAR para datos de longitud variable.  
- Analizar el impacto en índices y planes de ejecución antes de definir el esquema.  
- Realizar pruebas de carga para validar decisiones en entornos críticos.




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


---

# [Analizando planes de ejecución con Plan Explorer](https://www.youtube.com/watch?v=FYdu5id05_w&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=10)
 
# **Introducción**
Este tutorial presenta una herramienta gratuita diseñada para **analizar planes de ejecución en SQL Server** y mejorar el rendimiento de las consultas.  
Los planes de ejecución pueden ser complejos de interpretar, y esta herramienta facilita la optimización del código de manera más eficiente.  
Se invita a los usuarios a suscribirse al canal para recibir más contenido sobre **SQL Server** y plataformas de datos de Microsoft.

 

## **Presentación de SQL Server Plan Explorer**
- Herramienta: **SQL Server Plan Explorer** (SolarWinds).  
- **Gratuita** y compatible con sistemas operativos Windows.  
- Permite:
  - Importar planes de ejecución.
  - Integrarse con **SQL Server Management Studio (SSMS)** para ejecutar y visualizar planes directamente.



## **Uso de la Herramienta**
- Se muestra cómo abrir un plan de ejecución desde SSMS en **Plan Explorer**.  
- Diferencias clave:
  - Visualización gráfica más clara y detallada.
  - Operaciones más costosas se destacan en **rojo**, facilitando la identificación de cuellos de botella.
- Vista en formato **grilla**:
  - Permite ordenar operaciones por criterios como:
    - Cantidad de registros.
    - Consumo de CPU.
    - Uso de disco.

 

## **Análisis Detallado**
- Posibilidad de cambiar el enfoque del análisis:
  - **Costo acumulado**.
  - **CPU**.
  - **Disco**.
- Esto ayuda a optimizar consultas específicas según las necesidades del sistema.
 

## **Compartir y Guardar Planes**
- Los planes de ejecución se pueden guardar desde SSMS en archivos con extensión **.sqlplan** (formato XML).  
- Estos archivos se pueden abrir en **Plan Explorer** para análisis detallado.  
- Permite abrir planes generados por otros usuarios, facilitando la colaboración.

 
## **Análisis de Interbloqueos**
- **Plan Explorer** también permite analizar interbloqueos:
  - Identificación de operaciones involucradas.
  - Determinar el ejecutor, el causante y la víctima del bloqueo.
- Simplifica el análisis frente a la revisión manual de archivos XML.

 
## **Conclusión**
**SQL Server Plan Explorer** es una herramienta esencial para:
- Analizar planes de ejecución.
- Detectar cuellos de botella.
- Resolver interbloqueos de manera eficiente.

---


 
 
[SQL 2019 optimizar tiempos de Rollback](https://www.youtube.com/watch?v=qXw3EdDIOkY&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=15)
 
### **¿De qué trata el video?**
- Es un video del canal de **Maxi Acoto** sobre **SQL Server 2019**.
- El tema principal es una funcionalidad llamada **ADR (Accelerated Database Recovery)**.
- **¿Por qué es importante?** Porque normalmente, cuando haces un **rollback** (deshacer una transacción), puede tardar tanto como la transacción original. Esto es un problema en bases de datos grandes.



### **¿Qué hace ADR?**
- **ADR** acelera el proceso de recuperación y rollback.
- Con ADR activado, el rollback es **casi instantáneo**, en lugar de tardar segundos o minutos.



### **¿Cómo lo demuestra el video?**
1. **Sin ADR**:
   - Crea una base de datos y hace una transacción (inserta datos).
   - Mide el tiempo: la inserción tarda unos **6000 ms**.
   - Hace rollback: tarda casi lo mismo (**4724 ms**).
   - Conclusión: rollback es lento.

2. **Con ADR activado**:
   - Activa ADR en la base de datos.
   - Repite la prueba.
   - El rollback ahora es **instantáneo**.
   - Conclusión: mejora enorme en rendimiento.



### **Detalles importantes**:
- ADR se activa **por base de datos**, no globalmente.
- No funciona con **mirroring**.
- Se recomienda crear un **filegroup** para optimizar aún más.
- Aunque ADR nació en SQL Server 2019, también se puede usar en versiones posteriores (y mejorará en SQL Server 2022).



### **Cierre del video**:
- El presentador agradece y pide suscribirse.
- Anuncia que habrá más videos sobre SQL Server.




# [Usando el asistente de índices en SQL Server](https://www.youtube.com/watch?v=ZrRh6YSTkXc&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=14)


# [Monitoreando Timeout en SQL](https://www.youtube.com/watch?v=4RuUz86MS7k&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=17 )


Recomienda usar query_store esta dispinible desde sql 2016 o eventos extendidos para monitorear los TimeOut 



# [Cómo optimizar consultas SQL usando Columnas Calculadas e índices](https://www.youtube.com/watch?v=h2aMBZbQYas&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=18)


En **SQL Server** también puedes crear índices sobre expresiones, pero la forma es diferente a PostgreSQL. Aquí se llaman **índices en columnas calculadas**.

### ✅ ¿Cómo se hace?
1. **Crear una columna calculada** que aplique la función (por ejemplo, `LOWER` en PostgreSQL equivale a `LOWER()` en SQL Server).
2. **Crear un índice sobre esa columna calculada**.

 

### **Ejemplo práctico**
```sql
-- Paso 1: Crear la tabla
CREATE TABLE Clientes (
    Id INT PRIMARY KEY,
    Nombre NVARCHAR(100)
);

-- Paso 2: Agregar columna calculada con LOWER
ALTER TABLE Clientes
ADD NombreLower AS LOWER(Nombre);

-- Paso 3: Crear índice sobre la columna calculada
CREATE INDEX idx_NombreLower ON Clientes(NombreLower);
```

 

### **Puntos importantes en SQL Server**:
- La columna calculada debe ser **persistente** si quieres indexarla:
```sql
ALTER TABLE Clientes
ADD NombreLower AS LOWER(Nombre) PERSISTED;
```
- Si no la marcas como `PERSISTED`, SQL Server no permite crear el índice.
- El índice se usará cuando la consulta aplique la misma función:
```sql
SELECT * FROM Clientes WHERE LOWER(Nombre) = 'juan';
```



# [Comparando planes de ejecución](https://www.youtube.com/watch?v=9HwqhYWSf9Y&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=21)



# [CUIDADO con los índices mellizos en SQLServer](https://www.youtube.com/watch?v=9Lx_eSGNTKc&list=PL4xPHdgInKcFrHdFeLgt4Lmi8aS9QlHtA&index=35)


- Eliminar los  indices mellizos ya que el ix3 sirve para cumplir la misma funcion ix1 y ix2
- Tener cuidado con indices duplicados, 
- indices que no se utilizan
- generar mas indices que la cantidad de columnas  
```
CREATE INDEX ix1 ON test_table(c1);
CREATE INDEX ix2 ON test_table(c1, c2);
CREATE INDEX ix3 ON test_table(c1, c2, c3);
```
