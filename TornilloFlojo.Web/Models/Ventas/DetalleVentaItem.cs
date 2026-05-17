using System.Text.Json.Serialization;
namespace TornilloFlojo.Web.Models.Ventas;
public class DetalleVentaItem
{
    [JsonPropertyName("id_producto")]
    public int IdProducto { get; set; }
    [JsonPropertyName("cantidad")]
    public int Cantidad { get; set; }
    [JsonPropertyName("precio_unitario")]
    public decimal PrecioUnitario { get; set; }
}
