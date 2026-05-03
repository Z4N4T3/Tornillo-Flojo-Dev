# Sistema de Gestión para Tienda de Autopartes (Migración desde NicaPOS)

Este documento describe la migración de un esquema base (NicaPOS) hacia un sistema especializado de **Punto de Venta e Inventario de Autopartes** ("El Tornillo Flojo"). Aprovecha las fortalezas arquitectónicas existentes y las adapta estrictamente a los requerimientos de la venta de repuestos, abandonando el modelo de taller mecánico.

## Buenas Prácticas Arquitectónicas (Mantenidas)

- **Gestión de Estados:** Uso unificado de la tabla `estado` en todas las entidades para trazabilidad del ciclo de vida (Activo, Inactivo, etc.).
- **Geografía Normalizada:** Localización en tres niveles (`departamento` -> `municipio` -> `barrio`) para clientes y empleados.
- **Auditoría e Historial:** Registro inalterable de existencias mediante una estructura de **Kardex**, asegurando la integridad de los datos de inventario y costos.
- **Lógica Encapsulada:** Las reglas de negocio y transacciones complejas se mantienen estrictamente dentro de Procedimientos Almacenados (`usp_...`). Se eliminó el uso de `IDENTITY`, generando los IDs manualmente para evitar condiciones de carrera.
- **Seguridad Basada en Roles:** Control de acceso granular usando `rol` y `usuario` vinculados a la tabla de `estado`.

## Migración Estructural Clave

### 1. Recursos Humanos y Seguridad (Mantenido)
Se mantienen las tablas fundacionales de personal: `empleado`, `cargo`, y `usuario`.

### 2. Inventario y Abastecimiento (Nuevo Enfoque)
Se refactorizó el modelo para centrarse en compras y catálogo de repuestos:
- `producto`: Repuestos automotrices con precio de venta, donde el stock es un valor calculable.
- `producto_categoria`: Clasificación técnica (Motor, Suspensión, Eléctrico, etc.).
- `proveedor` y `compra`: Gestión de suplidores y facturas de entrada para abastecer el inventario de la tienda.

### 3. Compatibilidad de Repuestos (Nuevo)
A diferencia de un taller que registra los vehículos de los clientes, la tienda registra **qué repuestos le sirven a qué vehículos**:
```sql
CREATE TABLE vehiculo_marca (id INT PRIMARY KEY, nombre VARCHAR(100));
CREATE TABLE vehiculo_modelo (id INT PRIMARY KEY, nombre VARCHAR(100), id_marca INT FOREIGN KEY REFERENCES vehiculo_marca(id));

-- Relación de Muchos a Muchos
CREATE TABLE producto_compatibilidad (
    id INT PRIMARY KEY,
    id_producto INT FOREIGN KEY REFERENCES producto(id),
    id_modelo INT FOREIGN KEY REFERENCES vehiculo_modelo(id),
    anio_inicio INT NOT NULL,
    anio_fin INT NOT NULL
);
```

### 4. Transaccional: Facturación y Kardex
Se eliminó por completo el concepto de Órdenes de Trabajo y Servicios, siendo reemplazado por un modelo de Retail/POS:
- **Punto de Venta:** Apertura y cierre mediante `turno_caja`, procesando ventas a través de `factura` y `factura_detalle`.
- **Kardex (`kardex`):** Entidad central que audita todas las entradas (compras/ajustes) y salidas (ventas) de inventario.

## Instrucciones de Migración y Operación (MSSQL)

1.  **Inicialización:** El esquema se construye a partir de `DB_TornilloFLojo.sql`, el cual ya incluye las tablas adaptadas para la venta de autopartes.
2.  **Módulo de Compras:** Las entradas de inventario se gestionarán mediante `usp_Compra_Registrar`, que insertará la compra y sumará al `kardex`.
3.  **Módulo de Ventas:** Las salidas se gestionarán mediante `usp_Factura_Emitir`, que insertará la factura y restará del `kardex`.
4.  **Generación de IDs (Importante):** Todos los procedimientos almacenados de inserción (`Create`) deben autogenerar su ID leyendo el máximo actual y sumando 1, aislando la transacción con `WITH (UPDLOCK, SERIALIZABLE)`.

## Próximos Pasos (TODO)
- [ ] Desarrollar los Procedimientos Almacenados base (CRUD) siguiendo las directrices del documento `SP_CRUD_GUIDELINES.md`.
- [ ] Implementar validaciones en el SP de Facturación para impedir transacciones si el saldo en el Kardex es insuficiente.
- [ ] Construir un script de Carga de Datos inicial (`Seed Data`) para marcas, modelos, categorías y estados.
