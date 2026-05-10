USE [DB_TornilloFlojo];
GO

PRINT 'Insertando Estados (Prerrequisito)...';
-- Aseguramos que existan los estados básicos antes de insertar cargos y roles
IF NOT EXISTS (SELECT 1 FROM estado WHERE id = 1)
BEGIN
    INSERT INTO estado (id, nombre) VALUES 
    (1, 'Activo'), 
    (2, 'Inactivo'), 
    (3, 'Anulado');
END
GO

PRINT 'Insertando Cargos (Recursos Humanos)...';
INSERT INTO cargo (id, nombre, descripcion, salario_base, id_estado) VALUES
(1, 'Gerente General', 'Responsable de toda la operación y finanzas.', 50000.00, 1),
(2, 'Gerente de Sucursal', 'Encargado de la operación diaria de una sucursal.', 35000.00, 1),
(3, 'Jefe de Bodega', 'Gestión de Kardex y recepción de proveedores.', 25000.00, 1),
(4, 'Asesor de Ventas', 'Atención al cliente y cotizaciones en mostrador.', 15000.00, 1),
(5, 'Cajero', 'Manejo de flujo de efectivo y facturación.', 18000.00, 1);
GO

PRINT 'Insertando Roles del Sistema...';
INSERT INTO rol (id, nombre, descripcion, id_estado) VALUES
(1, 'Administrador Global', 'Acceso total al sistema en todas las sucursales.', 1),
(2, 'Administrador Local', 'Acceso casi total, restringido a su sucursal.', 1),
(3, 'Caja y Facturación', 'Acceso a POS, clientes y turnos de caja.', 1),
(4, 'Bodega y Compras', 'Acceso a inventario, compras y traslados.', 1),
(5, 'Ventas', 'Acceso a consultas y cotizaciones, sin manejo de dinero.', 1);
GO

PRINT 'Insertando Permisos Granulares...';
INSERT INTO permiso (id, nombre, descripcion) VALUES
-- Ventas y Caja
(1, 'FACTURA_CREAR', 'Emitir nuevas facturas.'),
(2, 'FACTURA_ANULAR', 'Cancelar facturas emitidas.'),
(3, 'TURNO_ABRIR', 'Iniciar un turno de caja.'),
(4, 'TURNO_CERRAR', 'Finalizar el turno de caja.'),
(5, 'GASTO_REGISTRAR', 'Registrar salidas de efectivo de caja chica.'),
-- Inventario
(6, 'INVENTARIO_VER', 'Consultar stock y compatibilidad.'),
(7, 'PRODUCTO_CREAR_EDITAR', 'Modificar catálogo de productos.'),
(8, 'COMPRA_REGISTRAR', 'Ingresar compras de proveedores.'),
(9, 'MOVIMIENTO_AJUSTAR', 'Ajustes manuales en el Kardex.'),
-- Admin
(10, 'USUARIO_GESTIONAR', 'Crear y modificar empleados/usuarios.'),
(11, 'SUCURSAL_GESTIONAR', 'Modificar datos de sucursales.'),
(12, 'REPORTE_VENTAS_VER', 'Acceder a métricas de ingresos.'),
(13, 'REPORTE_KARDEX_VER', 'Auditar historial de inventario.');
GO

PRINT 'Asignando Permisos a Roles (Matriz rol_permiso)...';
-- Administrador Global (Rol 1): Tiene todos los permisos (1 al 13)
INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT 1, id FROM permiso;

-- Administrador Local (Rol 2): Tiene todo excepto SUCURSAL_GESTIONAR (11)
INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT 2, id FROM permiso WHERE id != 11;

-- Caja y Facturación (Rol 3): Abrir/Cerrar Turno, Facturar, Gasto Operativo, Ver Inventario
INSERT INTO rol_permiso (id_rol, id_permiso) VALUES
(3, 1), (3, 3), (3, 4), (3, 5), (3, 6);

-- Bodega y Compras (Rol 4): Ver inventario, Modificar Producto, Registrar Compras, Ajustes de Inventario, Reportes de Kardex
INSERT INTO rol_permiso (id_rol, id_permiso) VALUES
(4, 6), (4, 7), (4, 8), (4, 9), (4, 13);

-- Ventas (Rol 5): Solo ver inventario para atención al cliente y cotizaciones
INSERT INTO rol_permiso (id_rol, id_permiso) VALUES
(5, 6);
GO

PRINT 'Carga de datos de Seguridad y RRHH completada exitosamente.';
