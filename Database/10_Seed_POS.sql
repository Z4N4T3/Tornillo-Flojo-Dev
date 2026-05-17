USE [DB_TornilloFlojo];
GO

IF NOT EXISTS(SELECT 1 FROM tipo_movimiento WHERE id = 1)
    INSERT INTO tipo_movimiento (id, nombre, multiplicador) VALUES (1, 'Entrada por Compra', 1);

IF NOT EXISTS(SELECT 1 FROM tipo_movimiento WHERE id = 2)
    INSERT INTO tipo_movimiento (id, nombre, multiplicador) VALUES (2, 'Salida por Venta', -1);

IF NOT EXISTS(SELECT 1 FROM tipo_movimiento WHERE id = 3)
    INSERT INTO tipo_movimiento (id, nombre, multiplicador) VALUES (3, 'Ajuste de Inventario', 0);


IF NOT EXISTS(SELECT 1 FROM cliente WHERE id = 1)
BEGIN
    IF NOT EXISTS(SELECT 1 FROM barrio WHERE id = 1)
    BEGIN
        IF NOT EXISTS(SELECT 1 FROM estado WHERE id=1) INSERT INTO estado(id, nombre) VALUES (1, 'Activo');
        IF NOT EXISTS(SELECT 1 FROM departamento WHERE id=1) INSERT INTO departamento(id, nombre) VALUES(1, 'Granada');
        IF NOT EXISTS(SELECT 1 FROM municipio WHERE id=1) INSERT INTO municipio(id, nombre, id_dep) VALUES(1, 'Granada', 1);
        INSERT INTO barrio (id, nombre, id_mun) VALUES (1, 'Centro Historico', 1);
    END
    
    INSERT INTO cliente (id, nombre1, apellido1, identificacion, id_barrio) 
    VALUES (1, 'Consumidor', 'Final', '000-000000-0000X', 1);
END


IF NOT EXISTS(SELECT 1 FROM producto_marca WHERE id = 1)
    INSERT INTO producto_marca (id, nombre) VALUES (1, 'Genérica');
    
IF NOT EXISTS(SELECT 1 FROM producto_categoria WHERE id = 1)
    INSERT INTO producto_categoria (id, nombre) VALUES (1, 'Accesorios y Consumibles');

IF NOT EXISTS(SELECT 1 FROM producto WHERE id = 1)
    INSERT INTO producto (id, codigo_parte, nombre, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
    VALUES (1, 'BUJ-001', 'Bujía NGK BKR6E', 2.50, 4.00, 1, 1, 1);
    
IF NOT EXISTS(SELECT 1 FROM producto WHERE id = 2)
    INSERT INTO producto (id, codigo_parte, nombre, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
    VALUES (2, 'FIL-002', 'Filtro de Aceite Premium', 5.00, 8.50, 1, 1, 1);
    
IF NOT EXISTS(SELECT 1 FROM producto WHERE id = 3)
    INSERT INTO producto (id, codigo_parte, nombre, precio_costo, precio_venta, id_marca, id_categoria, id_estado)
    VALUES (3, 'ACE-003', 'Aceite Motor 10W40 (Litro)', 6.00, 9.00, 1, 1, 1);


IF NOT EXISTS(SELECT 1 FROM sucursal WHERE id = 1)
    INSERT INTO sucursal (id, nombre, id_barrio, es_principal, id_estado) VALUES (1, 'Sucursal Central', 1, 1, 1);

IF NOT EXISTS(SELECT 1 FROM inventario_sucursal WHERE id_sucursal = 1 AND id_producto = 1)
    INSERT INTO inventario_sucursal (id_sucursal, id_producto, stock_actual, stock_minimo) VALUES (1, 1, 100, 10);
    
IF NOT EXISTS(SELECT 1 FROM inventario_sucursal WHERE id_sucursal = 1 AND id_producto = 2)
    INSERT INTO inventario_sucursal (id_sucursal, id_producto, stock_actual, stock_minimo) VALUES (1, 2, 50, 5);
    
IF NOT EXISTS(SELECT 1 FROM inventario_sucursal WHERE id_sucursal = 1 AND id_producto = 3)
    INSERT INTO inventario_sucursal (id_sucursal, id_producto, stock_actual, stock_minimo) VALUES (1, 3, 200, 20);


IF NOT EXISTS(SELECT 1 FROM turno_caja WHERE id = 1)
BEGIN
    IF EXISTS(SELECT 1 FROM usuario WHERE id = 1)
    BEGIN
        INSERT INTO turno_caja (id, id_usuario, id_sucursal, fecha_apertura, monto_inicial, id_estado)
        VALUES (1, 1, 1, GETDATE(), 1000.00, 1);
    END
END
GO
