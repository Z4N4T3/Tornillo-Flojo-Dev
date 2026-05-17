# 🔒 Auditoría Exhaustiva de Seguridad — TornilloFlojo.Web
**Fecha:** 2026-05-10  
**Auditor:** Antigravity  
**Alcance:** Proyecto completo `TornilloFlojo.Web` — Autenticación, Autorización, Configuración, Manejo de Errores, Exposición de Datos.

---

## Resumen Ejecutivo

| Severidad | Hallazgos |
|---|---|
| 🔴 **CRÍTICO** | 3 |
| 🟠 **ALTO** | 4 |
| 🟡 **MEDIO** | 3 |
| 🔵 **BAJO** | 2 |
| **TOTAL** | **12** |

**Veredicto general:** El proyecto tiene fallas de seguridad severas. La más grave es la **ausencia total del atributo `[Authorize]`** en el controlador `UsuariosController`, lo que permite que cualquier usuario no autenticado acceda a todas las vistas del módulo de gestión de usuarios simplemente navegando a la URL directa.

---

## 🔴 Hallazgos CRÍTICOS

### CRIT-01: Ausencia total de `[Authorize]` en `UsuariosController`
**Archivo:** `Controllers/UsuariosController.cs`  
**Línea:** 8 (declaración de clase)  
**Impacto:** Cualquier persona puede acceder a `/Usuarios`, `/Usuarios/Create` y `/Usuarios/Permisos` **sin autenticarse**.

**Estado actual:**
```csharp
public class UsuariosController : Controller  // ❌ SIN [Authorize]
{
    public async Task<IActionResult> Index() { ... }  // ❌ Acceso libre
    public IActionResult Create() { ... }              // ❌ Acceso libre
    public IActionResult Create(UsuarioCreateViewModel model) { ... } // ❌ Acceso libre
    public IActionResult Permisos() { ... }            // ❌ Acceso libre
}
```

**Lo que debería ser:**
```csharp
[Authorize]  // ✅ Requerir autenticación para TODO el controlador
public class UsuariosController : Controller
{
    [Authorize(Roles = "Administrador Global")]  // ✅ Solo admin puede ver la lista
    public async Task<IActionResult> Index() { ... }

    [Authorize(Roles = "Administrador Global")]  // ✅ Solo admin puede crear usuarios
    public IActionResult Create() { ... }

    [Authorize(Roles = "Administrador Global")]  // ✅ Solo admin puede gestionar permisos
    public IActionResult Permisos() { ... }
}
```

---

### CRIT-02: Ausencia de `[Authorize]` en `HomeController` para rutas protegidas
**Archivo:** `Controllers/HomeController.cs`  
**Líneas:** 73-76 (acción `Privacy`)  
**Impacto:** La vista `Privacy` es accesible sin autenticar. Además, la acción `Logout` no exige estar autenticado.

| Acción | ¿Tiene `[Authorize]`? | ¿Debería? |
|---|---|---|
| `Index` GET | ❌ No | No (es el login) |
| `Index` POST | ❌ No | No (es el login) |
| `Logout` POST | ❌ No | ✅ **Sí** — solo un usuario autenticado puede cerrar sesión |
| `Privacy` GET | ❌ No | ✅ **Sí** — solo usuarios autenticados |
| `Error` GET | ❌ No | No (debe ser accesible siempre) |

---

### CRIT-03: No existe una política de autorización global (Fallback Policy)
**Archivo:** `Program.cs`  
**Impacto:** Cualquier controlador o acción nuevo que se agregue al proyecto será accesible sin autenticación **por defecto**, a menos que el desarrollador recuerde agregar `[Authorize]` manualmente. Este es un patrón "inseguro por defecto".

**Estado actual (Program.cs, línea 4):**
```csharp
builder.Services.AddControllersWithViews();  // ❌ Sin política global
```

**Corrección recomendada — Filtro global + excepción explícita para Login:**
```csharp
builder.Services.AddControllersWithViews(options =>
{
    // ✅ TODAS las acciones requieren autenticación por defecto
    var policy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();
    options.Filters.Add(new AuthorizeFilter(policy));
});
```
Y en `HomeController`, marcar explícitamente las acciones públicas:
```csharp
[AllowAnonymous]  // ✅ Excepción explícita para la página de login
public IActionResult Index() { ... }
```

---

## 🟠 Hallazgos ALTOS

### HIGH-01: Datos fallback hardcodeados exponen información al público
**Archivo:** `Controllers/UsuariosController.cs`  
**Líneas:** 41-49  
**Impacto:** Si la base de datos no responde, el controlador devuelve datos falsos (nombres, identificaciones, correos) visibles sin autenticación.

