

USE ZapaImport_DW;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ETL_Ventas
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @n INT;

    BEGIN TRY
        BEGIN TRANSACTION;

     

        TRUNCATE TABLE stg.Producto;
        INSERT INTO stg.Producto (IdProducto, Codigo, Modelo, Marca, Categoria, Genero, Color, Talla, PaisOrigen, CostoImportacion, PrecioLista)
        SELECT IdProducto, Codigo, Modelo, Marca, Categoria, Genero, Color, Talla, PaisOrigen, CostoImportacion, PrecioLista
        FROM ZapaImport_OLTP.dbo.Producto;
        SET @n = @@ROWCOUNT;
        INSERT INTO dbo.ETL_Log (Paso, Filas, Estado) VALUES ('E- stg.Producto', @n, 'OK');

        TRUNCATE TABLE stg.Cliente;
        INSERT INTO stg.Cliente (IdCliente, NombreCompleto, Email, Distrito, Genero, FechaRegistro)
        SELECT IdCliente, NombreCompleto, Email, Distrito, Genero, FechaRegistro
        FROM ZapaImport_OLTP.dbo.Cliente;
        SET @n = @@ROWCOUNT;
        INSERT INTO dbo.ETL_Log (Paso, Filas, Estado) VALUES ('E- stg.Cliente', @n, 'OK');

        TRUNCATE TABLE stg.Vendedor;
        INSERT INTO stg.Vendedor (IdVendedor, Nombre, FechaIngreso)
        SELECT IdVendedor, Nombre, FechaIngreso
        FROM ZapaImport_OLTP.dbo.Vendedor;
        SET @n = @@ROWCOUNT;
        INSERT INTO dbo.ETL_Log (Paso, Filas, Estado) VALUES ('E- stg.Vendedor', @n, 'OK');

        TRUNCATE TABLE stg.VentaDetalle;
        INSERT INTO stg.VentaDetalle (IdDetalle, IdVenta, Fecha, IdCliente, IdVendedor, Canal, IdProducto, Cantidad, PrecioUnitario, DescuentoPorc)
        SELECT d.IdDetalle, d.IdVenta, v.Fecha, v.IdCliente, v.IdVendedor, v.Canal, d.IdProducto, d.Cantidad, d.PrecioUnitario, d.DescuentoPorc
        FROM ZapaImport_OLTP.dbo.DetalleVenta d
        JOIN ZapaImport_OLTP.dbo.Venta v ON v.IdVenta = d.IdVenta;
        SET @n = @@ROWCOUNT;
        INSERT INTO dbo.ETL_Log (Paso, Filas, Estado) VALUES ('E- stg.VentaDetalle', @n, 'OK');

  
        UPDATE stg.Producto SET
            Codigo = UPPER(LTRIM(RTRIM(Codigo))),
            Modelo = LTRIM(RTRIM(Modelo)),
            Marca = UPPER(LTRIM(RTRIM(Marca))),
            Categoria = LTRIM(RTRIM(Categoria)),
            Genero = LTRIM(RTRIM(Genero)),
            Color = LTRIM(RTRIM(Color)),
            PaisOrigen = LTRIM(RTRIM(PaisOrigen)),
            TallaNum = TRY_CAST(LTRIM(RTRIM(Talla)) AS INT);

        UPDATE stg.Producto SET
            RangoTalla = CASE 
                WHEN TallaNum IS NULL THEN 'SIN TALLA'
                WHEN TallaNum <= 38 THEN 'CHICA (35-38)'
                WHEN TallaNum <= 42 THEN 'MEDIA (39-42)'
                ELSE 'GRANDE (43+)'
            END;

        UPDATE stg.Cliente SET
            NombreCompleto = UPPER(REPLACE(REPLACE(LTRIM(RTRIM(NombreCompleto)), '  ', ' '), '  ', ' ')),
            Email = ISNULL(LOWER(LTRIM(RTRIM(Email))), 'no registrado'),
            Distrito = ISNULL(NULLIF(LTRIM(RTRIM(Distrito)), ''), 'No especificado'),
            Genero = ISNULL(Genero, 'N');

        UPDATE stg.Vendedor SET Nombre = UPPER(LTRIM(RTRIM(Nombre)));

        UPDATE stg.VentaDetalle SET
            CanalLimpio = CASE UPPER(LTRIM(RTRIM(Canal)))
                WHEN 'TIENDA' THEN 'Tienda física'
                WHEN 'WEB' THEN 'Tienda web'
                WHEN 'INSTAGRAM' THEN 'Instagram'
                WHEN 'WHATSAPP' THEN 'WhatsApp'
                ELSE 'Otro'
            END,
            DescuentoPorc = ISNULL(DescuentoPorc, 0);

        UPDATE stg.VentaDetalle SET
            TipoCanal = CASE WHEN CanalLimpio = 'Tienda física' THEN 'Presencial' ELSE 'Digital' END;

        TRUNCATE TABLE stg.VentaRechazada;
        INSERT INTO stg.VentaRechazada (IdDetalle, IdVenta, IdProducto, Cantidad, PrecioUnitario, Motivo)
        SELECT IdDetalle, IdVenta, IdProducto, Cantidad, PrecioUnitario, 'Cantidad o precio menor/igual a cero'
        FROM stg.VentaDetalle
        WHERE Cantidad <= 0 OR PrecioUnitario <= 0;
        SET @n = @@ROWCOUNT;

        DELETE FROM stg.VentaDetalle WHERE Cantidad <= 0 OR PrecioUnitario <= 0;
        INSERT INTO dbo.ETL_Log (Paso, Filas, Estado, Mensaje)
        VALUES ('T- Registros rechazados', @n, CASE WHEN @n = 0 THEN 'OK' ELSE 'ADVERTENCIA' END, 'Ver tabla stg.VentaRechazada');


        IF NOT EXISTS (SELECT 1 FROM dbo.Dim_Tiempo)
        BEGIN
            ;WITH Fechas AS (
                SELECT CAST('2026-01-01' AS DATE) AS Fecha
                UNION ALL
                SELECT DATEADD(DAY, 1, Fecha) FROM Fechas WHERE Fecha < '2026-12-31'
            )
            INSERT INTO dbo.Dim_Tiempo (SK_Tiempo, Fecha, Anio, Trimestre, Mes, NombreMes, DiaMes, DiaSemana, NombreDia, EsFinSemana)
            SELECT
                CONVERT(INT, CONVERT(CHAR(8), Fecha, 112)),
                Fecha,
                YEAR(Fecha),
                DATEPART(QUARTER, Fecha),
                MONTH(Fecha),
                CHOOSE(MONTH(Fecha), 'Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'),
                DAY(Fecha),
                (DATEDIFF(DAY, '19000101', Fecha) % 7) + 1,
                CHOOSE((DATEDIFF(DAY, '19000101', Fecha) % 7) + 1, 'Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'),
                CASE WHEN (DATEDIFF(DAY, '19000101', Fecha) % 7) + 1 >= 6 THEN 1 ELSE 0 END
            FROM Fechas
            OPTION (MAXRECURSION 400);
            SET @n = @@ROWCOUNT;
            INSERT INTO dbo.ETL_Log (Paso, Filas, Estado) VALUES ('L- Dim_Tiempo', @n, 'OK');
        END

        UPDATE d SET
            d.CostoImportacion = s.CostoImportacion,
            d.PrecioLista = s.PrecioLista
        FROM dbo.Dim_Producto d
        JOIN stg.Producto s ON s.IdProducto = d.IdProducto_OLTP
        WHERE d.CostoImportacion <> s.CostoImportacion OR d.PrecioLista <> s.PrecioLista;

        INSERT INTO dbo.Dim_Producto (IdProducto_OLTP, Codigo, Modelo, Marca, Categoria, Genero, Color, Talla, RangoTalla, PaisOrigen, CostoImportacion, PrecioLista)
        SELECT s.IdProducto, s.Codigo, s.Modelo, s.Marca, s.Categoria, s.Genero, s.Color,
               ISNULL(s.TallaNum, 0), s.RangoTalla, s.PaisOrigen, s.CostoImportacion, s.PrecioLista
        FROM stg.Producto s
        WHERE NOT EXISTS (SELECT 1 FROM dbo.Dim_Producto d WHERE d.IdProducto_OLTP = s.IdProducto);
        SET @n = @@ROWCOUNT;
        INSERT INTO dbo.ETL_Log (Paso, Filas, Estado) VALUES ('L- Dim_Producto (nuevos)', @n, 'OK');

        INSERT INTO dbo.Dim_Cliente (IdCliente_OLTP, NombreCompleto, Email, Distrito, Genero, FechaRegistro)
        SELECT s.IdCliente, s.NombreCompleto, s.Email, s.Distrito, s.Genero, s.FechaRegistro
        FROM stg.Cliente s
        WHERE NOT EXISTS (SELECT 1 FROM dbo.Dim_Cliente d WHERE d.IdCliente_OLTP = s.IdCliente);
        SET @n = @@ROWCOUNT;
        INSERT INTO dbo.ETL_Log (Paso, Filas, Estado) VALUES ('L- Dim_Cliente (nuevos)', @n, 'OK');

        INSERT INTO dbo.Dim_Vendedor (IdVendedor_OLTP, NombreVendedor, FechaIngreso)
        SELECT s.IdVendedor, s.Nombre, s.FechaIngreso
        FROM stg.Vendedor s
        WHERE NOT EXISTS (SELECT 1 FROM dbo.Dim_Vendedor d WHERE d.IdVendedor_OLTP = s.IdVendedor);
        SET @n = @@ROWCOUNT;
        INSERT INTO dbo.ETL_Log (Paso, Filas, Estado) VALUES ('L- Dim_Vendedor (nuevos)', @n, 'OK');

        INSERT INTO dbo.Dim_Canal (NombreCanal, TipoCanal)
        SELECT DISTINCT s.CanalLimpio, s.TipoCanal
        FROM stg.VentaDetalle s
        WHERE NOT EXISTS (SELECT 1 FROM dbo.Dim_Canal d WHERE d.NombreCanal = s.CanalLimpio);
        SET @n = @@ROWCOUNT;
        INSERT INTO dbo.ETL_Log (Paso, Filas, Estado) VALUES ('L- Dim_Canal (nuevos)', @n, 'OK');

        INSERT INTO dbo.Fact_Ventas (SK_Tiempo, SK_Producto, SK_Cliente, SK_Canal, SK_Vendedor, IdVenta, IdDetalle, Cantidad, PrecioUnitario, VentaBruta, DescuentoMonto, VentaNeta, CostoTotal, Utilidad)
        SELECT
            CONVERT(INT, CONVERT(CHAR(8), v.Fecha, 112)),
            p.SK_Producto,
            c.SK_Cliente,
            ca.SK_Canal,
            ISNULL(ve.SK_Vendedor, 0),
            v.IdVenta,
            v.IdDetalle,
            v.Cantidad,
            v.PrecioUnitario,
            b.Bruta,
            d.Dscto,
            b.Bruta - d.Dscto,
            k.Costo,
            b.Bruta - d.Dscto - k.Costo
        FROM stg.VentaDetalle v
        JOIN dbo.Dim_Producto p ON p.IdProducto_OLTP = v.IdProducto
        JOIN dbo.Dim_Cliente c ON c.IdCliente_OLTP = v.IdCliente
        JOIN dbo.Dim_Canal ca ON ca.NombreCanal = v.CanalLimpio
        LEFT JOIN dbo.Dim_Vendedor ve ON ve.IdVendedor_OLTP = v.IdVendedor
        CROSS APPLY (SELECT CAST(v.Cantidad * v.PrecioUnitario AS DECIMAL(12,2)) AS Bruta) b
        CROSS APPLY (SELECT CAST(b.Bruta * v.DescuentoPorc / 100.0 AS DECIMAL(12,2)) AS Dscto) d
        CROSS APPLY (SELECT CAST(v.Cantidad * p.CostoImportacion AS DECIMAL(12,2)) AS Costo) k
        WHERE NOT EXISTS (SELECT 1 FROM dbo.Fact_Ventas f WHERE f.IdDetalle = v.IdDetalle);
        SET @n = @@ROWCOUNT;
        INSERT INTO dbo.ETL_Log (Paso, Filas, Estado) VALUES ('L- Fact_Ventas (nuevas)', @n, 'OK');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.ETL_Log (Paso, Filas, Estado, Mensaje)
        VALUES ('ERROR EN ETL', NULL, 'ERROR', LEFT(ERROR_MESSAGE(), 400));
        THROW;
    END CATCH
END;
GO

EXEC dbo.usp_ETL_Ventas;
GO

SELECT IdLog, Paso, Filas, Estado, Mensaje FROM dbo.ETL_Log ORDER BY IdLog;
GO