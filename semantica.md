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



---


### ✅ **Escenario en PostgreSQL**
- **PC1**:  
  - `BEGIN;`  
  - `UPDATE clientes SET ... WHERE id = 1;`  
  - No hace `COMMIT` ni `ROLLBACK`.  
  - Resultado: PostgreSQL coloca un **bloqueo exclusivo (row-level lock)** sobre la fila `id = 1` en la tabla `clientes`.

- **PC2**:  
  - `BEGIN;`  
  - `SELECT * FROM clientes WHERE id = 1;`  
    - Este `SELECT` se ejecuta sin problema porque PostgreSQL permite lectura bajo **MVCC (Multi-Version Concurrency Control)**. PC2 ve el estado **antes del UPDATE** (snapshot consistente).
  - `UPDATE clientes SET ... WHERE id = 1;`  
    - Aquí PC2 **queda bloqueado** esperando que PC1 libere el lock (es decir, que haga `COMMIT` o `ROLLBACK`).  
    - Si PC1 tarda mucho, PC2 puede entrar en **deadlock detection** o timeout según configuración (`lock_timeout`).

**Conclusión en PostgreSQL:**  
- Lecturas no bloquean escrituras gracias a MVCC.  
- Escrituras sobre la misma fila sí se bloquean (espera activa).  
- No hay lectura sucia, porque PC2 nunca ve el cambio no confirmado.



### ✅ **Escenario en SQL Server**
- **PC1**:  
  - `BEGIN TRAN;`  
  - `UPDATE clientes SET ... WHERE id = 1;`  
  - No hace `COMMIT`.  
  - Resultado: SQL Server coloca un **lock exclusivo** sobre la fila (o página, según configuración).

- **PC2**:  
  - `BEGIN TRAN;`  
  - `SELECT * FROM clientes WHERE id = 1;`  
    - Aquí depende del **nivel de aislamiento**:
      - **READ COMMITTED (por defecto)**: PC2 **espera** porque el SELECT no puede leer la fila bloqueada por PC1.
      - **READ UNCOMMITTED**: PC2 lee el valor actualizado aunque no esté confirmado (**lectura sucia**).
      - **SNAPSHOT**: PC2 ve la versión anterior (similar a MVCC).
  - `UPDATE clientes SET ... WHERE id = 1;`  
    - Igual que PostgreSQL: PC2 queda bloqueado hasta que PC1 libere el lock.

**Conclusión en SQL Server:**  
- Por defecto, incluso el SELECT se bloquea (espera) porque no hay MVCC nativo como en PostgreSQL.  
- Si habilitas **READ UNCOMMITTED** o **NOLOCK**, puedes leer datos no confirmados (riesgo de inconsistencias).  
- Con **SNAPSHOT ISOLATION**, el comportamiento se parece a PostgreSQL.


#### 🔍 Diferencia clave:
- **PostgreSQL**: MVCC → SELECT nunca se bloquea, pero UPDATE sí espera.
- **SQL Server**: Por defecto SELECT también espera (bloqueo compartido/exclusivo), salvo que uses SNAPSHOT o NOLOCK.


---
---

### ✅ **Escenario explicado**
- **Cuenta inicial:** \$1000.
- **Celular 1:** inicia transferencia de \$1000 → transacción queda “pendiente” (no confirmada).
- **Celular 2:** ve el saldo (según la lógica de la app) y también intenta gastar los mismos \$1000 en una compra.

**Problema:**  
Si el sistema no maneja bien el aislamiento, ambos procesos podrían **comprometer el mismo saldo**, generando sobregiro o fraude.


### 🔍 **Qué pasa según el motor y aislamiento**
- **PostgreSQL (READ COMMITTED por defecto):**
  - Cada instrucción ve el estado confirmado al inicio de la instrucción.
  - Si la app no bloquea la fila, el segundo celular podría leer \$1000 y permitir la compra.
  - Cuando ambas transacciones intenten confirmar, una fallará por **conflicto de actualización** (UPDATE sobre la misma fila).
  - Resultado: **no hay doble gasto**, pero puede haber mala experiencia (una operación rechazada al final).

