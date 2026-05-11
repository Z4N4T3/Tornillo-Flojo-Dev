USE DB_TornilloFlojo;
GO

IF OBJECT_ID('usp_Usuario_Login', 'P') IS NOT NULL
    DROP PROCEDURE usp_Usuario_Login;
GO

CREATE PROCEDURE usp_Usuario_Login
    @username VARCHAR(50),
    @password_hash VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.id, u.username, u.id_rol, r.nombre AS RolNombre
    FROM usuario u
    INNER JOIN rol r ON u.id_rol = r.id
    WHERE u.username = @username 
      AND u.password_hash = @password_hash
      AND u.id_estado = 1; -- Activo
END
GO
