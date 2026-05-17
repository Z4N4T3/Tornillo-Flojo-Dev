/**
 * Módulo POS (Nueva Venta) — Lógica del Carrito y Comunicación con Backend
 * 
 * Gestiona:
 * - Búsqueda de productos (AJAX → /Ventas/BuscarProducto)
 * - Búsqueda de clientes (AJAX → /Ventas/BuscarCliente)
 * - Carrito en memoria del lado del cliente
 * - Envío de la venta (POST → /Ventas/ProcesarVenta)
 */

const pos = (function () {
    // ── Estado del carrito ─────────────────────────────────────────────────
    let carrito = [];
    let clienteSeleccionado = { id: 1, nombre: 'Consumidor Final' }; // Default
    const IVA_RATE = 0.15;
    let searchTimeout = null;
    let categoriaSeleccionada = ''; // '' = Todas
    let productosCache = []; // Cache de la última búsqueda para filtro de categoría

    // ── Cache de elementos del DOM ────────────────────────────────────────
    const ui = {
        itemsContainer: null,
        emptyMessage: null,
        subtotal: null,
        tax: null,
        total: null,
        btnProcesar: null,
        searchInput: null,
        productosGrid: null,
        clienteSearch: null,
        clienteNombre: null,
        antiForgeryToken: null
    };

    // ── Inicialización ────────────────────────────────────────────────────
    document.addEventListener('DOMContentLoaded', () => {
        ui.itemsContainer = document.getElementById('carritoItems');
        ui.emptyMessage   = document.getElementById('carritoVacioMsg');
        ui.subtotal       = document.getElementById('cartSubtotal');
        ui.tax            = document.getElementById('cartTax');
        ui.total          = document.getElementById('cartTotal');
        ui.btnProcesar    = document.getElementById('btnProcesarPago');
        ui.searchInput    = document.getElementById('searchProductos');
        ui.productosGrid  = document.getElementById('productosGrid');
        ui.clienteSearch  = document.getElementById('searchCliente');
        ui.clienteNombre  = document.getElementById('clienteNombreDisplay');
        ui.antiForgeryToken = document.querySelector('input[name="__RequestVerificationToken"]')?.value;

        // Bind: búsqueda de productos con debounce
        if (ui.searchInput) {
            ui.searchInput.addEventListener('input', () => {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(() => buscarProductos(ui.searchInput.value), 350);
            });
        }

        // Bind: búsqueda de clientes con debounce
        if (ui.clienteSearch) {
            ui.clienteSearch.addEventListener('input', () => {
                clearTimeout(searchTimeout);
                searchTimeout = setTimeout(() => buscarClientes(ui.clienteSearch.value), 350);
            });
        }

        // Cargar categorías dinámicamente al iniciar
        cargarCategorias();

        actualizarUI();
    });

    // ══════════════════════════════════════════════════════════════════════
    //  BÚSQUEDA DE PRODUCTOS (AJAX → Backend)
    // ══════════════════════════════════════════════════════════════════════

    // ── Carga Dinámica de Categorías ─────────────────────────────────────
    async function cargarCategorias() {
        try {
            const resp = await fetch('/Ventas/GetCategorias');
            if (!resp.ok) return;
            const categorias = await resp.json();
            const container = document.getElementById('categoriasFilter');
            if (!container) return;

            categorias.forEach(cat => {
                const btn = document.createElement('button');
                btn.className = 'btn btn-sm btn-outline-secondary rounded-pill px-3 btn-cat-filter';
                btn.textContent = cat.nombre;
                btn.dataset.catId = cat.id;
                btn.onclick = function() { filtrarPorCategoria(this, cat.id); };
                container.appendChild(btn);
            });
        } catch (err) {
            console.error('Error cargando categorías:', err);
        }
    }

    function filtrarPorCategoria(btn, catId) {
        categoriaSeleccionada = catId === '' ? '' : String(catId);

        // Actualizar UI de botones
        document.querySelectorAll('.btn-cat-filter').forEach(b => {
            b.classList.remove('btn-dark', 'active');
            b.classList.add('btn-outline-secondary');
        });
        btn.classList.remove('btn-outline-secondary');
        btn.classList.add('btn-dark', 'active');

        // Re-filtrar productos del cache
        renderProductosFiltrados();
    }

    function renderProductosFiltrados() {
        if (!ui.productosGrid) return;
        if (productosCache.length === 0) {
            renderProductosVacio();
            return;
        }

        const filtrados = categoriaSeleccionada === ''
            ? productosCache
            : productosCache.filter(p => String(p.idCategoria) === categoriaSeleccionada);

        if (filtrados.length === 0) {
            ui.productosGrid.innerHTML = `
                <div class="col-12 text-center text-muted py-5">
                    <i class="bi bi-funnel" style="font-size: 2.5rem;"></i>
                    <p class="mt-2">No hay productos en esta categoría</p>
                </div>`;
            return;
        }

        ui.productosGrid.innerHTML = filtrados.map(p => crearTarjetaProducto(p)).join('');
    }

    async function buscarProductos(query) {
        if (!query || query.length < 2) {
            productosCache = [];
            renderProductosVacio();
            return;
        }

        try {
            const resp = await fetch(`/Ventas/BuscarProducto?q=${encodeURIComponent(query)}`);
            if (!resp.ok) throw new Error('Error en la búsqueda');
            const productos = await resp.json();

            if (!ui.productosGrid) return;
            productosCache = productos;

            if (productos.length === 0) {
                ui.productosGrid.innerHTML = `
                    <div class="col-12 text-center text-muted py-5">
                        <i class="bi bi-search" style="font-size: 2.5rem;"></i>
                        <p class="mt-2">No se encontraron productos para "<strong>${escapeHtml(query)}</strong>"</p>
                    </div>`;
                return;
            }

            renderProductosFiltrados();
        } catch (err) {
            console.error('Error buscando productos:', err);
        }
    }

    function crearTarjetaProducto(p) {
        const stockClass = p.stockActual <= 5 ? 'bg-danger' : 'bg-warning text-dark';
        const precio = formatCurrency(p.precioVenta);
        return `
            <div class="col">
                <div class="card h-100 border-1 product-card" style="border-color: var(--border); cursor: pointer;"
                     onclick="pos.agregarAlCarrito(${p.id}, '${escapeHtml(p.nombre)}', ${p.precioVenta}, ${p.stockActual})">
                    <div class="bg-light d-flex align-items-center justify-content-center p-3 border-bottom text-muted" style="height: 140px;">
                        <i class="bi bi-gear-wide-connected" style="font-size: 3rem;"></i>
                    </div>
                    <div class="card-body p-3 d-flex flex-column">
                        <div class="d-flex justify-content-between align-items-start mb-1">
                            <h6 class="card-title mb-0 text-truncate" style="max-width: 70%;" title="${escapeHtml(p.nombre)}">${escapeHtml(p.nombre)}</h6>
                            <span class="badge ${stockClass}">Stock: ${p.stockActual}</span>
                        </div>
                        <small class="text-muted mb-3 font-monospace">${escapeHtml(p.codigoParte)}</small>
                        <div class="mt-auto d-flex justify-content-between align-items-center pt-2 border-top">
                            <span class="fs-5 fw-bold" style="color: #9A3412;">${precio}</span>
                            <button class="btn btn-sm btn-light rounded-circle"><i class="bi bi-plus-lg" style="color: var(--gold);"></i></button>
                        </div>
                    </div>
                </div>
            </div>`;
    }

    function renderProductosVacio() {
        if (!ui.productosGrid) return;
        ui.productosGrid.innerHTML = `
            <div class="col-12 text-center text-muted py-5">
                <i class="bi bi-box-seam" style="font-size: 2.5rem;"></i>
                <p class="mt-2">Escriba al menos 2 caracteres para buscar productos</p>
            </div>`;
    }

    // ══════════════════════════════════════════════════════════════════════
    //  BÚSQUEDA DE CLIENTES (AJAX → Backend)
    // ══════════════════════════════════════════════════════════════════════

    async function buscarClientes(query) {
        if (!query || query.length < 2) {
            ocultarDropdownClientes();
            return;
        }

        try {
            const resp = await fetch(`/Ventas/BuscarCliente?q=${encodeURIComponent(query)}`);
            if (!resp.ok) throw new Error('Error buscando clientes');
            const clientes = await resp.json();
            mostrarDropdownClientes(clientes);
        } catch (err) {
            console.error('Error buscando clientes:', err);
        }
    }

    function mostrarDropdownClientes(clientes) {
        let dropdown = document.getElementById('clienteDropdown');
        if (!dropdown) {
            dropdown = document.createElement('div');
            dropdown.id = 'clienteDropdown';
            dropdown.className = 'list-group position-absolute w-100 shadow-sm';
            dropdown.style.cssText = 'z-index: 1000; max-height: 200px; overflow-y: auto; top: 100%;';
            ui.clienteSearch?.parentElement?.style && (ui.clienteSearch.parentElement.style.position = 'relative');
            ui.clienteSearch?.parentElement?.appendChild(dropdown);
        }

        if (clientes.length === 0) {
            dropdown.innerHTML = '<div class="list-group-item text-muted small">Sin resultados</div>';
            return;
        }

        dropdown.innerHTML = clientes.map(c => `
            <button type="button" class="list-group-item list-group-item-action small"
                    onclick="pos.seleccionarCliente(${c.id}, '${escapeHtml(c.nombreCompleto)}')">
                <strong>${escapeHtml(c.nombreCompleto)}</strong>
                <span class="text-muted ms-2">${escapeHtml(c.identificacion)}</span>
            </button>`
        ).join('');
    }

    function ocultarDropdownClientes() {
        const dropdown = document.getElementById('clienteDropdown');
        if (dropdown) dropdown.remove();
    }

    function seleccionarCliente(id, nombre) {
        clienteSeleccionado = { id, nombre };
        if (ui.clienteSearch) ui.clienteSearch.value = nombre;
        if (ui.clienteNombre) ui.clienteNombre.textContent = nombre;
        ocultarDropdownClientes();
    }

    // ══════════════════════════════════════════════════════════════════════
    //  GESTIÓN DEL CARRITO (EN MEMORIA)
    // ══════════════════════════════════════════════════════════════════════

    function agregarAlCarrito(idProducto, nombre, precio, stockDisponible) {
        const itemExistente = carrito.find(i => i.id === idProducto);

        if (itemExistente) {
            if (stockDisponible !== undefined && itemExistente.cantidad >= stockDisponible) {
                alert(`Stock insuficiente. Disponible: ${stockDisponible}`);
                return;
            }
            itemExistente.cantidad += 1;
        } else {
            carrito.push({
                id: idProducto,
                nombre: nombre,
                precio: parseFloat(precio),
                cantidad: 1,
                stock: stockDisponible || 999
            });
        }

        actualizarUI();
    }

    function incrementarCantidad(idProducto) {
        const item = carrito.find(i => i.id === idProducto);
        if (item) {
            if (item.cantidad >= item.stock) {
                alert(`Stock máximo alcanzado (${item.stock}).`);
                return;
            }
            item.cantidad += 1;
            actualizarUI();
        }
    }

    function decrementarCantidad(idProducto) {
        const itemIndex = carrito.findIndex(i => i.id === idProducto);
        if (itemIndex !== -1) {
            if (carrito[itemIndex].cantidad > 1) {
                carrito[itemIndex].cantidad -= 1;
            } else {
                carrito.splice(itemIndex, 1);
            }
            actualizarUI();
        }
    }

    function eliminarItem(idProducto) {
        carrito = carrito.filter(i => i.id !== idProducto);
        actualizarUI();
    }

    function vaciarCarrito() {
        if (carrito.length === 0) return;
        if (confirm('¿Está seguro de que desea cancelar la venta actual?')) {
            carrito = [];
            clienteSeleccionado = { id: 1, nombre: 'Consumidor Final' };
            if (ui.clienteSearch) ui.clienteSearch.value = '';
            if (ui.clienteNombre) ui.clienteNombre.textContent = 'Consumidor Final';
            actualizarUI();
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    //  ACTUALIZACIÓN DE LA UI
    // ══════════════════════════════════════════════════════════════════════

    function actualizarUI() {
        if (!ui.itemsContainer) return;

        ui.itemsContainer.innerHTML = '';

        if (carrito.length === 0) {
            ui.itemsContainer.innerHTML = `
                <div class="text-center text-muted mt-5" id="carritoVacioMsg">
                    <i class="bi bi-cart-x" style="font-size: 3rem;"></i>
                    <p class="mt-2">El carrito está vacío</p>
                </div>`;
            ui.subtotal.textContent = 'C$ 0.00';
            ui.tax.textContent = 'C$ 0.00';
            ui.total.textContent = 'C$ 0.00';
            if (ui.btnProcesar) ui.btnProcesar.disabled = true;
            return;
        }

        let subtotalVal = 0;

        carrito.forEach(item => {
            const itemTotal = item.precio * item.cantidad;
            subtotalVal += itemTotal;

            const itemHtml = `
                <div class="card mb-2 shadow-sm border-0 position-relative">
                    <button class="btn btn-sm btn-link text-danger position-absolute top-0 end-0 p-2" onclick="pos.eliminarItem(${item.id})" title="Eliminar">
                        <i class="bi bi-x-lg"></i>
                    </button>
                    <div class="card-body p-2">
                        <div class="pe-4">
                            <h6 class="card-title mb-1 text-truncate" style="font-size: 0.9rem;" title="${escapeHtml(item.nombre)}">${escapeHtml(item.nombre)}</h6>
                            <p class="text-muted font-monospace mb-2" style="font-size: 0.8rem;">${formatCurrency(item.precio)} c/u</p>
                        </div>
                        <div class="d-flex justify-content-between align-items-end">
                            <div class="input-group input-group-sm" style="width: 100px;">
                                <button class="btn btn-outline-secondary" type="button" onclick="pos.decrementarCantidad(${item.id})"><i class="bi bi-dash"></i></button>
                                <input type="text" class="form-control text-center bg-white font-monospace" value="${item.cantidad}" readonly>
                                <button class="btn btn-outline-secondary" type="button" onclick="pos.incrementarCantidad(${item.id})"><i class="bi bi-plus"></i></button>
                            </div>
                            <span class="fw-bold font-monospace" style="color: #9A3412;">${formatCurrency(itemTotal)}</span>
                        </div>
                    </div>
                </div>`;
            ui.itemsContainer.insertAdjacentHTML('beforeend', itemHtml);
        });

        const taxVal = subtotalVal * IVA_RATE;
        const totalVal = subtotalVal + taxVal;

        ui.subtotal.textContent = formatCurrency(subtotalVal);
        ui.tax.textContent = formatCurrency(taxVal);
        ui.total.textContent = formatCurrency(totalVal);
        if (ui.btnProcesar) ui.btnProcesar.disabled = false;
    }

    // ══════════════════════════════════════════════════════════════════════
    //  PROCESAR PAGO (POST → Backend)
    // ══════════════════════════════════════════════════════════════════════

    async function procesarPago() {
        if (carrito.length === 0) return;

        const subtotalVal = carrito.reduce((sum, i) => sum + (i.precio * i.cantidad), 0);
        const taxVal = subtotalVal * IVA_RATE;
        const totalVal = subtotalVal + taxVal;

        const payload = {
            idCliente: clienteSeleccionado.id,
            subtotal: Math.round(subtotalVal * 100) / 100,
            impuesto: Math.round(taxVal * 100) / 100,
            total: Math.round(totalVal * 100) / 100,
            detalles: carrito.map(item => ({
                id_producto: item.id,
                cantidad: item.cantidad,
                precio_unitario: item.precio
            }))
        };

        // Deshabilitar botón durante el envío
        if (ui.btnProcesar) {
            ui.btnProcesar.disabled = true;
            ui.btnProcesar.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Procesando...';
        }

        try {
            const token = ui.antiForgeryToken
                || document.querySelector('input[name="__RequestVerificationToken"]')?.value
                || '';

            const resp = await fetch('/Ventas/ProcesarVenta', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'RequestVerificationToken': token
                },
                body: JSON.stringify(payload)
            });

            const result = await resp.json();

            if (result.success) {
                alert(`✅ ${result.mensaje}`);
                carrito = [];
                clienteSeleccionado = { id: 1, nombre: 'Consumidor Final' };
                if (ui.clienteSearch) ui.clienteSearch.value = '';
                if (ui.clienteNombre) ui.clienteNombre.textContent = 'Consumidor Final';
                actualizarUI();
            } else {
                alert(`❌ Error: ${result.error}`);
            }
        } catch (err) {
            alert('❌ Error de conexión al procesar la venta.');
            console.error('Error procesando venta:', err);
        } finally {
            if (ui.btnProcesar) {
                ui.btnProcesar.disabled = carrito.length === 0;
                ui.btnProcesar.innerHTML = '<i class="bi bi-cash-coin"></i> Procesar Pago';
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    //  UTILIDADES
    // ══════════════════════════════════════════════════════════════════════

    function formatCurrency(value) {
        return 'C$ ' + value.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }

    function escapeHtml(str) {
        if (!str) return '';
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    // ── API pública ───────────────────────────────────────────────────────
    return {
        agregarAlCarrito,
        incrementarCantidad,
        decrementarCantidad,
        eliminarItem,
        vaciarCarrito,
        procesarPago,
        seleccionarCliente,
        buscarProductos,
        buscarClientes,
        filtrarPorCategoria
    };
})();
