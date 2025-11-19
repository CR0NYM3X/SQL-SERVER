## ✅ Validación y Explicación Detallada de GPOs para SQL Server de Alto Rendimiento

### 1. 🔋 Políticas de Energía

**Ruta:** `Computer Configuration → Policies → Administrative Templates → System → Power Management`
- **Turn off hard disk after**:  
  Permite ahorrar energía apagando el disco físico tras un periodo de inactividad. Establecer en 0 minutos (nunca apagar) para servidores críticos, especialmente bases de datos

- **High Performance Power Scheme – ESENCIAL:**  
  ✔️ **Verificado.** Microsoft y expertos como Pinal Dave recomiendan cambiar el plan de energía a "Alto rendimiento" para evitar que el sistema reduzca la frecuencia del CPU, lo cual puede afectar negativamente el rendimiento de SQL Server.  
  Fuente: [Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/)

- **Deshabilitar suspensión de disco y CPU:**  
  ✔️ **Recomendado.** Evita que el sistema entre en estados de bajo consumo que pueden afectar la latencia de respuesta del servidor.

- **Prevenir hibernación:**  
  ✔️ **Recomendado.** La hibernación puede interferir con la disponibilidad continua de SQL Server.

---

### 2. 🧠 Configuración de Memoria y Paginación

**Ruta:** `Computer Configuration → Policies → Administrative Templates → System`

- **Lock Pages in Memory (LPIM):**  
  ✔️ **Verificado.** Esta política evita que Windows pagine a disco la memoria asignada a SQL Server, mejorando la estabilidad bajo presión de memoria. Se configura en `User Rights Assignment → Lock pages in memory`.  
  Fuente: [Microsoft Docs](https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/enable-the-lock-pages-in-memory-option-windows?view=sql-server-ver17)

- **Large System Cache:**  
  ⚠️ **Deprecado en versiones modernas.** Esta opción era útil en versiones antiguas de Windows Server, pero en versiones recientes ya no tiene efecto.

- **Archivo de paginación estático:**  
  ✔️ **Recomendado.** Un tamaño fijo evita la fragmentación y mejora la estabilidad del sistema.

---

### 3. 🌐 Optimizaciones de Red

**Ruta:** `Computer Configuration → Policies → Administrative Templates → Network → QoS Packet Scheduler`

- **Limit reservable bandwidth = 0%:**  
  ✔️ **Recomendado.** Por defecto, Windows reserva hasta un 20% del ancho de banda para tareas del sistema. Establecerlo en 0% libera ese ancho de banda para SQL Server.

- **TCP Chimney Offload / Receive Side Scaling (RSS):**  
  ✔️ **Condicional.** Estas opciones pueden mejorar el rendimiento si el hardware lo soporta. Se deben probar antes de habilitarse en producción.  
  Fuente: [Microsoft Performance Tuning Guidelines](https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/)

---

### 4. 📁 Sistema de Archivos

**Ruta:** `Computer Configuration → Policies → Administrative Templates → System → Filesystem`

- **Disable Last Access Timestamp:**  
  ✔️ **Verificado.** Desactivar la actualización del timestamp de último acceso (`NtfsDisableLastAccessUpdate`) mejora el rendimiento de disco, especialmente en sistemas con muchas operaciones de lectura.  
  Fuente: [Microsoft Docs](https://www.thewindowsclub.com/enable-or-disable-ntfs-last-access-time-stamp-updates)

- **NTFS Memory Usage:**  
  ✔️ **Recomendado.** Ajustar el uso de memoria para NTFS puede mejorar el rendimiento en servidores de archivos, aunque su impacto en SQL Server es limitado.

---

### 5. 🧮 Procesador y Programación

**Ruta:** `Computer Configuration → Policies → Administrative Templates → System`

- **Processor Scheduling – Priorizar programas en segundo plano:**  
  ✔️ **Recomendado.** SQL Server se ejecuta como servicio, por lo que priorizar procesos en segundo plano puede mejorar su rendimiento.

- **NUMA Awareness / Processor Affinity:**  
  ✔️ **Avanzado.** En servidores con múltiples sockets/NUMA, configurar afinidad puede mejorar el rendimiento, pero requiere pruebas cuidadosas.  
  Fuente: [Microsoft Performance Center](https://learn.microsoft.com/en-us/sql/relational-databases/performance/performance-center-for-sql-server-database-engine-and-azure-sql-database?view=sql-server-ver17)

---

### 6. 🔐 Seguridad y Auditoría

**Ruta:** `Computer Configuration → Policies → Windows Settings → Security Settings`

- **Audit Policies – No sobre-auditar:**  
  ✔️ **Recomendado.** Activar demasiadas auditorías puede generar sobrecarga en el sistema.

- **Event Log Sizes – Aumentar tamaño mínimo:**  
  ✔️ **Recomendado.** Evita pérdida de eventos importantes y reduce la frecuencia de escritura.

- **User Rights Assignment – Revisar privilegios del servicio SQL:**  
  ✔️ **Verificado.** Asegura que el servicio de SQL Server tenga los privilegios mínimos necesarios, incluyendo `SeLockMemoryPrivilege`, `SeServiceLogonRight`, etc.  
  Fuente: [Microsoft Q&A](https://learn.microsoft.com/en-us/answers/questions/938104/group-policy-settings-for-database-service-account)

---

### 7. 🧹 Servicios de Windows

**Ruta:** `Computer Configuration → Policies → Windows Settings → Security Settings → System Services`

- **Deshabilitar servicios innecesarios:**  
  ✔️ **Recomendado.** Servicios como `Windows Search`, `Print Spooler`, `Themes`, etc., consumen recursos innecesarios en servidores SQL.

---

### 8. ⚙️ Configuración de SQL Server vía GPO

**Ruta:** `Computer Configuration → Preferences → Windows Settings → Registry`

- **Max Degree of Parallelism / Cost Threshold for Parallelism / Max Server Memory:**  
  ✔️ **Verificado.** Estas configuraciones son clave para el rendimiento y pueden establecerse vía GPO modificando el registro.  
  Fuente: [Microsoft Docs - Server Memory Options](https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/server-memory-server-configuration-options?view=sql-server-ver17)

---

### 🚨 Consideraciones de Seguridad

- **Evitar cifrado innecesario:**  
  ✔️ **Recomendado.** El cifrado en reposo puede impactar el rendimiento si no se requiere por cumplimiento.

- **Evitar tracing excesivo:**  
  ✔️ **Recomendado.** Solo habilitar trazas cuando sea necesario.

- **Excluir archivos `.mdf`, `.ldf`, `.ndf` del antivirus:**  
  ✔️ **Verificado.** Mejora el rendimiento y evita bloqueos.  
  Fuente: https://learn.microsoft.com/en-us/sql/sql-server/install/antivirus-exclusions-for-sql-server

---

### 🛠 Herramientas de Análisis

- `gpresult /h report.html`  
- `Get-GPResultantSetOfPolicy -ReportType Html -Path C:\report.html`  
- `gpresult /z > policy_details.txt`  
✔️ **Verificado.** Herramientas estándar para verificar GPOs aplicadas.

---

### 📌 Recomendaciones Finales

1. Crear una **OU específica** para servidores SQL.
2. Aplicar una **GPO dedicada** con configuraciones optimizadas.
3. **Documentar desviaciones** de políticas estándar.
4. **Monitorear el impacto** de cada cambio.
