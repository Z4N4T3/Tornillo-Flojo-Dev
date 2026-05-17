namespace TornilloFlojo.Web.Models;
public class DashboardViewModel
{
    public int     VentasHoy              { get; set; }
    public decimal IngresosTotalesHoy     { get; set; }
    public int     ClientesAtendidosHoy   { get; set; }
    public int     ProductosBajoStock     { get; set; }
    public List<VentaDiaria> VentasSemanales { get; set; } = new();
    public decimal MaxVentaSemanal =>
        VentasSemanales.Count > 0 ? VentasSemanales.Max(v => v.TotalVentas) : 1;
}
public class VentaDiaria
{
    public DateTime Fecha           { get; set; }
    public int      CantidadVentas  { get; set; }
    public decimal  TotalVentas     { get; set; }
    public string DiaNombre => Fecha.ToString("ddd", new System.Globalization.CultureInfo("es-NI"))
                                    .Replace(".", "")
                                    .ToUpper();
    public int AlturaRelativa(decimal maxValor) =>
        maxValor > 0 ? (int)Math.Round((TotalVentas / maxValor) * 90) : 0;
}
