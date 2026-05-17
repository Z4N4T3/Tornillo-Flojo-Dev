USE [DB_TornilloFlojo];
GO

-- ============================================================
-- Seed: Usuario de Prueba con Rol "Bodega y Compras"
-- y datos de catálogo robustos para pruebas del módulo de inventario.
-- ============================================================

-- 1. Empleado bodeguero de prueba
PRINT 'Insertando Empleado Bodeguero de Prueba...';
IF NOT EXISTS (SELECT 1 FROM empleado WHERE id = 10)
BEGIN
    INSERT INTO empleado (id, nombre1, apellido1, identificacion, genero, id_cargo, id_sucursal, id_estado)
    VALUES (10, 'Carlos', 'Bodega', '009-000000-0010B', 'M', 3, 1, 1); -- cargo 3 = Jefe de Bodega
END
GO

-- 2. Usuario bodeguero de prueba (Rol ID 4 = "Bodega y Compras")
PRINT 'Insertando Usuario Bodeguero de Prueba...';
IF NOT EXISTS (SELECT 1 FROM usuario WHERE username = 'bodeguero')
BEGIN
    DECLARE @NuevoUserId INT;
    SELECT @NuevoUserId = ISNULL(MAX(id), 0) + 1 FROM usuario WITH (UPDLOCK, SERIALIZABLE);

    INSERT INTO usuario (id, username, password_hash, id_empleado, id_rol, id_sucursal, id_estado)
    VALUES (@NuevoUserId, 'bodeguero', 'bodega123', 10, 4, 1, 1); -- Rol 4 = "Bodega y Compras"
    
    PRINT '-> Credenciales: usuario=bodeguero | clave=bodega123';
END
GO

-- 3. Más marcas de repuestos
PRINT 'Insertando Marcas de Productos...';
IF NOT EXISTS (SELECT 1 FROM producto_marca WHERE id = 2) INSERT INTO producto_marca (id, nombre) VALUES (2, 'Bosch');
IF NOT EXISTS (SELECT 1 FROM producto_marca WHERE id = 3) INSERT INTO producto_marca (id, nombre) VALUES (3, 'Monroe');
IF NOT EXISTS (SELECT 1 FROM producto_marca WHERE id = 4) INSERT INTO producto_marca (id, nombre) VALUES (4, 'NGK');
IF NOT EXISTS (SELECT 1 FROM producto_marca WHERE id = 5) INSERT INTO producto_marca (id, nombre) VALUES (5, 'Gates');
IF NOT EXISTS (SELECT 1 FROM producto_marca WHERE id = 6) INSERT INTO producto_marca (id, nombre) VALUES (6, 'Mobil');
GO

-- 4. Categorías del catálogo
PRINT 'Insertando Categorías de Productos...';
IF NOT EXISTS (SELECT 1 FROM producto_categoria WHERE id = 2) INSERT INTO producto_categoria (id, nombre) VALUES (2, 'Motor y Lubricantes');
IF NOT EXISTS (SELECT 1 FROM producto_categoria WHERE id = 3) INSERT INTO producto_categoria (id, nombre) VALUES (3, 'Frenos y Suspensión');
IF NOT EXISTS (SELECT 1 FROM producto_categoria WHERE id = 4) INSERT INTO producto_categoria (id, nombre) VALUES (4, 'Eléctrico y Encendido');
IF NOT EXISTS (SELECT 1 FROM producto_categoria WHERE id = 5) INSERT INTO producto_categoria (id, nombre) VALUES (5, 'Transmisión y Dirección');
IF NOT EXISTS (SELECT 1 FROM producto_categoria WHERE id = 6) INSERT INTO producto_categoria (id, nombre) VALUES (6, 'Carrocería y Accesorios');
GO

-- 5. Productos de prueba (variados, con distintos niveles de stock)
PRINT 'Insertando Productos de Prueba para Inventario...';

