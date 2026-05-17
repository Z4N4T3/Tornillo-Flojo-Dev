USE DB_TornilloFlojo;
GO


IF OBJECT_ID('usp_Usuario_Insert', 'P') IS NOT NULL DROP PROCEDURE usp_Usuario_Insert;
GO
CREATE PROCEDURE usp_Usuario_Insert
    @username VARCHAR(50),
    @password_hash VARCHAR(256),
    @id_empleado INT = NULL,
    @id_rol INT = NULL,
    @id_sucursal INT = NULL,
    @id_estado INT = 1,
    @NuevoId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        
        SELECT @NuevoId = ISNULL(MAX(id), 0) + 1 FROM usuario WITH (UPDLOCK, SERIALIZABLE);

        INSERT INTO usuario (id, username, password_hash, id_empleado, id_rol, id_sucursal, id_estado, fecha_creacion)
        VALUES (@NuevoId, @username, @password_hash, @id_empleado, @id_rol, @id_sucursal, @id_estado, GETDATE());
        
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

IF OBJECT_ID('usp_Usuario_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_Usuario_GetAll;
GO
CREATE PROCEDURE usp_Usuario_GetAll
    @id_sucursal INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.id, u.username, u.fecha_creacion,
           u.id_empleado, e.nombre1 + ' ' + e.apellido1 AS empleado_nombre,
           u.id_rol, r.nombre AS rol_nombre,
           u.id_sucursal, s.nombre AS sucursal_nombre,
           u.id_estado, st.nombre AS estado_nombre
    FROM usuario u
    LEFT JOIN empleado e ON u.id_empleado = e.id
    LEFT JOIN rol r ON u.id_rol = r.id
    LEFT JOIN sucursal s ON u.id_sucursal = s.id
    INNER JOIN estado st ON u.id_estado = st.id
    WHERE u.id_estado = 1
      AND (@id_sucursal IS NULL OR u.id_sucursal = @id_sucursal);
END
GO

IF OBJECT_ID('usp_Usuario_GetById', 'P') IS NOT NULL DROP PROCEDURE usp_Usuario_GetById;
GO
CREATE PROCEDURE usp_Usuario_GetById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.id, u.username, u.fecha_creacion,
           u.id_empleado, e.nombre1 + ' ' + e.apellido1 AS empleado_nombre,
           u.id_rol, r.nombre AS rol_nombre,
           u.id_sucursal, s.nombre AS sucursal_nombre,
           u.id_estado, st.nombre AS estado_nombre
    FROM usuario u
    LEFT JOIN empleado e ON u.id_empleado = e.id
    LEFT JOIN rol r ON u.id_rol = r.id
    LEFT JOIN sucursal s ON u.id_sucursal = s.id
    INNER JOIN estado st ON u.id_estado = st.id
    WHERE u.id = @id;
END
GO

IF OBJECT_ID('usp_Usuario_Update', 'P') IS NOT NULL DROP PROCEDURE usp_Usuario_Update;
GO
CREATE PROCEDURE usp_Usuario_Update
    @id INT,
    @username VARCHAR(50),
    @id_empleado INT = NULL,
    @id_rol INT = NULL,
    @id_sucursal INT = NULL,
    @id_estado INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        
        UPDATE usuario
        SET username = @username,
            id_empleado = @id_empleado,
            id_rol = @id_rol,
            id_sucursal = @id_sucursal,
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

IF OBJECT_ID('usp_Usuario_Delete', 'P') IS NOT NULL DROP PROCEDURE usp_Usuario_Delete;
GO
CREATE PROCEDURE usp_Usuario_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        
        UPDATE usuario
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
