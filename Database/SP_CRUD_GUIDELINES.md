# Guía de Creación de Procedimientos Almacenados (CRUD)
**Proyecto:** Autopartes "El Tornillo Flojo"

## 1. Análisis del Esquema y Tablas "Core"
Tras evaluar el esquema de la base de datos, he identificado las tablas centrales o "Core" que sostienen el modelo de negocio. La lógica de acceso a datos debe centrarse en estas entidades principales:

1. **`producto` (Inventario):** El núcleo del catálogo. 
2. **`cliente` (Ventas):** Gestión de la cartera de clientes.
3. **`factura` y `factura_detalle` (Transaccional):** El punto de venta.
4. **`kardex` (Auditoría de Inventario):** Historial inalterable de movimientos.
5. **`proveedor` y `compra` (Abastecimiento):** Gestión de compras de repuestos.
6. **`usuario` y `empleado` (Seguridad/RH):** Accesos y roles.

### Operaciones Requeridas por Tabla Core
*   **Catálogos (Productos, Clientes, Usuarios):**
    *   **Create:** Insertar nuevos registros con validaciones.
    *   **Read:** Búsquedas por ID (detallada) y listados paginados (búsquedas por nombre o código).
    *   **Update:** Modificación segura de datos generales. *(Atención: El stock de un producto **nunca** debe modificarse con un simple Update, siempre debe ser resultado del Kardex).*
    *   **Delete:** Aplicar siempre **Borrado Lógico (Soft Delete)** cambiando su `id_estado` (ej. Activo -> Inactivo).
*   **Transaccionales (Factura, Compra, Kardex):**
    *   **Create:** SPs complejos que insertan en maestro-detalle y disparan acciones secundarias (ej. Una factura descuenta stock en Kardex, una compra incrementa stock).
    *   **Read:** Consultas pesadas (uso intensivo de JOINs).
    *   **Update / Delete:** Usualmente fuertemente restringidos (Anulaciones), sin borrado físico.

---

## 2. Consideraciones y Guidelines Principales (Reglas de Oro)

Para garantizar un código limpio, seguro y escalable, estableceremos las siguientes directrices al programar los Procedimientos Almacenados (SPs) en MSSQL:

> **1. Nomenclatura Estricta (No usar `sp_`)**
> Por convención, Microsoft SQL Server reserva el prefijo `sp_` para *System Procedures* almacenados en la base de datos `master`. Si creamos un SP con ese prefijo, el motor pierde tiempo buscándolo en `master` antes que en nuestra base de datos, afectando el rendimiento.
> *   **Convención a usar:** `usp_` (User Stored Procedure) seguido de la entidad y la acción. Ej: `usp_Producto_Insert`, `usp_Factura_GetById`.

> **2. Manejo Transaccional (ACID)**
> Cualquier procedimiento que involucre modificaciones en más de una tabla (Ej: Crear Factura, Kardex y FacturaDetalle al mismo tiempo) **debe** estar encapsulado en un bloque `BEGIN TRAN`, validar el éxito y finalizar con `COMMIT TRAN`. Si ocurre un error, debe hacer `ROLLBACK TRAN`.

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

1.  **Fase 1: Utilidad.** Crear procedimientos auxiliares (ej. generación de consecutivos para facturas o mapeo de estados).
2.  **Fase 2: Catálogos Simples.** (Create, Read, Update, SoftDelete) para catálogos como `estado`, `producto_categoria`, `vehiculo_marca`, etc.
3.  **Fase 3: Entidades Core.** CRUD robusto para `producto`, `cliente`, `proveedor`, `usuario`.
4.  **Fase 4: Transacciones Maestras (Complejas).** 
    *   `usp_Factura_Emitir`: Inserta factura, detalle, e invoca internamente el Kardex para restar inventario.
    *   `usp_Compra_Registrar`: Inserta compra de proveedor, detalle, e invoca internamente el Kardex para sumar inventario.
