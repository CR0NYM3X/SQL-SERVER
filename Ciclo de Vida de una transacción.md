
# Flujo de una transacción (lectura/escritura) en SQL Server

Este repositorio documenta el **flujo completo** de una transacción de lectura o escritura en SQL Server, desde el envío de la consulta hasta su ejecución, persistencia y limpieza. Incluye un diagrama de flujo (Mermaid) y contenido estructurado listo para usar en GitHub.

> **Contenido**
> - Diagrama de flujo
> - Paso 1: Envío y revisión
> - Paso 2: Storage Engine (búsqueda de páginas)
> - Paso 3: Optimización
>   - Tareas principales del Optimizer
>   - Importancia
>   - Compilación del plan
>   - Plan Cache
>   - Ejemplos con `optimize for ad hoc workloads`
> - Paso 4: Ejecución
> - Paso 5: Limpieza y liberación
> - Scripts útiles



 
***

# 📚 Flujo completo de una transacción (lectura o escritura) en SQL Server

## ✅ Paso 1: Envío de la consulta y revisión

### 1.1 **Envío**

El cliente envía la consulta (`SELECT`, `UPDATE`, etc.) a SQL Server.

### 1.2 **Análisis sintáctico (Parser)**

*   SQL Server valida:
    *   **Sintaxis:** ¿Está bien escrito según las reglas SQL?  
        *Ejemplo:* ¿Falta un `FROM`? ¿Hay comillas mal cerradas?
    *   **Estructura básica:** ¿Las palabras clave están en orden correcto?
*   Si hay error de sintaxis → se devuelve al cliente.

### 1.3 **Parse Tree**
 Si la sintaxis es correcta, el parser convierte la consulta en un árbol lógico:
				   Representa la consulta como nodos y operadores (SELECT, JOIN, WHERE, etc.).
  *   Convierte el texto en un **árbol lógico**:
  ```
        SELECT
          └── FROM (Clientes)
                └── WHERE (Id = 10)
```
*   Este árbol es una estructura interna que describe **qué se quiere hacer**, no **cómo hacerlo**.

### 1.4 **Binding**
* Después del parser, SQL Server hace binding y Verifica
  * Que las tablas, columnas, funciones existan.
  * Comprueba permisos del usuario.
  * Resuelve nombres (por ejemplo, si hay alias).
  * Si algo no existe o no tienes permisos, falla aquí.

 

***

## ✅ Paso 2: Storage Engine – Buscar la página

*   SQL Server busca la página que contiene la fila:
    *   Si está en **buffer pool (memoria)** → la usa.
    *   Si no → la lee del disco (`.mdf` / `.ndf`) y la carga al buffer pool.

***

## ✅ Paso 3: Optimización (Query Optimizer)
El Query Optimizer genera un plan de ejecución 

### Tareas principales:

1.  **Analiza opciones:**
    *   ¿Índice o table scan?
    *   Tipo de join: `Nested Loop`, `Merge Join`, `Hash Join`.
    *   ¿Ordenar en memoria o usar `tempdb`?
    *   ¿Paralelizar la consulta?

2.  **Calcula costos:**
    *   Basado en estadísticas, cardinalidad, tamaño de tablas, selectividad.
    *   Incluye CPU, I/O y memoria.

3.  **Genera el plan físico:**
    *   Operadores: `Index Seek`, `Hash Match`, `Sort`, etc.
    *   Decide paralelismo (`MAXDOP`) según `cost threshold for parallelism`.

4.  **Optimiza para reutilización:**
    *   Si el plan existe en **plan cache**, lo reutiliza.
    * si so existe entonces lo compila y lo guarda en el plan cache, (aquí entra optimize for ad hoc workloads).

> Problema: si hay miles de consultas únicas que se ejecutan solo una vez, el plan cache se llena de planes completos inútiles → consumo excesivo de memoria.


### 🔍 Importancia

