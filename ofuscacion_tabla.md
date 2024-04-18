
# Ejemplos de Ofuscación en una tabla: 


### Crear tabla Empleados de prueba:

```SQL
CREATE TABLE [dbo].[Empleados](
	[IDEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](100) NULL,
	[ApellidoPaterno] [nvarchar](50) NULL,
	[ApellidoMaterno] [nvarchar](50) NULL,
	[Telefono] [nvarchar](20) NULL,
	[TarjetaCredito] [nvarchar](20) NULL,
	[Correo] [nvarchar](100) NULL,
	[NumeroSeguroSocial] [nvarchar](20) NULL,
	[sueldo] [decimal](10, 2) NULL,

) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Empleados_ofuscado](
	[IDEmpleado] [int] NOT NULL,
	[Nombre] [nvarchar](100) NULL,
	[ApellidoPaterno] [nvarchar](50) NULL,
	[ApellidoMaterno] [nvarchar](50) NULL,
	[Telefono] [nvarchar](20) NULL,
	[TarjetaCredito] [nvarchar](20) NULL,
	[Correo] [nvarchar](100) NULL,
	[NumeroSeguroSocial] [nvarchar](20) NULL,
	[sueldo] [decimal](10, 2) NULL,

) ON [PRIMARY]
GO


```
### Insertar Información 

