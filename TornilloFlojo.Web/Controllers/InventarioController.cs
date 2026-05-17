using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Dapper;
using TornilloFlojo.Web.Models;

namespace TornilloFlojo.Web.Controllers;

[Authorize(Roles = "Administrador Global,Administrador Local,Bodega y Compras")]
public class InventarioController : Controller
{
    private readonly string _connectionString;

    public InventarioController(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection") ?? "";
    }

    public async Task<IActionResult> Index()
    {
        var model = new InventarioViewModel();
        int idSucursal = await ObtenerIdSucursalUsuario();

        using var connection = new SqlConnection(_connectionString);
        try
        {
            // Ejecutar el SP que obtendrá inventario + categorías + marcas
            using var multi = await connection.QueryMultipleAsync(
                "usp_Inventario_GetAll",
                new { id_sucursal = idSucursal },
                commandType: System.Data.CommandType.StoredProcedure
            );

            model.Productos = (await multi.ReadAsync<ProductoInventarioDto>()).ToList();
            model.Categorias = (await multi.ReadAsync<CategoriaDto>()).ToList();
            model.Marcas = (await multi.ReadAsync<MarcaDto>()).ToList();
        }
        catch (SqlException)
        {
            ViewBag.SpPendiente = true;
        }

        return View(model);
    }

    [HttpGet]
    public async Task<IActionResult> Detalle(int id)
    {
        int idSucursal = await ObtenerIdSucursalUsuario();
        using var connection = new SqlConnection(_connectionString);

        try
        {
            var producto = await connection.QueryFirstOrDefaultAsync<ProductoInventarioDto>(
                "usp_Inventario_GetById",
                new { id_producto = id, id_sucursal = idSucursal },
                commandType: System.Data.CommandType.StoredProcedure
            );

            if (producto == null)
            {
                return Json(new { success = false, message = "Producto no encontrado." });
            }

            return Json(new { success = true, data = producto });
        }
        catch (Exception ex)
        {
            return Json(new { success = false, message = "Error: " + ex.Message });
        }
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Guardar(ProductoViewModel model)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage);
            return Json(new { success = false, message = string.Join(" ", errors) });
        }

        try
        {
            using var connection = new SqlConnection(_connectionString);

            if (model.Id.HasValue && model.Id > 0)
            {
                // Editar producto
                await connection.ExecuteAsync(
                    "usp_Inventario_UpdateProducto",
                    new
                    {
                        id = model.Id,
                        codigo_parte = model.CodigoParte,
                        nombre = model.Nombre,
                        descripcion = model.Descripcion,
                        precio_costo = model.PrecioCosto,
                        precio_venta = model.PrecioVenta,
                        id_marca = model.IdMarca,
                        id_categoria = model.IdCategoria,
                        id_estado = model.IdEstado
                    },
                    commandType: System.Data.CommandType.StoredProcedure
                );
                return Json(new { success = true, message = "Producto actualizado correctamente." });
            }
            else
            {
                // Crear producto
                int idSucursal = await ObtenerIdSucursalUsuario();
                var p = new DynamicParameters();
                p.Add("@codigo_parte", model.CodigoParte);
                p.Add("@nombre", model.Nombre);
                p.Add("@descripcion", model.Descripcion);
                p.Add("@precio_costo", model.PrecioCosto);
                p.Add("@precio_venta", model.PrecioVenta);
                p.Add("@id_marca", model.IdMarca);
                p.Add("@id_categoria", model.IdCategoria);
                p.Add("@id_sucursal_inicial", idSucursal);
                p.Add("@NuevoId", dbType: System.Data.DbType.Int32, direction: System.Data.ParameterDirection.Output);

                await connection.ExecuteAsync(
                    "usp_Inventario_InsertProducto",
                    p,
                    commandType: System.Data.CommandType.StoredProcedure
                );
                return Json(new { success = true, message = "Producto creado correctamente." });
            }
        }
        catch (SqlException ex)
        {
            return Json(new { success = false, message = "Error en la base de datos: " + ex.Message });
        }
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Eliminar(int id)
    {
        // Solo los Administradores pueden eliminar (borrado lógico)
        // Validación manual necesaria porque [Authorize] anidado no sobrescribe roles de la clase
        if (!User.IsInRole("Administrador Global") && !User.IsInRole("Administrador Local"))
        {
            return Json(new { success = false, message = "Acceso denegado. Solo los Administradores pueden eliminar productos." });
        }

        try
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.ExecuteAsync(
                "usp_Inventario_DeleteProducto",
                new { id_producto = id },
                commandType: System.Data.CommandType.StoredProcedure
            );

            return Json(new { success = true, message = "Producto eliminado (baja lógica)." });
        }
        catch (SqlException ex)
        {
            return Json(new { success = false, message = "Error al eliminar: " + ex.Message });
        }
    }

    [HttpGet]
    public async Task<IActionResult> ExportarCSV()
    {
        int idSucursal = await ObtenerIdSucursalUsuario();
        using var connection = new SqlConnection(_connectionString);
        
        try
        {
            // usp_Inventario_GetAll devuelve 3 resultsets: productos, categorias, marcas
            // Para CSV solo necesitamos el primero
            using var multi = await connection.QueryMultipleAsync(
                "usp_Inventario_GetAll",
                new { id_sucursal = idSucursal },
                commandType: System.Data.CommandType.StoredProcedure
            );

            var productos = (await multi.ReadAsync<ProductoInventarioDto>()).ToList();
            
            var builder = new StringBuilder();
            // BOM UTF-8 para compatibilidad con Excel
            builder.Append('\uFEFF');
            builder.AppendLine("CodigoParte,Nombre,Marca,Categoria,PrecioVenta,StockActual,StockMinimo,AlertaStock");

            foreach (var prod in productos)
            {
                string alerta = prod.AlertaStock ? "STOCK BAJO" : "OK";
                // Escape de comillas dentro de strings
                string nombre = prod.Nombre.Replace("\"", "\"\"");
                string marca = prod.MarcaNombre.Replace("\"", "\"\"");
                string cat = prod.CategoriaNombre.Replace("\"", "\"\"");
                builder.AppendLine($"\"{prod.CodigoParte}\",\"{nombre}\",\"{marca}\",\"{cat}\",{prod.PrecioVenta},{prod.StockActual},{prod.StockMinimo},{alerta}");
            }

            return File(Encoding.UTF8.GetBytes(builder.ToString()), "text/csv; charset=utf-8", "inventario_tornilloflojo.csv");
        }
        catch (Exception ex)
        {
            return BadRequest("Error al generar CSV: " + ex.Message);
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
