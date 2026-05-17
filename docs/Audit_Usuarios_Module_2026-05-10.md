# Auditoría del Módulo de Usuarios — El Tornillo Flojo
**Fecha:** 2026-05-10  
**Auditor:** Desarrollador (App Layer)  
**Síntoma reportado:** Las vistas del módulo `/Usuarios` muestran datos estáticos hardcodeados en lugar de información real de la base de datos.

---

## 1. Hallazgos por Archivo

### 1.1 `Views/Usuarios/Index.cshtml` — ❌ Datos Estáticos en las Tarjetas de Resumen

**Tabla de usuarios (líneas 100-150):** ✅ Es dinámica — itera correctamente sobre `@Model` con `@foreach`.

**Tarjetas de estadísticas (líneas 16-67):** ❌ Completamente hardcodeadas:
| Elemento | Valor Hardcodeado | Valor Real en DB |
|---|---|---|
| Total de Usuarios | `42` (línea 27) | **1** |
| Admin | `4` (línea 42) | **1** |
| Vendedor | `24` (línea 48) | **0** |
| Cajero | `10` (línea 54) | **0** |
| Bodega | `4` (línea 60) | **0** |

**Paginación (líneas 154-164):** ❌ Hardcodeada — dice "Mostrando 1 a 3 de 42 registros" y los botones de página no funcionan.

### 1.2 `Views/Usuarios/Permisos.cshtml` — ❌ 100% Estática

Toda la matriz de permisos es HTML puro con checkboxes hardcodeados. No tiene:
- Ningún `@model` declarado (línea 1 es solo `@{ ViewData["Title"] = ... }`)
- Ningún `@foreach` para iterar roles ni permisos
- Ningún `asp-for` ni binding a datos del servidor
- Los roles en las columnas ("Administrador", "Gerente", "Cajero", "Bodega") están escritos a mano
- Los permisos en las filas están escritos a mano
- El estado de los checkboxes (checked/disabled) está fijo en el HTML

**Datos reales en la DB:**
- **5 roles** con permisos asignados via `rol_permiso`
- **13 permisos** registrados en la tabla `permiso`
- **36 registros** en `rol_permiso` que mapean qué rol tiene qué permiso

### 1.3 `Views/Usuarios/Create.cshtml` — ⚠️ Parcialmente Estática

El formulario usa correctamente `asp-for` para binding, pero los `<select>` de **Cargo** y **Rol** (líneas 55-73) tienen opciones hardcodeadas en lugar de cargar desde la DB:
```html
<!-- Cargo: hardcodeado -->
<option value="1">Gerente General</option>
<option value="2">Gerente de Tienda</option> <!-- ❌ No existe, es "Gerente de Sucursal" -->
...

<!-- Rol: hardcodeado con solo 4, existen 5 en DB -->
<option value="1">Administrador</option>
<option value="2">Vendedor</option>          <!-- ❌ Es "Ventas" en la DB -->
...
```

### 1.4 `Controllers/UsuariosController.cs` — ⚠️ Problemas Críticos

| Acción | Estado | Problema |
|---|---|---|
| `Index()` GET | ⚠️ Semi-funcional | La query SQL es correcta, PERO tiene un `catch` que silencia errores y devuelve **datos fake hardcodeados** (líneas 44-49). No envía estadísticas (total, distribución de roles) al View. |
| `Create()` GET | ❌ No carga catálogos | Retorna `View()` vacío sin cargar las listas de Cargos y Roles desde la DB |
| `Create()` POST | ❌ Sin lógica | Tiene `// TODO` en línea 65. No inserta nada en la DB |
| `Permisos()` | ❌ Sin lógica | Solo hace `return View()` sin enviar datos de la matriz `rol_permiso` |

---

## 2. Stored Procedures — Inventario

| SP Requerido | ¿Existe en DB? | Estado |
|---|---|---|
| `usp_Usuario_Login` | ✅ Sí | Funcional |
| `usp_Usuario_Listar` | ❌ No | **Necesario** — Listar usuarios con JOINs + estadísticas |
| `usp_Usuario_Crear` | ❌ No | **Necesario** — INSERT en `empleado` + `usuario` en transacción |
| `usp_Rol_Listar` | ❌ No | **Necesario** — Para poblar dropdown en Create |
| `usp_Cargo_Listar` | ❌ No | **Necesario** — Para poblar dropdown en Create |
| `usp_RolPermiso_Listar` | ❌ No | **Necesario** — Matriz de permisos por rol |
| `usp_RolPermiso_Actualizar` | ❌ No | **Necesario** — Guardar cambios en la matriz |

---

## 3. Modelos Faltantes

| Modelo | ¿Existe? | Estado |
|---|---|---|
| `UsuarioListViewModel` | ✅ | Correcto |
| `UsuarioCreateViewModel` | ✅ | Necesita agregar listas de Cargos/Roles |
| `UsuarioStatsViewModel` | ❌ | **Necesario** — Para las tarjetas de Total y Distribución |
| `PermisoMatrizViewModel` | ❌ | **Necesario** — Para la vista de Permisos |

---

## 4. Plan de Corrección

### Prioridad 1 — Stored Procedures (Base de Datos)
1. `usp_Usuario_Listar` — SELECT con JOINs existentes + query de estadísticas
2. `usp_Rol_Listar` — SELECT simple de la tabla `rol`
3. `usp_Cargo_Listar` — SELECT simple de la tabla `cargo`
4. `usp_RolPermiso_Listar` — PIVOT de la matriz rol-permiso
5. `usp_RolPermiso_Actualizar` — UPDATE/DELETE/INSERT en `rol_permiso`
6. `usp_Usuario_Crear` — INSERT transaccional en `empleado` + `usuario`

### Prioridad 2 — Backend (Controlador + Modelos)
1. Crear `UsuarioStatsViewModel` y `PermisoMatrizViewModel`
2. Refactorizar `UsuariosController.Index()` para enviar estadísticas + eliminar fallback estático
3. Implementar `UsuariosController.Permisos()` con carga dinámica
4. Implementar `UsuariosController.Create()` GET con catálogos y POST con inserción real

### Prioridad 3 — Frontend (Vistas Razor)
1. `Index.cshtml` — Reemplazar los números hardcodeados por `@Model.Stats.*`
2. `Permisos.cshtml` — Reescribir con `@model` y `@foreach` para roles y permisos
3. `Create.cshtml` — Reemplazar `<option>` hardcodeados por `asp-items`
