using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Dapper;
using TornilloFlojo.Web.Models;

namespace TornilloFlojo.Web.Controllers;

/// <summary>
/// Dashboard principal del ERP. Requiere sesión autenticada.
/// Consulta el SP usp_Dashboard_GetResumen para obtener KPIs en tiempo real.
/// </summary>
[Authorize] // ✅ CRIT-02: todas las acciones requieren autenticación
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

        // ── Ejecutar SP con múltiples result sets usando QueryMultiple ─────────
        // NOTA: Si el SP aún no existe, la consulta de fallback devuelve ceros
        // para no bloquear el desarrollo frontend. Ver 08_usp_Dashboard.sql.
        try
        {
            using var multi = await connection.QueryMultipleAsync(
                "usp_Dashboard_GetResumen",
                commandType: System.Data.CommandType.StoredProcedure
            );

            // Result Set 1: KPIs del día (una sola fila)
            var kpi = await multi.ReadFirstOrDefaultAsync<dynamic>();
            if (kpi != null)
            {
                model.VentasHoy            = (int)(kpi.VentasHoy ?? 0);
                model.IngresosTotalesHoy   = (decimal)(kpi.IngresosTotalesHoy ?? 0m);
                model.ClientesAtendidosHoy = (int)(kpi.ClientesAtendidosHoy ?? 0);
                model.ProductosBajoStock   = (int)(kpi.ProductosBajoStock ?? 0);
            }

            // Result Set 2: Ventas de los últimos 7 días para el gráfico
            var semanales = await multi.ReadAsync<VentaDiaria>();
            model.VentasSemanales = semanales.ToList();
        }
        catch (SqlException)
        {
            // SP todavía no creado en BD → el Dashboard renderiza con ceros.
            // Cuando el equipo de BD ejecute 08_usp_Dashboard.sql, los datos
            // aparecerán automáticamente sin necesidad de cambiar código.
            model.VentasHoy            = 0;
            model.IngresosTotalesHoy   = 0;
            model.ClientesAtendidosHoy = 0;
            model.ProductosBajoStock   = 0;
            model.VentasSemanales      = new List<VentaDiaria>();

            // ⬇ Opcional: agrega el error al ViewBag para un banner de aviso en dev
            ViewBag.SpPendiente = true;
        }

        return View(model);
    }
}
