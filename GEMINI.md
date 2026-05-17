# 🤖 Bitácora y Contexto del Proyecto 

Este archivo sirve como "memoria" y bitácora de las decisiones arquitectónicas, cambios recientes y sugerencias aplicadas al proyecto "Autopartes El Tornillo Flojo". Se actualizará continuamente para mantener el contexto entre sesiones y no saturar el documento oficial del proyecto.

## 📌 Estado Actual del Proyecto
* **Fase:** Modelado y Normalización de Base de Datos.
* **Stack Principal:** .NET 8, SQL Server (MSSQL).
* **Documento Core de Arquitectura:** `System_Analysis.md`

---

## 🚀 Protocolo de Despliegue y Sincronización (Multi-Repo)
* **Repositorio de Desarrollo (`Tornillo-Flojo-Dev`):** `https://github.com/Z4N4T3/Tornillo-Flojo-Dev.git`
  * Es el origen actual y contiene TODO el workspace (documentación, diseños, utilidades). Todos los cambios deben subirse aquí.
* **Repositorio de Producción/Entrega (`Tornillo-Flojo`):** `https://github.com/Z4N4T3/Tornillo-Flojo.git`
  * Contiene SOLAMENTE las carpetas `Database` y `TornilloFlojo.Web`.
  * Para sincronizar este repositorio, no se debe hacer push directo, sino filtrar el historial o usar sub-árboles para no contaminarlo con el resto de archivos.

---

## 📝 Historial de Cambios y Decisiones Clave

### [Mayo 2026] Preparación del Entorno de Desarrollo 
* **Contexto:** Se requiere configurar el ambiente para iniciar el desarrollo del backend en .NET.
* **Acciones:**
  * Se instaló la extensión **C# Dev Kit** (`ms-dotnettools.csdevkit`) y sus dependencias (`C#` y `.NET Runtime`) directamente en el entorno.
  * Se confirmó que el entorno está configurado para utilizar el marketplace oficial de VS Code.
* **Estado:** Extensión instalada con éxito. Pendiente verificación de compilación una vez se cree la solución.

### [Mayo 2026] Setup de Frontend y UI de Prueba (StitchMCP)
* **Contexto:** Extracción de interfaz y setup inicial sin dependencias en el servidor .NET.
* **Acciones:**
  * Se creó un proyecto base de Node.js + Vite en la carpeta `/Frontend`.
  * Se extrajo exitosamente la pantalla de "Login" desde el proyecto "ERP El Tornillo Flojo" utilizando la integración StitchMCP.
  * Se instalaron las dependencias del frontend (npm install) y se configuró la pantalla descargada como el `index.html` del proyecto.
* **Estado:** Completado.

### [Mayo 2026] Setup de Backend MVC (.NET 10)
* **Contexto:** Inicializar la arquitectura base según la estructura del proyecto en `source\repos\Test` (usando MVC en lugar de Razor Pages aisladas) usando el CLI de .NET disponible en Archivos de Programa.
* **Acciones:**
  * Se creó la solución `TornilloFlojo.sln`.
  * Se hizo scaffold del proyecto `TornilloFlojo.Web` usando el comando `dotnet new mvc -f net10.0`.
  * Se migró la pantalla de Login (previamente estática en Vite) hacia el proyecto MVC en `Views/Home/Index.cshtml`, aislando la vista del Layout principal.
  * Se trasladó la imagen de fondo hacia `wwwroot`.
* **Estado:** Compilación exitosa. La interfaz de login ahora se renderiza desde el servidor (SSR) mediante ASP.NET Core. No se incluyeron configuraciones de base de datos ni Entity Framework temporalmente.

### [Mayo 2026] Refactorización de Frontend a Razor + Bootstrap
* **Contexto:** Decisión arquitectónica para aprovechar las ventajas del enlace de datos fuerte (Strongly Typed Views) y la validación de MVC.
* **Acciones:**
  * Se eliminó la dependencia de Tailwind CSS en favor de Bootstrap 5 (incluido por defecto en ASP.NET Core).
  * Se creó el modelo `LoginViewModel` con anotaciones de datos (Data Annotations) para la validación.
  * Se actualizó `HomeController` para manejar el POST del login y comprobar `ModelState.IsValid`.
  * Se creó la plantilla `_LoginLayout.cshtml` sin navbar ni footer para el login.
  * Se reescribió `Index.cshtml` utilizando Bootstrap Grid y Razor Tag Helpers (`asp-for`, `asp-validation-for`, `asp-action`).
* **Estado:** Completado y compilado sin advertencias. La vista ahora cuenta con validación tanto del lado del cliente como del servidor integrada.

