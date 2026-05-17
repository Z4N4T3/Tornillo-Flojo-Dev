using System.ComponentModel.DataAnnotations;
namespace TornilloFlojo.Web.Models
{
    public class UsuarioListViewModel
    {
        public int Id { get; set; }
        public string EmpleadoNombre { get; set; } = string.Empty;
        public string Identificacion { get; set; } = string.Empty;
        public string Contacto { get; set; } = string.Empty;
        public string CargoNombre { get; set; } = string.Empty;
        public string RolNombre { get; set; } = string.Empty;
        public string EstadoNombre { get; set; } = string.Empty;
        public string Iniciales { get; set; } = string.Empty;
    }
}
