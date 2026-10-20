IF DB_ID('ZapaImport_OLTP') IS NOT NULL 
BEGIN 
    ALTER DATABASE ZapaImport_OLTP SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
    DROP DATABASE ZapaImport_OLTP; 
END 
GO 
CREATE DATABASE ZapaImport_OLTP; 
GO 
USE ZapaImport_OLTP; 
GO

CREATE TABLE dbo.Producto (
    IdProducto INT NOT NULL PRIMARY KEY,
    Codigo VARCHAR(20) NOT NULL,
    Modelo VARCHAR(50) NOT NULL,
    Marca VARCHAR(30) NOT NULL,
    Categoria VARCHAR(20) NOT NULL,
    Genero VARCHAR(10) NOT NULL,
    Color VARCHAR(20) NOT NULL,
    Talla VARCHAR(5) NOT NULL,
    PaisOrigen VARCHAR(30) NOT NULL,
    CostoImportacion DECIMAL(10,2) NOT NULL,
    PrecioLista DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL
);
GO

CREATE TABLE dbo.Cliente (
    IdCliente INT NOT NULL PRIMARY KEY,
    NombreCompleto VARCHAR(80) NOT NULL,
    Email VARCHAR(80) NULL,
    Distrito VARCHAR(40) NULL,
    Genero CHAR(1) NULL,
    FechaRegistro DATE NOT NULL
);
GO

CREATE TABLE dbo.Vendedor (
    IdVendedor INT NOT NULL PRIMARY KEY,
    Nombre VARCHAR(60) NOT NULL,
    FechaIngreso DATE NOT NULL
);
GO

CREATE TABLE dbo.Venta (
    IdVenta INT NOT NULL PRIMARY KEY,
    Fecha DATE NOT NULL,
    IdCliente INT NOT NULL REFERENCES dbo.Cliente(IdCliente),
    IdVendedor INT NULL REFERENCES dbo.Vendedor(IdVendedor),
    Canal VARCHAR(20) NOT NULL,
    MedioPago VARCHAR(20) NOT NULL
);
GO

CREATE TABLE dbo.DetalleVenta (
    IdDetalle INT NOT NULL PRIMARY KEY,
    IdVenta INT NOT NULL REFERENCES dbo.Venta(IdVenta),
    IdProducto INT NOT NULL REFERENCES dbo.Producto(IdProducto),
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    DescuentoPorc DECIMAL(5,2) NULL
);
GO

INSERT INTO dbo.Producto VALUES
(1,  'AD-001', 'Superstar',       'adidas ',      'Casual',    'Unisex',  'Blanco',       '40 ',  'Vietnam',    220.00, 399.00, 12),
(2,  'AD-002', 'Superstar',       'ADIDAS',       'Casual',    'Unisex',  'Blanco',       '42',   'Vietnam',    220.00, 399.00, 10),
(3,  'AD-003', 'Superstar',       'ADIDAS',       'Casual',    'Unisex',  'Negro',        '39',   'Vietnam',    220.00, 399.00, 8),
(4,  'AD-004', 'Ultraboost 22',   'ADIDAS',       'Running',   'Hombre',  'Negro',        '41',   'Vietnam',    310.00, 549.00, 6),
(5,  'NK-001', 'Air Max 270',     'NIKE',         'Casual',    'Hombre',  'Negro',        '42',   'Indonesia',  310.00, 529.00, 9),
(6,  'NK-002', 'Air Max 270',     'NIKE',         'Casual',    'Hombre',  'Blanco',       '40',   'Indonesia',  310.00, 529.00, 7),
(7,  'CV-001', 'Chuck Taylor 70', 'CONVERSE',     'Casual',    'Unisex',  'Negro',        '38',   'Vietnam',    155.00, 289.00, 11),
(8,  'CV-002', 'Chuck Taylor 70', 'CONVERSE',     'Casual',    'Unisex',  'Rojo',         '39',   'Vietnam',    155.00, 289.00, 8),
(9,  'VN-001', 'Old Skool',       'VANS',         'Casual',    'Unisex',  'Negro',        '40',   'China',      175.00, 319.00, 10),
(10, 'VN-002', 'Old Skool',       'VANS',         'Casual',    'Unisex',  'Azul Marino',  '42',   'China',      175.00, 319.00, 9),
(11, 'NB-001', '574',             'NEW BALANCE',  'Casual',    'Unisex',  'Gris',         '37',   'USA',        210.00, 379.00, 6),
(12, 'NB-002', '574',             'NEW BALANCE',  'Casual',    'Unisex',  'Azul',         '40',   'USA',        210.00, 379.00, 8),
(13, 'PM-001', 'RS-X',            'PUMA',         'Running',   'Hombre',  'Multicolor',   '43',   'Vietnam',    250.00, 449.00, 5),
(14, 'PM-002', 'Suede Classic',   'PUMA',         'Casual',    'Unisex',  'Negro',        '39',   'Vietnam',    250.00, 449.00, 7);
GO

