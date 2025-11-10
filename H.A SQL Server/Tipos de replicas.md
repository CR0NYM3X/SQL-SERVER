En **SQL Server**, existen varios tipos de **replicación** que puedes configurar, dependiendo de tus necesidades de disponibilidad, rendimiento y sincronización de datos. Aquí te explico los principales:

---

### ✅ **Replicación Transaccional**
- **Objetivo:** Distribución de datos en tiempo casi real (no es HA pura).
- **Nivel:** Tablas y objetos específicos.
- **Cómo funciona:** Publica cambios (inserciones, actualizaciones, eliminaciones) desde el **Publisher** hacia **Subscribers** mediante un **Distributor**.
- **Características:**
  - Ideal para replicar datos entre servidores para reporting o aplicaciones distribuidas.
  - No ofrece failover automático.
  - no clustering
  - El suscriptor puede estar desfasado unos segundos.
  - Puede haber retraso mínimo, pero no garantiza sincronización perfecta.
- **Uso típico:** Escenarios donde se necesita compartir datos con otras aplicaciones o sitios remotos, no tanto para alta disponibilidad.

---

### 🔄 2. **Replicación de mezcla (Merge Replication)**
- **Uso típico**: Aplicaciones móviles o distribuidas donde los cambios pueden ocurrir en múltiples nodos.
- **Características**:
  - Permite que tanto el publicador como el suscriptor hagan cambios.
  - Los cambios se sincronizan y se resuelven los conflictos.
- **Ideal para**: Bases de datos que se modifican en ambos extremos.

---

### 📦 3. **Replicación de instantáneas (Snapshot Replication)**
- **Uso típico**: Cuando los datos no cambian con frecuencia o no se requiere sincronización continua.
- **Características**:
  - Se toma una "foto" de los datos y se copia al suscriptor.
  - No hay seguimiento de cambios entre snapshots.
- **Ideal para**: Informes periódicos o sincronización puntual.

---

### ✅ **Always On Availability Groups **
- **Objetivo:** Alta disponibilidad y recuperación ante desastres.
- **Nivel:** Grupo de bases de datos.
- **Cómo funciona:** Replica bases completas entre nodos usando **Windows Server Failover Clustering (WSFC)**.
- **Características:**
  - Failover automático.
  - Réplicas sincrónicas (HA) y asincrónicas (DR).
  - Réplicas de solo lectura para balanceo.
- **Uso típico:** Entornos críticos donde se necesita continuidad del servicio y mínima pérdida de datos.

---
### 🟢 **Always On Availability Groups (AGs)**

- **Propósito:** Alta disponibilidad y recuperación ante desastres con réplicas en tiempo real.
- **Requiere:** Windows Server Failover Clustering (WSFC).
- **Funcionamiento:** Replica grupos de bases de datos entre múltiples nodos. Las réplicas pueden ser *sincrónicas* (alta disponibilidad) o *asincrónicas* (recuperación ante desastres).
- **Ventajas:**
  - Failover automático.
  - Réplicas de solo lectura para balanceo de carga.
  - Sincronización casi inmediata.
- **Ideal para:** Entornos críticos que requieren alta disponibilidad y mínima pérdida de datos.

### 🟢 **Database Mirroring**  
**Propósito:** Alta disponibilidad y recuperación ante desastres a nivel de base de datos individual.  
**Requiere:** Dos o tres instancias de SQL Server (principal, espejo y opcionalmente un testigo para failover automático).  
**Funcionamiento:** Replica una base de datos específica desde el servidor principal al espejo. Puede ser en modo sincrónico (alta disponibilidad) o asincrónico (recuperación ante desastres).  
**Ventajas:**
- Failover automático (si se configura con testigo).
- Replicación a nivel de base de datos, más simple que AGs.
- Menor complejidad que Always On AGs.
**Limitaciones:**
- Solo replica una base de datos a la vez.
- No permite acceso de solo lectura a la réplica.
- Descontinuado a partir de SQL Server 2016 (aunque aún funciona en versiones posteriores).
**Ideal para:** Aplicaciones que requieren alta disponibilidad de una base de datos específica y no necesitan acceso a la réplica.
 
### 🟡 **Log Shipping**

- **Propósito:** Recuperación ante desastres con replicación diferida.
- **Requiere:** Configuración manual entre servidores.
- **Funcionamiento:** Copia y restaura periódicamente los *logs de transacciones* desde el servidor principal al secundario.
- **Ventajas:**
  - Fácil de configurar.
  - No requiere clustering.
  - Buena opción para sitios remotos.
- **Limitaciones:**
  - No hay failover automático.
  - Hay pérdida de datos entre cada envío de log.
- **Ideal para:** Entornos donde se tolera cierto retraso en la recuperación y se busca simplicidad.

 

### 🧠 **Resumen comparativo**

| Característica                  | Always On AGs                  | Log Shipping                     |
|--------------------------------|--------------------------------|----------------------------------|
| Tipo de replicación            | Sincrónica / Asincrónica       | Asincrónica                      |
| Failover automático            | Sí                             | No                               |
| Requiere WSFC                  | Sí                             | No                               |
| Réplicas de solo lectura       | Sí                             | No                               |
| Configuración                  | Más compleja                   | Más sencilla                     |
| Pérdida de datos potencial     | Mínima                         | Puede haber entre envíos de log |
| Ideal para                     | Alta disponibilidad            | Recuperación ante desastres     |



## 👂 ¿Para qué sirve el Listener?

El Listener es crucial para la alta disponibilidad y la continuidad del negocio porque:

* **Abstracción de la Instancia Primaria:** Permite que las aplicaciones cliente se conecten a las bases de datos del Availability Group utilizando un **nombre de red virtual (VNN)** y una dirección IP virtual (VIP) fijos, en lugar de los nombres de instancia de SQL Server físicos.
* **Facilita el Failover (Conmutación por Error):** Cuando ocurre una conmutación por error y una réplica secundaria toma el rol de principal, el Listener **redirige automáticamente** las conexiones de los clientes a la nueva réplica principal. Esto significa que la cadena de conexión de la aplicación **no necesita ser modificada** después de un failover.
* **Enrutamiento de Conexiones:** El Listener se encarga de dirigir el tráfico:
    * Todas las conexiones de lectura/escritura (por defecto) se envían a la **réplica principal**.
    * Si se configura el **enrutamiento de solo lectura** (`read-only routing`), el Listener puede dirigir las conexiones con intención de solo lectura (`ApplicationIntent=ReadOnly`) a una de las **réplicas secundarias** configuradas para permitir lecturas.

En esencia, el Listener actúa como un **proxy** o un **intermediario** que garantiza que siempre puedas acceder a la base de datos, aunque el servidor subyacente que la aloja cambie debido a un evento de alta disponibilidad.
