/*
==============================================================================
08_usp_Dashboard.sql — Procedimientos Almacenados del Dashboard

Proyecto: Autopartes El Tornillo Flojo
Responsable: Equipo de Base de Datos
Fecha de solicitud: Mayo 2026

INSTRUCCIONES:
  Ejecutar este script en la base de datos DB_TornilloFlojo.
  Una vez ejecutado, el Dashboard del ERP mostrará datos reales en tiempo real.
==============================================================================
*/

USE [DB_TornilloFlojo];
GO

IF OBJECT_ID('dbo.usp_Dashboard_GetResumen', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Dashboard_GetResumen;
GO

CREATE PROCEDURE dbo.usp_Dashboard_GetResumen
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(f.id)                                             AS VentasHoy,

        ISNULL(SUM(f.total), 0)                                 AS IngresosTotalesHoy,

        COUNT(DISTINCT f.id_cliente)                            AS ClientesAtendidosHoy,

        (
            SELECT COUNT(*)
            FROM dbo.inventario_sucursal
            WHERE stock_actual <= stock_minimo
        )                                                        AS ProductosBajoStock
    FROM dbo.factura f
    WHERE CAST(f.fecha_emision AS DATE) = CAST(GETDATE() AS DATE);

    SELECT
        CAST(f.fecha_emision AS DATE)  AS Fecha,
        COUNT(f.id)                    AS CantidadVentas,
        ISNULL(SUM(f.total), 0)        AS TotalVentas
    FROM dbo.factura f
    WHERE f.fecha_emision >= CAST(DATEADD(DAY, -6, CAST(GETDATE() AS DATE)) AS DATETIME)
    GROUP BY CAST(f.fecha_emision AS DATE)
    ORDER BY Fecha ASC;

END;
GO

PRINT 'SP usp_Dashboard_GetResumen creado exitosamente.';
GO
