# 🔩 CLAUDE.md — Autopartes "El Tornillo Flojo"

Archivo de contexto para asistentes de IA. Contiene el estado real del proyecto, las convenciones de código y las reglas de negocio clave que deben respetarse en cada sesión.

---

## 1. Descripción del Proyecto

ERP web para gestión de inventario, facturación y punto de venta de una tienda de repuestos automotrices con soporte multi-sucursal. Proyecto universitario con stack Microsoft.

- **Nombre:** Autopartes El Tornillo Flojo
- **Tipo:** ERP / POS Web (monolítico, SSR)
- **Estado actual:** Fase de Modelado de Datos + Módulo de Usuarios en desarrollo activo

---

## 2. Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| Framework | ASP.NET Core 9 MVC (`net9.0`) |
| Lenguaje | C# |
| ORM / DAL | **Dapper** + `Microsoft.Data.SqlClient` (NO Entity Framework) |
| Base de Datos | SQL Server (MSSQL) — instancia local `localhost` |
| Frontend | Razor Views (CSHTML) + Bootstrap 5 |
| Solución | `TornilloFlojo.slnx` |

> **IMPORTANTE:** El proyecto usa **Dapper**, no Entity Framework. No sugerir migraciones EF ni DbContext. Toda lógica de BD va en Stored Procedures.

---

## 3. Estructura del Repositorio

```
Tornillo-Flojo/
├── TornilloFlojo.slnx              # Archivo de solución
├── TornilloFlojo.Web/              # Proyecto principal ASP.NET MVC
│   ├── Controllers/
│   │   ├── HomeController.cs       # Login (GET/POST)
│   │   └── UsuariosController.cs   # Gestión de usuarios (en desarrollo)
│   ├── Models/
│   │   ├── LoginViewModel.cs
│   │   ├── UsuarioCreateViewModel.cs
│   │   └── UsuarioListViewModel.cs
│   ├── Views/
│   │   ├── Home/Index.cshtml       # Pantalla de Login
│   │   ├── Usuarios/
│   │   │   ├── Index.cshtml        # Listado de usuarios
│   │   │   ├── Create.cshtml       # Formulario de creación
│   │   │   └── Permisos.cshtml     # Matriz de permisos (RBAC)
│   │   └── Shared/
│   │       └── _LoginLayout.cshtml # Layout sin navbar (solo login)
│   ├── wwwroot/
│   │   ├── bg-repuestos.jpg        # Imagen de fondo login
│   │   ├── css/, js/, lib/
│   │   └── favicon.ico
│   ├── Program.cs
│   ├── appsettings.json            # Connection string a localhost
│   └── TornilloFlojo.Web.csproj
├── Database/
│   ├── DB_TornilloFLojo.sql        # Esquema completo (fuente de verdad)
│   ├── 01_Seed_Geografia.sql       # Datos de departamentos/municipios/barrios
│   ├── 02_Seed_Seguridad.sql       # Seed de roles, permisos, estados
│   ├── 03_Seed_TestUser.sql        # Usuario de prueba
│   ├── SP_CRUD_GUIDELINES.md       # ⚠️ LEER ANTES DE CREAR SPs
│   ├── ER_Diagram_mermaid.txt      # Diagrama ER en Mermaid
│   ├── roles_permisos.md           # Cargos, roles y permisos definidos
│   └── DATABASE-SCHEMA-MIGRATION.md
├── docs/
│   ├── Requuisitos-funcionales.md  # RF-01 a RF-10
│   ├── Requuisitos-no-funcionales.md
│   ├── Modelo_Relacional_Mermaid.md
│   └── Diccionario-de-datos-Tornillo Flojo.csv
├── System_Analysis.md              # Arquitectura y decisiones técnicas
├── GEMINI.md                       # Bitácora de sesiones anteriores
└── Informe_Normalizacion.md        # Auditoría 1NF/2NF/3NF
```

---

## 4. Base de Datos

### Cadena de Conexión
```
Server=localhost;Database=DB_TornilloFlojo;Trusted_Connection=True;TrustServerCertificate=True;
```
Se inyecta vía `IConfiguration` con la clave `"DefaultConnection"`.

### Tablas Core (en orden de dependencia)

