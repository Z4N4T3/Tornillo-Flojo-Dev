using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Dapper;
using TornilloFlojo.Web.Models;
namespace TornilloFlojo.Web.Controllers;
[Authorize]
public class DashboardController : Controller
{
    private readonly string _connectionString;
    public DashboardController(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection") ?? "";
    }
    public async Task<IActionResult> Index()
    {
        var model = new DashboardViewModel();
        using var connection = new SqlConnection(_connectionString);
        try
        {
            using var multi = await connection.QueryMultipleAsync(
                "usp_Dashboard_GetResumen",
                commandType: System.Data.CommandType.StoredProcedure
            );
            var kpi = await multi.ReadFirstOrDefaultAsync<dynamic>();
            if (kpi != null)
            {
                model.VentasHoy            = (int)(kpi.VentasHoy ?? 0);
                model.IngresosTotalesHoy   = (decimal)(kpi.IngresosTotalesHoy ?? 0m);
                model.ClientesAtendidosHoy = (int)(kpi.ClientesAtendidosHoy ?? 0);
                model.ProductosBajoStock   = (int)(kpi.ProductosBajoStock ?? 0);
            }
            var semanales = await multi.ReadAsync<VentaDiaria>();
            model.VentasSemanales = semanales.ToList();
        }
        catch (SqlException)
        {
            model.VentasHoy            = 0;
            model.IngresosTotalesHoy   = 0;
            model.ClientesAtendidosHoy = 0;
            model.ProductosBajoStock   = 0;
            model.VentasSemanales      = new List<VentaDiaria>();
            ViewBag.SpPendiente = true;
        }
        return View(model);
    }
}