```csharp
catch (Exception)
{
    // ❌ SILENCIA el error y devuelve datos fake
    usuarios = new List<UsuarioListViewModel>
    {
        new() { EmpleadoNombre = "Roberto Carlos", Identificacion = "EMP-001", ... },
        new() { EmpleadoNombre = "Maria Garcia",   Identificacion = "EMP-042", ... },
        ...
    };
}
```

**Riesgo:** 
1. Oculta errores de conexión reales (la app parece funcionar cuando no lo está).
2. Los datos fake podrían confundirse con datos reales por los usuarios.

**Corrección:** Eliminar el fallback, dejar que el error se propague y mostrar una página de error genérica.

---

### HIGH-02: Contraseña de base de datos en texto plano en `appsettings.json`
**Archivo:** `appsettings.json` (línea 3) y `Database/00_Create_AppLogin.sql` (línea 10)  
**Impacto:** Las credenciales `tornillo_app / TornilloApp#2026!` están en texto plano en el repositorio Git.

```json
"DefaultConnection": "Server=192.168.0.13;Database=DB_TornilloFlojo;User Id=tornillo_app;Password=TornilloApp#2026!;..."
```

**Riesgos:**
- Cualquier persona con acceso al repositorio obtiene las credenciales de la DB.
- El archivo `appsettings.json` está **commiteado** (no está en `.gitignore`).
- El script `00_Create_AppLogin.sql` también contiene la contraseña.

**Corrección recomendada:**
1. Mover la cadena de conexión a `appsettings.Development.json` (ya ignorado en `.gitignore`).
2. En producción, usar **variables de entorno** o **User Secrets** de .NET.

---

### HIGH-03: La contraseña de usuario se almacena como texto plano en la DB
**Referencia:** `docs/Audit_Login_2026-05-10.md` (línea 28)  
**Evidencia:** El campo `password_hash` contiene `admin123` en texto plano.  
**Impacto:** Si un atacante obtiene acceso de lectura a la tabla `usuario`, todas las contraseñas están expuestas sin ningún tipo de hash.

**Corrección:** Implementar hashing con **BCrypt** o **PBKDF2** antes de almacenar las contraseñas. El SP `usp_Usuario_Login` debe comparar hashes, no texto plano.

---

### HIGH-04: Cookie de autenticación sin configuración de seguridad
**Archivo:** `Program.cs` (líneas 6-10)

```csharp
builder.Services.AddAuthentication("Cookies")
    .AddCookie("Cookies", options =>
    {
        options.LoginPath = "/Home/Index";
        // ❌ Falta: ExpireTimeSpan (timeout de sesión)
        // ❌ Falta: SlidingExpiration
        // ❌ Falta: Cookie.HttpOnly = true (ya es default, pero debe ser explícito)
        // ❌ Falta: Cookie.SecurePolicy (HTTPS only)
        // ❌ Falta: Cookie.SameSite
        // ❌ Falta: AccessDeniedPath (redirigir si no tiene permiso)
    });
```

**Corrección recomendada:**
```csharp
.AddCookie("Cookies", options =>
{
    options.LoginPath = "/Home/Index";
    options.AccessDeniedPath = "/Home/AccessDenied";
    options.ExpireTimeSpan = TimeSpan.FromMinutes(30);
    options.SlidingExpiration = true;
    options.Cookie.HttpOnly = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    options.Cookie.SameSite = SameSiteMode.Strict;
});
```

---

## 🟡 Hallazgos MEDIOS

### MED-01: No hay protección Anti-Forgery (`[ValidateAntiForgeryToken]`) en los POST
**Archivos:** `HomeController.cs` (líneas 30, 66), `UsuariosController.cs` (línea 60)  
**Impacto:** Las acciones POST son vulnerables a ataques **CSRF** (Cross-Site Request Forgery).

| Acción POST | ¿Tiene `[ValidateAntiForgeryToken]`? |
|---|---|
| `Home/Index` POST (login) | ❌ No |
| `Home/Logout` POST | ❌ No |
| `Usuarios/Create` POST | ❌ No |

**Nota:** Las vistas sí generan el token implícitamente via `<form asp-action="...">`, pero el servidor **no lo valida** porque falta el atributo en el controlador.

---

### MED-02: El _Layout.cshtml expone enlaces de navegación sin verificar autenticación
**Archivo:** `Views/Shared/_Layout.cshtml` (líneas 23-32)

```html
<ul class="navbar-nav flex-grow-1">
    <li class="nav-item">
        <a class="nav-link" asp-controller="Usuarios" asp-action="Index">Usuarios</a>  <!-- ❌ Siempre visible -->
    </li>
    <li class="nav-item">
        <a class="nav-link" asp-controller="Usuarios" asp-action="Permisos">Permisos</a>  <!-- ❌ Siempre visible -->
    </li>
</ul>
```

