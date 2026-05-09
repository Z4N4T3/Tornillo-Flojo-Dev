# Modelo Relacional de Base de Datos - Autopartes "El Tornillo Flojo"

A continuación se presenta el Diagrama de Entidad-Relación (ERD) detallado con todas las tablas, campos, tipos de datos y relaciones del esquema consolidado actual.

```mermaid
erDiagram
    estado {
        INT id PK
        VARCHAR(50) nombre
    }

    departamento {
        INT id PK
        VARCHAR(100) nombre
    }

    municipio {
        INT id PK
        VARCHAR(100) nombre
        INT id_dep FK
    }

    barrio {
        INT id PK
        VARCHAR(100) nombre
        INT id_mun FK
    }

    sucursal {
        INT id PK
        VARCHAR(150) nombre
        VARCHAR(20) telefono
        VARCHAR(100) email
        INT id_barrio FK
        VARCHAR(300) direccion_detalle
        BIT es_principal
        INT id_estado FK
    }

    permiso {
        INT id PK
        VARCHAR(100) nombre
        VARCHAR(200) descripcion
    }

    rol {
        INT id PK
        VARCHAR(50) nombre
        VARCHAR(200) descripcion
        INT id_estado FK
    }

    rol_permiso {
        INT id_rol PK,FK
        INT id_permiso PK,FK
    }

    cargo {
        INT id PK
        VARCHAR(100) nombre
        VARCHAR(500) descripcion
        DECIMAL(18,2) salario_base
        INT id_estado FK
    }

    empleado {
        INT id PK
        VARCHAR(50) nombre1
        VARCHAR(50) nombre2
        VARCHAR(50) apellido1
        VARCHAR(50) apellido2
        VARCHAR(20) identificacion
        CHAR(1) genero
        INT id_cargo FK
        INT id_sucursal FK
        INT id_estado FK
    }

    usuario {
        INT id PK
        VARCHAR(50) username
        VARCHAR(256) password_hash
        INT id_empleado FK
        INT id_rol FK
        INT id_sucursal FK
        INT id_estado FK
        DATETIME fecha_creacion
    }

    usuario_permiso {
        INT id_usuario PK,FK
        INT id_permiso PK,FK
    }

    cliente {
        INT id PK
        VARCHAR(50) nombre1
        VARCHAR(50) nombre2
        VARCHAR(50) apellido1
        VARCHAR(50) apellido2
        VARCHAR(20) identificacion
        VARCHAR(20) telefono
        VARCHAR(100) email
        INT id_barrio FK
        DATETIME fecha_registro
    }

    vehiculo_marca {
        INT id PK
        VARCHAR(100) nombre
    }

    vehiculo_modelo {
        INT id PK
        VARCHAR(100) nombre
        INT id_marca FK
    }

    producto_marca {
        INT id PK
        VARCHAR(100) nombre
    }

    producto_categoria {
        INT id PK
        VARCHAR(100) nombre
    }

    producto {
        INT id PK
        VARCHAR(50) codigo_parte
        VARCHAR(200) nombre
        VARCHAR(MAX) descripcion
        DECIMAL(18,2) precio_costo
        DECIMAL(18,2) precio_venta
        INT id_marca FK
        INT id_categoria FK
        INT id_estado FK
    }

    inventario_sucursal {
        INT id_sucursal PK,FK
        INT id_producto PK,FK
        INT stock_actual
        INT stock_minimo
    }

    proveedor {
        INT id PK
        VARCHAR(200) nombre_comercial
        VARCHAR(20) ruc
        VARCHAR(20) telefono
        VARCHAR(100) email
        VARCHAR(500) direccion
        INT id_estado FK
    }

    compra {
        BIGINT id PK
        VARCHAR(50) numero_factura_proveedor
        INT id_proveedor FK
        INT id_sucursal FK
        DATETIME fecha_compra
        DECIMAL(18,2) total
        INT id_estado FK
    }

    compra_detalle {
        BIGINT id PK
        BIGINT id_compra FK
        INT id_producto FK
        INT cantidad
        DECIMAL(18,2) costo_unitario
        DECIMAL(18,2) subtotal
    }

    producto_compatibilidad {
        INT id PK
        INT id_producto FK
        INT id_modelo FK
        INT anio_inicio
        INT anio_fin
    }

    tipo_movimiento {
        INT id PK
        VARCHAR(50) nombre
        INT multiplicador
    }

    movimiento {
        BIGINT id PK
        INT id_producto FK
        INT id_tipo_movimiento FK
        INT id_sucursal FK
        INT cantidad
        DECIMAL(18,2) costo_unitario
        INT stock_resultante
        DATETIME fecha_movimiento
        INT id_usuario FK
        VARCHAR(100) referencia
    }

    turno_caja {
        INT id PK
        INT id_usuario FK
        INT id_sucursal FK
        DATETIME fecha_apertura
        DATETIME fecha_cierre
        DECIMAL(18,2) monto_inicial
        DECIMAL(18,2) monto_final
        INT id_estado FK
    }

    factura {
        BIGINT id PK
        VARCHAR(50) numero_factura
        INT id_cliente FK
        INT id_turno_caja FK
        INT id_sucursal FK
        DECIMAL(18,2) subtotal
        DECIMAL(18,2) impuesto
        DECIMAL(18,2) total
        DATETIME fecha_emision
        INT id_estado FK
    }

    factura_detalle {
        BIGINT id PK
        BIGINT id_factura FK
        INT id_producto FK
        INT cantidad
        DECIMAL(18,2) precio_unitario
        DECIMAL(18,2) subtotal
    }

    gasto_operativo {
        BIGINT id PK
        INT id_turno_caja FK
        INT id_sucursal FK
        VARCHAR(300) concepto
        DECIMAL(18,2) monto
        DATETIME fecha
        INT id_usuario FK
        INT id_estado FK
    }

    %% RELACIONES

    %% Geografía
    departamento ||--o{ municipio : "tiene"
    municipio ||--o{ barrio : "contiene"

    %% Sucursal
    barrio ||--o{ sucursal : "ubica"
    estado ||--o{ sucursal : "estatus"

    %% Seguridad y HR
    estado ||--o{ rol : "estatus"
    rol ||--o{ rol_permiso : "posee"
    permiso ||--o{ rol_permiso : "incluido_en"

    estado ||--o{ cargo : "estatus"
    cargo ||--o{ empleado : "desempeña"
    sucursal ||--o{ empleado : "labora_en"
    estado ||--o{ empleado : "estatus"

    empleado ||--o{ usuario : "es"
    rol ||--o{ usuario : "tiene_perfil"
    sucursal ||--o{ usuario : "opera_en"
    estado ||--o{ usuario : "estatus"

    usuario ||--o{ usuario_permiso : "tiene_permiso_extra"
    permiso ||--o{ usuario_permiso : "asignado_a"

    %% Clientes
    barrio ||--o{ cliente : "reside"

    %% Vehículos
    vehiculo_marca ||--o{ vehiculo_modelo : "fabrica"

    %% Productos
    producto_marca ||--o{ producto : "marca"
    producto_categoria ||--o{ producto : "clasifica"
    estado ||--o{ producto : "estatus"

    %% Inventario por Sucursal
    sucursal ||--o{ inventario_sucursal : "almacena"
    producto ||--o{ inventario_sucursal : "en_stock"

    %% Compras
    estado ||--o{ proveedor : "estatus"
    proveedor ||--o{ compra : "provee"
    sucursal ||--o{ compra : "realizada_por"
    estado ||--o{ compra : "estatus"

    compra ||--|{ compra_detalle : "contiene"
    producto ||--o{ compra_detalle : "adquirido_en"

    %% Compatibilidad
    producto ||--o{ producto_compatibilidad : "aplica_a"
    vehiculo_modelo ||--o{ producto_compatibilidad : "es_compatible_con"

    %% Movimientos (Kardex)
    producto ||--o{ movimiento : "afectado_por"
    tipo_movimiento ||--o{ movimiento : "es_de_tipo"
    sucursal ||--o{ movimiento : "ocurre_en"
    usuario ||--o{ movimiento : "registrado_por"

    %% Ventas
    usuario ||--o{ turno_caja : "abre"
    sucursal ||--o{ turno_caja : "pertenece_a"
    estado ||--o{ turno_caja : "estatus"

    cliente ||--o{ factura : "compra"
    turno_caja ||--o{ factura : "generada_en"
    sucursal ||--o{ factura : "emitida_por"
    estado ||--o{ factura : "estatus"

    factura ||--|{ factura_detalle : "incluye"
    producto ||--o{ factura_detalle : "vendido_en"

    %% Egresos
    turno_caja ||--o{ gasto_operativo : "registra"
    sucursal ||--o{ gasto_operativo : "ejercido_en"
    usuario ||--o{ gasto_operativo : "autorizado_por"
    estado ||--o{ gasto_operativo : "estatus"

```
