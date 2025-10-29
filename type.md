## ✅ **1. Numéricos Exactos**
| Tipo       | Tamaño | Rango mínimo | Rango máximo | Uso |
|------------|--------|-------------|-------------|------|
| **BIT**    | 1 bit | 0 | 1 | Valores booleanos (sí/no). |
| **TINYINT**| 1 byte| 0 | 255 | Contadores pequeños (edad, días). |
| **SMALLINT**| 2 bytes| -32,768 | 32,767 | Cantidades pequeñas. |
| **INT**    | 4 bytes| -2,147,483,648 | 2,147,483,647 | Identificadores, contadores. |
| **BIGINT** | 8 bytes| -9,223,372,036,854,775,808 | 9,223,372,036,854,775,807 | IDs grandes, cálculos masivos. |
| **DECIMAL(p,s)** / **NUMERIC(p,s)** | 5-17 bytes | -10^38+1 | 10^38-1 | Valores exactos con decimales (finanzas). |
| **MONEY**  | 8 bytes| -922,337,203,685,477.5808 | 922,337,203,685,477.5807 | Valores monetarios grandes. |
| **SMALLMONEY**| 4 bytes| -214,748.3648 | 214,748.3647 | Valores monetarios pequeños. |

 
## ✅ **2. Numéricos Aproximados**
| Tipo       | Tamaño | Rango aproximado | Uso |
|------------|--------|-------------------|------|
| **FLOAT(n)**| 4-8 bytes| ±1.79E+308 | Valores científicos, cálculos aproximados. |
| **REAL**   | 4 bytes| ±3.40E+38 | Similar a FLOAT(24), menos precisión. |
 

## ✅ **3. Fecha y Hora**
| Tipo       | Tamaño | Rango | Uso |
|------------|--------|-------|------|
| **DATE**   | 3 bytes| 0001-01-01 a 9999-12-31 | Fechas sin hora. |
| **DATETIME**| 8 bytes| 1753-01-01 a 9999-12-31 | Fecha y hora (precisión 3 ms). |
| **DATETIME2**| 6-8 bytes| 0001-01-01 a 9999-12-31 | Fecha y hora con más precisión. |
| **SMALLDATETIME**| 4 bytes| 1900-01-01 a 2079-06-06 | Fecha y hora menos precisa. |
| **TIME**   | 3-5 bytes| 00:00:00 a 23:59:59.9999999 | Hora sin fecha. |
| **DATETIMEOFFSET**| 8-10 bytes| Igual que DATETIME2 + zona horaria | Fechas con zona horaria. |
 

## ✅ **4. Cadenas de Caracteres**
**No Unicode**
| Tipo       | Tamaño | Rango | Uso |
|------------|--------|-------|------|
| **CHAR(n)**| n bytes| 1 a 8000 | Texto fijo (códigos). |
| **VARCHAR(n)**| n bytes| 1 a 8000 | Texto variable (nombres, descripciones). |
| **VARCHAR(MAX)**| Hasta 2 GB | Texto muy largo (documentos). |

**Unicode**
| Tipo       | Tamaño | Rango | Uso |
|------------|--------|-------|------|
| **NCHAR(n)**| 2n bytes| 1 a 4000 | Texto fijo Unicode. |
| **NVARCHAR(n)**| 2n bytes| 1 a 4000 | Texto variable Unicode. |
| **NVARCHAR(MAX)**| Hasta 2 GB | Texto Unicode largo. |

 

## ✅ **5. Binarios**
| Tipo       | Tamaño | Uso |
|------------|--------|------|
| **BINARY(n)**| n bytes| Datos binarios fijos. |
| **VARBINARY(n)**| n bytes| Datos binarios variables. |
| **VARBINARY(MAX)**| Hasta 2 GB | Archivos, imágenes. |
| **IMAGE** | Obsoleto | Datos binarios grandes. |

 
## ✅ **6. Otros**
| Tipo       | Uso |
|------------|------|
| **XML**    | Almacena datos XML. |
| **JSON**   | Almacena datos JSON (en NVARCHAR). |
| **UNIQUEIDENTIFIER** | GUID (identificadores únicos). |
| **SQL_VARIANT** | Valores de distintos tipos en una columna. |
