USE [DB_TornilloFlojo];
GO

-- ============================================================
-- SP: usp_Inventario_GetAll
-- Obtiene el listado completo de productos con stock por sucursal.
-- Devuelve 3 resultsets: Productos, Categorias, Marcas.
-- ============================================================
CREATE OR ALTER PROCEDURE usp_Inventario_GetAll
    @id_sucursal INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Resultset 1: Inventario de productos con flag de alerta
    SELECT
        p.id                                        AS Id,
        p.codigo_parte                              AS CodigoParte,
        p.nombre                                    AS Nombre,
        ISNULL(p.descripcion, '')                   AS Descripcion,
        p.precio_costo                              AS PrecioCosto,
        p.precio_venta                              AS PrecioVenta,
        p.id_marca                                  AS IdMarca,
        ISNULL(pm.nombre, 'Sin Marca')              AS MarcaNombre,
        p.id_categoria                              AS IdCategoria,
        ISNULL(pc.nombre, 'Sin Categoría')          AS CategoriaNombre,
        p.id_estado                                 AS IdEstado,
        e.nombre                                    AS EstadoNombre,
        ISNULL(inv.stock_actual, 0)                 AS StockActual,
        ISNULL(inv.stock_minimo, 5)                 AS StockMinimo,
        CASE
            WHEN ISNULL(inv.stock_actual, 0) <= ISNULL(inv.stock_minimo, 5) THEN 1
            ELSE 0
        END                                         AS AlertaStock
    FROM producto p
    INNER JOIN estado e          ON p.id_estado = e.id
    LEFT JOIN producto_marca pm  ON p.id_marca = pm.id
    LEFT JOIN producto_categoria pc ON p.id_categoria = pc.id
    LEFT JOIN inventario_sucursal inv ON p.id = inv.id_producto
        AND inv.id_sucursal = @id_sucursal
    WHERE p.id_estado = 1
    ORDER BY p.nombre;

    -- Resultset 2: Categorías para panel lateral
    SELECT id AS Id, nombre AS Nombre
    FROM producto_categoria
    ORDER BY nombre;

    -- Resultset 3: Marcas para el formulario
    SELECT id AS Id, nombre AS Nombre
    FROM producto_marca
    ORDER BY nombre;
END
GO

-- ============================================================
-- SP: usp_Inventario_GetById
-- Devuelve el detalle completo de un producto para el modal de edición.
-- ============================================================
CREATE OR ALTER PROCEDURE usp_Inventario_GetById
    @id_producto INT,
    @id_sucursal INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.id                                        AS Id,
        p.codigo_parte                              AS CodigoParte,
        p.nombre                                    AS Nombre,
        ISNULL(p.descripcion, '')                   AS Descripcion,
        p.precio_costo                              AS PrecioCosto,
        p.precio_venta                              AS PrecioVenta,
        p.id_marca                                  AS IdMarca,
        ISNULL(pm.nombre, '')                       AS MarcaNombre,
        p.id_categoria                              AS IdCategoria,
        ISNULL(pc.nombre, '')                       AS CategoriaNombre,
        p.id_estado                                 AS IdEstado,
        e.nombre                                    AS EstadoNombre,
        ISNULL(inv.stock_actual, 0)                 AS StockActual,
        ISNULL(inv.stock_minimo, 5)                 AS StockMinimo,
        CASE
            WHEN ISNULL(inv.stock_actual, 0) <= ISNULL(inv.stock_minimo, 5) THEN 1
            ELSE 0
        END                                         AS AlertaStock
    FROM producto p
    INNER JOIN estado e           ON p.id_estado = e.id
    LEFT JOIN producto_marca pm   ON p.id_marca = pm.id
    LEFT JOIN producto_categoria pc ON p.id_categoria = pc.id
    LEFT JOIN inventario_sucursal inv ON p.id = inv.id_producto
        AND inv.id_sucursal = @id_sucursal
    WHERE p.id = @id_producto;
END
GO

-- ============================================================
-- SP: usp_Inventario_InsertProducto
-- Crea un producto en el catálogo e inicializa su entrada
-- en inventario_sucursal con stock = 0.
-- Sigue las guidelines: generación manual de ID, ACID, TRY/CATCH.
-- ============================================================
CREATE OR ALTER PROCEDURE usp_Inventario_InsertProducto
    @codigo_parte       VARCHAR(50),
    @nombre             VARCHAR(200),
    @descripcion        VARCHAR(MAX) = NULL,
    @precio_costo       DECIMAL(18,2) = NULL,
    @precio_venta       DECIMAL(18,2),
    @id_marca           INT = NULL,
    @id_categoria       INT = NULL,
    @id_sucursal_inicial INT,
    @NuevoId            INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        -- Generación manual de ID (sin IDENTITY)
        SELECT @NuevoId = ISNULL(MAX(id), 0) + 1
        FROM producto WITH (UPDLOCK, SERIALIZABLE);

        INSERT INTO producto (id, codigo_parte, nombre, descripcion, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
        VALUES (@NuevoId, @codigo_parte, @nombre, @descripcion, @precio_costo, @precio_venta, @id_marca, @id_categoria, 1);

        -- Inicializar stock en la sucursal (si aún no existe el registro)
        IF NOT EXISTS (
            SELECT 1 FROM inventario_sucursal
            WHERE id_sucursal = @id_sucursal_inicial AND id_producto = @NuevoId
        )
        BEGIN
            INSERT INTO inventario_sucursal (id_sucursal, id_producto, stock_actual, stock_minimo)
            VALUES (@id_sucursal_inicial, @NuevoId, 0, 5);
        END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        DECLARE @Msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Msg, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- SP: usp_Inventario_UpdateProducto
-- Actualiza los metadatos del producto (no modifica stock).
-- El stock SOLO se modifica a través de movimientos (usp_Factura_Emitir, etc.)
-- ============================================================
CREATE OR ALTER PROCEDURE usp_Inventario_UpdateProducto
    @id             INT,
    @codigo_parte   VARCHAR(50),
    @nombre         VARCHAR(200),
    @descripcion    VARCHAR(MAX) = NULL,
    @precio_costo   DECIMAL(18,2) = NULL,
    @precio_venta   DECIMAL(18,2),
    @id_marca       INT = NULL,
    @id_categoria   INT = NULL,
    @id_estado      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        -- Verificar que el producto existe y está activo
        IF NOT EXISTS (SELECT 1 FROM producto WHERE id = @id)
        BEGIN
            RAISERROR('El producto con ID %d no existe.', 16, 1, @id);
        END

        UPDATE producto
        SET
            codigo_parte = @codigo_parte,
            nombre       = @nombre,
            descripcion  = @descripcion,
            precio_costo = @precio_costo,
            precio_venta = @precio_venta,
            id_marca     = @id_marca,
            id_categoria = @id_categoria,
            id_estado    = @id_estado
        WHERE id = @id;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        DECLARE @Msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Msg, 16, 1);
    END CATCH
END
GO

-- ============================================================
-- SP: usp_Inventario_DeleteProducto
-- Borrado LÓGICO: cambia el estado del producto a Inactivo (id=2).
-- Nunca ejecuta DELETE físico. (Guideline #5)
-- ============================================================
CREATE OR ALTER PROCEDURE usp_Inventario_DeleteProducto
    @id_producto INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM producto WHERE id = @id_producto)
        BEGIN
            RAISERROR('El producto con ID %d no existe.', 16, 1, @id_producto);
        END

        UPDATE producto
        SET id_estado = 2  -- 2 = Inactivo
        WHERE id = @id_producto;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        DECLARE @Msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Msg, 16, 1);
    END CATCH
END
GO
