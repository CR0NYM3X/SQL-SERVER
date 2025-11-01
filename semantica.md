## ⚙️ 2. Modelo de concurrencia

### 🔸 PostgreSQL:

Usa **MVCC (Multi-Version Concurrency Control)**. Cada transacción ve una versión consistente de los datos. Las escrituras no bloquean lecturas.

### 🔸 SQL Server:

SQL Server **no usa MVCC puro**, sino un modelo basado en **locking y latching**, aunque desde SQL Server 2005 incluye **Snapshot Isolation** que simula MVCC usando **versionado de filas** en *tempdb*.

#### Modos de aislamiento en SQL Server:

*   Read Committed (por defecto)
*   Read Committed Snapshot (activa versionado)
*   Snapshot Isolation (requiere configuración)
*   Repeatable Read
*   Serializable

> 📌 **Nota**: El versionado en SQL Server no es automático como en PostgreSQL. Hay que activarlo explícitamente.

***


## 💾 3. Lectura desde disco y memoria

### 🔸 PostgreSQL:

Lee desde disco si no está en el buffer pool. Si hay espacio, se cachea.

### 🔸 SQL Server:

Usa el **Buffer Pool** para cachear páginas de datos. Si una página no está en memoria, se lee desde disco y se guarda en el buffer pool.

*   Las lecturas son **por página de 8 KB**
*   Usa **Lazy Writer** para liberar memoria
*   Usa **Read-Ahead** para anticipar lecturas

***

## ✍️ 4. Escritura y recuperación

### 🔸 PostgreSQL:

*   Escribe en **WAL (Write Ahead Log)** y en **buffer pool**
*   El checkpoint escribe los buffers al disco

### 🔸 SQL Server:

*   Escribe primero en el **Log de transacciones** (similar al WAL)
*   Luego en el **Buffer Pool**
*   El **Checkpoint** escribe páginas modificadas al disco

#### Componentes clave:

*   **Transaction Log**: Registro secuencial de operaciones
*   **Buffer Pool**: Memoria RAM con páginas modificadas
*   **Checkpoint**: Evento que fuerza escritura de páginas sucias al disco
*   **Lazy Writer**: Libera páginas del buffer pool cuando hay presión de memoria

***

## 🔁 5. Checkpoints

### 🔸 PostgreSQL:

Checkpoints periódicos o forzados. Escriben buffers al disco y sincronizan WAL.

### 🔸 SQL Server:

Checkpoints automáticos, indirectos o manuales. Escriben páginas sucias al disco y marcan el punto de recuperación en el log.

> 📌 SQL Server tiene más tipos de checkpoint:

*   **Automatic**
*   **Indirect**
*   **Manual**
*   **Internal**




## 🚫 7. Cuándo no usar ciertas configuraciones

*   No usar **Snapshot Isolation** en SQL Server sin entender el impacto en *tempdb*.
*   No usar **Read Committed Snapshot** si se requiere bloqueo explícito.

## 📌 9. Consideraciones antes y después

*   Activar **Snapshot Isolation** requiere configuración en la base de datos.
*   El tamaño del **Transaction Log** debe ser monitoreado para evitar crecimiento excesivo.
*   El rendimiento de *tempdb* afecta directamente al versionado en SQL Server.
