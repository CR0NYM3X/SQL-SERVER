### ✅ **Migración directa con BACKUP/RESTORE o DETACH/ATTACH**
- **Regla general:** SQL Server **solo permite restaurar backups desde la versión inmediatamente anterior** (o algunas anteriores) hacia una versión más nueva, nunca hacia una más vieja.
- **Compatibilidad:**
  - **SQL Server 2012 → 2014 → 2016 → 2017 → 2019 → 2022**  
    ✔ Puedes restaurar backups o hacer attach sin problemas.
  - **SQL Server 2008 / 2008 R2 → 2012 → 2014 → 2016**  
    ✔ Necesitas pasar por una versión intermedia (no puedes saltar directo a 2019/2022 sin probar).
  - **SQL Server 2005 o anterior**  
    ❌ No puedes restaurar directo en versiones modernas. Debes migrar primero a 2008 o 2012.

**Importante:**  
- Después de restaurar, ajusta el **compatibility level** para aprovechar nuevas funciones.
- No existe downgrade (no puedes restaurar un backup de 2019 en 2016).
