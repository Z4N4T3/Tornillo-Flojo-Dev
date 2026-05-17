using System.ComponentModel.DataAnnotations;

namespace TornilloFlojo.Web.Models;

public class InventarioViewModel
{
    public List<ProductoInventarioDto> Productos { get; set; } = new List<ProductoInventarioDto>();
    public List<CategoriaDto> Categorias { get; set; } = new List<CategoriaDto>();
    public List<MarcaDto> Marcas { get; set; } = new List<MarcaDto>();
}

public class ProductoInventarioDto
{
    public int Id { get; set; }
    public string CodigoParte { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public decimal? PrecioCosto { get; set; }
    public decimal PrecioVenta { get; set; }
    public int? IdMarca { get; set; }
    public string MarcaNombre { get; set; } = string.Empty;
    public int? IdCategoria { get; set; }
    public string CategoriaNombre { get; set; } = string.Empty;
    public int IdEstado { get; set; }
    public string EstadoNombre { get; set; } = string.Empty;
    
    // Inventory specific
    public int StockActual { get; set; }
    public int StockMinimo { get; set; }
    public bool AlertaStock { get; set; }
}

public class ProductoViewModel
{
    public int? Id { get; set; }
    
    [Required(ErrorMessage = "El código de parte es obligatorio.")]
    [Display(Name = "Código de Parte")]
    public string CodigoParte { get; set; } = string.Empty;
    
    [Required(ErrorMessage = "El nombre del producto es obligatorio.")]
    public string Nombre { get; set; } = string.Empty;
    
    public string? Descripcion { get; set; }
    
    [Display(Name = "Precio de Costo")]
    [Range(0, 9999999.99, ErrorMessage = "El precio debe ser un valor positivo.")]
    public decimal? PrecioCosto { get; set; }
    
    [Required(ErrorMessage = "El precio de venta es obligatorio.")]
    [Display(Name = "Precio de Venta")]
    [Range(0, 9999999.99, ErrorMessage = "El precio debe ser un valor positivo.")]
    public decimal PrecioVenta { get; set; }
    
    [Display(Name = "Marca")]
    public int? IdMarca { get; set; }
    
    [Display(Name = "Categoría")]
    public int? IdCategoria { get; set; }
    
    [Display(Name = "Estado")]
    public int IdEstado { get; set; } = 1;
}

public class CategoriaDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
}

public class MarcaDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
}
