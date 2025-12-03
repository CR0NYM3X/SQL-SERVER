
## Conexion string 
```
Server=192.28.230.122;Application Name=TEST_APLICATION;Database=master;User Id=sys_usert;Password=A138AFB73ECD5B64F6;Encrypt=True;TrustServerCertificate=True;Connect Timeout=30;

*** Referencias ***
https://www.mssqltips.com/sqlservertip/7220/sql-server-connection-strings-reference-guide/
https://www.connectionstrings.com/sql-server/
https://www.connectionstrings.com/all-sql-server-connection-string-keywords/
```

## Accesos directos
```
--- SQL Server Configuration Manager 
C:\Windows\SysWOW64\mmc.exe /32 C:\Windows\SysWOW64\SQLServerManager15.msc

--- SQL Server Profiler 
C:\Program Files (x86)\Microsoft SQL Server\<versión>\Tools\Binn\profiler.exe
```
---

### 🧠 ¿Por qué aparecen en `sys.database_permissions`?

Porque SQL Server permite asignar permisos directamente a estos roles o usuarios especiales. Por ejemplo:

- Si ves que `public` tiene permiso `SELECT` sobre una tabla, **todos los usuarios** podrán hacer `SELECT` en esa tabla.
- Si `guest` tiene permiso `CONNECT`, entonces usuarios sin usuario en la base de datos podrán conectarse.
- Si `dbo` tiene permisos sobre un objeto, es porque es el propietario o tiene privilegios elevados.

### Diferencia de DDL Y DML 
**Lenguaje de Definición de Datos (DDL):**

`Propósito:` El DDL se utiliza para definir la estructura y las características de la base de datos. <br>
`Operaciones típicas:` Crear, modificar y eliminar objetos de la base de datos, como tablas, índices, vistas, esquemas, etc. <br>
`Ejemplos de sentencias DDL:` CREATE TABLE, ALTER TABLE, DROP TABLE, CREATE INDEX, CREATE VIEW, etc. <br>
`Efecto en los datos:` Las sentencias DDL no afectan directamente a los datos almacenados en la base de datos, sino a la estructura y definición de cómo se almacenan y organizan esos datos.


**Lenguaje de Manipulación de Datos (DML):** <br>
`Propósito:` El DML se utiliza para manipular y trabajar con los datos almacenados en la base de datos. <br>
`Operaciones típicas:` Insertar, recuperar, actualizar y eliminar datos dentro de las tablas de la base de datos. <br>
`Ejemplos de sentencias DML:` SELECT, INSERT, UPDATE, DELETE, etc. <br>
`Efecto en los datos:` Las sentencias DML sí afectan directamente a los datos almacenados en la base de datos, cambiando su contenido, añadiendo nuevos datos o eliminando datos existentes.

**Lenguaje de Control de Datos (DCL)**
Estos comandos permiten al Administrador del sistema gestor de base de datos, controlar el acceso a los objetos<br>
GRANT, permite otorgar permisos.<br>
REVOKE, elimina los permisos que previamente se han concedido.



### Ver configuraciónes del servidor
```
SELECT* FROM sys.configurations WHERE configuration_id = 1568 

sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
```

### Estructura 
```
msdb.dbo.backupmediafamily

[Base de datos].[esquema].[tabla]
```

### comandos básicos
```
use mydba_test -- sirve para que use una base de datos

go  ---  le indicas que está completo y que la interfaz de SQL Server debe ejecutar ese comando antes de continuar con cualquier otro comando siguiente
```


