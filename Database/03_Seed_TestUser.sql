USE [DB_TornilloFlojo];
GO

PRINT 'Insertando Sucursal Matriz (Prerrequisito)...';
-- Necesitamos una sucursal física para poder asignar al empleado y al usuario.
IF NOT EXISTS (SELECT 1 FROM sucursal WHERE id = 1)
BEGIN
    -- id_barrio = 46 corresponde a Managua según el Seed Geográfico
    INSERT INTO sucursal (id, nombre, telefono, email, id_barrio, direccion_detalle, es_principal, id_estado)
    VALUES (1, 'Casa Matriz Managua', '2222-3333', 'matriz@tornilloflojo.com', 1, 'Rotonda Bello Horizonte 1c al Sur', 1, 1);
END
GO

PRINT 'Insertando Empleado de Prueba (Administrador)...';
-- El empleado es el ente de RRHH vinculado al usuario.
IF NOT EXISTS (SELECT 1 FROM empleado WHERE id = 1)
BEGIN
    -- id_cargo 1 = Gerente General (Definido en 02_Seed_Seguridad)
    INSERT INTO empleado (id, nombre1, nombre2, apellido1, apellido2, identificacion, genero, id_cargo, id_sucursal, id_estado)
    VALUES (1, 'Super', '', 'Admin', '', '001-000000-0000A', 'M', 1, 1, 1); 
END
GO

PRINT 'Insertando Usuario de Prueba (Login)...';
-- El registro de inicio de sesión propiamente dicho.
IF NOT EXISTS (SELECT 1 FROM usuario WHERE id = 1)
BEGIN
    -- id_rol 1 = Administrador Global (Tiene acceso a TODO)
    -- NOTA: Para propósitos de testing inicial he dejado 'admin123' en texto plano. 
    -- Cuando implementes el backend en C#, debes reemplazar este valor por el Hash real (Ej. BCrypt o PBKDF2).
    INSERT INTO usuario (id, username, password_hash, id_empleado, id_rol, id_sucursal, id_estado)
    VALUES (1, 'admin', 'admin123', 1, 1, 1, 1); 
END
GO

PRINT 'Carga de Usuario de Prueba completada.';
PRINT '-> Credenciales para pruebas:';
PRINT '-> Usuario: admin';
PRINT '-> Clave: admin123';
