### 🧪 Requisitos clave

- Windows Server Standard o Datacenter (con soporte para clustering).
- SQL Server Enterprise Edition (para múltiples réplicas sincronizadas).
- Red confiable entre los nodos.
- DNS y Active Directory correctamente configurados.
- Firewall configurado para permitir puertos de clúster y SQL Server (ej. 1433, 5022).
 

### ⚠️ Consideraciones clave

- Todos los nodos deben estar en el mismo **Windows Failover Cluster**.
- Las bases deben estar en modo **FULL recovery**.
- Se requiere **SQL Server Enterprise Edition** para múltiples réplicas sincronizadas.
- El **quorum** debe estar bien configurado para evitar pérdida de servicio.
 
 



### 🛡️ Infraestructura robusta recomendada

Para alta disponibilidad y tolerancia a fallos, se recomienda:

- **2 o más réplicas secundarias** (una local y otra en sitio remoto).
- **1 nodo de quorum** (puede ser un File Share Witness).
- **Red redundante** (dos interfaces de red por nodo).
- **Almacenamiento rápido y replicado** (preferiblemente SSD o NVMe).
- **Monitoreo y alertas** (con herramientas como SCOM, Zabbix, o Prometheus).

 
### 🧪 Ejemplo de arquitectura robusta

```plaintext
[ Cliente ]
    |
[ Load Balancer (opcional) ]
    |
[ Nodo 1 - SQL Server Primary ]
    |
[ Nodo 2 - SQL Server Secondary (sincronizado, solo lectura) ]
    |
[ Nodo 3 - SQL Server Secondary (asíncrono, en sitio remoto) ]
    |
[ Nodo 4 - File Share Witness / Quorum ]
```


### 📌 Detalles clave:

- **WSFC se instala en los nodos 1, 2 y opcionalmente en el 3** si quieres que el nodo remoto participe en el clúster (por ejemplo, para failover manual o monitoreo).
- **Nodo 4** solo necesita tener una carpeta compartida accesible por los nodos del clúster. No requiere instalación de WSFC.
- El **quorum** se configura desde el **Administrador de clústeres de conmutación por error**, y se recomienda usar **File Share Witness** en clústeres con número par de nodos (como este).


### 🧠 Roles en detalle

 
#### 🔵 **Nodo 1 – Réplica primaria (activo)**

| Característica | Detalle |
|----------------|--------|
| **Sincronización** | Envía datos en tiempo real a las réplicas secundarias. |
| **Ubicación** | Sitio principal o nodo activo del clúster. |
| **Modo de acceso** | Lectura y escritura (acepta todas las operaciones DML y DDL). |
| **Rol en HA** | Nodo principal del grupo de disponibilidad. En caso de falla, otro nodo puede asumir su rol si hay failover automático configurado. |
| **Ventaja** | Punto central de operaciones. Garantiza consistencia y disponibilidad de datos. |

✅ **Ideal para**:  
- Aplicaciones críticas de negocio  
- Operaciones de escritura intensiva  
- Procesamiento de transacciones  
- Alta disponibilidad y recuperación ante desastres  

 

#### 🟢 **Nodo 2 – Réplica secundaria sincronizada (solo lectura)**

| Característica | Detalle |
|----------------|--------|
| **Sincronización** | En tiempo real con el nodo primario.  Reciben datos desde el nodo primario. |
| **Ubicación** | Mismo sitio o red local que el primario. |
| **Modo de acceso** | Solo lectura (ideal para reportes, BI, consultas pesadas). |
| **Rol en HA** | Puede asumir el rol de primario automáticamente si el nodo 1 falla (failover automático). |
| **Ventaja** | Reduce carga en el nodo principal y mejora rendimiento general. |

✅ **Ideal para**:  
- Consultas analíticas  
- Reportes  
- Balanceo de carga de lectura  
- Alta disponibilidad local

 

#### 🟡 **Nodo 3 – Réplica secundaria asíncrona (sitio remoto)**

| Característica | Detalle |
|----------------|--------|
| **Sincronización** | No en tiempo real (puede haber retraso). |
| **Ubicación** | Sitio remoto (otra ciudad, región o datacenter). |
| **Modo de acceso** | Puede ser solo lectura o sin acceso directo. |
| **Rol en DR** | Actúa como respaldo en caso de desastre total en el sitio principal. |
| **Failover** | Solo **manual**, no automático. |

✅ **Ideal para**:  
- Recuperación ante desastres (Disaster Recovery)  
- Protección geográfica  
- Continuidad del negocio



 
#### 🟣 **Nodo 4 – File Share Witness / Quorum**
Es un archivo compartido en red que actúa como voto adicional en un clúster de alta disponibilidad (WSFC).
Su función principal es ayudar a mantener el quorum, especialmente cuando hay un número par de nodos.

