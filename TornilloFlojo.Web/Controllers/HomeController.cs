using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.Data.SqlClient;
using Dapper;
using TornilloFlojo.Web.Models;

namespace TornilloFlojo.Web.Controllers;

public class HomeController : Controller
{
    private readonly string _connectionString;

    public HomeController(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection") ?? "";
    }

    // ✅ CRIT-02/CRIT-03: Login es público — excepción explícita al filtro global
    [AllowAnonymous]
    [HttpGet]
    public IActionResult Index()
    {
        if (User.Identity != null && User.Identity.IsAuthenticated)
        {
            return RedirectToAction("Index", "Dashboard");
        }
        return View(new LoginViewModel());
    }

    // ✅ Login POST también es público
    [AllowAnonymous]
    [HttpPost]
    [ValidateAntiForgeryToken] // ✅ MED-01: Protección contra CSRF
    public async Task<IActionResult> Index(LoginViewModel model)
    {
        if (ModelState.IsValid)
        {
            using var connection = new SqlConnection(_connectionString);
            
            var user = await connection.QueryFirstOrDefaultAsync<dynamic>(
                "usp_Usuario_Login",
                new { username = model.Username, password_hash = model.Password },
                commandType: System.Data.CommandType.StoredProcedure
            );

            if (user != null)
            {
                var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.Name, user.username),
                    new Claim(ClaimTypes.Role, user.RolNombre),
                    new Claim("Id", user.id.ToString())
                };

                var identity = new ClaimsIdentity(claims, "Cookies");
                var principal = new ClaimsPrincipal(identity);

                await HttpContext.SignInAsync("Cookies", principal);

                return RedirectToAction("Index", "Dashboard");
            }
            
            ModelState.AddModelError(string.Empty, "Usuario o contraseña incorrectos.");
        }

        return View(model);
    }

    // ✅ CRIT-02: Logout requiere autenticación — solo un usuario logueado puede cerrar sesión
    [Authorize]
    [HttpPost]
    [ValidateAntiForgeryToken] // ✅ MED-01: Protección contra CSRF
    public async Task<IActionResult> Logout()
    {
        await HttpContext.SignOutAsync("Cookies");
        return RedirectToAction("Index", "Home");
    }

    // ✅ Privacy requiere autenticación (cubierta por el filtro global)
    public IActionResult Privacy()
    {
        return View();
    }

    // ✅ LOW-02: Vista de Acceso Denegado para usuarios sin permisos suficientes
    [AllowAnonymous]
    public IActionResult AccessDenied()
    {
        return View();
    }

    // ✅ Error debe ser público para que siempre pueda renderizarse
    [AllowAnonymous]
    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
