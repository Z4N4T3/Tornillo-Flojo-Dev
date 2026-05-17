using System.Text.Json.Serialization;

namespace TornilloFlojo.Web.Models.Ventas;

/// <summary>
/// Representa una línea de detalle dentro del carrito de compras.
/// Se serializa a JSON para enviarlo al SP usp_Factura_Emitir (@detalles_json).
/// Los nombres de las propiedades JSON deben coincidir con lo que espera OPENJSON en el SP.
/// </summary>
public class DetalleVentaItem
{
    [JsonPropertyName("id_producto")]
    public int IdProducto { get; set; }

    [JsonPropertyName("cantidad")]
    public int Cantidad { get; set; }

    [JsonPropertyName("precio_unitario")]
    public decimal PrecioUnitario { get; set; }
}
