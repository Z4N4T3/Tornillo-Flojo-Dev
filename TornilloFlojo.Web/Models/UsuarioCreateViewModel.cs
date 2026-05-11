using System.ComponentModel.DataAnnotations;

namespace TornilloFlojo.Web.Models
{
    public class UsuarioCreateViewModel
    {
        [Required(ErrorMessage = "El nombre completo es requerido")]
        public string NombreCompleto { get; set; } = string.Empty;

        [Required(ErrorMessage = "La identificación es requerida")]
        public string Identificacion { get; set; } = string.Empty;

        [EmailAddress(ErrorMessage = "Correo electrónico inválido")]
        public string? Email { get; set; }

        public string? Telefono { get; set; }

        [Required(ErrorMessage = "Seleccione un cargo")]
        public int IdCargo { get; set; }

        [Required(ErrorMessage = "Seleccione un rol")]
        public int IdRol { get; set; }

        [Required(ErrorMessage = "El nombre de usuario es requerido")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña temporal es requerida")]
        [DataType(DataType.Password)]
        public string PasswordTemporal { get; set; } = string.Empty;
    }
}