```SQL
-- Inserts adicionales para agregar 50 registros a la tabla Empleados
INSERT INTO Empleados (Nombre, ApellidoPaterno, ApellidoMaterno, Telefono, TarjetaCredito, Correo, NumeroSeguroSocial)
VALUES 
('Alejandro', 'Gutiérrez', 'Hernández', '111-222-3333', '1111-2222-3333-4444', 'alejandro.gutierrez@example.com', '111-22-3333'),
('Fernanda', 'Sánchez', 'Martínez', '444-555-6666', '4444-5555-6666-7777', 'fernanda.sanchez@example.com', '444-55-6666'),
('Javier', 'Díaz', 'González', '777-888-9999', '7777-8888-9999-0000', 'javier.diaz@example.com', '777-88-9999'),
('Paola', 'Torres', 'López', '222-333-4444', '2222-3333-4444-5555', 'paola.torres@example.com', '222-33-4444'),
('Roberto', 'García', 'Fernández', '555-666-7777', '5555-6666-7777-8888', 'roberto.garcia@example.com', '555-66-7777'),
('Verónica', 'Rodríguez', 'Pérez', '888-999-0000', '8888-9999-0000-1111', 'veronica.rodriguez@example.com', '888-99-0000'),
('Sergio', 'Hernández', 'Gómez', '333-444-5555', '3333-4444-5555-6666', 'sergio.hernandez@example.com', '333-44-5555'),
('Ana', 'Martínez', 'Sánchez', '666-777-8888', '6666-7777-8888-9999', 'ana.martinez@example.com', '666-77-8888'),
('Daniel', 'López', 'Martínez', '999-000-1111', '9999-0000-1111-2222', 'daniel.lopez@example.com', '999-00-1111'),
('Marisol', 'Pérez', 'González', '444-555-6666', '4444-5555-6666-7777', 'marisol.perez@example.com', '444-55-6666'),
('Ricardo', 'González', 'Fernández', '777-888-9999', '7777-8888-9999-0000', 'ricardo.gonzalez@example.com', '777-88-9999'),
('Paulina', 'Sánchez', 'López', '222-333-4444', '2222-3333-4444-5555', 'paulina.sanchez@example.com', '222-33-4444'),
('Gerardo', 'Hernández', 'Martínez', '555-666-7777', '5555-6666-7777-8888', 'gerardo.hernandez@example.com', '555-66-7777'),
('Montserrat', 'Gómez', 'Pérez', '888-999-0000', '8888-9999-0000-1111', 'montserrat.gomez@example.com', '888-99-0000'),
('Miguel', 'Martínez', 'González', '333-444-5555', '3333-4444-5555-6666', 'miguel.martinez@example.com', '333-44-5555'),
('Jessica', 'López', 'Sánchez', '666-777-8888', '6666-7777-8888-9999', 'jessica.lopez@example.com', '666-77-8888'),
('Gustavo', 'Pérez', 'Martínez', '999-000-1111', '9999-0000-1111-2222', 'gustavo.perez@example.com', '999-00-1111'),
('Miriam', 'González', 'Fernández', '444-555-6666', '4444-5555-6666-7777', 'miriam.gonzalez@example.com', '444-55-6666'),
('Alejandra', 'Sánchez', 'López', '777-888-9999', '7777-8888-9999-0000', 'alejandra.sanchez@example.com', '777-88-9999'),
('Héctor', 'Hernández', 'Martínez', '222-333-4444', '2222-3333-4444-5555', 'hector.hernandez@example.com', '222-33-4444'),
('Sandra', 'Pérez', 'González', '555-666-7777', '5555-6666-7777-8888', 'sandra.perez@example.com', '555-66-7777'),
('Oscar', 'Martínez', 'Sánchez', '888-999-0000', '8888-9999-0000-1111', 'oscar.martinez@example.com', '888-99-0000'),
('Karla', 'López', 'Martínez', '333-444-5555', '3333-4444-5555-6666', 'karla.lopez@example.com', '333-44-5555'),
('Jorge', 'González', 'Fernández', '666-777-8888', '6666-7777-8888-9999', 'jorge.gonzalez@example.com', '666-77-8888'),
('Lucía', 'Sánchez', 'López', '999-000-1111', '9999-0000-1111-2222', 'lucia.sanchez@example.com', '999-00-1111'),
('Gabriel', 'Martínez', 'González', '444-555-6666', '4444-5555-6666-7777', 'gabriel.martinez@example.com', '444-55-6666'),
('María', 'Pérez', 'Martínez', '777-888-9999', '7777-8888-9999-0000', 'maria.perez@example.com', '777-88-9999'),
('Rosa', 'Hernández', 'Gómez', '222-333-4444', '2222-3333-4444-5555', 'rosa.hernandez@example.com', '222-33-4444'),
('Mauricio', 'González', 'Hernández', '555-666-7777', '5555-6666-7777-8888', 'mauricio.gonzalez@example.com', '555-66-7777'),
('Diana', 'Sánchez', 'Martínez', '888-999-0000', '8888-9999-0000-1111', 'diana.sanchez@example.com', '888-99-0000'),
('Fernando', 'Martínez', 'López', '333-444-5555', '3333-4444-5555-6666', 'fernando.martinez@example.com', '333-44-5555'),
('Ana', 'Gómez', 'González', '666-777-8888', '6666-7777-8888-9999', 'ana.gomez@example.com', '666-77-8888'),
('Gabriela', 'Pérez', 'Sánchez', '999-000-1111', '9999-0000-1111-2222', 'gabriela.perez@example.com', '999-00-1111'),
('Arturo', 'González', 'Martínez', '444-555-6666', '4444-5555-6666-7777', 'arturo.gonzalez@example.com', '444-55-6666'),
('Natalia', 'Sánchez', 'Hernández', '777-888-9999', '7777-8888-9999-0000', 'natalia.sanchez@example.com', '777-88-9999'),
('Eduardo', 'Martínez', 'Pérez', '222-333-4444', '2222-3333-4444-5555', 'eduardo.martinez@example.com', '222-33-4444'),
('Sofía', 'González', 'Gómez', '555-666-7777', '5555-6666-7777-8888', 'sofia.gonzalez@example.com', '555-66-7777'),
('Andrés', 'Hernández', 'López', '888-999-0000', '8888-9999-0000-1111', 'andres.hernandez@example.com', '888-99-0000'),
('Martha', 'Gómez', 'Martínez', '333-444-5555', '3333-4444-5555-6666', 'martha.gomez@example.com', '333-44-5555'),
('Antonio', 'Pérez', 'González', '666-777-8888', '6666-7777-8888-9999', 'antonio.perez@example.com', '666-77-8888'),
('Susana', 'Martínez', 'Sánchez', '999-000-1111', '9999-0000-1111-2222', 'susana.martinez@example.com', '999-00-1111'),
('Roberto', 'González', 'Martínez', '444-555-6666', '4444-5555-6666-7777', 'roberto.gonzalez@example.com', '444-55-6666'),
('Alejandra', 'Sánchez', 'Gómez', '777-888-9999', '7777-8888-9999-0000', 'alejandra.sanchez@example.com', '777-88-9999'),
('Ricardo', 'Hernández', 'Martínez', '222-333-4444', '2222-3333-4444-5555', 'ricardo.hernandez@example.com', '222-33-4444'),
('Sara', 'Pérez', 'González', '555-666-7777', '5555-6666-7777-8888', 'sara.perez@example.com', '555-66-7777'),
('Pablo', 'Martínez', 'Sánchez', '888-999-0000', '8888-9999-0000-1111', 'pablo.martinez@example.com', '888-99-0000'),
('Marcela', 'López', 'Martínez', '333-444-5555', '3333-4444-5555-6666', 'marcela.lopez@example.com', '333-44-5555'),
('Mario', 'González', 'Fernández', '666-777-8888', '6666-7777-8888-9999', 'mario.gonzalez@example.com', '666-77-8888'),
('Monica', 'Sánchez', 'López', '999-000-1111', '9999-0000-1111-2222', 'monica.sanchez@example.com', '999-00-1111'),
('Julio', 'Martínez', 'González', '444-555-6666', '4444-5555-6666-7777', 'julio.martinez@example.com', '444-55-6666');
```