- **SQL Server (READ COMMITTED por defecto):**
  - El SELECT del segundo celular podría quedar bloqueado si la primera transacción tiene lock exclusivo.
  - Esto evita que el segundo celular vea el saldo hasta que la primera transacción termine.
  - Resultado: **más seguro**, pero menos concurrente.



### ✅ **Riesgo real**
Si la lógica de la aplicación **no espera confirmación** y autoriza la compra solo por el saldo leído, el fraude ocurre **en la capa de negocio**, no en la base de datos.  
Por eso, **el aislamiento por sí solo no basta**: se necesita **control transaccional + lógica de negocio**.

 

 

### ✅ ¿Puede el cliente lograr el fraude con **READ COMMITTED** en PostgreSQL y SQL Server?

**Respuesta corta:**  
**No**, el fraude no se concreta a nivel de base de datos, pero **sí puede parecer que ocurre en la capa de aplicación** si la lógica está mal diseñada.

 

### 🔍 **Por qué NO ocurre el fraude en la base de datos**
- **PostgreSQL (READ COMMITTED):**
  - Cada instrucción ve datos confirmados al inicio de la instrucción.
  - Si Celular 1 hace `UPDATE saldo = saldo - 1000` y no confirma, Celular 2 lee el saldo anterior (\$1000) porque MVCC permite lecturas sin bloqueo.
  - Cuando Celular 2 intenta hacer `UPDATE saldo = saldo - 1000`, queda bloqueado esperando que Celular 1 termine.
  - Resultado: **una transacción se completa, la otra falla** (por deadlock o por falta de saldo).

- **SQL Server (READ COMMITTED):**
  - Celular 1 bloquea la fila con lock exclusivo.
  - Celular 2 no puede leer el saldo (queda esperando) hasta que Celular 1 termine.
  - Resultado: **más seguro**, porque ni siquiera puede ver el saldo.

 

### ⚠️ **Dónde está el riesgo real**
Si la **aplicación autoriza la compra solo por el saldo leído**, sin esperar confirmación de la transacción, entonces:
- El segundo celular podría iniciar la compra y el sistema externo (pasarela de pago) la procesa.
- Después, la base de datos rechaza la operación, pero el pago ya se autorizó.
- Esto no es un problema del aislamiento, sino de la **lógica de negocio y la integración con sistemas externos**.

 
### ✅ **Cómo evitar el fraude**
- **Nivel SERIALIZABLE** o **SELECT ... FOR UPDATE** en operaciones críticas.
- **Transacciones atómicas**: débito y crédito en la misma transacción.
- **Validación final antes de confirmar**: verificar saldo actualizado.
- **Bloqueo lógico en la aplicación**: marcar la cuenta como “en operación” para evitar concurrencia.



### 🔐 **Niveles de aislamiento recomendados para evitar fraudes**
1. **SERIALIZABLE**  
   - Garantiza que las transacciones se ejecuten como si fueran secuenciales.
   - Evita lecturas inconsistentes y doble gasto.
   - Más seguro, pero menos escalable.

2. **REPEATABLE READ**  
   - Evita que otra transacción cambie la fila mientras la primera lee.
   - Reduce riesgo, pero no tan estricto como SERIALIZABLE.

3. **Bloqueos explícitos (SELECT ... FOR UPDATE)**  
   - Cuando se consulta el saldo, se bloquea la fila hasta confirmar la operación.

4. **Optimistic Concurrency + Validación en la app**  
   - Leer saldo, intentar operación, y antes de confirmar verificar que el saldo sigue disponible.
   - Si no, abortar.

 
### ✅ **Mejor práctica en bancos**
- **Transacción atómica:** débito y crédito en la misma transacción.
- **Bloqueo de fila:** al iniciar la operación, bloquear el registro de la cuenta.
- **Nivel SERIALIZABLE o FOR UPDATE** para operaciones críticas.
- **Validación en la capa de negocio**: nunca confiar solo en el saldo leído.