1. **`estado`** — Tabla de estados unificada (Activo/Inactivo/etc.) para todas las entidades
2. **`departamento` → `municipio` → `barrio`** — Geografía normalizada
3. **`sucursal`** — Entidad fundacional multi-sucursal (campo `es_principal`)
4. **`cargo`** — Puestos de RRHH (Gerente, Cajero, Asesor de Ventas...)
5. **`rol`** — Perfiles de acceso al sistema
6. **`permiso`** — Accesos granulares (ej: `FACTURA_CREAR`, `INVENTARIO_VER`)
7. **`rol_permiso`** — Relación M:N rol↔permiso
8. **`empleado`** — Personal (vinculado a `barrio` y `cargo`)
9. **`usuario`** — Credenciales (vinculado a `empleado`, `rol`, `sucursal`, `estado`)
10. **`usuario_permiso`** — Excepciones individuales de permiso
11. **`producto_categoria`**, **`producto_marca`** — Catálogos de clasificación
12. **`producto`** — Catálogo de repuestos (sin `stock_actual` — va en `inventario_sucursal`)
13. **`inventario_sucursal`** — PK compuesta (`id_sucursal`, `id_producto`); stock por sede
14. **`vehiculo_marca`**, **`vehiculo_modelo`**, **`producto_compatibilidad`** — Motor RF-02
15. **`cliente`**, **`proveedor`** — Terceros
16. **`turno_caja`** — Apertura/cierre de caja por usuario y sucursal
17. **`factura`**, **`factura_detalle`** — POS transaccional
18. **`compra`**, **`compra_detalle`** — Abastecimiento de proveedor
19. **`movimiento`** — Kardex inmutable (entradas/salidas de inventario)
20. **`gasto_operativo`** — Egresos no-inventariables (caja chica, servicios)

### Reglas de Negocio Críticas de BD

- **Sin `IDENTITY`:** Los IDs se generan manualmente en cada SP con:
  ```sql
  SELECT @NuevoId = ISNULL(MAX(id), 0) + 1 FROM Tabla WITH (UPDLOCK, SERIALIZABLE)
  ```
- **Sin DELETE físico:** Toda eliminación es un `UPDATE ... SET id_estado = [Inactivo]`
- **Stock nunca por UPDATE directo:** Solo mediante inserción en `movimiento` (Kardex)
- **Facturas/Compras** son inmutables; se anulan con transacciones de reverso

---

## 5. Convenciones de Stored Procedures

Prefijo: **`usp_`** (no `sp_`). Formato: `usp_Entidad_Accion`

```
usp_Producto_Insert
usp_Factura_GetById
usp_Usuario_Delete       → internamente hace UPDATE SET id_estado=Inactivo
usp_Factura_Emitir       → transacción compleja: factura + detalle + movimiento kardex
usp_Compra_Registrar     → transacción compleja: compra + detalle + movimiento kardex
```

**Estructura mínima de un SP:**
```sql
CREATE PROCEDURE usp_Entidad_Accion
    @Param1 INT, @Param2 VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN
            -- lógica aquí
        COMMIT TRAN
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
```

**Fases de implementación de SPs:**
1. Fundacionales: geografía, `estado`, `sucursal`
2. Catálogos y RBAC: productos, categorías, `rol`, `permiso`
3. Core: `producto`, `cliente`, `empleado`, `usuario`
4. Transaccionales: `factura`, `compra`, `movimiento` (kardex), `gasto_operativo`

---

## 6. Convenciones de Código C# / MVC

### Inyección de Conexión DB
```csharp
// En el constructor del Controller:
private readonly string _connectionString;
public MiController(IConfiguration configuration)
{
    _connectionString = configuration.GetConnectionString("DefaultConnection") ?? "";
}

// En cada acción:
using var connection = new SqlConnection(_connectionString);
var result = await connection.QueryAsync<MiViewModel>("usp_Entidad_Get");
```

### Patrón de Fallback (mientras BD no está lista)
Si la query falla, los controllers retornan datos de prueba hardcodeados para no bloquear el desarrollo de la UI. Ver `UsuariosController.Index()` como referencia.

### Layouts
- **`_Layout.cshtml`** — Layout general con navbar (todas las páginas internas)
- **`_LoginLayout.cshtml`** — Layout limpio, solo para `Views/Home/Index.cshtml`

