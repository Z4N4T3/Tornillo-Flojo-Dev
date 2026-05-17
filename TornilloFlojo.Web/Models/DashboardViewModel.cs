namespace TornilloFlojo.Web.Models;

/// <summary>
/// KPIs del día y ventas semanales para la vista principal del Dashboard.
/// </summary>
public class DashboardViewModel
{
    // ── KPIs del día ──────────────────────────────────────────────────────────
    public int     VentasHoy              { get; set; }
    public decimal IngresosTotalesHoy     { get; set; }
    public int     ClientesAtendidosHoy   { get; set; }
    public int     ProductosBajoStock     { get; set; }

    // ── Gráfico semanal ───────────────────────────────────────────────────────
    public List<VentaDiaria> VentasSemanales { get; set; } = new();

    // ── Máximo para calcular alturas relativas del gráfico de barras ──────────
    public decimal MaxVentaSemanal =>
        VentasSemanales.Count > 0 ? VentasSemanales.Max(v => v.TotalVentas) : 1;
}

/// <summary>
/// Un punto de datos para el gráfico de rendimiento semanal.
/// </summary>
public class VentaDiaria
{
    public DateTime Fecha           { get; set; }
    public int      CantidadVentas  { get; set; }
    public decimal  TotalVentas     { get; set; }

    // Nombre del día en español para el eje X
    public string DiaNombre => Fecha.ToString("ddd", new System.Globalization.CultureInfo("es-NI"))
                                    .Replace(".", "")
                                    .ToUpper();

    // Altura de la barra como porcentaje (0-100) relativo al máximo de la semana
    public int AlturaRelativa(decimal maxValor) =>
        maxValor > 0 ? (int)Math.Round((TotalVentas / maxValor) * 90) : 0;
}
