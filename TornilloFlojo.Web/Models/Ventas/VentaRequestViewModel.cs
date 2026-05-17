using System.ComponentModel.DataAnnotations;

namespace TornilloFlojo.Web.Models.Ventas;

/// <summary>
/// Modelo principal que recibe el POST del frontend al procesar una venta.
/// Se espera un JSON enviado via fetch() desde pos.js.
/// </summary>
public class VentaRequestViewModel
{
    [Required(ErrorMessage = "Debe seleccionar un cliente.")]
    public int IdCliente { get; set; }

    [Required]
    public decimal Subtotal { get; set; }

    [Required]
    public decimal Impuesto { get; set; }

    [Required]
    public decimal Total { get; set; }

    [Required(ErrorMessage = "El carrito no puede estar vacío.")]
    [MinLength(1, ErrorMessage = "Debe agregar al menos un producto.")]
    public List<DetalleVentaItem> Detalles { get; set; } = new();
}
