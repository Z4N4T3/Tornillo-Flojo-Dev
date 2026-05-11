USE [master];
GO

-- ============================================================
-- Crear Login de SQL Server para la aplicación .NET
-- ============================================================
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = N'tornillo_app')
BEGIN
    CREATE LOGIN [tornillo_app]
    WITH PASSWORD   = N'TornilloApp#2026!',
         CHECK_EXPIRATION = OFF,
         CHECK_POLICY     = ON;
    PRINT 'Login [tornillo_app] creado exitosamente.';
END
ELSE
BEGIN
    PRINT 'Login [tornillo_app] ya existe.';
END
GO

-- ============================================================
-- Una vez creada la base de datos, mapear el Login al usuario
-- ============================================================
USE [DB_TornilloFlojo];
GO

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = N'tornillo_app')
BEGIN
    CREATE USER [tornillo_app] FOR LOGIN [tornillo_app];
    PRINT 'Usuario [tornillo_app] creado en DB_TornilloFlojo.';
END
ELSE
BEGIN
    PRINT 'Usuario [tornillo_app] ya existe en la base de datos.';
END
GO

-- ============================================================
-- Otorgar permisos mínimos necesarios (Principio de mínimo privilegio)
-- La aplicación sólo ejecutará Stored Procedures y hará consultas.
-- No necesita DDL (CREATE TABLE, ALTER, DROP).
-- ============================================================
ALTER ROLE [db_datareader] ADD MEMBER [tornillo_app]; -- SELECT en todas las tablas
ALTER ROLE [db_datawriter] ADD MEMBER [tornillo_app]; -- INSERT, UPDATE, DELETE en todas las tablas
GRANT EXECUTE TO [tornillo_app];                      -- Ejecutar Stored Procedures
GO

PRINT '========================================';
PRINT 'Setup completado.';
PRINT 'Connection String para appsettings.json:';
PRINT 'Server=0.0.0.0;Database=DB_TornilloFlojo;User Id=tornillo_app;Password=TornilloApp#2026!;TrustServerCertificate=True;';
PRINT '========================================';
