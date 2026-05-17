// inventario.js

$(document).ready(function () {
    // Filtro por Búsqueda (Texto)
    $('#busquedaTexto').on('keyup', function () {
        filtrarTabla();
    });

    // Filtro por Categoría (Click en Panel Lateral)
    $('.btn-filtro-categoria').on('click', function (e) {
        e.preventDefault();
        
        // Actualizar UI activa
        $('.btn-filtro-categoria').removeClass('active text-dark fw-semibold').addClass('text-muted');
        $(this).removeClass('text-muted').addClass('active text-dark fw-semibold');

        // Guardar la categoría seleccionada en un atributo del input de búsqueda (como hack simple)
        $('#busquedaTexto').data('categoria', $(this).data('id'));
        
        filtrarTabla();
    });
});

function filtrarTabla() {
    var texto = $('#busquedaTexto').val().toLowerCase();
    var categoriaId = $('#busquedaTexto').data('categoria') || "";

    $('#tablaInventario tbody tr.producto-fila').each(function () {
        var fila = $(this);
        var filaCatId = fila.data('categoria');
        
        var nombre = fila.find('.nombre-producto').text().toLowerCase();
        var codigo = fila.find('td:first').text().toLowerCase();
        var marca = fila.find('.marca-producto').text().toLowerCase();

        var matchTexto = (nombre.includes(texto) || codigo.includes(texto) || marca.includes(texto));
        var matchCat = (categoriaId === "" || filaCatId == categoriaId);

        if (matchTexto && matchCat) {
            fila.show();
        } else {
            fila.hide();
        }
    });
}

function abrirModalProducto(id) {
    // Reset form
    $('#frmProducto')[0].reset();
    $('#Id').val('');
    $('#modalError').addClass('d-none').text('');
    
    if (id) {
        // Modo Edición
        $('#modalTitle').text('Editar Producto');
        $('#estadoContainer').show();
        
        // Obtener detalle del producto
        $.get('/Inventario/Detalle/' + id, function (res) {
            if (res.success) {
                var p = res.data;
                $('#Id').val(p.id);
                $('#CodigoParte').val(p.codigoParte);
                $('#Nombre').val(p.nombre);
                $('#Descripcion').val(p.descripcion);
                $('#IdMarca').val(p.idMarca || '');
                $('#IdCategoria').val(p.idCategoria || '');
                $('#PrecioCosto').val(p.precioCosto);
                $('#PrecioVenta').val(p.precioVenta);
                $('#IdEstado').val(p.idEstado);
                
                $('#productoModal').modal('show');
            } else {
                alert(res.message || 'Error al cargar producto.');
            }
        }).fail(function () {
            alert("Error de conexión al cargar detalle.");
        });
    } else {
        // Modo Nuevo
        $('#modalTitle').text('Nuevo Producto');
        $('#estadoContainer').hide();
        $('#IdEstado').val(1);
        $('#productoModal').modal('show');
    }
}

function guardarProducto() {
    // Validaciones básicas HTML5
    var form = $('#frmProducto')[0];
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }

    var btn = $('#btnGuardar');
    btn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm"></span> Guardando...');
    $('#modalError').addClass('d-none');

    var data = $('#frmProducto').serialize();

    $.post('/Inventario/Guardar', data, function (res) {
        if (res.success) {
            $('#productoModal').modal('hide');
            // Recargar para ver los cambios (o podríamos actualizar el DOM por AJAX, pero reload asegura consistencia del stock inicial)
            location.reload();
        } else {
            $('#modalError').removeClass('d-none').text(res.message);
            btn.prop('disabled', false).html('<i class="bi bi-save"></i> Guardar');
        }
    }).fail(function () {
        $('#modalError').removeClass('d-none').text("Error de red. Intente de nuevo.");
        btn.prop('disabled', false).html('<i class="bi bi-save"></i> Guardar');
    });
}

function eliminarProducto(id, nombre) {
    if (confirm(`¿Está seguro de que desea eliminar (dar de baja) el producto '${nombre}'?`)) {
        var token = $('input[name="__RequestVerificationToken"]').val();
        
        $.post('/Inventario/Eliminar', { id: id, __RequestVerificationToken: token }, function (res) {
            if (res.success) {
                location.reload();
            } else {
                alert(res.message);
            }
        }).fail(function () {
            alert("Error de red al intentar eliminar.");
        });
    }
}
