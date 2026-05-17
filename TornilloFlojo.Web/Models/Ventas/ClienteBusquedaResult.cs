namespace TornilloFlojo.Web.Models.Ventas;

/// <summary>
/// DTO que mapea el result set devuelto por usp_Cliente_Busqueda.
/// Se devuelve como JSON al frontend via AJAX.
/// </summary>
public class ClienteBusquedaResult
{
    public int Id { get; set; }
    public string NombreCompleto { get; set; } = string.Empty;
    public string Identificacion { get; set; } = string.Empty;
    public string? Telefono { get; set; }
}
