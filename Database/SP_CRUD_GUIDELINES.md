# Guía de Creación de Procedimientos Almacenados (CRUD)
**Proyecto:** Autopartes "El Tornillo Flojo"

## 1. Análisis del Esquema y Tablas "Core"
Tras evaluar el esquema de la base de datos, he identificado las tablas centrales o "Core" que sostienen el modelo de negocio. La lógica de acceso a datos debe centrarse en estas entidades principales:

1. **`sucursal` (Estructura Base):** Tabla fundacional para operaciones multi-sucursal.
2. **`producto` e `inventario_sucursal` (Inventario):** Núcleo del catálogo y control de stock independiente por sucursal.
3. **`cliente` (Ventas):** Gestión de la cartera de clientes.
4. **`factura` y `factura_detalle` (Transaccional):** El punto de venta y control de cajas.
5. **`movimiento` (Kardex):** Historial inalterable de entradas y salidas de inventario por sucursal.
6. **`proveedor` y `compra` (Abastecimiento):** Gestión de compras de repuestos.
7. **`usuario`, `empleado` y RBAC (`rol`, `permiso`):** Accesos, roles y control de sucursal operativa.
8. **`gasto_operativo` (Financiero):** Flujo de efectivo y egresos no inventariables.

### Operaciones Requeridas por Tabla Core
*   **Catálogos (Productos, Clientes, Sucursales, Usuarios, Roles):**
    *   **Create:** Insertar nuevos registros con validaciones y control de concurrencia.
    *   **Read:** Búsquedas por ID (detallada) y listados paginados. Las consultas deben filtrar por `id_sucursal` cuando aplique para separar la vista de datos por tienda.
    *   **Update:** Modificación segura de datos generales. *(Atención: El stock de un producto **nunca** debe modificarse con un simple Update en `inventario_sucursal`, siempre debe generarse un registro en la tabla `movimiento`).*
    *   **Delete:** Aplicar siempre **Borrado Lógico (Soft Delete)** cambiando su `id_estado` (ej. Activo -> Inactivo).
*   **Transaccionales (Factura, Compra, Movimiento, Gasto Operativo):**
    *   **Create:** SPs complejos que insertan en maestro-detalle y disparan acciones secundarias (ej. Una factura genera un `movimiento` de salida que descuenta stock en `inventario_sucursal` de la tienda correspondiente).
    *   **Read:** Consultas pesadas (uso intensivo de JOINs), típicamente filtradas por `id_sucursal` y rangos de fecha.
    *   **Update / Delete:** Fuertemente restringidos (Anulaciones mediante transacciones de reverso o estados de anulación), sin borrado físico.

---

## 2. Consideraciones y Guidelines Principales (Reglas de Oro)

Para garantizar un código limpio, seguro y escalable, estableceremos las siguientes directrices al programar los Procedimientos Almacenados (SPs) en MSSQL:

> **1. Nomenclatura Estricta (No usar `sp_`)**
> Por convención, Microsoft SQL Server reserva el prefijo `sp_` para *System Procedures* almacenados en la base de datos `master`. Si creamos un SP con ese prefijo, el motor pierde tiempo buscándolo en `master` antes que en nuestra base de datos, afectando el rendimiento.
> *   **Convención a usar:** `usp_` (User Stored Procedure) seguido de la entidad y la acción. Ej: `usp_Producto_Insert`, `usp_Factura_GetById`.

> **2. Manejo Transaccional (ACID)**
> Cualquier procedimiento que involucre modificaciones en más de una tabla (Ej: Crear Factura, movimiento y FacturaDetalle al mismo tiempo) **debe** estar encapsulado en un bloque `BEGIN TRAN`, validar el éxito y finalizar con `COMMIT TRAN`. Si ocurre un error, debe hacer `ROLLBACK TRAN`.

> **3. Control y Captura de Errores**
> Todas las operaciones DML (Insert, Update, Delete) deben estar obligatoriamente dentro de un bloque `BEGIN TRY ... END TRY` y gestionar la captura en `BEGIN CATCH ... END CATCH` para retornar mensajes legibles a Entity Framework Core o la capa que lo consuma.

> **4. Generación Manual de Identidades (Sin IDENTITY)**
> Dado que se ha retirado la propiedad `IDENTITY(1,1)` de las tablas, los Procedimientos Almacenados de inserción (Create) serán los responsables de calcular y asignar el próximo ID disponible.
> *   Se debe utilizar una lógica del tipo `SELECT @NuevoId = ISNULL(MAX(id), 0) + 1 FROM Tabla WITH (UPDLOCK, SERIALIZABLE)`.
> *   Es **crucial** utilizar los hints `WITH (UPDLOCK, SERIALIZABLE)` o manejar la transacción con el nivel de aislamiento adecuado para evitar condiciones de carrera (duplicación de IDs) en entornos de alta concurrencia.

> **5. Protección de Datos (Borrado Lógico)**
> Bajo ninguna circunstancia los SPs de "Eliminación" ejecutarán comandos `DELETE FROM` sobre tablas Core o Históricas. El procedimiento llamado `usp_Entidad_Delete` ejecutará internamente un `UPDATE Entidad SET id_estado = [Inactivo] WHERE id = @Id`.

---

## 3. Instrucciones de Implementación (Flujo a Seguir)

Cuando comencemos a codificar, seguiremos esta ruta de implementación:

1.  **Fase 1: Fundacionales y Utilidad.** Procedimientos auxiliares y CRUD para tablas de geografía y estado (`estado`, `departamento`, `municipio`, `barrio`, `sucursal`).
2.  **Fase 2: Catálogos y Seguridad (RBAC).** CRUD para catálogos básicos (`producto_categoria`, `producto_marca`, `vehiculo_marca`) y la configuración de accesos (`rol`, `permiso`, `rol_permiso`).
3.  **Fase 3: Entidades Core.** CRUD robusto para `producto`, `cliente`, `proveedor`, `empleado` y `usuario` (contemplando la asignación de sucursal base y rol).
4.  **Fase 4: Inventario y Transacciones Maestras (Complejas).** 
    *   Lógica para gestionar `inventario_sucursal` y auditar en `movimiento`.
    *   `usp_Factura_Emitir`: Inserta factura, detalle, e invoca internamente el Kardex (`movimiento`) para restar inventario de la sucursal emisora.
    *   `usp_Compra_Registrar`: Inserta compra de proveedor, detalle, e invoca internamente el Kardex (`movimiento`) para sumar inventario en la sucursal receptora.
    *   CRUD para `gasto_operativo` asociado al `turno_caja` correspondiente.
