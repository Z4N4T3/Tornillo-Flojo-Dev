USE [master];
GO

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

ALTER ROLE [db_datareader] ADD MEMBER [tornillo_app];
ALTER ROLE [db_datawriter] ADD MEMBER [tornillo_app];
GRANT EXECUTE TO [tornillo_app];
GO

PRINT '========================================';
PRINT 'Setup completado.';
PRINT 'Connection String para appsettings.json:';
PRINT 'Server=Z4n4t3\SQLEXPRESS;Database=DB_TornilloFlojo;User Id=tornillo_app;Password=TornilloApp#2026!;TrustServerCertificate=True;MultipleActiveResultSets=True;';
PRINT '========================================';
