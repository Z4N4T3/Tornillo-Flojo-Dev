# Estructura de Acceso y Recursos Humanos - DB Tornillo Flojo

Este documento define la estructura propuesta de Cargos, Roles y Permisos basada en el esquema relacional del sistema de gestión de inventario y punto de venta para la empresa de autopartes **Tornillo Flojo**.

## 1. Cargos (Tabla `cargo`)
Representan los puestos de trabajo físicos dentro de la empresa (Recursos Humanos).

* **Gerente General:** Responsable de toda la operación, compras mayores y finanzas de todas las sucursales.
* **Gerente de Sucursal:** Encargado de la operación diaria, supervisión de personal y flujos de caja de una sucursal específica.
* **Jefe de Bodega / Inventario:** Responsable de recibir proveedores, gestionar el Kardex y asegurar el stock mínimo.
* **Asesor de Ventas (Mostrador):** Atiende a los clientes, verifica compatibilidad de repuestos y prepara pedidos.
* **Cajero:** Encargado exclusivo del flujo de dinero, apertura/cierre de turnos y facturación.

---

## 2. Roles del Sistema (Tabla `rol`)
Representan los perfiles de acceso al software. Agrupan un conjunto de permisos predeterminados.

* **Administrador Global:** Acceso total al sistema en todas las sucursales (Configuración, RRHH, Reportes financieros).
* **Administrador Local:** Acceso casi total, pero restringido a su `id_sucursal` (no puede ver ventas de otras sedes).
* **Caja y Facturación:** Acceso a los módulos de punto de venta (POS), clientes y turnos de caja.
* **Bodega y Compras:** Acceso al Kardex, registro de compras a proveedores y traslados de inventario.
* **Ventas (Solo Lectura/Cotización):** Acceso para consultar inventario, compatibilidad de vehículos y pre-facturación, pero sin manejo de efectivo.

---

## 3. Permisos (Tabla `permiso`)
Estos son los accesos granulares que se asignarán a los roles (mediante `rol_permiso`) o a usuarios específicos para excepciones (mediante `usuario_permiso`).

### Módulo de Ventas y Caja
* `FACTURA_CREAR`: Emitir nuevas facturas.
* `FACTURA_ANULAR`: Cancelar facturas emitidas (generalmente requiere rol gerencial).
* `TURNO_ABRIR`: Iniciar un turno de caja con monto inicial.
* `TURNO_CERRAR`: Finalizar el turno y declarar el monto final.
* `GASTO_REGISTRAR`: Registrar salidas de efectivo operativas de la caja chica.

### Módulo de Inventario y Bodega
* `INVENTARIO_VER`: Consultar stock, precios y compatibilidad de repuestos.
* `PRODUCTO_CREAR_EDITAR`: Modificar catálogo, precios y categorías.
* `COMPRA_REGISTRAR`: Ingresar facturas de proveedores al sistema.
* `MOVIMIENTO_AJUSTAR`: Forzar entradas o salidas en el Kardex (ajustes por pérdida/merma).

### Módulo Administrativo y Configuración
* `USUARIO_GESTIONAR`: Crear empleados, credenciales y asignar roles.
* `SUCURSAL_GESTIONAR`: Modificar datos de las ubicaciones físicas.
* `REPORTE_VENTAS_VER`: Acceder a métricas de ingresos.
* `REPORTE_KARDEX_VER`: Auditar el historial de movimientos de inventario.