###  insertando la información  ofuscando  en la tabla nueva Empleados_ofuscado

```SQL

insert into Empleados_ofuscado 
 select 
  IDEmpleado
 --, a.Nombre as nombre
 , b.Nombre as NombreNEW
 --, a.ApellidoPaterno 
 , c.ApellidoPaterno as ApellidoPaternoNEW
 --, a.ApellidoMaterno
 , d.ApellidoMaterno as ApellidoMaternoNEW 
 --,Telefono
 , LEFT(Telefono, 3) + '-' +  cast(CAST(FLOOR(RAND(CHECKSUM(NEWID()))  * 9000000 + 1000000) AS INT)  as varchar) as TelefonoNEW
 ,  'XXXX-XXXX-XXX-' + SUBSTRING(TarjetaCredito  , len(TarjetaCredito) -3  , 4) as TarjetaCreditoNEW
 -- , Correo
 ,  TRANSLATE(   LOWER (b.Nombre + '.' + c.ApellidoPaterno +  SUBSTRING( Correo , CHARINDEX('@', Correo), LEN(Correo)))  , 'áéíóúÁÉÍÓÚ', 'aeiouAEIOU')  as CorreoNEW 

 --, REPLICATE('x', CHARINDEX('@', Correo) - 1) + SUBSTRING(Correo, CHARINDEX('@', Correo), LEN(Correo)) as CorreoNEW /* Coloca en X */
 --, NumeroSeguroSocial
 ,LEFT( NumeroSeguroSocial , LEN( NumeroSeguroSocial ) - 4)  + cast(CAST(FLOOR(RAND(CHECKSUM(NEWID()))  * 9000 + 1000) AS INT)  as varchar) as NumeroSeguroSocialNEW
 --,sueldo
 ,  cast(CAST(FLOOR(RAND(CHECKSUM(NEWID()))  * (50000 - 1000 + 1) + 1000) AS INT)  as decimal(10,2)) as sueldoNEW
 from Empleados as  a 
  left join ( SELECT Nombre, ROW_NUMBER() OVER (ORDER BY NEWID()) AS Num FROM Empleados) as b on  a.IDEmpleado=b.Num
  left join ( SELECT ApellidoPaterno, ROW_NUMBER() OVER (ORDER BY NEWID()) AS Num FROM Empleados) as c on  a.IDEmpleado=c.Num
  left join ( SELECT ApellidoMaterno, ROW_NUMBER() OVER (ORDER BY NEWID()) AS Num FROM Empleados) as d on  a.IDEmpleado=d.Num

```




