namespace TornilloFlojo.Web.Models.Ventas;

/// <summary>
/// DTO que mapea el result set devuelto por usp_Producto_BusquedaPOS.
/// Se devuelve como JSON al frontend via AJAX.
/// </summary>
public class ProductoBusquedaResult
{
    public int Id { get; set; }
    public string CodigoParte { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public decimal PrecioVenta { get; set; }
    public int StockActual { get; set; }
}
