USE DB_TornilloFlojo;
GO


IF OBJECT_ID('usp_Producto_Insert', 'P') IS NOT NULL DROP PROCEDURE usp_Producto_Insert;
GO
CREATE PROCEDURE usp_Producto_Insert
    @codigo_parte VARCHAR(50),
    @nombre VARCHAR(200),
    @descripcion VARCHAR(MAX) = NULL,
    @precio_costo DECIMAL(18,2) = NULL,
    @precio_venta DECIMAL(18,2),
    @id_marca INT = NULL,
    @id_categoria INT = NULL,
    @id_estado INT = 1,
    @NuevoId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        
        SELECT @NuevoId = ISNULL(MAX(id), 0) + 1 FROM producto WITH (UPDLOCK, SERIALIZABLE);

        INSERT INTO producto (id, codigo_parte, nombre, descripcion, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
        VALUES (@NuevoId, @codigo_parte, @nombre, @descripcion, @precio_costo, @precio_venta, @id_marca, @id_categoria, @id_estado);
        
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

IF OBJECT_ID('usp_Producto_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_Producto_GetAll;
GO
CREATE PROCEDURE usp_Producto_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.id, p.codigo_parte, p.nombre, p.descripcion, p.precio_costo, p.precio_venta, 
           p.id_marca, pm.nombre AS marca_nombre,
           p.id_categoria, pc.nombre AS categoria_nombre,
           p.id_estado, e.nombre AS estado_nombre
    FROM producto p
    LEFT JOIN producto_marca pm ON p.id_marca = pm.id
    LEFT JOIN producto_categoria pc ON p.id_categoria = pc.id
    INNER JOIN estado e ON p.id_estado = e.id
    WHERE p.id_estado = 1;
END
GO

IF OBJECT_ID('usp_Producto_GetById', 'P') IS NOT NULL DROP PROCEDURE usp_Producto_GetById;
GO
CREATE PROCEDURE usp_Producto_GetById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.id, p.codigo_parte, p.nombre, p.descripcion, p.precio_costo, p.precio_venta, 
           p.id_marca, pm.nombre AS marca_nombre,
           p.id_categoria, pc.nombre AS categoria_nombre,
           p.id_estado, e.nombre AS estado_nombre
    FROM producto p
    LEFT JOIN producto_marca pm ON p.id_marca = pm.id
    LEFT JOIN producto_categoria pc ON p.id_categoria = pc.id
    INNER JOIN estado e ON p.id_estado = e.id
    WHERE p.id = @id;
END
GO

IF OBJECT_ID('usp_Producto_Update', 'P') IS NOT NULL DROP PROCEDURE usp_Producto_Update;
GO
CREATE PROCEDURE usp_Producto_Update
    @id INT,
    @codigo_parte VARCHAR(50),
    @nombre VARCHAR(200),
    @descripcion VARCHAR(MAX) = NULL,
    @precio_costo DECIMAL(18,2) = NULL,
    @precio_venta DECIMAL(18,2),
    @id_marca INT = NULL,
    @id_categoria INT = NULL,
    @id_estado INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        
        UPDATE producto
        SET codigo_parte = @codigo_parte,
            nombre = @nombre,
            descripcion = @descripcion,
            precio_costo = @precio_costo,
            precio_venta = @precio_venta,
            id_marca = @id_marca,
            id_categoria = @id_categoria,
            id_estado = @id_estado
        WHERE id = @id;
        
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

IF OBJECT_ID('usp_Producto_Delete', 'P') IS NOT NULL DROP PROCEDURE usp_Producto_Delete;
GO
CREATE PROCEDURE usp_Producto_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        
        UPDATE producto
        SET id_estado = 2 
        WHERE id = @id;
        
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO
