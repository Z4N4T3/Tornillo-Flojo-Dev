# Auditoría de Login — El Tornillo Flojo
**Fecha:** 2026-05-10  
**Auditor:** Antigravity (DB Layer)  
**Síntoma reportado:** Al ingresar `admin` / `admin123` en el formulario de login, el sistema no hace nada.

---

## 1. Resultado de la Auditoría — Capa de Base de Datos

**Veredicto: ✅ La base de datos está correcta. El problema NO es de este lado.**

Query ejecutada:
```sql
SELECT u.id, u.username, u.password_hash, u.id_estado,
       e.nombre AS estado, r.nombre AS rol, s.nombre AS sucursal
FROM usuario u
LEFT JOIN estado e ON e.id = u.id_estado
LEFT JOIN rol r    ON r.id = u.id_rol
LEFT JOIN sucursal s ON s.id = u.id_sucursal;
```

Resultado:

| Campo | Valor |
|---|---|
| `id` | 1 |
| `username` | admin |
| `password_hash` | admin123 |
| `id_estado` | 1 (Activo) |
| `rol` | Administrador Global |
| `sucursal` | Casa Matriz Managua |

El registro existe, está **Activo**, tiene un **rol asignado** y una **sucursal asignada**. No hay ningún problema de integridad de datos.

---

## 2. Causa Raíz Identificada — Capa de Aplicación (.NET)

**Archivo:** `TornilloFlojo.Web/Controllers/HomeController.cs`

El método `[HttpPost] Index(LoginViewModel model)` **no contiene ninguna lógica de autenticación**. Al recibir el formulario con datos válidos, redirige al propio Login (`GET /`), creando un loop que simula que "no pasa nada".

```csharp
[HttpPost]
public IActionResult Index(LoginViewModel model)
{
    if (ModelState.IsValid)
    {
        // ❌ SIN LÓGICA: No consulta la base de datos
        // ❌ No valida username/password
        // ❌ No establece sesión de usuario
        return RedirectToAction("Index", "Home"); // Vuelve al mismo Login
    }
    return View(model);
}
```

---

## 3. Trabajo Pendiente para el Equipo de Backend

Para resolver el problema, el equipo de backend debe implementar en `HomeController.cs`:

1. **Crear un Stored Procedure** `usp_Usuario_Login` que reciba `@username` y `@password_hash` y retorne los datos del usuario si las credenciales son válidas.
2. **Consultar la DB** desde el `POST` del controlador usando `Dapper` o `ADO.NET` directamente.
3. **Establecer la sesión** del usuario autenticado (HttpContext.Session o Cookie de autenticación).
4. **Redirigir al Dashboard** en caso de éxito, o devolver error en caso de credenciales inválidas.

> **Nota de seguridad:** El campo `password_hash` actualmente almacena texto plano (`admin123`). Cuando se implemente la autenticación real, **este valor debe reemplazarse por el hash BCrypt o PBKDF2** que genere la capa de Identity de ASP.NET Core.
