
IF DB_ID('ZapaImport_DW') IS NOT NULL 
BEGIN 
    ALTER DATABASE ZapaImport_DW SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
    DROP DATABASE ZapaImport_DW; 
END 
GO 
CREATE DATABASE ZapaImport_DW; 
GO 
USE ZapaImport_DW; 
GO 

CREATE SCHEMA stg;
GO

CREATE TABLE dbo.Dim_Tiempo (
    SK_Tiempo INT NOT NULL,
    Fecha DATE NOT NULL,
    Anio SMALLINT NOT NULL,
    Trimestre TINYINT NOT NULL,
    Mes TINYINT NOT NULL,
    NombreMes VARCHAR(12) NOT NULL,
    DiaMes TINYINT NOT NULL,
    DiaSemana TINYINT NOT NULL,
    NombreDia VARCHAR(12) NOT NULL,
    EsFinSemana BIT NOT NULL,
    CONSTRAINT PK_Dim_Tiempo PRIMARY KEY (SK_Tiempo),
    CONSTRAINT UQ_Dim_Tiempo_Fecha UNIQUE (Fecha)
);
GO

CREATE TABLE dbo.Dim_Producto (
    SK_Producto INT IDENTITY(1,1) NOT NULL,
    IdProducto_OLTP INT NOT NULL,
    Codigo VARCHAR(20) NOT NULL,
    Modelo VARCHAR(50) NOT NULL,
    Marca VARCHAR(30) NOT NULL,
    Categoria VARCHAR(20) NOT NULL,
    Genero VARCHAR(10) NOT NULL,
    Color VARCHAR(20) NOT NULL,
    Talla INT NOT NULL,
    RangoTalla VARCHAR(20) NOT NULL,
    PaisOrigen VARCHAR(30) NOT NULL,
    CostoImportacion DECIMAL(10,2) NOT NULL,
    PrecioLista DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_Dim_Producto PRIMARY KEY (SK_Producto),
    CONSTRAINT UQ_Dim_Producto_BK UNIQUE (IdProducto_OLTP)
);
GO

CREATE TABLE dbo.Dim_Cliente (
    SK_Cliente INT IDENTITY(1,1) NOT NULL,
    IdCliente_OLTP INT NOT NULL,
    NombreCompleto VARCHAR(80) NOT NULL,
    Email VARCHAR(80) NOT NULL,
    Distrito VARCHAR(40) NOT NULL,
    Genero CHAR(1) NOT NULL,
    FechaRegistro DATE NOT NULL,
    CONSTRAINT PK_Dim_Cliente PRIMARY KEY (SK_Cliente),
    CONSTRAINT UQ_Dim_Cliente_BK UNIQUE (IdCliente_OLTP)
);
GO

CREATE TABLE dbo.Dim_Canal (
    SK_Canal INT IDENTITY(1,1) NOT NULL,
    NombreCanal VARCHAR(20) NOT NULL,
    TipoCanal VARCHAR(12) NOT NULL,
    CONSTRAINT PK_Dim_Canal PRIMARY KEY (SK_Canal),
    CONSTRAINT UQ_Dim_Canal_Nombre UNIQUE (NombreCanal)
);
GO

CREATE TABLE dbo.Dim_Vendedor (
    SK_Vendedor INT IDENTITY(1,1) NOT NULL,
    IdVendedor_OLTP INT NULL,
    NombreVendedor VARCHAR(60) NOT NULL,
    FechaIngreso DATE NULL,
    CONSTRAINT PK_Dim_Vendedor PRIMARY KEY (SK_Vendedor)
);
GO

SET IDENTITY_INSERT dbo.Dim_Vendedor ON;
INSERT INTO dbo.Dim_Vendedor (SK_Vendedor, IdVendedor_OLTP, NombreVendedor, FechaIngreso)
VALUES (0, NULL, 'SIN VENDEDOR (VENTA ONLINE)', NULL);
SET IDENTITY_INSERT dbo.Dim_Vendedor OFF;
GO