### Conectarse a sql server desde CMD
[Link descargar SQLCMD](https://learn.microsoft.com/es-es/sql/tools/sqlcmd/sqlcmd-utility?view=sql-server-ver16&tabs=odbc%2Cwindows&pivots=cs1-bash) <br> 

Puedes usar la herramienta de SQLCMD.exe o OSQL.exe

```
# Directorio donde se encuentra la herramienta:
C:\Program Files\Microsoft SQL Server\150\Tools\Binn

//// Ejemplos #1
OSQL.EXE -E -S My_hostnameServ -d Mydba -Q "SELECT name FROM sys.databases" 

//// Ejemplos #2
OSQL.EXE -S My_hostnameServ -d Mydba -U Usuario_test -i script.sql -o "C:\Users\alex\Desktop\log_script.txt"

*** Info parámetro ***
-E Este le indicas que utilice el windows autentication, con esta opcion no colocas ningun usuario o contraseña
-S Colocas el hostname del servidor
-d colocas el nombre de la base de datos a la que te conectas 
-Q sirve para ejecutar querys
-i Sirve para ejecutar scripts que tengan querys denstro del script
-U Indicas el usuario con el que te vas a conectas 
-o se guarda en un archivo como lgo toda la salida que se va ejecutar
```

Tambien puede conectarse de esta forma desde el cmd 
```

******** EJEMPLO #1 ********
runas /user:DOMINIO\omar.lopez "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe"

******** EJEMPLO #2 ********
runas /user:DOMINIO\omar.lopez "C:\Windows\System32\cmd.exe"


-- Tambien puede ser una ruta como: "C:\Program Files (x86)\Microsoft SQL Server\150\Tools\Binn\ManagementStudio\Ssms.exe"

runas: se utiliza en Windows para ejecutar programas con diferentes credenciales de usuario que las actuales.
 Sin embargo, runas no se usa directamente para conectarte a un servidor SQL Server de manera remota,
pero puedes utilizarlo para ejecutar aplicaciones como SQL Server Management Studio (SSMS) con diferentes credenciales.

/netonly: Indica que se realizará la autenticación de red remota,
lo que significa que se usarán las credenciales proporcionadas solo para recursos de red
 y no para los recursos locales.

/user:MYDOMINIO\user1: Especifica el nombre del dominio y el usuario con el que se ejecutará la aplicación.
 En este caso, MYDOMINIO es el nombre del dominio y user1 es el nombre de usuario.

"C:\Program Files\Microsoft SQL Server\110\Tools\binn\VSShell\Common7\IDE\Ssms.exe": Es la ubicación de la aplicación
SQL Server Management Studio (SSMS) en el sistema de archivos de Windows.
```

### Puertos por dafault que usa el sql server
    puerto: 1433, 1434, 4022, 135, de tipo TCP y el 1434 UDP.


### Bases de Datos del Sistema en SQL Server:
En SQL Server, las bases de datos del sistema son bases de datos que se utilizan para administrar y controlar el propio sistema de gestión de bases de datos. Algunas de las bases de datos del sistema más importantes en SQL Server son:<br>

**`master:`** La base de datos "master" almacena información crítica sobre la configuración del servidor, inicios de sesión, seguridad y otros aspectos fundamentales. Esta base de datos es esencial para el funcionamiento del servidor y no se puede desactivar.<br>

**`model:`** La base de datos "model" se utiliza como plantilla para crear nuevas bases de datos. Cualquier cambio que realices en "model" se aplicará a las bases de datos recién creadas.<br>

**`msdb:`** La base de datos "msdb" almacena información sobre la programación de tareas, mantenimiento, respaldos, jobs y otras tareas administrativas.<br>

**`tempdb:`** La base de datos "tempdb" es una base de datos temporal que se utiliza para almacenar datos temporales y variables de sesión, así como para ayudar en la clasificación y unión de datos.



##  cuenta de servicio 
La cuenta de servicio que configuras al instalar SQL Server es crucial para la seguridad y el rendimiento. Aquí están algunas razones por las que no se recomienda dejar la cuenta predeterminada:

**Seguridad:** <br>
La cuenta predeterminada suele ser NT SERVICE\MSSQLSERVER, que tiene privilegios elevados (como miembro del rol sysadmin).   
Usar una cuenta personalizada permite restringir permisos y limitar el acceso a recursos específicos.  <br>
**Principio de menor privilegio:**  <br>
Siempre ejecuta los servicios de SQL Server con los privilegios más bajos posibles.  
Utiliza cuentas de dominio (como gMSA o MSA) si tu servidor está en un dominio.   
Si no está en un dominio, considera usar cuentas virtuales.  <br>
**Personalización:**  <br>
Configurar una cuenta personalizada te permite ajustar permisos según tus necesidades.   
Puedes otorgar acceso a compartir archivos o otros servidores de bases de datos de manera más controlada.  <br>


```
gMSA (Cuenta de Servicio Administrada de Grupo):
Funcionalidad: Ofrece la misma funcionalidad que las sMSA, pero se extiende a varios servidores dentro del dominio.
Uso: Permite que todas las instancias de un servicio en una granja de servidores utilicen la misma entidad de servicio, lo que permite que los protocolos de autenticación mutua funcionen1.
Administración de Contraseñas: El sistema operativo de Windows administra la contraseña de la cuenta en lugar de requerir intervención manual del administrador.
Aplicaciones Prácticas: Ideal para servicios que se ejecutan en múltiples servidores sin necesidad de sincronizar contraseñas entre instancias de servicio.
sMSA (Cuenta de Servicio Administrado Independiente):
Funcionalidad: Introducida en Windows Server 2008 R2 y Windows 7, proporciona administración automática de contraseñas y SPN.
Uso: Diseñada para una sola instancia de servicio en un servidor.
Administración de Contraseñas: Similar a la gMSA, pero no se extiende a varios servidores1.
```
---

### 🧠 Conceptos de arquitectura y rendimiento relacionados con NUMA/UMA

| Concepto | Descripción |
|---------|-------------|
| **NUMA (Non-Uniform Memory Access)** | Arquitectura donde cada CPU tiene su propia memoria local. SQL Server puede optimizar el uso de recursos si está bien configurado. |
| **UMA (Uniform Memory Access)** | Arquitectura donde todos los CPUs acceden a la misma memoria con igual latencia. Menos eficiente en sistemas grandes. |
| **Soft-NUMA** | Técnica de SQL Server para simular NUMA en sistemas que no lo tienen, dividiendo CPUs lógicamente para mejorar el rendimiento. |
| **Affinity Mask / CPU Affinity** | Configuración que permite asignar CPUs específicos a SQL Server para controlar el uso de núcleos y mejorar el rendimiento. |
| **Memory Nodes** | En NUMA, cada nodo tiene su propia memoria. SQL Server puede asignar memoria por nodo para optimizar el acceso. |
| **Scheduler** | SQL Server usa planificadores por CPU y por nodo NUMA. Entender cómo se distribuyen las tareas es clave para evitar cuellos de botella. |
| **Parallelism (MAXDOP)** | Controla cuántos núcleos se usan para ejecutar una consulta en paralelo. Mal configurado puede causar problemas en entornos NUMA. |
| **Resource Governor** | Permite controlar el uso de CPU y memoria por grupo de trabajo, útil en servidores con múltiples aplicaciones o instancias. |
| **Buffer Pool Extension** | Usa SSD como extensión de memoria para el buffer pool, útil cuando hay limitaciones de RAM física. |
| **Lock Pages in Memory** | Permite que SQL Server mantenga páginas en memoria sin que el sistema operativo las intercambie, mejorando estabilidad en entornos críticos. |



---

### 🧠 Comparación general de entornos

| Entorno        | Propósito principal                     | Datos usados           | Usuarios principales         | Nivel de riesgo |
|----------------|------------------------------------------|-------------------------|-------------------------------|------------------|
| **Desarrollo** | Crear y probar nuevas funcionalidades    | Ficticios o mínimos     | Desarrolladores, DBAs         | Bajo             |
| **QA**         | Validar calidad y funcionalidad          | Simulados o anonimizados| QA, testers, DBAs             | Medio            |
| **Staging**    | Simular producción para pruebas finales  | Similares a producción  | DevOps, DBAs, QA              | Alto             |
| **Preprod**    | Validación con usuarios clave            | Reales o replicados     | Usuarios finales, QA, negocio| Alto             |
| **Producción** | Uso real por clientes o usuarios finales | Reales                  | Todos                         | Crítico          |

--- 

### 🧩 Tipos de RAID

| **RAID** | **Descripción** | **Ventajas** | **Desventajas** |
|----------|------------------|--------------|------------------|
| **RAID 0** | Distribuye los datos entre dos o más discos (striping). | Alta velocidad de lectura/escritura. | No tiene redundancia; si falla un disco, se pierde todo. |
| **RAID 1** | Duplica los datos en dos discos (mirroring). | Alta disponibilidad; tolerancia a fallos. | Solo se usa el 50% del espacio total. |
| **RAID 5** | Distribuye datos y paridad entre tres o más discos. | Buena velocidad y tolerancia a fallos. | Rendimiento de escritura más bajo; requiere mínimo 3 discos. |
| **RAID 6** | Similar a RAID 5 pero con doble paridad. | Puede tolerar la falla de dos discos. | Menor rendimiento de escritura; requiere mínimo 4 discos. |
| **RAID 10 (1+0)** | Combina RAID 1 y RAID 0 (mirroring + striping). | Alta velocidad y redundancia. | Costoso; requiere mínimo 4 discos. |
| **RAID 50 (5+0)** | Combina RAID 5 y RAID 0. | Mejor rendimiento y tolerancia que RAID 5. | Complejidad; requiere mínimo 6 discos. |
| **RAID 60 (6+0)** | Combina RAID 6 y RAID 0. | Alta tolerancia a fallos y buen rendimiento. | Muy complejo; requiere mínimo 8 discos. |
| **RAID 2, 3, 4** | Obsoletos o poco usados. Usan técnicas de paridad específicas. | Algunas ventajas en entornos específicos. | No se usan comúnmente hoy en día. |
| **JBOD (Just a Bunch Of Disks)** | No es RAID, pero se usa para agrupar discos sin redundancia. | Aprovecha todo el espacio. | Sin tolerancia a fallos. |

 
### 🧠 ¿Cuál es mejor según el uso?

| **Uso** | **RAID recomendado** |
|--------|-----------------------|
| Alto rendimiento sin necesidad de redundancia | RAID 0 |
| Alta disponibilidad y simplicidad | RAID 1 |
| Equilibrio entre rendimiento y seguridad | RAID 5 o RAID 6 |
| Máxima seguridad y velocidad | RAID 10 |
| Grandes volúmenes y alta tolerancia | RAID 50 o RAID 60 |


# **Estructuras internas de SQL Server (.mdf, .ndf)** 
que se usan para administrar el espacio en disco dentro de los archivos de datos (.mdf, .ndf). Son fundamentales para entender cómo SQL Server organiza las páginas y extents.

 
### ✅ **1. GAM (Global Allocation Map)**

*   **Qué es:** Una página especial que indica **qué extents (8 páginas = 64 KB)** están **libres o asignados** en un archivo de base de datos.
*   **Función:** Cada bit en la GAM representa un extent:
    *   **0** = extent asignado.
    *   **1** = extent libre.
*   **Ubicación:** Cada GAM cubre 4 GB de espacio de datos y se encuentra cada 511.232 páginas (\~4 GB).
 

### ✅ **2. SGAM (Shared Global Allocation Map)**

*   **Qué es:** Otra página especial que indica **qué extents están parcialmente usados para asignaciones mixtas**.
*   **Función:** SQL Server puede asignar páginas individuales dentro de un extent (mixed extent). SGAM marca:
    *   **1** = extent tiene páginas libres para asignación mixta.
    *   **0** = extent no disponible para asignación mixta.
*   **Ubicación:** Igual que GAM, cada SGAM cubre 4 GB.
 
### ✅ **3. PFS (Page Free Space)**

*   **Qué es:** Página que rastrea el **espacio libre dentro de cada página** y si está asignada.
*   **Función:** Indica:
    *   Si la página está asignada.
    *   Si es parte de un objeto.
    *   Cuánto espacio libre tiene (en rangos: 0-50%, 50-80%, etc.).
*   **Ubicación:** Cada PFS cubre 8.088 páginas (\~64 MB).


---

### ✅ **1. Memoria RAM**

*   **Qué es:** La memoria física del servidor que SQL Server utiliza para almacenar datos, ejecutar consultas y mantener estructuras internas.
*   **Trabajo:** SQL Server reserva una parte de la RAM para su operación (configurable con `max server memory` y `min server memory`).
*   **Ventaja:** Acceso rápido a datos y estructuras sin depender del disco.
*   **Desventaja:** Si hay poca RAM, SQL Server puede recurrir a disco (swap), lo que degrada el rendimiento.

 
### ✅ **2. Buffer Pool**

*   **Qué es:** Es la **zona principal dentro de la RAM** que SQL Server usa para almacenar **páginas de datos e índices** que se leen desde disco.
*   **Trabajo:** Cuando una consulta necesita datos, SQL Server los carga en el buffer pool. Si ya están ahí, se evita leer del disco (mucho más lento).
*   **Ventaja:** Reduce I/O en disco, mejora velocidad de lectura y escritura.
*   **Desventaja:** Si el buffer pool es pequeño, habrá más expulsión de páginas y más lecturas desde disco → rendimiento pobre.
 
### ✅ **3. Cache**

*   **Qué es:** Conjunto de áreas en memoria para almacenar información temporal:
    *   **Plan Cache:** Guarda planes de ejecución compilados para reutilizarlos.
    *   **Procedure Cache:** Similar, para procedimientos almacenados.
    *   **Data Cache:** Parte del buffer pool que contiene datos.
*   **Trabajo:** Evita recompilar consultas y reduce tiempo de ejecución.
*   **Ventaja:** Ahorra CPU y tiempo en consultas repetitivas.
*   **Desventaja:** Si hay demasiados planes o consultas ad-hoc, puede fragmentarse y consumir memoria innecesaria.



#  **throughput**
 se refiere a la **cantidad de trabajo que el sistema puede procesar en un período de tiempo determinado**. Es una métrica clave para medir el rendimiento, especialmente en sistemas transaccionales o de consultas masivas.

### ✅ **Definición técnica**

*   Es la **tasa de operaciones completadas por segundo** (o por minuto/hora), como:
    *   Transacciones (TPS: Transactions Per Second)
    *   Consultas ejecutadas
    *   Lecturas/escrituras en disco
*   Se mide en **operaciones por unidad de tiempo**.

### ✅ **Relación con rendimiento**

*   **Alto throughput** = el sistema procesa muchas operaciones rápidamente.
*   **Bajo throughput** = el sistema está limitado por CPU, memoria, I/O, bloqueos o concurrencia.

### ✅ **Ejemplo práctico**

Si un servidor SQL procesa:

*   10,000 consultas en 10 segundos → throughput = **1,000 consultas/segundo**.

### ✅ **Factores que afectan el throughput**

*   **Hardware**: CPU, RAM, velocidad de disco.
*   **Diseño de la base**: índices, normalización.
*   **Concurrencia**: bloqueos, aislamiento de transacciones.
*   **Configuración**: tamaño de pool de conexiones, parámetros de I/O.


### ✅ **¿Qué es un Data Mart?**

Un **data mart** es un **subconjunto especializado de un almacén de datos (data warehouse)**, diseñado para atender las necesidades de un área específica de negocio (por ejemplo, ventas, marketing, finanzas).

*   **Propósito:** Permitir acceso rápido y eficiente a datos relevantes para un departamento sin tener que consultar todo el data warehouse.
*   **Características:**
    *   Contiene datos resumidos y filtrados.
    *   Facilita análisis y generación de reportes específicos.
    *   Reduce costos y complejidad frente a un data warehouse completo.
*   **Tipos:**
    *   **Dependiente:** Se alimenta de un data warehouse central.
    *   **Independiente:** Se construye directamente desde sistemas fuente.
    *   **Lógico:** Integra datos sin almacenarlos físicamente.
 
 
---


# ¿Qué es un procesador (CPU)?

Un **procesador (CPU)** es el cerebro del computador, encargado de ejecutar instrucciones y procesar datos. Interpreta y ejecuta operaciones aritméticas, lógicas y de control.
 

### ¿Para qué sirve?

- Ejecutar programas y coordinar el funcionamiento del sistema.
- Procesar datos provenientes de memoria y dispositivos.
- Controlar el flujo de instrucciones.



### Partes físicas del procesador

1. **Núcleos (Cores físicos y lógicos)**  
   Cada núcleo puede ejecutar instrucciones de forma independiente.
2. **Unidad de Control (CU)**  
   Interpreta instrucciones y coordina operaciones.
3. **Unidad Aritmético-Lógica (ALU)**  
   Realiza cálculos matemáticos y operaciones lógicas.
4. **Registros**  
   Memoria ultrarrápida para datos temporales.
5. **Cache**  
   Niveles L1, L2, L3 para acelerar acceso a datos.
6. **Bus interno**  
   Conecta componentes internos.
7. **Socket**  
   Punto físico donde se instala el procesador en la placa madre.



### Términos técnicos y conceptos clave

- **Clock Speed (Frecuencia):** Velocidad de ejecución (GHz).
- **Pipeline:** Flujo de instrucciones dividido en etapas.
- **Hyper-Threading:** Tecnología para ejecutar múltiples hilos por núcleo.
- **NUMA:** Arquitectura de memoria no uniforme.
- **Cache Miss / Hit:** Acceso exitoso o fallido a la cache.
- **Instruction Set (ISA):** Conjunto de instrucciones soportadas (x86, ARM).
- **Overclock:** Práctica de aumentar la frecuencia de reloj (medida en GHz).



### Características importantes

- **Número de núcleos:** Más núcleos = más paralelismo.
- **Cache:** L1 (rápida, pequeña), L2 (intermedia), L3 (grande, compartida).
- **Socket:** Define compatibilidad con la placa madre.
- **TDP (Thermal Design Power):** Consumo y disipación térmica.
- **Arquitectura:** 32-bit vs 64-bit.



### ¿Por qué y cuándo usar ciertas características?

- **Más núcleos** → Servidores, multitarea pesada.
- **Alta frecuencia** → Juegos, aplicaciones que dependen de velocidad por hilo.
- **Cache grande** → Procesamiento intensivo de datos.



### Consideraciones

- Balance entre núcleos, frecuencia y consumo.
- Compatibilidad con placa madre y memoria.
- Refrigeración adecuada para evitar throttling.
- No siempre más núcleos = mejor → depende del software.
- Overclock sin refrigeración adecuada → riesgo de daño (genera más calor, aumento en voltaje, reduce la vida útil).



## Cores físicos vs lógicos

- **Cores físicos:** Núcleos reales dentro del procesador. Cada uno ejecuta instrucciones de manera independiente.
- **Cores lógicos:** Se crean mediante tecnologías como Hyper-Threading (Intel) o SMT (AMD).
  - Cada núcleo físico se divide en dos hilos lógicos, permitiendo ejecutar más tareas en paralelo.
  - Ejemplo: Un CPU con 8 núcleos físicos y Hyper-Threading activado tendrá 16 hilos lógicos.

**Ventaja de los hilos lógicos:**
- Mejor aprovechamiento del tiempo muerto del núcleo físico.
- Mayor rendimiento en cargas multitarea y paralelismo.

**Consideración:**
- No duplica el rendimiento, solo mejora la eficiencia (ganancia típica: 20-30%).



## Tipos de caché en un procesador

Los procesadores modernos tienen cachés multinivel para reducir la latencia entre CPU y memoria RAM:

### 1. Caché L1 (Nivel 1)
- **Ubicación:** Dentro de cada núcleo.
- **Tamaño:** Muy pequeña (16 KB a 128 KB por núcleo).
- **Velocidad:** La más rápida.
- **Función:** Almacena instrucciones y datos más usados por el núcleo.
- **Ventaja:** Acceso casi inmediato → mejora el rendimiento en operaciones repetitivas.

### 2. Caché L2 (Nivel 2)
- **Ubicación:** Dentro del núcleo o compartida entre pocos núcleos.
- **Tamaño:** Mayor que L1 (256 KB a 1 MB por núcleo).
- **Velocidad:** Más lenta que L1, pero más rápida que RAM.
- **Función:** Almacena datos que no caben en L1.
- **Ventaja:** Reduce la dependencia de la RAM → mejora eficiencia en multitarea.

### 3. Caché L3 (Nivel 3)
- **Ubicación:** Compartida entre todos los núcleos del procesador.
- **Tamaño:** Grande (2 MB a 64 MB).
- **Velocidad:** Más lenta que L2, pero mucho más rápida que RAM.
- **Función:** Almacena datos comunes para todos los núcleos.
- **Ventaja:** Mejora la comunicación entre núcleos y reduce accesos a memoria principal.

### 4. Caché L4 (opcional en algunos procesadores)
- **Ubicación:** Puede estar en el chip o en la placa madre.
- **Función:** Actúa como buffer entre CPU y RAM.
- **Ventaja:** Aumenta rendimiento en cargas muy grandes (servidores, HPC).



## Beneficios generales de la caché
- Reduce latencia: Acceso más rápido que la RAM.
- Mejora rendimiento: Menos ciclos de espera.
- Optimiza multitarea: Cada nivel almacena datos estratégicamente.



## Consideraciones
- Más caché = mejor rendimiento, pero también mayor costo y consumo.
- Caché L1 es crítica para velocidad por núcleo.
- Caché L3 es clave en servidores y cargas paralelas.



## ¿Qué es NUMA?

**NUMA (Non-Uniform Memory Access)** es una arquitectura de hardware que divide la memoria en nodos asociados a grupos de CPU.

*   Cada nodo tiene su propia memoria RAM local.
*   Acceder a memoria local es más rápido que acceder a memoria de otro nodo.

**Objetivo:** Mejorar el rendimiento en servidores con muchos procesadores evitando cuellos de botella en acceso a memoria.

### Ventajas de NUMA

*   Menor latencia al acceder a memoria local.
*   Mejor escalabilidad en servidores multiprocesador.
*   Optimiza cargas paralelas (OLTP, OLAP).

### Desventajas

*   Acceso a memoria remota es más lento.
*   Requiere que el software (SQL Server, OS) sea NUMA-aware.
*   Configuración incorrecta puede causar desequilibrio.

### ¿Cuándo usarlo?

*   Siempre que el hardware lo soporte (servidores grandes).
*   SQL Server lo detecta automáticamente.

### ¿Cuándo no?

*   No se puede desactivar si el hardware es NUMA.
*   No tiene sentido en servidores pequeños (pocos cores).


## ¿Qué es Soft-NUMA?

es una característica de SQL Server crea varios nodos Soft-Numa logicos  (desde la versión 2016 se activa automáticamente) que permite dividir los núcleos de CPU de un único socket grande (o un servidor sin NUMA físico) en múltiples grupos lógicos, que SQL Server llama nodos Soft-NUMA.  

**Objetivo:**
*   El objetivo es mejorar la escalabilidad y el rendimiento al crear particiones lógicas de los recursos, lo que beneficia a las estructuras internas del motor de base de datos.
*   Reducir contención en servidores con muchos cores (ej. 64).
*   Balancear schedulers y memoria.

### Ventajas de Soft-NUMA

*   Mejor paralelismo en cargas OLTP.
*   Reduce contención en spinlocks.
*   Permite ajustar `MAXDOP` por nodo lógico.

### Desventajas

*   Configuración manual puede ser compleja.
*   No siempre necesario si la carga está bien balanceada.

### ¿Cuándo usarlo?

*   Servidores con más de 8 cores por nodo NUMA físico.
*   Alta concurrencia y problemas de contención.

### ¿Cuándo no?

*   Servidores pequeños.
*   Si la carga no presenta problemas de escalabilidad.



## Consideraciones

*   **NUMA = hardware (nivel físico).**
*   **Soft-NUMA = software (nivel SQL Server).**
*   SQL Server crea Soft-NUMA automáticamente desde 2016 si detecta muchos cores.

**Ver configuración:**

```sql
SELECT node_id, memory_node_id, online_scheduler_count, processor_group
FROM sys.dm_os_nodes
WHERE node_state_desc = 'ONLINE';

"SELECT * FROM sys.dm_os_schedulers WHERE status = 'VISIBLE ONLINE';


-- Hardware information from SQL Server 2022  (Query 18) (Hardware Info)
SELECT cpu_count AS [Logical CPU Count], scheduler_count, (socket_count * cores_per_socket) AS [Physical Core Count], socket_count AS [Socket Count], cores_per_socket, numa_node_count, physical_memory_kb/1024 AS [Physical Memory (MB)], max_workers_count AS [Max Workers Count], affinity_type_desc AS [Affinity Type], sqlserver_start_time AS [SQL Server Start Time], DATEDIFF(hour, sqlserver_start_time, GETDATE()) AS [SQL Server Up Time (hrs)], virtual_machine_type_desc AS [Virtual Machine Type], softnuma_configuration_desc AS [Soft NUMA Configuration], sql_memory_model_desc, container_type_desc FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);


```


## Cómo se activa Soft-NUMA

*   Automático en SQL Server 2016+.
*   Manual: Configuración avanzada o parámetros de inicio.
*   No requiere cambios en hardware.


## Ejemplo práctico de Soft-NUMA

Supongamos:

*   Servidor con 64 cores físicos y 2 nodos NUMA físicos (32 cores cada uno).
*   SQL Server detecta que cada nodo NUMA físico tiene más de 8 cores → entonces crea Soft-NUMA dividiendo cada nodo físico en 4 nodos lógicos (8 cores cada uno).

**Resultado:**

*   En vez de 2 nodos NUMA físicos grandes, tienes 8 nodos NUMA lógicos.
*   Cada nodo lógico tiene su propio scheduler group y memory node.
*   Esto reduce contención interna y mejora paralelismo.

## ¿Por qué usar Soft-NUMA si ya tengo NUMA físico?

*   NUMA físico agrupa CPUs y memoria en nodos grandes.
*   Si cada nodo tiene muchos cores, puede haber contención en spinlocks y plan cache.
*   Soft-NUMA subdivide esos nodos para:
    *   Mejor balanceo de schedulers.
    *   Menos competencia por recursos internos.
    *   Optimización en cargas OLTP muy concurrentes.



### ¿Qué Pasa si NO Tienes NUMA Físico?

Si tu servidor o máquina virtual (VM) no tiene nodos NUMA físicos (todo se reporta como un solo nodo 0), SQL Server activará Soft-NUMA para dividir los recursos lógicos, si se cumplen los requisitos de núcleos:

SQL Server divide los núcleos lógicos en nodos Soft-NUMA más pequeños

* **Beneficios Clave:**
  * **Schedulers:** Se crean **schedulers** independientes para cada nodo Soft-NUMA, mejorando la gestión de subprocesos.
  * **Escritores Diferidos (Lazy Writer):** Se crea un subproceso de **Lazy Writer** por cada nodo, mejorando el rendimiento de las E/S y la administración de la memoria.
  * **Partición Interna:** SQL Server particiona estructuras internas (como las de caché de búfer) a nivel de nodo Soft-NUMA, reduciendo la contención de bloqueos internos (*latches*).


## 1. 🥇 Prioridad: NUMA Física (Hardware NUMA)

Cuando el sistema operativo le reporta a SQL Server que existe una estructura NUMA física (múltiples nodos de CPU/memoria), SQL Server hace lo siguiente:

1.  **Adopta la Topología:** Utiliza inmediatamente los nodos físicos (Node 0, Node 1, etc.) para alinear sus estructuras internas.
2.  **Alineación de Recursos:** Crea **schedulers** (planificadores), **lazy writers**, y particiona el **Buffer Pool** (caché de datos) para que cada estructura pertenezca a su nodo NUMA físico. Esto asegura que los procesos de un nodo accedan preferentemente a la memoria local de ese nodo, que es el objetivo principal de NUMA.

En este escenario, el Soft-NUMA ya **no es necesario** para crear la partición *básica* de recursos.


## 🧠 Proceso  Automático de Soft-NUMA 

El flujo de decisión que sigue el motor de SQL Server (`sqlservr.exe`) para particionar los núcleos lógicos de un *socket* o de un nodo NUMA grande es el siguiente:

### 1. Detección de la Topología de Hardware

SQL Server primero consulta al sistema operativo para determinar la topología de la CPU.

* **¿Hay NUMA Físico?**
    * **Si SÍ (Hardware NUMA):** SQL Server identifica los límites de cada nodo NUMA físico. La decisión de Soft-NUMA se aplicará *dentro* de esos nodos físicos.
    * **Si NO (Solo un Socket Grande o VM mal configurada):** SQL Server trata todos los núcleos visibles como un solo nodo grande.

### 2. Aplicación de la Regla de Activación (Heurística)

SQL Server evalúa cada nodo (físico o el único nodo grande sin NUMA) con la siguiente regla:

* **Regla:** Si un nodo tiene **8 o más núcleos lógicos**, SQL Server decide aplicar la partición Soft-NUMA.
    * **Motivo:** Se considera que por debajo de 8 núcleos, el *overhead* de la coordinación de *threads* no es un problema de escalabilidad significativo, y el costo de dividir estructuras internas no se justifica.

### 3. Cálculo de la Partición (El Flujo Semántico)

Si se cumple la regla (8 o más núcleos), SQL Server calcula el número de nodos Soft-NUMA y los núcleos por nodo utilizando un proceso de división simple y consistente:

* **Paso 3a: División por el Múltiplo de 8.**
    El número de núcleos del nodo se divide en la mayor cantidad de grupos posible, con el tamaño preferente de **8 núcleos lógicos** por nodo Soft-NUMA.
    * *Ejemplo:* Si el nodo tiene **16 núcleos**, se crean **2 nodos Soft-NUMA** (16 / 8 = 2).

* **Paso 3b: Manejo del Sobrante.**
    Si el número total de núcleos no es divisible exactamente por 8, se aplica la partición más equitativa posible, intentando mantener los nodos del mismo tamaño.
    * *Ejemplo 1:* Si el nodo tiene **12 núcleos**, se dividiría en **2 nodos Soft-NUMA**, cada uno con **6 núcleos** (12 / 2 = 6).
    * *Ejemplo 2:* Si el nodo tiene **18 núcleos**, se dividiría en **2 nodos Soft-NUMA**, uno con **9** y el otro con **9** (18 / 2 = 9).

### 4. Creación de Objetos Internos

Una vez definida la topología Soft-NUMA, SQL Server **asigna** recursos específicos a cada nodo Soft-NUMA recién creado.

* **Asignación de Schedulers:** Se crea un *scheduler* de CPU dedicado para cada nodo Soft-NUMA.
* **Partición del Buffer Pool:** La memoria caché de datos se particiona para que cada nodo Soft-NUMA tenga acceso optimizado a la sección de memoria que le corresponde.

 
 
### Scheduler

Los **Schedulers** (Planificadores) en SQL Server son componentes internos fundamentales del motor de base de datos responsables de gestionar y asignar los **subprocesos (threads)** de trabajo a los **núcleos de CPU** disponibles.
En esencia, son el mecanismo de **SQL Server** para manejar la concurrencia y asegurarse de que el trabajo se distribuya eficientemente en el hardware.

 
## ⚙️ Concepto y Función Principal

### 1. Gestión de la CPU

Cada **núcleo lógico** de CPU que SQL Server utiliza es mapeado a un *Scheduler*. Si tu servidor tiene 16 núcleos lógicos, SQL Server crea 16 *Schedulers*.

* **Asignación de Subprocesos:** La función principal del *Scheduler* es mantener un control de los subprocesos de trabajo y moverlos entre los tres estados principales:
    * **RUNNING (Ejecutándose):** El subproceso está activo en el núcleo de la CPU.
    * **RUNNABLE (Ejecutable):** El subproceso está listo para ejecutarse y esperando su turno para ser asignado a la CPU.
    * **SUSPENDED (Suspendido):** El subproceso está esperando que se complete un recurso (como una lectura de disco, un bloqueo, o un recurso de red).

### 2. Coordinación de Concurrencia

Los *Schedulers* no solo gestionan el tiempo de CPU, sino que también actúan como el punto de control para la **concurrencia** dentro de SQL Server:

* **Supervisión:** El *Scheduler* se asegura de que ningún subproceso acapare el núcleo por demasiado tiempo, forzando periódicamente a los subprocesos a ceder el control (este es el concepto de *cooperative scheduling* o **planificación cooperativa** que utiliza SQL Server).
* **Gestión de Trabajadores:** Los *Schedulers* manejan los subprocesos que realizan el trabajo de las consultas entrantes. Estos subprocesos se conocen como **SQL OS Workers** (Trabajadores del Sistema Operativo de SQL Server).
 

 
---


 

# **Memoria RAM: Conceptos Clave y Uso**

##  **¿Qué es la Memoria RAM?**

La **RAM (Random Access Memory)** es un tipo de memoria volátil que almacena datos e instrucciones de forma temporal mientras el procesador ejecuta tareas.

*   **Volátil:** Pierde la información al apagar el equipo.
*   **Acceso aleatorio:** Permite leer y escribir datos en cualquier posición con la misma velocidad.

**Función principal:**

*   Servir como espacio de trabajo rápido para el CPU, evitando depender del disco (mucho más lento).



##  **¿Para qué sirve?**

*   Almacenar programas y datos en ejecución.
*   Mejorar la velocidad del sistema.
*   Permitir multitarea (varias aplicaciones abiertas).



##  **Partes físicas y lógicas del procesador relacionadas con RAM**

*   **Físicas:**
    *   **Módulos DIMM/SODIMM:** Tarjetas donde se monta la RAM.
    *   **Chips DRAM:** Donde se almacenan los datos.
*   **Lógicas:**
    *   **Controlador de memoria:** Gestiona el acceso entre CPU y RAM.
    *   **Caches (L1, L2, L3):** Memoria ultrarrápida integrada en CPU para reducir latencia.
    *   **Bus de memoria:** Canal de comunicación entre CPU y RAM.



##  **Términos técnicos y conceptos clave**

*   **Latencia:** Tiempo que tarda en acceder a un dato.
*   **Ancho de banda:** Cantidad de datos que puede transferir por segundo.
*   **DDR (Double Data Rate):** Tecnología que transfiere datos dos veces por ciclo.
*   **Dual Channel:** Configuración que duplica el ancho de banda usando dos módulos.
*   **Memoria volátil:** Pierde datos al apagar el equipo.



##  **Características importantes**

*   **Capacidad:** Cantidad total (GB).
*   **Velocidad:** Medida en MHz (ej. DDR4-3200).
*   **Tipo:** DDR3, DDR4, DDR5.
*   **Latencia CAS:** Tiempo de respuesta del módulo.
*   **Consumo energético:** Importante en servidores y laptops.



##  **¿Por qué y cuándo usar más RAM?**

*   **Por qué:** Mejora rendimiento, reduce uso de disco (swap).
*   **Cuándo:**
    *   Aplicaciones pesadas (edición, bases de datos, virtualización).
    *   Servidores con alta concurrencia.
    *   Juegos y software gráfico.

 

##  **Consideraciones**

*   Compatibilidad con placa madre y CPU.
*   Número de slots disponibles.
*   Configuración en canales (dual, quad).
*   Balance entre velocidad y latencia.



##  **Ventajas**

*   Mayor velocidad de ejecución.
*   Permite multitarea fluida.
*   Reduce cuellos de botella en CPU.

##  **Desventajas**

*   Volátil (pierde datos al apagar).
*   Costo elevado en grandes capacidades.
*   No sustituye almacenamiento permanente.
 

##  **Tipos de Memoria RAM**

*   **DRAM (Dynamic RAM):** Base de la mayoría de módulos.
*   **SDRAM (Synchronous DRAM):** Sincronizada con el reloj del sistema.
*   **DDR (DDR3, DDR4, DDR5):** Estándar actual.
*   **ECC RAM:** Corrige errores, usada en servidores.
*   **SRAM:** Más rápida, usada en cachés.
*   **VRAM:** Memoria para tarjetas gráficas.





 

# **Memoria en SQL Server: Conceptos Clave**

##  **1. Buffer Pool**

*   **¿Qué es?**  
    Es la **zona principal de memoria** en SQL Server donde se almacenan páginas de datos y planes de ejecución para evitar accesos al disco.
*   **¿Para qué sirve?**  
    Reduce I/O en disco, acelerando consultas.
*   **Función:**  
    Mantener datos y objetos en memoria para acceso rápido.
*   **Ventajas:**
    *   Disminuye latencia.
    *   Mejora rendimiento en OLTP y OLAP.
*   **¿Se activa?**  
    Automático. Se ajusta con `max server memory` y `min server memory`.
*   **Nivel:**  
    Software (SQL Server administra la memoria física del hardware).
*   **Consideraciones:**
    *   Ajustar tamaño según carga.
    *   Evitar que el OS quede sin memoria.
*   **¿Cuándo usar?**  
    Siempre, es parte del motor.



##  **2. Memory Grants**

*   **¿Qué es?**  
    Cantidad de memoria que SQL Server asigna a una consulta para operaciones como **sort** o **hash join**.
*   **¿Para qué sirve?**  
    Evitar que consultas grandes saturen la memoria.
*   **Función:**  
    Controlar uso de memoria en operaciones intensivas.
*   **Ventajas:**
    *   Previene bloqueos por falta de memoria.
*   **¿Se activa?**  
    Automático, pero se puede monitorear con `sys.dm_exec_query_memory_grants`.
*   **Nivel:**  
    Software.
*   **Consideraciones:**
    *   Consultas mal optimizadas pueden pedir más memoria.
    *   Ajustar `workload` y estadísticas.
*   **¿Cuándo usar?**  
    Siempre, es interno.



##  **3. Memory Clerk**

*   **¿Qué es?**  
    Componentes internos que **administran diferentes áreas de memoria** (Buffer Pool, Cache, etc.).
*   **¿Para qué sirve?**  
    Controlar y reportar consumo de memoria por tipo.
*   **Función:**  
    Cada clerk gestiona una parte específica (ej. `CACHESTORE_SQLCP` para planes).
*   **Ventajas:**
    *   Permite diagnóstico detallado.
*   **¿Se activa?**  
    Automático.
*   **Nivel:**  
    Software.
*   **Consulta:**
    ```sql
    SELECT type, pages_kb FROM sys.dm_os_memory_clerks ORDER BY pages_kb DESC;
    ```



##  **4. Cache (Plan Cache y Data Cache)**

*   **¿Qué es?**
    *   **Plan Cache:** Almacena planes de ejecución compilados.
    *   **Data Cache:** Páginas de datos en memoria.
*   **¿Para qué sirve?**  
    Evitar recompilar consultas y reducir I/O.
*   **Función:**  
    Mejorar rendimiento reutilizando recursos.
*   **Ventajas:**
    *   Ahorra CPU.
    *   Reduce latencia.
*   **¿Se activa?**  
    Automático.
*   **Nivel:**  
    Software.
*   **Consideraciones:**
    *   Consultas ad-hoc pueden fragmentar el cache.
    *   Usar parámetros para reutilización.



##  **Otros términos importantes**

*   **Stolen Memory:** Memoria tomada del Buffer Pool para otras tareas.
*   **Reserved Memory:** Memoria reservada para operaciones críticas.
*   **Target Memory:** Memoria que SQL Server intenta alcanzar según carga.



##  **Características importantes**

*   SQL Server **no usa toda la RAM física** automáticamente → se configura con `max server memory`.
*   Desde SQL Server 2016, el motor es **NUMA-aware** y gestiona memoria por nodos.
*   Usa **Lazy Writer** para liberar páginas no usadas.



##  **Ventajas del manejo de memoria en SQL Server**

*   Optimiza rendimiento sin intervención manual.
*   Escala en servidores grandes.
*   Reduce I/O y CPU.

##  **Desventajas**

*   Configuración incorrecta puede causar:
    *   Paginación en OS.
    *   Bloqueos por falta de memoria.
*   Consultas mal diseñadas pueden consumir excesiva memoria.



##  **¿Es hardware o software?**

*   **Hardware:** La RAM física.
*   **Software:** SQL Server administra la memoria asignada por el OS.



##  **Tipos de memoria en SQL Server**

*   **Buffer Pool:** Datos y planes.
*   **Query Workspace:** Para operaciones complejas.
*   **Plan Cache:** Planes compilados.
*   **Log Cache:** Para transacciones.
*   **Columnstore Object Pool:** Para índices columnstore.
 
 
 


 