### ViewModels
Todos los ViewModels usan **Data Annotations** para validación. Prefijo por módulo: `UsuarioCreateViewModel`, `UsuarioListViewModel`, etc.

---

## 7. Módulos y Estado de Implementación

| Módulo | Vista | Controller | SP | Estado |
|--------|-------|------------|----|--------|
| Login | ✅ Completo | ✅ Parcial (sin auth real) | ❌ | 🟡 UI lista, sin auth |
| Usuarios - Listado | ✅ Completo | ✅ Con fallback | ❌ | 🟡 UI lista, sin SP |
| Usuarios - Crear | ✅ Completo | 🟡 Stub (TODO) | ❌ | 🟡 UI lista, sin lógica |
| Usuarios - Permisos | ✅ Completo | 🟡 Stub (sin data) | ❌ | 🟡 UI lista, sin data |
| Inventario | ❌ | ❌ | ❌ | 🔴 No iniciado |
| Facturación / POS | ❌ | ❌ | ❌ | 🔴 No iniciado |
| Kardex | ❌ | ❌ | ❌ | 🔴 No iniciado |
| Compras | ❌ | ❌ | ❌ | 🔴 No iniciado |
| Reportes | ❌ | ❌ | ❌ | 🔴 No iniciado |

---

## 8. RBAC — Roles y Permisos Definidos

**Roles:**
- `Administrador Global` — Acceso total a todas las sucursales
- `Administrador Local` — Acceso total pero restringido a su `id_sucursal`
- `Caja y Facturación` — Módulo POS, clientes, turnos
- `Bodega y Compras` — Kardex, compras, traslados
- `Ventas (Solo Lectura)` — Consultas e inventario, sin manejo de caja

**Permisos granulares clave:**
`FACTURA_CREAR`, `FACTURA_ANULAR`, `TURNO_ABRIR`, `TURNO_CERRAR`, `GASTO_REGISTRAR`, `INVENTARIO_VER`, `PRODUCTO_CREAR_EDITAR`, `COMPRA_REGISTRAR`, `MOVIMIENTO_AJUSTAR`, `USUARIO_GESTIONAR`, `SUCURSAL_GESTIONAR`, `REPORTE_VENTAS_VER`, `REPORTE_KARDEX_VER`

---

## 9. Requisitos Funcionales (Resumen)

| ID | Módulo | Título |
|----|--------|--------|
| RF-01 | Inventario | Registro de Repuestos (SKU, marca, precios, categoría) |
| RF-02 | Inventario | Motor de Compatibilidad repuesto↔vehículo (N:M) |
| RF-03 | Inventario | Control de Stock via Kardex (sin UPDATE directo) |
| RF-04 | Inventario | Alertas visuales de stock bajo mínimo |
| RF-05 | Ventas | Proceso de Facturación con descuento de stock en tiempo real |
| RF-06 | Ventas | Inmutabilidad de precios en facturas históricas |
| RF-07 | Ventas | Gestión de Turnos con arqueo ciego |
| RF-08 | Ventas | Flujo de efectivo: ingresos + egresos operativos |
| RF-09 | Admin | Autenticación + bitácora de auditoría (fase futura) |
| RF-10 | Admin | Reportes exportables (ventas, rotación, stock bajo mínimo) |

**Decisiones tomadas:** Sin bimonetario (moneda única). Sin índices no agrupados por ahora. `DATETIME` en vez de `DATETIME2`. Auditoría (RF-09) en fase futura.

---

## 10. Próximos Pasos Prioritarios

1. **Stored Procedures `usp_Usuario_*`** — Conectar el módulo de Usuarios (Index, Create, Permisos) con la BD real
2. **Autenticación** — Implementar sesión/cookies en `HomeController` con `usp_Usuario_Login`
3. **SPs Fase 1-3** — Fundacionales → Catálogos → Core (ver `SP_CRUD_GUIDELINES.md`)
4. **Módulo de Inventario** — Vistas + Controller + SPs de `producto` e `inventario_sucursal`
5. **POS / Facturación** — `usp_Factura_Emitir` + vista de punto de venta

---

*Última actualización: Mayo 2026 | Generado automáticamente por análisis del proyecto*
