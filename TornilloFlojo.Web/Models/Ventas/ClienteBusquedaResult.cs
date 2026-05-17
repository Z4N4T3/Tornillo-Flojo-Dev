namespace TornilloFlojo.Web.Models.Ventas;
public class ClienteBusquedaResult
{
    public int Id { get; set; }
    public string NombreCompleto { get; set; } = string.Empty;
    public string Identificacion { get; set; } = string.Empty;
    public string? Telefono { get; set; }
}