CREATE TABLE dbo.Fact_Ventas (
    SK_Venta BIGINT IDENTITY(1,1) NOT NULL,
    SK_Tiempo INT NOT NULL,
    SK_Producto INT NOT NULL,
    SK_Cliente INT NOT NULL,
    SK_Canal INT NOT NULL,
    SK_Vendedor INT NOT NULL,
    IdVenta INT NOT NULL,
    IdDetalle INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    VentaBruta DECIMAL(12,2) NOT NULL,
    DescuentoMonto DECIMAL(12,2) NOT NULL,
    VentaNeta DECIMAL(12,2) NOT NULL,
    CostoTotal DECIMAL(12,2) NOT NULL,
    Utilidad DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_Fact_Ventas PRIMARY KEY (SK_Venta),
    CONSTRAINT UQ_Fact_Ventas_Origen UNIQUE (IdDetalle),
    CONSTRAINT FK_Fact_Tiempo FOREIGN KEY (SK_Tiempo) REFERENCES dbo.Dim_Tiempo(SK_Tiempo),
    CONSTRAINT FK_Fact_Producto FOREIGN KEY (SK_Producto) REFERENCES dbo.Dim_Producto(SK_Producto),
    CONSTRAINT FK_Fact_Cliente FOREIGN KEY (SK_Cliente) REFERENCES dbo.Dim_Cliente(SK_Cliente),
    CONSTRAINT FK_Fact_Canal FOREIGN KEY (SK_Canal) REFERENCES dbo.Dim_Canal(SK_Canal),
    CONSTRAINT FK_Fact_Vendedor FOREIGN KEY (SK_Vendedor) REFERENCES dbo.Dim_Vendedor(SK_Vendedor)
);
GO

CREATE INDEX IX_Fact_Tiempo ON dbo.Fact_Ventas(SK_Tiempo);
CREATE INDEX IX_Fact_Producto ON dbo.Fact_Ventas(SK_Producto);
CREATE INDEX IX_Fact_Cliente ON dbo.Fact_Ventas(SK_Cliente);
CREATE INDEX IX_Fact_Canal ON dbo.Fact_Ventas(SK_Canal);
CREATE INDEX IX_Fact_Vendedor ON dbo.Fact_Ventas(SK_Vendedor);
GO


CREATE TABLE stg.Producto (
    IdProducto INT,
    Codigo VARCHAR(20),
    Modelo VARCHAR(50),
    Marca VARCHAR(30),
    Categoria VARCHAR(20),
    Genero VARCHAR(10),
    Color VARCHAR(20),
    Talla VARCHAR(5),
    PaisOrigen VARCHAR(30),
    CostoImportacion DECIMAL(10,2),
    PrecioLista DECIMAL(10,2),
    TallaNum INT NULL,
    RangoTalla VARCHAR(20) NULL
);
GO

CREATE TABLE stg.Cliente (
    IdCliente INT,
    NombreCompleto VARCHAR(80),
    Email VARCHAR(80),
    Distrito VARCHAR(40),
    Genero CHAR(1),
    FechaRegistro DATE
);
GO

CREATE TABLE stg.Vendedor (
    IdVendedor INT,
    Nombre VARCHAR(60),
    FechaIngreso DATE
);
GO

CREATE TABLE stg.VentaDetalle (
    IdDetalle INT,
    IdVenta INT,
    Fecha DATE,
    IdCliente INT,
    IdVendedor INT NULL,
    Canal VARCHAR(20),
    CanalLimpio VARCHAR(20) NULL,
    TipoCanal VARCHAR(12) NULL,
    IdProducto INT,
    Cantidad INT,
    PrecioUnitario DECIMAL(10,2),
    DescuentoPorc DECIMAL(5,2) NULL
);
GO

CREATE TABLE stg.VentaRechazada (
    IdDetalle INT,
    IdVenta INT,
    IdProducto INT,
    Cantidad INT,
    PrecioUnitario DECIMAL(10,2),
    Motivo VARCHAR(100),
    FechaRechazo DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE dbo.ETL_Log (
    IdLog INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATETIME NOT NULL DEFAULT GETDATE(),
    Paso VARCHAR(80) NOT NULL,
    Filas INT NULL,
    Estado VARCHAR(15) NOT NULL,
    Mensaje VARCHAR(400) NULL
);
GO

SELECT s.name AS Esquema, t.name AS Tabla 
FROM sys.tables t 
JOIN sys.schemas s ON s.schema_id = t.schema_id 
ORDER BY s.name, t.name;
GO