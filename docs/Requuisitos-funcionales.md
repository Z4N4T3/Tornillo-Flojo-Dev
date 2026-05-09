# Requerimientos Funcionales (RF)

## Módulo de Inventario y Productos
| ID | Título | Descripción |
| :--- | :--- | :--- |
| **RF-01** | **Registro de Repuestos** | El sistema debe permitir el registro de repuestos capturando obligatoriamente: SKU, Nombre, Marca, Precio Costo, Precio Venta, Stock actual, Stock mínimo y Categoría. |
| **RF-02** | **Motor de Compatibilidad** | Implementación de una relación N:M para asociar un único código de repuesto con múltiples modelos de vehículos y sus respectivos rangos de años. |
| **RF-03** | **Control de Stock (Kardex)** | Se prohíbe la modificación directa de existencias. Todo ajuste de inventario debe realizarse mediante un registro en el Kardex (Fecha, Usuario, Tipo de Movimiento, Cantidad). |
| **RF-04** | **Alertas de Reposición** | El sistema debe generar notificaciones visuales automáticas cuando el stock de un producto alcance o sea inferior al stock mínimo definido. |

## Módulo de Ventas y Caja
| ID | Título | Descripción |
| :--- | :--- | :--- |
| **RF-05** | **Proceso de Facturación** | Capacidad de emitir facturas calculando totales, descontando existencias en tiempo real y almacenando la moneda de la transacción junto a su tasa de cambio. |
| **RF-06** | **Inmutabilidad de Precios** | Los precios aplicados en una factura deben persistir de forma independiente, garantizando que cambios futuros en el catálogo de productos no alteren los registros históricos de ventas. |
| **RF-07** | **Gestión de Turnos** | Apertura y cierre de caja mediante la modalidad de **arqueo ciego**, donde el sistema valida el monto ingresado por el cajero contra el saldo esperado en sistema. |
| **RF-08** | **Flujo de Efectivo** | Registro detallado de ingresos por ventas y egresos operativos (pagos a proveedores, servicios y gastos menores). |

## Módulo de Administración, Seguridad y Reportes
| ID | Título | Descripción |
| :--- | :--- | :--- |
| **RF-09** | **Seguridad y Auditoría** | Autenticación obligatoria de usuarios e implementación de una bitácora (*log*) que registre cronológicamente cada acción crítica realizada en el sistema. |
| **RF-10** | **Reportes y Exportación** | Generación de reportes con opción de exportación sobre: ventas por rango de fechas, productos de mayor rotación, inventario bajo mínimos y estados de resultados básicos. |