using System.ComponentModel.DataAnnotations;

namespace TornilloFlojo.Web.Models
{
    public class UsuarioCreateViewModel
    {
        // ── Datos del Empleado ──────────────────────────────────────────────
        [Required(ErrorMessage = "El primer nombre es requerido")]
        [Display(Name = "Primer Nombre")]
        public string Nombre1 { get; set; } = string.Empty;

        [Display(Name = "Segundo Nombre")]
        public string? Nombre2 { get; set; }

        [Required(ErrorMessage = "El primer apellido es requerido")]
        [Display(Name = "Primer Apellido")]
        public string Apellido1 { get; set; } = string.Empty;

        [Display(Name = "Segundo Apellido")]
        public string? Apellido2 { get; set; }

        [Required(ErrorMessage = "La identificación (cédula) es requerida")]
        [Display(Name = "Cédula / Identificación")]
        public string Identificacion { get; set; } = string.Empty;

        [Display(Name = "Cargo")]
        [Required(ErrorMessage = "Seleccione un cargo")]
        public int IdCargo { get; set; }

        // ── Credenciales del Usuario del Sistema ────────────────────────────
        [Required(ErrorMessage = "El nombre de usuario es requerido")]
        [Display(Name = "Nombre de Usuario")]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña temporal es requerida")]
        [DataType(DataType.Password)]
        [Display(Name = "Contraseña Temporal")]
        public string PasswordTemporal { get; set; } = string.Empty;

        [Required(ErrorMessage = "Seleccione un rol del sistema")]
        [Display(Name = "Rol del Sistema")]
        public int IdRol { get; set; }
    }
}
