/*
==============================================================================
CARSHOP MANAGEMENT SYSTEM - CONSOLIDATED SCHEMA
Derived from NicaPOS Architecture Good Practices
==============================================================================
*/

USE [master]
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'DB_Carshop')
    DROP DATABASE [DB_Carshop];
GO

CREATE DATABASE [DB_Carshop];
GO

USE [DB_Carshop];
GO

-- 1. FOUNDATIONAL TABLES (Status & Geography)
CREATE TABLE estado (
    id INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE departamento (
    id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE municipio (
    id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_dep INT FOREIGN KEY REFERENCES departamento(id)
);

CREATE TABLE barrio (
    id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_mun INT FOREIGN KEY REFERENCES municipio(id)
);

-- 2. SECURITY & HR
-- 2a. RBAC: Roles, Permisos y Asignaciones
CREATE TABLE permiso (
    id INT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL, -- Ej: 'CREAR_FACTURA', 'ANULAR_FACTURA', 'VER_REPORTES'
    descripcion VARCHAR(200)
);

CREATE TABLE rol (
    id INT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL, -- Ej: 'Administrador', 'Vendedor', 'Cajero'
    descripcion VARCHAR(200),
    id_estado INT FOREIGN KEY REFERENCES estado(id)
);

-- Tabla intermedia: permisos predefinidos por rol (M:N)
CREATE TABLE rol_permiso (
    id_rol INT NOT NULL FOREIGN KEY REFERENCES rol(id),
    id_permiso INT NOT NULL FOREIGN KEY REFERENCES permiso(id),
    CONSTRAINT PK_rol_permiso PRIMARY KEY (id_rol, id_permiso)
);

CREATE TABLE cargo (
    id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500),
    salario_base DECIMAL(18, 2),
    id_estado INT FOREIGN KEY REFERENCES estado(id)
);

CREATE TABLE empleado (
    id INT PRIMARY KEY,
    nombre1 VARCHAR(50) NOT NULL,
    nombre2 VARCHAR(50),
    apellido1 VARCHAR(50) NOT NULL,
    apellido2 VARCHAR(50),
    identificacion VARCHAR(20) UNIQUE NOT NULL,
    genero CHAR(1),
    id_cargo INT FOREIGN KEY REFERENCES cargo(id),
    id_estado INT FOREIGN KEY REFERENCES estado(id)
);

CREATE TABLE usuario (
    id INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(256) NOT NULL,
    id_empleado INT FOREIGN KEY REFERENCES empleado(id),
    id_rol INT FOREIGN KEY REFERENCES rol(id),        -- Rol/Perfil base del usuario
    id_estado INT FOREIGN KEY REFERENCES estado(id),
    fecha_creacion DATETIME DEFAULT GETDATE()
);

-- Tabla intermedia: permisos personalizados por usuario (M:N)
-- Permite otorgar permisos adicionales sin modificar el rol base
CREATE TABLE usuario_permiso (
    id_usuario INT NOT NULL FOREIGN KEY REFERENCES usuario(id),
    id_permiso INT NOT NULL FOREIGN KEY REFERENCES permiso(id),
    CONSTRAINT PK_usuario_permiso PRIMARY KEY (id_usuario, id_permiso)
);

-- 3. CUSTOMERS & VEHICLES
CREATE TABLE cliente (
    id INT PRIMARY KEY,
    nombre1 VARCHAR(50) NOT NULL,
    nombre2 VARCHAR(50),
    apellido1 VARCHAR(50) NOT NULL,
    apellido2 VARCHAR(50),
    identificacion VARCHAR(20) UNIQUE,
    telefono VARCHAR(20),
    email VARCHAR(100),
    id_barrio INT FOREIGN KEY REFERENCES barrio(id),
    fecha_registro DATETIME DEFAULT GETDATE()
);

CREATE TABLE vehiculo_marca (
    id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE vehiculo_modelo (
    id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_marca INT FOREIGN KEY REFERENCES vehiculo_marca(id)
);

-- 4. INVENTORY (Auto Parts)
CREATE TABLE producto_categoria (
    id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE producto (
    id INT PRIMARY KEY,
    codigo_parte VARCHAR(50) UNIQUE,
    nombre VARCHAR(200) NOT NULL,
    descripcion VARCHAR(MAX),
    stock_actual INT DEFAULT 0,
    stock_minimo INT DEFAULT 5,
    precio_venta DECIMAL(18, 2) NOT NULL,
    id_categoria INT FOREIGN KEY REFERENCES producto_categoria(id),
    id_estado INT FOREIGN KEY REFERENCES estado(id)
);

-- 5. SUPPLIERS & PURCHASES
CREATE TABLE proveedor (
    id INT PRIMARY KEY,
    nombre_comercial VARCHAR(200) NOT NULL,
    ruc VARCHAR(20) UNIQUE,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(500),
    id_estado INT FOREIGN KEY REFERENCES estado(id)
);

CREATE TABLE compra (
    id BIGINT PRIMARY KEY,
    numero_factura_proveedor VARCHAR(50) NOT NULL,
    id_proveedor INT FOREIGN KEY REFERENCES proveedor(id),
    fecha_compra DATETIME DEFAULT GETDATE(),
    total DECIMAL(18,2) NOT NULL,
    id_estado INT FOREIGN KEY REFERENCES estado(id)
);

CREATE TABLE compra_detalle (
    id BIGINT PRIMARY KEY,
    id_compra BIGINT FOREIGN KEY REFERENCES compra(id),
    id_producto INT FOREIGN KEY REFERENCES producto(id),
    cantidad INT NOT NULL,
    costo_unitario DECIMAL(18,2) NOT NULL,
    subtotal AS (cantidad * costo_unitario)
);

-- 6. COMPATIBILIDAD DE REPUESTOS (M:N)
CREATE TABLE producto_compatibilidad (
    id INT PRIMARY KEY,
    id_producto INT FOREIGN KEY REFERENCES producto(id),
    id_modelo INT FOREIGN KEY REFERENCES vehiculo_modelo(id),
    anio_inicio INT NOT NULL,
    anio_fin INT NOT NULL
);

-- 7. KARDEX (Control de Existencias Trazable)
CREATE TABLE tipo_movimiento (
    id INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    multiplicador INT NOT NULL -- 1 para Entrada, -1 para Salida
);

CREATE TABLE movimiento (
    id BIGINT PRIMARY KEY,
    id_producto INT FOREIGN KEY REFERENCES producto(id),
    id_tipo_movimiento INT FOREIGN KEY REFERENCES tipo_movimiento(id),
    cantidad INT NOT NULL,
    costo_unitario DECIMAL(18, 2) NOT NULL,
    stock_resultante INT NOT NULL,
    fecha_movimiento DATETIME DEFAULT GETDATE(),
    id_usuario INT FOREIGN KEY REFERENCES usuario(id),
    referencia VARCHAR(100)
);

-- 8. FACTURACIÓN Y PUNTO DE VENTA
CREATE TABLE turno_caja (
    id INT PRIMARY KEY,
    id_usuario INT FOREIGN KEY REFERENCES usuario(id),
    fecha_apertura DATETIME DEFAULT GETDATE(),
    fecha_cierre DATETIME NULL,
    monto_inicial DECIMAL(18,2) NOT NULL,
    monto_final DECIMAL(18,2) NULL,
    id_estado INT FOREIGN KEY REFERENCES estado(id)
);

CREATE TABLE factura (
    id BIGINT PRIMARY KEY,
    numero_factura VARCHAR(50) UNIQUE NOT NULL,
    id_cliente INT FOREIGN KEY REFERENCES cliente(id),
    id_turno_caja INT FOREIGN KEY REFERENCES turno_caja(id),
    subtotal DECIMAL(18,2) NOT NULL,
    impuesto DECIMAL(18,2) NOT NULL,
    total DECIMAL(18,2) NOT NULL,
    fecha_emision DATETIME DEFAULT GETDATE(),
    id_estado INT FOREIGN KEY REFERENCES estado(id)
);

CREATE TABLE factura_detalle (
    id BIGINT PRIMARY KEY,
    id_factura BIGINT FOREIGN KEY REFERENCES factura(id),
    id_producto INT FOREIGN KEY REFERENCES producto(id),
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(18, 2) NOT NULL,
    subtotal AS (cantidad * precio_unitario)
);

-- 9. STORED PROCEDURES
-- (Procedimientos a implementar según SP_CRUD_GUIDELINES.md)
GO