| Característica | Detalle |
|----------------|--------|
| **Función principal** | Actúa como testigo para ayudar al clúster a determinar si hay mayoría (quorum) en caso de fallos. |
| **Ubicación** | Carpeta compartida en un servidor accesible por todos los nodos del clúster. No necesita SQL Server instalado. |
| **Modo de acceso** | Solo lectura/escritura por parte del clúster de Windows (no por usuarios ni aplicaciones). |
| **Rol en HA** | Ayuda a evitar el “split-brain” y permite que el clúster tome decisiones de failover correctamente. |
| **Ventaja** | Mejora la tolerancia a fallos y permite mantener el quorum con un número impar de nodos. |



✅ **Ideal para**:  
- Clústeres con número par de nodos  
- Escenarios donde se necesita alta disponibilidad sin perder quorum  
- Ambientes distribuidos donde no todos los nodos están en el mismo sitio físico  
- Evita que el clúster se apague si un nodo falla.
- Permite que el clúster tome decisiones correctas de failover.
- Mejora la tolerancia a fallos sin necesidad de agregar más servidores.

### ⚠️ ¿Por qué es importante el File Share Witness?

En un clúster de solo 2 nodos, **no se puede alcanzar quorum si uno falla**, a menos que haya un **tercer voto**. Por eso se recomienda agregar un **File Share Witness**, que es simplemente una carpeta compartida en otro servidor o equipo de red confiable.

- **Sin FSW**: Si un nodo falla, el clúster no puede decidir quién debe ser el nuevo primario.
- **Con FSW**: El nodo restante puede mantener el servicio activo.

---
---
---

En **SQL Server**, existen varios tipos de **replicación** que puedes configurar, dependiendo de tus necesidades de disponibilidad, rendimiento y sincronización de datos. Aquí te explico los principales:

 
 
 
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
- **Uso típico:** Escenarios donde se necesita compartir datos con otras aplicaciones o sitios remotos, no tanto para alta disponibilidad. Bases críticas que deben estar actualizadas casi al instante.


### **1. Snapshot Publication**
- **Cómo funciona:**  
  Toma una **instantánea completa** de los datos en un momento específico y la envía al suscriptor.
- **Características:**
  - No mantiene sincronización continua.
  - Se vuelve a generar la instantánea cuando se necesita actualizar.
- **Ventajas:**
  - Fácil de configurar.
  - Útil para datos que cambian poco.
- **Desventajas:**
  - Puede ser pesado si la base es grande.
- **Ideal para:**  
  Datos estáticos o que no requieren actualización frecuente.

 

 

### **3. Peer-to-Peer Publication**
- **Cómo funciona:**  
  Es una extensión de la replicación transaccional, pero **todos los nodos son iguales** (no hay publicador único).
- **Características:**
  - Cada nodo puede publicar y suscribirse.
  - Sincronización bidireccional.
- **Ventajas:**
  - Alta disponibilidad y escalabilidad.
- **Desventajas:**
  - Complejo de administrar.
- **Ideal para:**  
  Entornos distribuidos donde varias instancias deben tener los mismos datos.

 

### **4. Merge Publication**
- **Cómo funciona:**  
  Permite que **publicador y suscriptor hagan cambios** y luego los combina (merge).
- **Características:**
  - Usa triggers y tablas de seguimiento para detectar cambios.
- **Ventajas:**
  - Ideal para entornos desconectados (offline).
- **Desventajas:**
  - Conflictos si ambos modifican el mismo dato.
- **Ideal para:**  
  Aplicaciones móviles o sucursales que trabajan offline y luego sincronizan.

---

## 👂 ¿Para qué sirve el Listener?

El Listener es crucial para la alta disponibilidad y la continuidad del negocio porque:

* **Abstracción de la Instancia Primaria:** Permite que las aplicaciones cliente se conecten a las bases de datos del Availability Group utilizando un **nombre de red virtual (VNN)** y una dirección IP virtual (VIP) fijos, en lugar de los nombres de instancia de SQL Server físicos.
* **Facilita el Failover (Conmutación por Error):** Cuando ocurre una conmutación por error y una réplica secundaria toma el rol de principal, el Listener **redirige automáticamente** las conexiones de los clientes a la nueva réplica principal. Esto significa que la cadena de conexión de la aplicación **no necesita ser modificada** después de un failover.
* **Enrutamiento de Conexiones:** El Listener se encarga de dirigir el tráfico:
    * Todas las conexiones de lectura/escritura (por defecto) se envían a la **réplica principal**.
    * Si se configura el **enrutamiento de solo lectura** (`read-only routing`), el Listener puede dirigir las conexiones con intención de solo lectura (`ApplicationIntent=ReadOnly`) a una de las **réplicas secundarias** configuradas para permitir lecturas.

En esencia, el Listener actúa como un **proxy** o un **intermediario** que garantiza que siempre puedas acceder a la base de datos, aunque el servidor subyacente que la aloja cambie debido a un evento de alta disponibilidad.
