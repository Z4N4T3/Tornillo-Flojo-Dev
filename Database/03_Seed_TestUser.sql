USE [DB_TornilloFlojo];
GO

PRINT 'Insertando Barrio (Prerrequisito para Sucursal)...';
IF NOT EXISTS (SELECT 1 FROM barrio WHERE id = 1)
BEGIN
    INSERT INTO barrio (id, nombre, id_mun) VALUES (1, 'Bello Horizonte', 46);
END
GO

PRINT 'Insertando Sucursal Matriz (Prerrequisito)...';
IF NOT EXISTS (SELECT 1 FROM sucursal WHERE id = 1)
BEGIN
    INSERT INTO sucursal (id, nombre, telefono, email, id_barrio, direccion_detalle, es_principal, id_estado)
    VALUES (1, 'Casa Matriz Managua', '2222-3333', 'matriz@tornilloflojo.com', 1, 'Rotonda Bello Horizonte 1c al Sur', 1, 1);
END
GO

PRINT 'Insertando Empleado de Prueba (Administrador)...';
IF NOT EXISTS (SELECT 1 FROM empleado WHERE id = 1)
BEGIN
    INSERT INTO empleado (id, nombre1, nombre2, apellido1, apellido2, identificacion, genero, id_cargo, id_sucursal, id_estado)
    VALUES (1, 'Super', '', 'Admin', '', '001-000000-0000A', 'M', 1, 1, 1); 
END
GO

PRINT 'Insertando Usuario de Prueba (Login)...';
IF NOT EXISTS (SELECT 1 FROM usuario WHERE id = 1)
BEGIN
    INSERT INTO usuario (id, username, password_hash, id_empleado, id_rol, id_sucursal, id_estado)
    VALUES (1, 'admin', 'admin123', 1, 1, 1, 1); 
END
GO

PRINT 'Carga de Usuario de Prueba completada.';
PRINT '-> Credenciales para pruebas:';
PRINT '-> Usuario: admin';
PRINT '-> Clave: admin123';
