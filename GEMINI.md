# 🤖 Bitácora y Contexto de IA (GEMINI)

Este archivo sirve como "memoria" y bitácora de las decisiones arquitectónicas, cambios recientes y sugerencias aplicadas al proyecto "Autopartes El Tornillo Flojo". Se actualizará continuamente para mantener el contexto entre sesiones y no saturar el documento oficial del proyecto.

## 📌 Estado Actual del Proyecto
* **Fase:** Modelado y Normalización de Base de Datos.
* **Stack Principal:** .NET 8, SQL Server (MSSQL).
* **Documento Core de Arquitectura:** `System_Analysis.md`

---

## 📝 Historial de Cambios y Decisiones Clave

### [Mayo 2026] Implementación de RBAC (Roles y Permisos)
* **Contexto:** Se solicitó incluir un sistema de permisos dinámicos y roles predefinidos.
* **Decisión:** Se adoptó un modelo mixto con tablas `rol`, `permiso`, `rol_permiso` (M:N) y `usuario_permiso` (M:N).
* **Impacto:** Permite tener perfiles como 'Vendedor' o 'Administrador', y otorgar excepciones (permisos extra) a usuarios individuales sin alterar el rol base.
* **Archivos modificados:** `DB_TornilloFLojo.sql`

### [Mayo 2026] Normalización de Base de Datos (1NF, 2NF, 3NF)
* **Contexto:** Auditoría académica de las formas normales.
* **Cambios aplicados:** 
  * Se corrigió la tabla `cliente` dividiendo `nombre_completo` en atributos atómicos para cumplir con la **1NF**.
  * Se generó el `Informe_Normalizacion.md`.
  * Se actualizó `Diccionario-de-datos-Tornillo Flojo.csv` incluyendo la columna "Restricciones" (PK, FK, NOT NULL).
* **Desnormalizaciones aceptadas:** Se decidió mantener `stock_actual` en `producto` y los `totales` en facturas por razones de rendimiento (práctica común en sistemas POS), documentándolo debidamente.

### [Mayo 2026] Soporte Multi-Sucursal
* **Contexto:** Se solicitó que el sistema soporte una o varias sucursales físicas de la tienda.
* **Decisión:** Se creó la tabla `sucursal` como entidad fundacional (antes de Security & HR) que se enlaza a `barrio` para reutilizar la geografía ya modelada. Se incluyó la bandera `es_principal` para identificar la casa matriz.
* **Tablas modificadas con `id_sucursal`:** `empleado`, `usuario`, `compra`, `movimiento`, `turno_caja`, `factura`.
* **Impacto en Inventario:** Se eliminaron `stock_actual` y `stock_minimo` de la tabla `producto` y se creó la tabla `inventario_sucursal` (PK compuesta: `id_sucursal`, `id_producto`), permitiendo que cada sucursal lleve su propio kardex de existencias.
* **Archivos modificados:** `DB_TornilloFLojo.sql`, `ER_Diagram_mermaid.txt`, `Diccionario-de-datos-Tornillo Flojo.csv`.

### [Mayo 2026] Consolidación Inicial del Esquema
* **Contexto:** Refactorización de la base de datos de un taller a un punto de venta y kardex.
* **Decisión:** Se creó el script consolidado `DB_TornilloFLojo.sql` y las reglas de Stored Procedures en `SP_CRUD_GUIDELINES.md`.

---

## 💡 Próximos Pasos Sugeridos
- [x] **Diccionario de datos:** Actualizar el CSV para incluir las nuevas tablas de roles y permisos, y las tablas que faltaban originalmente.
- [ ] **Lógica de Negocio (Kardex):** Desarrollar los Procedimientos Almacenados (Stored Procedures) que actualizarán automáticamente el `stock_actual` del producto cuando se inserte un registro en `movimiento`.
- [ ] **Backend:** Iniciar el setup de la solución en Visual Studio (.NET 8) y configurar el Entity Framework Core (*Database-First* o *Code-First* según se decida).
