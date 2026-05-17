using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.Data.SqlClient;
using Dapper;
using TornilloFlojo.Web.Models;
namespace TornilloFlojo.Web.Controllers
{
    [Authorize(Roles = "Administrador Global,Administrador Local")]
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
            var usuarios = await connection.QueryAsync<UsuarioListViewModel>(query);
            ViewBag.TotalUsuarios = usuarios.Count();
            ViewBag.AdminCount = usuarios.Count(u => u.RolNombre == "Administrador");
            ViewBag.VendedorCount = usuarios.Count(u => u.RolNombre == "Vendedor");
            ViewBag.CajeroCount = usuarios.Count(u => u.RolNombre == "Cajero");
            ViewBag.BodegaCount = usuarios.Count(u => u.RolNombre == "Bodega");
            return View(usuarios);
        }
        public async Task<IActionResult> Create()
        {
            await CargarDropdowns();
            return View(new UsuarioCreateViewModel());
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(UsuarioCreateViewModel model)
        {
            if (!ModelState.IsValid)
            {
                await CargarDropdowns();
                return View(model);
            }
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            var existe = await connection.ExecuteScalarAsync<int>(
                "SELECT COUNT(1) FROM usuario WHERE username = @username",
                new { username = model.Username });
            if (existe > 0)
            {
                ModelState.AddModelError(nameof(model.Username), "Ese nombre de usuario ya está en uso.");
                await CargarDropdowns();
                return View(model);
            }
            var idSucursal = await connection.ExecuteScalarAsync<int?>(
                "SELECT TOP 1 id_sucursal FROM usuario WHERE username = @username",
                new { username = User.Identity!.Name });
            var pEmpleado = new DynamicParameters();
            pEmpleado.Add("@nombre1",        model.Nombre1);
            pEmpleado.Add("@nombre2",        model.Nombre2);
            pEmpleado.Add("@apellido1",      model.Apellido1);
            pEmpleado.Add("@apellido2",      model.Apellido2);
            pEmpleado.Add("@identificacion", model.Identificacion);
            pEmpleado.Add("@id_cargo",       model.IdCargo);
            pEmpleado.Add("@id_sucursal",    idSucursal);
            pEmpleado.Add("@id_estado",      1);
            pEmpleado.Add("@NuevoId", dbType: System.Data.DbType.Int32,
                          direction: System.Data.ParameterDirection.Output);
            await connection.ExecuteAsync(
                "usp_Empleado_Insert",
                pEmpleado,
                commandType: System.Data.CommandType.StoredProcedure);
            int idEmpleado = pEmpleado.Get<int>("@NuevoId");
            var pUsuario = new DynamicParameters();
            pUsuario.Add("@username",      model.Username);
            pUsuario.Add("@password_hash", model.PasswordTemporal);
            pUsuario.Add("@id_empleado",   idEmpleado);
            pUsuario.Add("@id_rol",        model.IdRol);
            pUsuario.Add("@id_sucursal",   idSucursal);
            pUsuario.Add("@id_estado",     1);
            pUsuario.Add("@NuevoId", dbType: System.Data.DbType.Int32,
                         direction: System.Data.ParameterDirection.Output);
            await connection.ExecuteAsync(
                "usp_Usuario_Insert",
                pUsuario,
                commandType: System.Data.CommandType.StoredProcedure);
            TempData["Exito"] = $"Usuario '{model.Username}' creado exitosamente.";
            return RedirectToAction(nameof(Index));
        }
        public IActionResult Permisos()
        {
            return View();
        }
        private async Task CargarDropdowns()
        {
            using var connection = new SqlConnection(_connectionString);
            var cargos = await connection.QueryAsync(
                "SELECT id AS Value, nombre AS Text FROM cargo WHERE id_estado = 1 ORDER BY nombre");
            var roles = await connection.QueryAsync(
                "SELECT id AS Value, nombre AS Text FROM rol WHERE id_estado = 1 ORDER BY nombre");
            ViewBag.Cargos = new SelectList(cargos, "Value", "Text");
            ViewBag.Roles  = new SelectList(roles,  "Value", "Text");
        }
    }
}