-- Productos con stock normal
IF NOT EXISTS (SELECT 1 FROM producto WHERE id = 4)
    INSERT INTO producto (id, codigo_parte, nombre, descripcion, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
    VALUES (4, 'FRN-004', 'Pastillas de Freno Delanteras', 'Compatibles con sedanes y camionetas medianas.', 12.00, 22.00, 3, 3, 1);

IF NOT EXISTS (SELECT 1 FROM producto WHERE id = 5)
    INSERT INTO producto (id, codigo_parte, nombre, descripcion, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
    VALUES (5, 'COR-005', 'Correa Dentada Gates', 'Banda de distribución de alta duración, reforzada.', 18.00, 35.00, 5, 5, 1);

IF NOT EXISTS (SELECT 1 FROM producto WHERE id = 6)
    INSERT INTO producto (id, codigo_parte, nombre, descripcion, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
    VALUES (6, 'BAT-006', 'Batería 12V 60Ah Bosch', 'Batería de arranque para vehículos de motor a gasolina.', 45.00, 75.00, 2, 4, 1);

IF NOT EXISTS (SELECT 1 FROM producto WHERE id = 7)
    INSERT INTO producto (id, codigo_parte, nombre, descripcion, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
    VALUES (7, 'ACE-007', 'Aceite Sintético Mobil 1 5W30', 'Aceite totalmente sintético de alto rendimiento.', 8.00, 14.50, 6, 2, 1);

-- Productos con STOCK BAJO (para probar la alerta visual, stock <= 5)
IF NOT EXISTS (SELECT 1 FROM producto WHERE id = 8)
    INSERT INTO producto (id, codigo_parte, nombre, descripcion, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
    VALUES (8, 'AMO-008', 'Amortiguador Trasero Monroe', 'Amortiguador gas-oil de alto rendimiento.', 28.00, 55.00, 3, 3, 1);

IF NOT EXISTS (SELECT 1 FROM producto WHERE id = 9)
    INSERT INTO producto (id, codigo_parte, nombre, descripcion, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
    VALUES (9, 'BUJ-009', 'Bujía Bosch Doble Platino', 'Mayor durabilidad y eficiencia en el encendido.', 3.50, 7.00, 2, 4, 1);

IF NOT EXISTS (SELECT 1 FROM producto WHERE id = 10)
    INSERT INTO producto (id, codigo_parte, nombre, descripcion, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
    VALUES (10, 'SEN-010', 'Sensor de Oxígeno Bosch Universal', 'Sensor lambda de hilo calefactor para catalizador.', 22.00, 40.00, 2, 4, 1);

GO

-- 6. Inventario en Sucursal 1 para los productos nuevos
PRINT 'Insertando registros de inventario_sucursal (stock por sucursal)...';

-- Stock normal
IF NOT EXISTS (SELECT 1 FROM inventario_sucursal WHERE id_sucursal = 1 AND id_producto = 4)
    INSERT INTO inventario_sucursal (id_sucursal, id_producto, stock_actual, stock_minimo) VALUES (1, 4, 30, 5);

IF NOT EXISTS (SELECT 1 FROM inventario_sucursal WHERE id_sucursal = 1 AND id_producto = 5)
    INSERT INTO inventario_sucursal (id_sucursal, id_producto, stock_actual, stock_minimo) VALUES (1, 5, 15, 5);

IF NOT EXISTS (SELECT 1 FROM inventario_sucursal WHERE id_sucursal = 1 AND id_producto = 6)
    INSERT INTO inventario_sucursal (id_sucursal, id_producto, stock_actual, stock_minimo) VALUES (1, 6, 8, 5);

IF NOT EXISTS (SELECT 1 FROM inventario_sucursal WHERE id_sucursal = 1 AND id_producto = 7)
    INSERT INTO inventario_sucursal (id_sucursal, id_producto, stock_actual, stock_minimo) VALUES (1, 7, 40, 5);

-- Stock bajo (AlertaStock = TRUE)
IF NOT EXISTS (SELECT 1 FROM inventario_sucursal WHERE id_sucursal = 1 AND id_producto = 8)
    INSERT INTO inventario_sucursal (id_sucursal, id_producto, stock_actual, stock_minimo) VALUES (1, 8, 3, 5);   -- ALERTA

IF NOT EXISTS (SELECT 1 FROM inventario_sucursal WHERE id_sucursal = 1 AND id_producto = 9)
    INSERT INTO inventario_sucursal (id_sucursal, id_producto, stock_actual, stock_minimo) VALUES (1, 9, 2, 5);   -- ALERTA

IF NOT EXISTS (SELECT 1 FROM inventario_sucursal WHERE id_sucursal = 1 AND id_producto = 10)
    INSERT INTO inventario_sucursal (id_sucursal, id_producto, stock_actual, stock_minimo) VALUES (1, 10, 0, 5);  -- ALERTA (sin stock)

GO

PRINT '';
PRINT '=== Seed Inventario Completado ===';
PRINT 'Usuarios disponibles:';
PRINT '  - admin     / admin123  (Administrador Global)';
PRINT '  - bodeguero / bodega123 (Bodega y Compras)';
PRINT 'Productos con alerta de stock bajo: IDs 8, 9, 10';
