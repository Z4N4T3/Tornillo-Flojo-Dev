using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using TornilloFlojo.Web.Models;

namespace TornilloFlojo.Web.Controllers;

public class HomeController : Controller
{
    [HttpGet]
    public IActionResult Index()
    {
        return View(new LoginViewModel());
    }

    [HttpPost]
    public IActionResult Index(LoginViewModel model)
    {
        if (ModelState.IsValid)
        {
            // Lógica de autenticación iría aquí
            // Por ahora solo redirigimos para simular éxito
            return RedirectToAction("Index", "Home"); 
        }

        // Si hay errores, volver a mostrar la vista con el modelo
        return View(model);
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