INSERT INTO dbo.Cliente VALUES
(1,  '  luis  Mendoza Rojas ',    'LMENDOZA@CORREO.COM',     'San Borja',      'M', '2025-10-15'),
(2,  'María García Torres',       'maria.garcia@gmail.com',  'Los Olivos',     'F', '2025-11-02'),
(3,  'Carlos Quispe Mamani',      NULL,                      'San Miguel',     'M', '2025-11-20'),
(4,  'Ana Lucía Rodríguez Paz',   'ana.rodriguez@hotmail.com','Jesús María',   'F', '2025-12-01'),
(5,  'Pedro Sánchez',             'pedro.s@yahoo.com',       'Miraflores',     'M', '2025-12-10'),
(6,  'Rosa  Flores  Quispe',      NULL,                      NULL,             'F', '2026-01-05'),
(7,  'Jorge Luis Paredes Vega',   'jparedes@gmail.com',      'San Borja',      'M', '2026-01-12'),
(8,  'Carmen Díaz',               'carmen.diaz@outlook.com', 'Los Olivos',     'F', '2026-01-20'),
(9,  'Miguel Ángel Torres Cruz',  NULL,                      'San Miguel',     NULL,'2026-02-01'),
(10, 'Valentina López Ríos',      'vlopez@gmail.com',        'Jesús María',    'F', '2026-02-14'),
(11, 'Diego Fernando Castro',     'dcastro@correo.com',      'Miraflores',     'M', '2026-03-01'),
(12, 'Luciana Vargas Medina',     'luciana.v@gmail.com',     'Miraflores',     'F', '2026-03-15');
GO

INSERT INTO dbo.Vendedor VALUES
(1, 'Lucía Paredes',  '2025-08-01'),
(2, 'Carlos Ramos',   '2025-09-15'),
(3, 'Diego Salazar',  '2026-02-01');
GO

INSERT INTO dbo.Venta VALUES
(1,  '2026-01-05', 1,  1,    'Tienda',     'Efectivo'),
(2,  '2026-01-08', 2,  1,    'tienda ',    'Tarjeta'),
(3,  '2026-01-12', 3,  NULL, 'WEB',        'Tarjeta'),
(4,  '2026-01-15', 4,  2,    'Tienda',     'Efectivo'),
(5,  '2026-01-20', 5,  1,    'Instagram',  'Yape'),
(6,  '2026-01-25', 6,  NULL, 'Web',        'Transferencia'),
(7,  '2026-02-02', 7,  1,    'Tienda',     'Tarjeta'),
(8,  '2026-02-05', 8,  2,    'tienda ',    'Efectivo'),
(9,  '2026-02-08', 9,  3,    'Instagram',  'Yape'),
(10, '2026-02-12', 10, NULL, 'WEB',        'Tarjeta'),
(11, '2026-02-15', 11, 3,    'WhatsApp',   'Plin'),
(12, '2026-02-20', 12, 1,    'Tienda',     'Efectivo'),
(13, '2026-02-25', 1,  NULL, 'Web',        'Tarjeta'),
(14, '2026-03-01', 2,  1,    'Tienda',     'Tarjeta'),
(15, '2026-03-05', 3,  2,    'Instagram',  'Yape'),
(16, '2026-03-08', 4,  NULL, 'WEB',        'Transferencia'),
(17, '2026-03-12', 5,  1,    'tienda ',    'Efectivo'),
(18, '2026-03-15', 6,  2,    'WhatsApp',   'Plin'),
(19, '2026-03-18', 7,  3,    'Instagram',  'Yape'),
(20, '2026-03-22', 8,  NULL, 'Web',        'Tarjeta'),
(21, '2026-03-25', 9,  1,    'Tienda',     'Tarjeta'),
(22, '2026-04-02', 10, 2,    'Tienda',     'Efectivo'),
(23, '2026-04-05', 11, NULL, 'WEB',        'Tarjeta'),
(24, '2026-04-10', 12, 1,    'tienda ',    'Yape'),
(25, '2026-04-15', 1,  2,    'Instagram',  'Plin'),
(26, '2026-04-20', 2,  NULL, 'Web',        'Transferencia'),
(27, '2026-05-03', 3,  1,    'Tienda',     'Tarjeta'),
(28, '2026-05-06', 4,  1,    'Instagram',  'Yape'),
(29, '2026-05-10', 5,  2,    'tienda ',    'Efectivo'),
(30, '2026-05-14', 6,  NULL, 'WEB',        'Tarjeta'),
(31, '2026-05-18', 7,  3,    'WhatsApp',   'Plin'),
(32, '2026-05-22', 8,  1,    'Tienda',     'Tarjeta'),
(33, '2026-05-26', 9,  NULL, 'Web',        'Transferencia'),
(34, '2026-06-05', 10, 2,    'Instagram',  'Yape'),
(35, '2026-06-12', 11, 1,    'Tienda',     'Efectivo'),
(36, '2026-06-20', 12, NULL, 'WEB',        'Tarjeta');
GO

