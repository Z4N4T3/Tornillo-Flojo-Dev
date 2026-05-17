USE DB_TornilloFlojo;
GO

-- ==============================================
-- CRUD para tabla 'empleado'
-- ==============================================

-- 1. INSERT
IF OBJECT_ID('usp_Empleado_Insert', 'P') IS NOT NULL DROP PROCEDURE usp_Empleado_Insert;
GO
CREATE PROCEDURE usp_Empleado_Insert
    @nombre1 VARCHAR(50),
    @nombre2 VARCHAR(50) = NULL,
    @apellido1 VARCHAR(50),
    @apellido2 VARCHAR(50) = NULL,
    @identificacion VARCHAR(20),
    @genero CHAR(1) = NULL,
    @id_cargo INT = NULL,
    @id_sucursal INT = NULL,
    @id_estado INT = 1, -- 1: Activo
    @NuevoId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        
        SELECT @NuevoId = ISNULL(MAX(id), 0) + 1 FROM empleado WITH (UPDLOCK, SERIALIZABLE);

        INSERT INTO empleado (id, nombre1, nombre2, apellido1, apellido2, identificacion, genero, id_cargo, id_sucursal, id_estado)
        VALUES (@NuevoId, @nombre1, @nombre2, @apellido1, @apellido2, @identificacion, @genero, @id_cargo, @id_sucursal, @id_estado);
        
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- 2. GET ALL
IF OBJECT_ID('usp_Empleado_GetAll', 'P') IS NOT NULL DROP PROCEDURE usp_Empleado_GetAll;
GO
CREATE PROCEDURE usp_Empleado_GetAll
    @id_sucursal INT = NULL -- Opcional para filtrar por sucursal
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.id, e.nombre1, e.nombre2, e.apellido1, e.apellido2, e.identificacion, e.genero,
           e.id_cargo, c.nombre AS cargo_nombre,
           e.id_sucursal, s.nombre AS sucursal_nombre,
           e.id_estado, st.nombre AS estado_nombre
    FROM empleado e
    LEFT JOIN cargo c ON e.id_cargo = c.id
    LEFT JOIN sucursal s ON e.id_sucursal = s.id
    INNER JOIN estado st ON e.id_estado = st.id
    WHERE e.id_estado = 1 
      AND (@id_sucursal IS NULL OR e.id_sucursal = @id_sucursal);
END
GO

-- 3. GET BY ID
IF OBJECT_ID('usp_Empleado_GetById', 'P') IS NOT NULL DROP PROCEDURE usp_Empleado_GetById;
GO
CREATE PROCEDURE usp_Empleado_GetById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.id, e.nombre1, e.nombre2, e.apellido1, e.apellido2, e.identificacion, e.genero,
           e.id_cargo, c.nombre AS cargo_nombre,
           e.id_sucursal, s.nombre AS sucursal_nombre,
           e.id_estado, st.nombre AS estado_nombre
    FROM empleado e
    LEFT JOIN cargo c ON e.id_cargo = c.id
    LEFT JOIN sucursal s ON e.id_sucursal = s.id
    INNER JOIN estado st ON e.id_estado = st.id
    WHERE e.id = @id;
END
GO

-- 4. UPDATE
IF OBJECT_ID('usp_Empleado_Update', 'P') IS NOT NULL DROP PROCEDURE usp_Empleado_Update;
GO
CREATE PROCEDURE usp_Empleado_Update
    @id INT,
    @nombre1 VARCHAR(50),
    @nombre2 VARCHAR(50) = NULL,
    @apellido1 VARCHAR(50),
    @apellido2 VARCHAR(50) = NULL,
    @identificacion VARCHAR(20),
    @genero CHAR(1) = NULL,
    @id_cargo INT = NULL,
    @id_sucursal INT = NULL,
    @id_estado INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        
        UPDATE empleado
        SET nombre1 = @nombre1,
            nombre2 = @nombre2,
            apellido1 = @apellido1,
            apellido2 = @apellido2,
            identificacion = @identificacion,
            genero = @genero,
            id_cargo = @id_cargo,
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

-- 5. DELETE (Borrado lógico)
IF OBJECT_ID('usp_Empleado_Delete', 'P') IS NOT NULL DROP PROCEDURE usp_Empleado_Delete;
GO
CREATE PROCEDURE usp_Empleado_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        
        -- id_estado = 2 (Inactivo)
        UPDATE empleado
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
