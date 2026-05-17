using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Dapper;
using TornilloFlojo.Web.Models.Ventas;

namespace TornilloFlojo.Web.Controllers
{
    /// <summary>
    /// Controlador del módulo de Punto de Venta (POS).
    /// Gestiona la búsqueda de productos/clientes y la emisión de facturas.
    /// Utiliza Dapper para invocar Stored Procedures (patrón del proyecto).
    /// </summary>
    [Authorize]
    public class VentasController : Controller
    {
        private readonly string _connectionString;

        public VentasController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? "";
        }

        // ── GET: /Ventas/NuevaVenta ─────────────────────────────────────────
        /// <summary>
        /// Renderiza la vista principal del POS.
        /// </summary>
        public IActionResult NuevaVenta()
        {
            return View();
        }

        // ── GET: /Ventas/BuscarProducto?q=...&idSucursal=... ────────────────
        /// <summary>
        /// Endpoint AJAX. Ejecuta usp_Producto_BusquedaPOS para buscar
        /// productos disponibles en la sucursal indicada.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> BuscarProducto(string q, int? idSucursal)
        {
            if (string.IsNullOrWhiteSpace(q) || q.Length < 2)
                return Json(new List<ProductoBusquedaResult>());

            // Si no se envía idSucursal, obtenerla del usuario logueado
            int sucursal = idSucursal ?? await ObtenerIdSucursalUsuario();

            using var connection = new SqlConnection(_connectionString);
            var productos = await connection.QueryAsync<ProductoBusquedaResult>(
                "usp_Producto_BusquedaPOS",
                new { id_sucursal = sucursal, busqueda = q },
                commandType: System.Data.CommandType.StoredProcedure
            );

            return Json(productos);
        }

        // ── GET: /Ventas/BuscarCliente?q=... ────────────────────────────────
        /// <summary>
        /// Endpoint AJAX. Ejecuta usp_Cliente_Busqueda para buscar
        /// clientes por nombre o identificación.
        /// </summary>
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

        // ── POST: /Ventas/ProcesarVenta ─────────────────────────────────────
        /// <summary>
        /// Endpoint AJAX. Recibe el carrito completo como JSON desde pos.js,
        /// serializa los detalles y ejecuta usp_Factura_Emitir.
        /// </summary>
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
                // ── Resolver datos del usuario logueado ──────────────────
                int userId = ObtenerIdUsuario();
                int idSucursal = await ObtenerIdSucursalUsuario();

                // ── Serializar detalles a JSON para el SP ────────────────
                string detallesJson = JsonSerializer.Serialize(model.Detalles);

                // ── Ejecutar SP transaccional ────────────────────────────
                var p = new DynamicParameters();
                p.Add("@id_cliente", model.IdCliente);
                p.Add("@id_turno_caja", 1); // Valor temporal — módulo de turnos pendiente
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
                // Errores controlados desde el SP (ej. stock insuficiente)
                return Json(new { success = false, error = ex.Message });
            }
        }

        // ── HELPERS PRIVADOS ────────────────────────────────────────────────

        /// <summary>
        /// Obtiene el ID del usuario logueado desde los Claims de la cookie.
        /// </summary>
        private int ObtenerIdUsuario()
        {
            var idClaim = User.Claims.FirstOrDefault(c => c.Type == "Id");
            return idClaim != null ? int.Parse(idClaim.Value) : 0;
        }

        /// <summary>
        /// Consulta la sucursal asignada al usuario logueado.
        /// Se resuelve dinámicamente desde la BD porque el login SP
        /// no incluye id_sucursal en los Claims actualmente.
        /// </summary>
        private async Task<int> ObtenerIdSucursalUsuario()
        {
            int userId = ObtenerIdUsuario();

            using var connection = new SqlConnection(_connectionString);
            var idSucursal = await connection.ExecuteScalarAsync<int?>(
                "SELECT id_sucursal FROM usuario WHERE id = @id",
                new { id = userId }
            );

            // Fallback a sucursal 1 (principal) si no está asignada
            return idSucursal ?? 1;
        }
    }
}