### [Mayo 2026] Implementación de RBAC (Roles y Permisos)
* **Contexto:** Se solicitó incluir un sistema de permisos dinámicos y roles predefinidos.
* **Decisión:** Se adoptó un modelo mixto con tablas `rol`, `permiso`, `rol_permiso` (M:N) y `usuario_permiso` (M:N).
* **Impacto:** Permite tener perfiles como 'Vendedor' o 'Administrador', y otorgar excepciones (permisos extra) a usuarios individuales sin alterar el rol base.
* **Archivos modificados:** `DB_TornilloFLojo.sql`

### [Mayo 2026] Normalización de Base de Datos (1NF, 2NF, 3NF)
* **Contexto:** Auditoría académica de las formas normales.
* **Cambios aplicados:** 
  * Se corrigió la tabla `cliente` dividiendo `nombre_completo` en atributos atómicos para cumplir con la **1NF**.
  * Se generó el `Informe_Normalizacion.md`.
  * Se actualizó `Diccionario-de-datos-Tornillo Flojo.csv` incluyendo la columna "Restricciones" (PK, FK, NOT NULL).
* **Desnormalizaciones aceptadas:** Se decidió mantener `stock_actual` en `producto` y los `totales` en facturas por razones de rendimiento (práctica común en sistemas POS), documentándolo debidamente.

### [Mayo 2026] Soporte Multi-Sucursal
* **Contexto:** Se solicitó que el sistema soporte una o varias sucursales físicas de la tienda.
* **Decisión:** Se creó la tabla `sucursal` como entidad fundacional (antes de Security & HR) que se enlaza a `barrio` para reutilizar la geografía ya modelada. Se incluyó la bandera `es_principal` para identificar la casa matriz.
* **Tablas modificadas con `id_sucursal`:** `empleado`, `usuario`, `compra`, `movimiento`, `turno_caja`, `factura`.
* **Impacto en Inventario:** Se eliminaron `stock_actual` y `stock_minimo` de la tabla `producto` y se creó la tabla `inventario_sucursal` (PK compuesta: `id_sucursal`, `id_producto`), permitiendo que cada sucursal lleve su propio kardex de existencias.
* **Archivos modificados:** `DB_TornilloFLojo.sql`, `ER_Diagram_mermaid.txt`, `Diccionario-de-datos-Tornillo Flojo.csv`.

### [Mayo 2026] Análisis de Cobertura RF/RNF y Correcciones
* **Contexto:** Se cruzaron los requisitos funcionales (RF-01 a RF-10) y no funcionales (RNF-01 a RNF-06) contra el esquema SQL para detectar brechas.
* **Brechas corregidas:**
  * **RF-01:** Se creó la tabla `producto_marca` para marcas de repuestos (Bosch, Monroe, etc.) y se agregó `id_marca` como FK en `producto`. Se agregó el campo `precio_costo` a `producto`.
  * **RF-08:** Se creó la tabla `gasto_operativo` para registrar egresos no-inventariables (pago de servicios, caja chica, alquiler).
* **Brechas descartadas (decisión del usuario):**
  * RF-05 bimonetario (moneda/tasa de cambio) — el sistema operará con moneda única.
  * RF-09 bitácora de auditoría — se implementará en una fase futura.
  * RNF-04 migración DATETIME→DATETIME2 — se mantiene DATETIME.
  * RNF-06 índices no agrupados — descartados por el momento.
* **Archivos modificados:** `DB_TornilloFLojo.sql`, `ER_Diagram_mermaid.txt`, `Diccionario-de-datos-Tornillo Flojo.csv`.

### [Mayo 2026] Consolidación Inicial del Esquema
* **Contexto:** Refactorización de la base de datos de un taller a un punto de venta y kardex.
* **Decisión:** Se creó el script consolidado `DB_TornilloFLojo.sql` y las reglas de Stored Procedures en `SP_CRUD_GUIDELINES.md`.

---

## 💡 Próximos Pasos Sugeridos
- [x] **Diccionario de datos:** Actualizar el CSV para incluir las nuevas tablas de roles y permisos, y las tablas que faltaban originalmente.
- [ ] **Lógica de Negocio (Kardex):** Desarrollar los Procedimientos Almacenados (Stored Procedures) que actualizarán automáticamente el `stock_actual` del producto cuando se inserte un registro en `movimiento`.
- [ ] **Backend:** Iniciar el setup de la solución en Visual Studio (.NET 8) y configurar el Entity Framework Core (*Database-First* o *Code-First* según se decida).
