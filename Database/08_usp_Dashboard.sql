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

-- ============================================================================
-- SP: usp_Dashboard_GetResumen
-- Descripción: Retorna dos result sets para poblar el Dashboard principal.
--
--   Result Set 1 (una fila): KPIs del día actual
--     - VentasHoy            INT     → Cantidad de facturas emitidas hoy
--     - IngresosTotalesHoy   DECIMAL → Suma de factura.total del día
--     - ClientesAtendidosHoy INT     → Clientes únicos en facturas de hoy
--     - ProductosBajoStock   INT     → Productos donde stock_actual <= stock_minimo
--
--   Result Set 2 (hasta 7 filas): Ventas de los últimos 7 días (para gráfico)
--     - Fecha          DATE    → Fecha del día
--     - CantidadVentas INT     → Número de facturas en ese día
--     - TotalVentas    DECIMAL → Suma de ingresos en ese día
--
-- Consumido por: DashboardController.cs → Dapper QueryMultipleAsync
-- ============================================================================
IF OBJECT_ID('dbo.usp_Dashboard_GetResumen', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Dashboard_GetResumen;
GO

CREATE PROCEDURE dbo.usp_Dashboard_GetResumen
AS
BEGIN
    SET NOCOUNT ON;

    -- ── Result Set 1: KPIs del Día ────────────────────────────────────────────
    SELECT
        -- Cantidad de facturas emitidas hoy
        COUNT(f.id)                                             AS VentasHoy,

        -- Suma de ingresos del día (0 si no hay facturas)
        ISNULL(SUM(f.total), 0)                                 AS IngresosTotalesHoy,

        -- Clientes únicos atendidos hoy
        COUNT(DISTINCT f.id_cliente)                            AS ClientesAtendidosHoy,

        -- Productos con stock por debajo del mínimo en cualquier sucursal
        (
            SELECT COUNT(*)
            FROM dbo.inventario_sucursal
            WHERE stock_actual <= stock_minimo
        )                                                        AS ProductosBajoStock
    FROM dbo.factura f
    WHERE CAST(f.fecha_emision AS DATE) = CAST(GETDATE() AS DATE);

    -- ── Result Set 2: Ventas de los Últimos 7 Días (Gráfico) ─────────────────
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

-- ── Verificación rápida post-ejecución ──────────────────────────────────────
-- Ejecutar para confirmar que el SP fue creado correctamente:
-- EXEC dbo.usp_Dashboard_GetResumen;
PRINT 'SP usp_Dashboard_GetResumen creado exitosamente.';
GO
