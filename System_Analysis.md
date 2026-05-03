# 🎓 Documento de Arquitectura y Análisis: Autopartes "El Tornillo Flojo"
*(Versión Optimizada para Proyecto Universitario - Stack Microsoft)*

## 1. 🎯 Objetivo del Proyecto
Desarrollar una solución web integral para la gestión de inventario y facturación de repuestos automotrices. El sistema se construirá utilizando el ecosistema de **.NET**, priorizando la robustez, la seguridad y el uso de un motor de base de datos relacional de nivel empresarial para garantizar la integridad de los datos comerciales.

---

## 2. 🧩 Módulos Funcionales (Core Business)

### 2.1. Seguridad y Acceso (Identity & RBAC)
* **Autenticación:** Sistema de inicio de sesión gestionado mediante ASP.NET Core Identity.
* **Autorización Basada en Roles:** Acceso diferenciado para `Administrador`, `Vendedor` y `Bodeguero`. Las vistas de Razor se renderizarán dinámicamente ocultando o mostrando opciones según el rol del usuario autenticado.

### 2.2. Gestión de Inventario y Compatibilidad
* **Catálogo Maestro:** Registro de SKU, descripción técnica, marca, precios y stock.
* **Relaciones de Compatibilidad:** Uso de tablas intermedias en MSSQL para vincular un repuesto con múltiples modelos y años de vehículos.
* **Control de Existencias (Kardex):** Registro de cada movimiento (Entrada/Salida) mediante Entity Framework Core para asegurar la trazabilidad.

### 2.3. Facturación y Ventas
* **Punto de Venta Web:** Formulario interactivo para la selección de repuestos y cálculo automático de totales.
* **Persistencia Histórica:** Almacenamiento detallado de la factura (Line Items) para preservar los precios de venta en el momento de la transacción.
* **Gestión de Caja:** Registro de transacciones vinculadas a turnos de usuario específicos.

---

## 3. 🛠️ Stack Tecnológico Seleccionado

Se ha optado por una arquitectura monolítica moderna basada en tecnologías de Microsoft, ideal para demostrar un alto nivel de competencia en ingeniería de software.

### 3.1. Frontend (Capa de Presentación)
* **Tecnología:** **.NET 8 Razor Pages / MVC**.
* **Descripción:** Renderizado del lado del servidor (SSR) que permite una integración nativa con la lógica de C#.
* **Estilos:** Se utilizará **Tailwind CSS** o **Bootstrap** (vía LibMan) para garantizar que la interfaz web sea responsiva y profesional.

### 3.2. Backend (Lógica de Negocio y API)
* **Framework:** **ASP.NET Core 9 (Web API)**.
* **ORM:** **Entity Framework Core (EF Core)** utilizando el enfoque *Code-First*. Esto permite definir la estructura de la base de datos directamente desde clases en C#, facilitando el control de versiones del esquema.
* **Lenguaje:** **C# 13**.

### 3.3. Base de Datos
* **Motor:** **Microsoft SQL Server (MSSQL)**.
* **Justificación:** Motor relacional robusto con soporte total para procedimientos almacenados, vistas e integridad referencial compleja necesaria para el rubro automotriz.

---

## 4. 🚀 Infraestructura y Despliegue

Dada la naturaleza universitaria del proyecto, se proponen las siguientes opciones:

* **Entorno de Desarrollo:** Visual Studio 2022 Community / VS Code y SQL Server Management Studio (SSMS).
* **Opciones de Despliegue:**
    * **Azure for Students:** Uso de créditos gratuitos para alojar el App Service y la base de datos SQL en la nube de Microsoft.
    * **Local/IIS:** Demostración en servidor local mediante Internet Information Services para la presentación presencial.

---

## 5. 🌟 Valor Agregado Académico (Puntos Extra)

1.  **Inyección de Dependencias:** Uso nativo del contenedor de dependencias de .NET para un código desacoplado y testeable.
2.  **Migraciones de EF Core:** Demostración del historial de cambios en la base de datos mediante comandos de consola.
3.  **Seguridad:** Implementación de protección contra ataques CSRF (Cross-Site Request Forgery) nativa en Razor Pages.
4.  **Documentación (Swagger):** Exposición de los endpoints de la API mediante Swagger/OpenAPI para pruebas de integración.

---
*Documento actualizado: Enfoque en Stack .NET / MSSQL para Autopartes El Tornillo Flojo*