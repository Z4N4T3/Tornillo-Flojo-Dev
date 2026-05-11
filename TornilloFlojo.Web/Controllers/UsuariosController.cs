using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Dapper;
using TornilloFlojo.Web.Models;

namespace TornilloFlojo.Web.Controllers
{
    public class UsuariosController : Controller
    {
        private readonly string _connectionString;

        public UsuariosController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? "";
        }

        public async Task<IActionResult> Index()
        {
            using var connection = new SqlConnection(_connectionString);
            var query = @"
                SELECT 
                    u.id AS Id,
                    e.nombre1 + ' ' + ISNULL(e.apellido1, '') AS EmpleadoNombre,
                    e.identificacion AS Identificacion,
                    u.username + '@tornilloflojo.com' AS Contacto,
                    c.nombre AS CargoNombre,
                    r.nombre AS RolNombre,
                    st.nombre AS EstadoNombre,
                    SUBSTRING(e.nombre1, 1, 1) + SUBSTRING(ISNULL(e.apellido1, ''), 1, 1) AS Iniciales
                FROM usuario u
                INNER JOIN empleado e ON u.id_empleado = e.id
                LEFT JOIN cargo c ON e.id_cargo = c.id
                INNER JOIN rol r ON u.id_rol = r.id
                INNER JOIN estado st ON u.id_estado = st.id";
                
            IEnumerable<UsuarioListViewModel> usuarios;
            try
            {
                usuarios = await connection.QueryAsync<UsuarioListViewModel>(query);
            }
            catch (Exception)
            {
                // Fallback de prueba si las tablas no existen, están vacías o la conexión falla
                usuarios = new List<UsuarioListViewModel>
                {
                    new UsuarioListViewModel { Id = 1, EmpleadoNombre = "Roberto Carlos", Identificacion = "EMP-001", Contacto = "roberto@tornilloflojo.com", CargoNombre = "Gerente General", RolNombre = "admin", EstadoNombre = "Activo", Iniciales = "RC" },
                    new UsuarioListViewModel { Id = 2, EmpleadoNombre = "Maria Garcia", Identificacion = "EMP-042", Contacto = "mgarcia@tornilloflojo.com", CargoNombre = "Vendedora Mostrador", RolNombre = "seller", EstadoNombre = "Activo", Iniciales = "MG" },
                    new UsuarioListViewModel { Id = 3, EmpleadoNombre = "Juan Lopez", Identificacion = "EMP-088", Contacto = "jlopez@tornilloflojo.com", CargoNombre = "Cajero Principal", RolNombre = "cashier", EstadoNombre = "Inactivo", Iniciales = "JL" }
                };
            }

            return View(usuarios);
        }

        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Create(UsuarioCreateViewModel model)
        {
            if (ModelState.IsValid)
            {
                // TODO: Lógica para insertar en empleado y usuario mediante SP
                return RedirectToAction(nameof(Index));
            }
            return View(model);
        }

        public IActionResult Permisos()
        {
            return View();
        }
    }
}
