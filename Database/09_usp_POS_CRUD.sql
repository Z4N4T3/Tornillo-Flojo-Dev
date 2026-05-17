USE [DB_TornilloFlojo];
GO

-- =============================================
-- Author:      Antigravity
-- Description: Búsqueda dinámica de clientes para el POS
-- =============================================
CREATE OR ALTER PROCEDURE usp_Cliente_Busqueda
    @busqueda VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 20 
        id, 
        LTRIM(RTRIM(nombre1 + ' ' + ISNULL(nombre2 + ' ', '') + apellido1 + ' ' + ISNULL(apellido2, ''))) AS nombre_completo,
        identificacion,
        telefono
    FROM cliente
    WHERE 
        identificacion LIKE '%' + @busqueda + '%' OR
        nombre1 LIKE '%' + @busqueda + '%' OR
        apellido1 LIKE '%' + @busqueda + '%'
    ORDER BY nombre1;
END
GO

-- =============================================
-- Author:      Antigravity
-- Description: Búsqueda dinámica de productos para el POS en una sucursal específica
-- =============================================
CREATE OR ALTER PROCEDURE usp_Producto_BusquedaPOS
    @id_sucursal INT,
    @busqueda VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 50
        p.id,
        p.codigo_parte,
        p.nombre,
        p.precio_venta,
        inv.stock_actual
    FROM producto p
    INNER JOIN inventario_sucursal inv ON p.id = inv.id_producto
    WHERE 
        inv.id_sucursal = @id_sucursal AND
        p.id_estado = 1 AND -- Solo productos activos
        (p.codigo_parte LIKE '%' + @busqueda + '%' OR p.nombre LIKE '%' + @busqueda + '%')
    ORDER BY p.nombre;
END
GO

-- =============================================
-- Author:      Antigravity
-- Description: Emisión de una nueva factura (Transaccional).
--              Inserta Factura, Detalles, Movimientos de Inventario y actualiza Stock.
-- =============================================
CREATE OR ALTER PROCEDURE usp_Factura_Emitir
    @id_cliente INT,
    @id_turno_caja INT,
    @id_sucursal INT,
    @subtotal DECIMAL(18,2),
    @impuesto DECIMAL(18,2),
    @total DECIMAL(18,2),
    @id_usuario INT, -- El usuario que está registrando la venta
    @detalles_json NVARCHAR(MAX), -- JSON con los detalles [{ "id_producto": 1, "cantidad": 2, "precio_unitario": 150.00 }]
    @id_factura_generada BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        -- 1. Generar ID manual para la cabecera de la factura
        DECLARE @NuevoFacturaId BIGINT;
        SELECT @NuevoFacturaId = ISNULL(MAX(id), 0) + 1 FROM factura WITH (UPDLOCK, SERIALIZABLE);

        -- Generar número de factura (Formato: F-{SUC}-00000X)
        DECLARE @NumeroFactura VARCHAR(50) = 'F-' + CAST(@id_sucursal AS VARCHAR) + '-' + RIGHT('000000' + CAST(@NuevoFacturaId AS VARCHAR), 6);

        -- 2. Insertar en Factura
        INSERT INTO factura (id, numero_factura, id_cliente, id_turno_caja, id_sucursal, subtotal, impuesto, total, fecha_emision, id_estado)
        VALUES (@NuevoFacturaId, @NumeroFactura, @id_cliente, @id_turno_caja, @id_sucursal, @subtotal, @impuesto, @total, GETDATE(), 1);

        -- 3. Parsear JSON de Detalles a una tabla temporal en memoria
        DECLARE @DetallesTemp TABLE (
            id_producto INT,
            cantidad INT,
            precio_unitario DECIMAL(18,2)
        );

        INSERT INTO @DetallesTemp (id_producto, cantidad, precio_unitario)
        SELECT id_producto, cantidad, precio_unitario
        FROM OPENJSON(@detalles_json)
        WITH (
            id_producto INT '$.id_producto',
            cantidad INT '$.cantidad',
            precio_unitario DECIMAL(18,2) '$.precio_unitario'
        );

        -- 4. Recorrer los detalles para insertarlos y afectar inventario/kardex
        DECLARE @IdProducto INT, @Cantidad INT, @PrecioUnitario DECIMAL(18,2);
        DECLARE @NuevoDetalleId BIGINT;
        DECLARE @NuevoMovimientoId BIGINT;
        DECLARE @StockActual INT;

        DECLARE cur_detalles CURSOR FOR SELECT id_producto, cantidad, precio_unitario FROM @DetallesTemp;
        OPEN cur_detalles;
        FETCH NEXT FROM cur_detalles INTO @IdProducto, @Cantidad, @PrecioUnitario;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- 4.1. Generar ID y Crear Factura Detalle
            SELECT @NuevoDetalleId = ISNULL(MAX(id), 0) + 1 FROM factura_detalle WITH (UPDLOCK, SERIALIZABLE);
            
            INSERT INTO factura_detalle (id, id_factura, id_producto, cantidad, precio_unitario)
            VALUES (@NuevoDetalleId, @NuevoFacturaId, @IdProducto, @Cantidad, @PrecioUnitario);

            -- 4.2. Validar Stock en la sucursal actual
            SELECT @StockActual = stock_actual 
            FROM inventario_sucursal WITH (UPDLOCK, SERIALIZABLE)
            WHERE id_sucursal = @id_sucursal AND id_producto = @IdProducto;

            IF @StockActual IS NULL OR @StockActual < @Cantidad
            BEGIN
                -- Rechazar la transacción si no hay stock (o si el producto no existe en esa sucursal)
                RAISERROR('Stock insuficiente para el producto ID %d en la sucursal actual.', 16, 1, @IdProducto);
            END

            -- 4.3. Actualizar Inventario (Restar cantidad)
            UPDATE inventario_sucursal
            SET stock_actual = stock_actual - @Cantidad
            WHERE id_sucursal = @id_sucursal AND id_producto = @IdProducto;

            -- 4.4. Generar ID e Insertar en el Kardex (Movimiento)
            DECLARE @StockResultante INT = @StockActual - @Cantidad;
            SELECT @NuevoMovimientoId = ISNULL(MAX(id), 0) + 1 FROM movimiento WITH (UPDLOCK, SERIALIZABLE);

            -- Asumimos que id_tipo_movimiento = 2 corresponde a 'Salida por Venta'
            INSERT INTO movimiento (id, id_producto, id_tipo_movimiento, id_sucursal, cantidad, costo_unitario, stock_resultante, fecha_movimiento, id_usuario, referencia)
            VALUES (@NuevoMovimientoId, @IdProducto, 2, @id_sucursal, @Cantidad, @PrecioUnitario, @StockResultante, GETDATE(), @id_usuario, 'Venta Factura ' + @NumeroFactura);

            FETCH NEXT FROM cur_detalles INTO @IdProducto, @Cantidad, @PrecioUnitario;
        END

        CLOSE cur_detalles;
        DEALLOCATE cur_detalles;

        COMMIT TRAN;
        SET @id_factura_generada = @NuevoFacturaId;
    END TRY
    BEGIN CATCH
        -- En caso de cualquier error, deshacer todas las operaciones
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        
        -- Cerrar el cursor si quedó abierto debido al error
        IF CURSOR_STATUS('global', 'cur_detalles') >= -1 
        BEGIN
            CLOSE cur_detalles;
            DEALLOCATE cur_detalles;
        END

        -- Relanzar el error al cliente / ORM
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