*   El Optimizer **no ejecuta la consulta**, solo decide la estrategia.
*   Una mala decisión (por estadísticas desactualizadas) puede causar:
    *   Table scans innecesarios.
    *   Uso excesivo de `tempdb`.
    *   Planes subóptimos → bajo rendimiento.

***

### Compilación del plan
Compilar el plan no significa lo mismo que compilar código C# o Java, pero sí implica un proceso interno importante.

*   Asigna recursos (memoria, estimación de datos).
*   Resuelve tipos: asegura que las columnas y parámetros tengan tipos correctos.
*   Genera estructuras internas → crea el plan ejecutable que el motor puede usar. **Execution Plan**.

### Guardar en el Plan Cache

*    El plan compilado se almacena en memoria para reutilización en futuras ejecuciones.

 

### Ejemplo práctico: `optimize for ad hoc workloads`

*   **OFF:**
    *   Primera ejecución: parsea, optimiza, compila y guarda el plan completo.
    *   Segunda ejecución: Si el texto es igual (o parametrizado) reutiliza el plan guardado en cache y es más rápido.

*   **ON:**
    *   Primera ejecución: guarda solo un **stub** (hash y metadatos).
    *   Segunda ejecución: compila y guarda el plan completo.
    *   Beneficio: reduce uso de memoria en entornos con consultas únicas.

> Beneficio:
       > Reduce el uso de memoria en el plan cache cuando hay muchas consultas únicas.
       > Mejora la eficiencia en entornos con aplicaciones que generan SQL dinámico o consultas ad hoc.

###   ¿Por qué es importante?

*  Compilar cuesta CPU:
    * Consultas complejas pueden tardar mucho en compilar.
*  Reutilización ahorra tiempo:
    * Si el plan está en cache, se evita todo este proceso.
*  Parámetros y recompilación:
    * Si cambian estadísticas o parámetros, puede forzar recompilación.
 
 

***


# Paso 4: Ejecución

**4.1 El Execution Engine ejecuta el plan:**
- Si necesita espacio temporal (sort, hash, spill), usa tempdb.

 

**4.2 Modificar en memoria:**
- La actualización se hace en la en memoria RAM (buffer pool).  
- Nunca modifica directamente en el disco duro.  
- Esa página queda marcada como *dirty page* (modificada, pendiente de escribir en disco).
 

**4.3 (WAL) - Registrar en el log (LDF):**
- Antes de confirmar la transaccion con COMMIT, SQL Server escribe el registro de la transacción en el log (LDF).  
- Esto cumple la regla **WAL (Write-Ahead Logging)**: el log se escribe antes que los data files (MDF/NDF).  
- Esto garantiza recuperación ante fallos.

 
**4.4 Confirmar al cliente:**
- Una vez que el log está en disco LDF, SQL Server responde que el COMMIT fue exitoso.  
- *Ojo:* en este momento, los datos NO están en el .mdf todavía, solo en memoria y en el log.

 
**4.5 Checkpoint (más tarde):**
- SQL Server escribe las *dirty pages* del buffer pool al disco (.mdf/.ndf).  
- Esto ocurre periódicamente, no en cada COMMIT.  
- Objetivo: reducir tiempo de recuperación y mantener consistencia.

**También se dispara el Checkpoint en eventos como:**
- BACKUP
- ALTER DATABASE
- Cambio de recovery model
- Detener la instancia

 
**4.6 Extra: Lazy Writer**
- No siempre se usa Checkpoint para escribir en disco, también se usa Lazy Writer que es un proceso en segundo plano que libera memoria:  
  - Si el buffer pool necesita espacio, el lazy writer toma páginas sucias y las escribe al disco.  
  - Esto ocurre fuera del checkpoint, cuando hay presión de memoria.

 

# Paso 5: Limpieza y liberación

- Si hubo spills, tempdb limpia sus estructuras al terminar la consulta.  
- El plan puede quedar en cache para reutilización.

 ---

### 📌 **Resumen visual**

    Cliente → Parser → Binding → Optimizer → Plan Cache → Execution Engine → Buffer Pool → Log (LDF) → Checkpoint → Disco (MDF/NDF)
 
