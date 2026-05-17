namespace TornilloFlojo.Web.Models.Ventas;
public class ProductoBusquedaResult
{
    public int Id { get; set; }
    public string CodigoParte { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public decimal PrecioVenta { get; set; }
    public int StockActual { get; set; }
}
