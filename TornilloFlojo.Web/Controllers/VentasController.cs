using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Dapper;
using TornilloFlojo.Web.Models.Ventas;
using TornilloFlojo.Web.Models;
namespace TornilloFlojo.Web.Controllers
{
    [Authorize]
    public class VentasController : Controller
    {
        private readonly string _connectionString;
        public VentasController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? "";
        }
        public async Task<IActionResult> NuevaVenta()
        {
            return View();
        }

        [HttpGet]
        public async Task<IActionResult> GetCategorias()
        {
            using var connection = new SqlConnection(_connectionString);
            var categorias = await connection.QueryAsync<CategoriaDto>(
                "SELECT id AS Id, nombre AS Nombre FROM producto_categoria ORDER BY nombre"
            );
            return Json(categorias);
        }

        [HttpGet]
        public async Task<IActionResult> BuscarProducto(string q, int? idSucursal, int? idCategoria)
        {
            if (string.IsNullOrWhiteSpace(q) || q.Length < 2)
                return Json(new List<ProductoBusquedaResult>());
            int sucursal = idSucursal ?? await ObtenerIdSucursalUsuario();
            using var connection = new SqlConnection(_connectionString);
            var productos = await connection.QueryAsync<ProductoBusquedaResult>(
                "usp_Producto_BusquedaPOS",
                new { id_sucursal = sucursal, busqueda = q },
                commandType: System.Data.CommandType.StoredProcedure
            );
            return Json(productos);
        }
        [HttpGet]
        public async Task<IActionResult> BuscarCliente(string q)
        {
            if (string.IsNullOrWhiteSpace(q) || q.Length < 2)
                return Json(new List<ClienteBusquedaResult>());
            using var connection = new SqlConnection(_connectionString);
            var clientes = await connection.QueryAsync<ClienteBusquedaResult>(
                "usp_Cliente_Busqueda",
                new { busqueda = q },
                commandType: System.Data.CommandType.StoredProcedure
            );
            return Json(clientes);
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ProcesarVenta([FromBody] VentaRequestViewModel model)
        {
            if (!ModelState.IsValid)
            {
                var errores = ModelState.Values
                    .SelectMany(v => v.Errors)
                    .Select(e => e.ErrorMessage);
                return Json(new { success = false, error = string.Join(" | ", errores) });
            }
            try
            {
                int userId = ObtenerIdUsuario();
                int idSucursal = await ObtenerIdSucursalUsuario();
                string detallesJson = JsonSerializer.Serialize(model.Detalles);
                var p = new DynamicParameters();
                p.Add("@id_cliente", model.IdCliente);
                p.Add("@id_turno_caja", 1);
                p.Add("@id_sucursal", idSucursal);
                p.Add("@subtotal", model.Subtotal);
                p.Add("@impuesto", model.Impuesto);
                p.Add("@total", model.Total);
                p.Add("@id_usuario", userId);
                p.Add("@detalles_json", detallesJson);
                p.Add("@id_factura_generada",
                       dbType: System.Data.DbType.Int64,
                       direction: System.Data.ParameterDirection.Output);
                using var connection = new SqlConnection(_connectionString);
                await connection.ExecuteAsync(
                    "usp_Factura_Emitir",
                    p,
                    commandType: System.Data.CommandType.StoredProcedure
                );
                long facturaId = p.Get<long>("@id_factura_generada");
                return Json(new
                {
                    success = true,
                    facturaId,
                    mensaje = $"Factura #{facturaId} emitida exitosamente."
                });
            }
            catch (SqlException ex)
            {
                return Json(new { success = false, error = ex.Message });
            }
        }
        private int ObtenerIdUsuario()
        {
            var idClaim = User.Claims.FirstOrDefault(c => c.Type == "Id");
            return idClaim != null ? int.Parse(idClaim.Value) : 0;
        }
        private async Task<int> ObtenerIdSucursalUsuario()
        {
            int userId = ObtenerIdUsuario();
            using var connection = new SqlConnection(_connectionString);
            var idSucursal = await connection.ExecuteScalarAsync<int?>(
                "SELECT id_sucursal FROM usuario WHERE id = @id",
                new { id = userId }
            );
            return idSucursal ?? 1;
        }
    }
}
