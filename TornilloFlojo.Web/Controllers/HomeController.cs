using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authentication;
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

    [HttpGet]
    public IActionResult Index()
    {
        if (User.Identity != null && User.Identity.IsAuthenticated)
        {
            return RedirectToAction("Index", "Usuarios");
        }
        return View(new LoginViewModel());
    }

    [HttpPost]
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

                return RedirectToAction("Index", "Usuarios");
            }
            
            ModelState.AddModelError(string.Empty, "Usuario o contraseña incorrectos.");
        }

        return View(model);
    }

    [HttpPost]
    public async Task<IActionResult> Logout()
    {
        await HttpContext.SignOutAsync("Cookies");
        return RedirectToAction("Index", "Home");
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
