# Requerimientos No Funcionales (RNF)

| ID | Categoría | Descripción |
| :--- | :--- | :--- |
| **RNF-01** | **Arquitectura y Patrones** | El sistema debe ser desarrollado bajo el patrón **Modelo-Vista-Controlador (MVC)** utilizando **ASP.NET Core 9** y **C# 13**. |
| **RNF-02** | **Persistencia** | El acceso a la base de datos debe realizarse exclusivamente a través de **Entity Framework Core** utilizando el enfoque **Code-First**. |
| **RNF-03** | **Seguridad y Prevención** | Todos los formularios web (**Razor Pages**) deben estar protegidos contra ataques **CSRF** (*Cross-Site Request Forgery*). |
| **RNF-04** | **Motor de Base de Datos** | La información debe persistir en **Microsoft SQL Server (MSSQL)**, utilizando tipos de datos precisos: `DECIMAL(18,2)` para valores monetarios y `DATETIME2` para fechas. |
| **RNF-05** | **Interfaz de Usuario** | El frontend debe ser responsivo (**Mobile-First**) utilizando **Bootstrap**, adaptando la vista tanto para resoluciones de escritorio (caja del POS) como tabletas (bodega). |
| **RNF-06** | **Tiempos de Respuesta** | Las consultas de búsqueda de repuestos en el POS, apoyadas por índices no agrupados en MSSQL, no deben demorar más de **1.5 segundos** en retornar los datos al cliente. |