INSERT INTO dbo.DetalleVenta VALUES
(1,  1,  1,  2, 399.00, 0),
(2,  1,  7,  1, 289.00, NULL),
(3,  2,  2,  1, 399.00, 0),
(4,  2,  9,  2, 319.00, 0),
(5,  3,  5,  2, 529.00, 0),
(6,  3,  10, 1, 319.00, NULL),
(7,  4,  3,  1, 399.00, 0),
(8,  4,  12, 1, 379.00, 0),
(9,  5,  1,  2, 399.00, 2),
(10, 5,  8,  1, 289.00, 0),
(11, 6,  6,  2, 529.00, 0),
(12, 6,  14, 1, 449.00, NULL),
(13, 7,  2,  2, 399.00, 0),
(14, 7,  9,  1, 319.00, 0),
(15, 8,  1,  1, 399.00, 0),
(16, 8,  11, 2, 379.00, 0),
(17, 9,  7,  2, 289.00, 0),
(18, 9,  13, 1, 449.00, NULL),
(19, 10, 5,  1, 529.00, 0),
(20, 10, 3,  2, 399.00, 0),
(21, 11, 12, 1, 379.00, 0),
(22, 11, 14, 2, 449.00, 0),
(23, 12, 2,  2, 399.00, 3),
(24, 12, 10, 1, 319.00, 0),
(25, 13, 6,  1, 529.00, NULL),
(26, 13, 1,  2, 399.00, 0),
(27, 14, 9,  2, 319.00, 0),
(28, 14, 8,  1, 289.00, 0),
(29, 15, 3,  2, 399.00, 0),
(30, 15, 12, 1, 379.00, NULL),
(31, 16, 5,  2, 529.00, 0),
(32, 16, 14, 1, 449.00, 0),
(33, 17, 1,  2, 399.00, 0),
(34, 17, 7,  2, 289.00, 0),
(35, 18, 11, 1, 379.00, 0),
(36, 18, 2,  1, 399.00, NULL),
(37, 19, 8,  2, 289.00, 0),
(38, 19, 10, 1, 319.00, 0),
(39, 20, 6,  1, 529.00, 0),
(40, 20, 3,  2, 399.00, 0),
(41, 21, 9,  2, 319.00, 0),
(42, 21, 12, 1, 379.00, 0),
(43, 22, 1,  1, 399.00, 0),
(44, 22, 7,  1, 289.00, NULL),
(45, 23, 5,  2, 529.00, 0),
(46, 23, 13, 1, 449.00, 0),
(47, 24, 2,  2, 399.00, 0),
(48, 24, 14, 1, 449.00, 0),
(49, 25, 3,  1, 399.00, 0),
(50, 25, 8,  2, 289.00, 0),
(51, 26, 6,  2, 529.00, 0),
(52, 26, 11, 1, 379.00, NULL),
(53, 27, 1,  3, 399.00, 0),
(54, 27, 9,  2, 319.00, 0),

(55, 28, 4,  0, 549.00, 0);
GO