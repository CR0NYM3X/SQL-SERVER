# La Captura de Datos Modificados (CDC) en SQL Server

La Captura de Datos Modificados (CDC) en SQL Server es una característica poderosa que permite rastrear y registrar los cambios (inserciones, actualizaciones y eliminaciones) que ocurren en las tablas de una base de datos. Aquí te explico sus principales usos:

## Principales Usos

1. **Seguimiento de Cambios**: CDC captura los cambios en las tablas y los almacena en tablas de cambios especiales. Esto es útil para mantener un registro histórico de las modificaciones de datos.
2. **Integración de Datos**: Facilita la integración de datos entre diferentes sistemas. Por ejemplo, en procesos de ETL (Extracción, Transformación y Carga), CDC permite extraer solo los datos modificados, lo que mejora la eficiencia y reduce el tiempo de procesamiento.
3. **Auditoría y Cumplimiento**: Ayuda en la auditoría de datos y en el cumplimiento de normativas, ya que proporciona un registro detallado de todas las modificaciones realizadas en las tablas.
4. **Replicación de Datos**: CDC puede ser utilizado para replicar datos modificados a otras bases de datos o sistemas, asegurando que las copias de los datos estén siempre actualizadas.
5. **Análisis de Datos**: Permite realizar análisis de cambios en los datos a lo largo del tiempo, lo que puede ser útil para detectar tendencias o patrones.

En resumen, CDC es una herramienta valiosa para cualquier escenario donde necesites rastrear y gestionar cambios en los datos de manera eficiente y confiable.

## Tablas del Sistema de Captura de Datos Modificados (CDC)

Cada una de las tablas del sistema de Captura de Datos Modificados (CDC) en SQL Server tiene un propósito específico:

1. **cdc.change_tables**:
   - **Propósito**: Contiene una fila por cada tabla de cambios en la base de datos.
   - **Uso**: Permite identificar todas las tablas que están habilitadas para CDC y proporciona información sobre cada una de ellas.
2. **cdc.ddl_history**:
   - **Propósito**: Registra una fila para cada cambio del lenguaje de definición de datos (DDL) realizado en las tablas habilitadas para CDC.
   - **Uso**: Ayuda a rastrear los cambios en la estructura de las tablas, como la adición o eliminación de columnas.
3. **cdc.lsn_time_mapping**:
   - **Propósito**: Contiene una fila para cada transacción que tiene filas en una tabla de cambios.
   - **Uso**: Se utiliza para mapear entre los valores de confirmación del número de secuencia de registro (LSN) y la hora de confirmación de la transacción.
4. **cdc.captured_columns**:
   - **Propósito**: Contiene una fila para cada columna de la que se ha realizado un seguimiento en una instancia de captura.
   - **Uso**: Proporciona detalles sobre las columnas específicas que están siendo rastreadas por CDC.
5. **cdc.index_columns**:
   - **Propósito**: Contiene una fila para cada columna de índice asociada a una tabla de cambios.
   - **Uso**: Ayuda a identificar las columnas de índice que están involucradas en las tablas de cambios, lo cual es útil para optimizar las consultas y el rendimiento.


```markdown
```
# Guía Básica para Habilitar y Configurar la Captura de Datos Modificados (CDC) en SQL Server
Para habilitar y configurar la Captura de Datos Modificados (CDC) en SQL Server, necesitas seguir varios pasos. Aquí te dejo una guía básica:


## Habilitar CDC para la Base de Datos
Este comando crea el esquema `cdc` y las tablas:
```sql
EXEC sys.sp_cdc_enable_db;
 ```


## Habilitar CDC para una Tabla Específica

```sql
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',          -- Esquema de la tabla de origen
    @source_name = N'TuTabla',        -- Nombre de la tabla de origen
    @role_name = N'cdc_admin',        -- Nombre del rol para acceder a los datos de CDC, en caso de no tener un rol no colocarlo
    @capture_instance = N'dbo_TuTabla', -- (Opcional) Nombre de la instancia de captura
    @supports_net_changes = 1;        -- (Opcional) Soporte para cambios netos
GO
```

## Asignar Permisos a un Usuario

```sql
GRANT SELECT, UPDATE, DELETE ON SCHEMA::cdc TO TuUsuario;
GRANT EXECUTE ON OBJECT::[cdc].[sp_cdc_help_change_data_capture] TO TuUsuario;
GRANT EXECUTE ON OBJECT::[cdc].[sp_cdc_get_ddl_history] TO TuUsuario;
GRANT EXECUTE ON OBJECT::[cdc].[sp_cdc_scan] TO TuUsuario;
GRANT EXECUTE ON OBJECT::[cdc].[sp_cdc_enable_table] TO TuUsuario;
GRANT EXECUTE ON OBJECT::[cdc].[sp_cdc_disable_table] TO TuUsuario;
```

## Verificar si CDC Está Habilitado en la Base de Datos

```sql
SELECT name, is_cdc_enabled FROM sys.databases;
```

## Verificar si Existe el Esquema

```sql
SELECT * FROM sys.schemas WHERE name LIKE '%cdc%';
```

## Validar que Tablas Existen Dentro del Esquema

```sql
SELECT * FROM sys.tables WHERE schema_id IN (SELECT schema_id FROM sys.schemas WHERE name LIKE 'cdc');
```
