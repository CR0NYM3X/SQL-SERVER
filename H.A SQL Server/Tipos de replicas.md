En **SQL Server**, existen varios tipos de **replicación** que puedes configurar, dependiendo de tus necesidades de disponibilidad, rendimiento y sincronización de datos. Aquí te explico los principales:

---

### 🔁 1. **Replicación transaccional**
- **Uso típico**: Distribuir datos en tiempo casi real desde una base de datos principal a una o varias secundarias.
- **Características**:
  - Alta velocidad.
  - Ideal para reportes o sistemas de solo lectura.
  - El suscriptor puede estar desfasado unos segundos.
- **Componentes**: Publicador, Distribuidor, Suscriptor.

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

### 🧠 4. **Grupos de disponibilidad Always On (Alta disponibilidad)**
- **Uso típico**: Alta disponibilidad y recuperación ante desastres.
- **Características**:
  - Réplicas sincronizadas o asincrónicas.
  - Permite conmutación por error automática.
  - Las réplicas secundarias pueden ser de solo lectura.
- **Requiere**: SQL Server Enterprise Edition y configuración de clúster de Windows.

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
