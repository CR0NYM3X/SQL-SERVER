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

### 🧩 5. **Log Shipping**
- **Uso típico**: Copia de seguridad de logs y restauración en otro servidor.
- **Características**:
  - No es una replicación en tiempo real.
  - Puede haber desfase significativo.
- **Ideal para**: Recuperación ante desastres con bajo costo.