**Corrección:** Usar `@if(User.Identity.IsAuthenticated)` y verificaciones de rol para mostrar/ocultar enlaces condicionalmente. Además, agregar un botón de Logout para usuarios autenticados.

---

### MED-03: El servidor corre en HTTP sin redirección forzosa a HTTPS
**Archivo:** `Properties/launchSettings.json` (perfil activo: `http`, línea 8)

El perfil de lanzamiento predeterminado es `http` en el puerto `5079`. Aunque `Program.cs` tiene `app.UseHttpsRedirection()`, el servidor arranca solo en HTTP, por lo que las cookies de autenticación viajan **sin cifrar** en la red local.

---

## 🔵 Hallazgos BAJOS

### LOW-01: `UseStaticFiles()` está después de `UseAuthorization()` en el pipeline
**Archivo:** `Program.cs` (líneas 25-28)

```csharp
app.UseAuthentication();   // Línea 25
app.UseAuthorization();    // Línea 26
app.UseStaticFiles();      // Línea 28 ← ❌ Debería estar ANTES
```

**Impacto:** Todos los archivos estáticos (CSS, JS, imágenes) pasan por el pipeline de autenticación/autorización innecesariamente. Aunque no genera un bloqueo, es un patrón incorrecto que podría causar problemas si se aplica una política global.

**Corrección:** Mover `app.UseStaticFiles()` antes de `app.UseAuthentication()`.

---

### LOW-02: No existe una vista `AccessDenied`
**Impacto:** Si se implementa autorización por roles y un usuario autenticado intenta acceder a un recurso para el que no tiene permisos, recibirá un error genérico 403 o será redirigido al login (confuso).

---

## Mapa de Rutas y Estado de Seguridad

| Ruta | Controlador | Acción | Auth Requerida | Rol Requerido | Estado |
|---|---|---|---|---|---|
| `/` | Home | Index GET | ❌ No | — | ✅ OK (es el login) |
| `/` | Home | Index POST | ❌ No | — | ✅ OK (procesa el login) |
| `/Home/Logout` | Home | Logout POST | ❌ No | — | 🟠 Debería requerir auth |
| `/Home/Privacy` | Home | Privacy GET | ❌ No | — | 🟡 Debería requerir auth |
| `/Home/Error` | Home | Error GET | ❌ No | — | ✅ OK (debe ser público) |
| `/Usuarios` | Usuarios | Index GET | ❌ **No** | — | 🔴 **CRÍTICO** |
| `/Usuarios/Create` | Usuarios | Create GET | ❌ **No** | — | 🔴 **CRÍTICO** |
| `/Usuarios/Create` | Usuarios | Create POST | ❌ **No** | — | 🔴 **CRÍTICO** |
| `/Usuarios/Permisos` | Usuarios | Permisos GET | ❌ **No** | — | 🔴 **CRÍTICO** |

---

## Plan de Remediación Priorizado

### 🔴 Inmediato (antes de desplegar)
1. **Agregar `[Authorize]` a `UsuariosController`** a nivel de clase.
2. **Agregar filtro global `AuthorizeFilter`** en `Program.cs` y marcar las acciones públicas con `[AllowAnonymous]`.
3. **Mover `UseStaticFiles()` antes de `UseAuthentication()`** en el pipeline.
4. **Agregar `[ValidateAntiForgeryToken]`** a todas las acciones POST.
5. **Eliminar los datos fallback hardcodeados** en el catch de `UsuariosController.Index()`.

### 🟠 Corto plazo (esta semana)
6. **Configurar la cookie de autenticación** con `ExpireTimeSpan`, `SecurePolicy`, `SameSite`, y `AccessDeniedPath`.
7. **Mover credenciales de DB** a `appsettings.Development.json` o User Secrets.
8. **Implementar hashing de contraseñas** (BCrypt/PBKDF2).

### 🟡 Mediano plazo
9. **Implementar autorización por roles** en cada acción según el sistema RBAC diseñado en la DB.
10. **Crear vista `AccessDenied`** para respuestas 403 amigables.
11. **Condicionar la navegación del `_Layout`** según el usuario autenticado y su rol.
12. **Forzar HTTPS** como perfil de lanzamiento predeterminado.

---

> **Nota:** Este informe es complementario a los documentos `Audit_Login_2026-05-10.md` y `Audit_Usuarios_Module_2026-05-10.md` que cubren los hallazgos funcionales (datos estáticos, SPs faltantes). El presente documento se enfoca exclusivamente en **seguridad y acceso no autorizado**.
