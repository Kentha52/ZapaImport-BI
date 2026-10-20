SELECT
    (SELECT COUNT(*) FROM ZapaImport_OLTP.dbo.DetalleVenta WHERE Cantidad > 0) AS Filas_OLTP_Validas,
    (SELECT COUNT(*) FROM dbo.Fact_Ventas) AS Filas_Fact,
    (SELECT COUNT(*) FROM stg.VentaRechazada) AS Filas_Rechazadas;

SELECT
    (SELECT SUM(Cantidad * PrecioUnitario * (1 - ISNULL(DescuentoPorc, 0) / 100.0))
     FROM ZapaImport_OLTP.dbo.DetalleVenta WHERE Cantidad > 0) AS VentaNeta_OLTP,
    (SELECT SUM(VentaNeta) FROM dbo.Fact_Ventas) AS VentaNeta_DW;

SELECT 'Dim_Tiempo' AS Tabla, COUNT(*) AS Filas FROM dbo.Dim_Tiempo
UNION ALL SELECT 'Dim_Producto', COUNT(*) FROM dbo.Dim_Producto
UNION ALL SELECT 'Dim_Cliente', COUNT(*) FROM dbo.Dim_Cliente
UNION ALL SELECT 'Dim_Canal', COUNT(*) FROM dbo.Dim_Canal
UNION ALL SELECT 'Dim_Vendedor', COUNT(*) FROM dbo.Dim_Vendedor
UNION ALL SELECT 'Fact_Ventas', COUNT(*) FROM dbo.Fact_Ventas;
GO

SELECT
    SUM(f.VentaNeta) AS VentaNeta_Total,
    SUM(f.Cantidad) AS Pares_Vendidos,
    SUM(f.Utilidad) AS Utilidad_Total,
    CAST(100.0 * SUM(f.Utilidad) / SUM(f.VentaNeta) AS DECIMAL(5,2)) AS Margen_Pct,
    CAST(SUM(f.VentaNeta) / COUNT(DISTINCT f.IdVenta) AS DECIMAL(10,2)) AS Ticket_Promedio,
    CAST(100.0 * SUM(f.DescuentoMonto) / SUM(f.VentaBruta) AS DECIMAL(5,2)) AS Descuento_Pct
FROM dbo.Fact_Ventas f;
GO

SELECT
    p.Marca,
    SUM(f.Cantidad) AS Pares,
    SUM(f.VentaNeta) AS VentaNeta,
    SUM(f.Utilidad) AS Utilidad,
    CAST(100.0 * SUM(f.Utilidad) / SUM(f.VentaNeta) AS DECIMAL(5,2)) AS Margen_Pct
FROM dbo.Fact_Ventas f
JOIN dbo.Dim_Producto p ON p.SK_Producto = f.SK_Producto
GROUP BY p.Marca
ORDER BY VentaNeta DESC;
GO

SELECT TOP(5)
    p.Marca,
    p.Modelo,
    SUM(f.Cantidad) AS Pares,
    SUM(f.Utilidad) AS Utilidad
FROM dbo.Fact_Ventas f
JOIN dbo.Dim_Producto p ON p.SK_Producto = f.SK_Producto
GROUP BY p.Marca, p.Modelo
ORDER BY Utilidad DESC;
GO

SELECT
    t.Mes,
    t.NombreMes,
    SUM(f.VentaNeta) AS VentaNeta,
    SUM(f.Utilidad) AS Utilidad,
    SUM(f.Cantidad) AS Pares
FROM dbo.Fact_Ventas f
JOIN dbo.Dim_Tiempo t ON t.SK_Tiempo = f.SK_Tiempo
GROUP BY t.Mes, t.NombreMes
ORDER BY t.Mes;
GO

SELECT
    c.NombreCanal,
    c.TipoCanal,
    COUNT(DISTINCT f.IdVenta) AS Ventas,
    SUM(f.VentaNeta) AS VentaNeta,
    CAST(100.0 * SUM(f.Utilidad) / SUM(f.VentaNeta) AS DECIMAL(5,2)) AS Margen_Pct
FROM dbo.Fact_Ventas f
JOIN dbo.Dim_Canal c ON c.SK_Canal = f.SK_Canal
GROUP BY c.NombreCanal, c.TipoCanal
ORDER BY VentaNeta DESC;
GO

SELECT
    p.RangoTalla,
    p.Talla,
    SUM(f.Cantidad) AS Pares
FROM dbo.Fact_Ventas f
JOIN dbo.Dim_Producto p ON p.SK_Producto = f.SK_Producto
GROUP BY p.RangoTalla, p.Talla
ORDER BY Pares DESC, p.Talla;
GO

SELECT
    v.NombreVendedor,
    COUNT(DISTINCT f.IdVenta) AS Ventas,
    SUM(f.VentaNeta) AS VentaNeta,
    SUM(f.Utilidad) AS Utilidad
FROM dbo.Fact_Ventas f
JOIN dbo.Dim_Vendedor v ON v.SK_Vendedor = f.SK_Vendedor
GROUP BY v.NombreVendedor
ORDER BY VentaNeta DESC;
GO

SELECT TOP(5)
    cl.Distrito,
    COUNT(DISTINCT f.IdVenta) AS Ventas,
    SUM(f.VentaNeta) AS VentaNeta
FROM dbo.Fact_Ventas f
JOIN dbo.Dim_Cliente cl ON cl.SK_Cliente = f.SK_Cliente
GROUP BY cl.Distrito
ORDER BY VentaNeta DESC;
GO

SELECT
    p.Marca,
    p.Modelo,
    p.Talla,
    o.Stock,
    ISNULL(SUM(f.Cantidad), 0) AS Pares_Vendidos
FROM dbo.Dim_Producto p
JOIN ZapaImport_OLTP.dbo.Producto o ON o.IdProducto = p.IdProducto_OLTP
LEFT JOIN dbo.Fact_Ventas f ON f.SK_Producto = p.SK_Producto
GROUP BY p.Marca, p.Modelo, p.Talla, o.Stock
HAVING ISNULL(SUM(f.Cantidad), 0) <= 3
ORDER BY o.Stock DESC;
GO