# Informe de Normalización de Base de Datos
**Proyecto:** Autopartes El Tornillo Flojo
**Archivo analizado:** `DB_TornilloFLojo.sql`

## 1. Resumen de Cumplimiento
Tras analizar exhaustivamente el esquema de la base de datos, se determina que el diseño **cumple en su mayor parte** con las reglas de normalización (está estructurado de manera sólida), pero presenta ciertas **excepciones de desnormalización deliberada** muy comunes en sistemas transaccionales para optimizar el rendimiento.

A continuación, se detalla el análisis para cada forma normal (1NF, 2NF, 3NF) y se proponen los cambios necesarios si se desea un cumplimiento estricto.

---

## 2. Primera Forma Normal (1NF)
**Regla:** Todos los atributos deben ser atómicos (indivisibles), no deben existir grupos repetitivos y cada tabla debe tener una clave primaria.
*   **Estado:** Parcialmente Cumple.
*   **Análisis:**
    *   Todas las tablas poseen una clave primaria explícita (`id`).
    *   No existen arreglos ni grupos repetitivos en las columnas.
    *   **Falla técnica en atomicidad:** En la tabla `cliente`, el campo `nombre_completo` almacena tanto nombres como apellidos en una sola cadena de texto. Si el negocio requiere buscar, ordenar o agrupar solo por apellido, este campo no es atómico. En contraste, la tabla `empleado` sí está normalizada separando `nombre1`, `nombre2`, `apellido1`, `apellido2`.

## 3. Segunda Forma Normal (2NF)
**Regla:** El esquema debe estar en 1NF. Además, no deben existir dependencias parciales (ningún atributo no clave debe depender solo de una parte de una clave primaria compuesta).
*   **Estado:** Cumple totalmente.
*   **Análisis:** 
    *   El diseño utiliza claves primarias subrogadas (`id` tipo INT o BIGINT) de una sola columna en todas las tablas del esquema.
    *   Dado que no existen claves primarias compuestas en la estructura, es lógicamente imposible que exista una dependencia parcial hacia la clave. Todos los atributos de cada tabla dependen de la clave primaria completa (`id`).

## 4. Tercera Forma Normal (3NF)
**Regla:** El esquema debe estar en 2NF. Además, no deben existir dependencias transitivas (ningún atributo no clave debe depender de otro atributo no clave; todos deben depender única y directamente de la clave primaria de la tabla).
*   **Estado:** No Cumple (Existen desnormalizaciones intencionales).
*   **Análisis:** Se identificaron campos que almacenan datos calculados o derivados, lo cual viola la 3NF, ya que sus valores dependen del contenido de otras tablas:
    1.  **Redundancia de Totales en Factura:** En la tabla `factura`, los campos `subtotal`, `impuesto` y `total` dependen del cálculo de las sumas en `factura_detalle`. 
    2.  **Redundancia de Totales en Compra:** En la tabla `compra`, el campo `total` depende lógicamente de la sumatoria aritmética de los subtotales en `compra_detalle`.
    3.  **Redundancia de Inventario:** En la tabla `producto`, el campo `stock_actual` viola la 3NF porque su valor depende íntegramente de la sumatoria de los movimientos (entradas y salidas) registrados en la tabla `kardex`. 

*(Nota: En sistemas transaccionales y de punto de venta (POS), mantener el `stock_actual` y los `totales` pre-calculados es una buena práctica para no comprometer el rendimiento de las consultas y lecturas, aunque teóricamente rompa la 3NF).*

---

## 5. Propuesta de Cambios (Para un cumplimiento estricto)

Si el objetivo del proyecto exige que la base de datos esté **100% normalizada**, se deben aplicar las siguientes modificaciones estructurales:

### Para cumplir con 1NF:
**1. Modificar tabla `cliente`:**
Dividir `nombre_completo` para garantizar la atomicidad y estandarizar con la estructura de `empleado`.
```sql
ALTER TABLE cliente DROP COLUMN nombre_completo;
ALTER TABLE cliente ADD nombre1 VARCHAR(50) NOT NULL;
ALTER TABLE cliente ADD nombre2 VARCHAR(50);
ALTER TABLE cliente ADD apellido1 VARCHAR(50) NOT NULL;
ALTER TABLE cliente ADD apellido2 VARCHAR(50);
```

### Para cumplir con 3NF:
**2. Modificar tabla `producto`:**
Eliminar el campo de stock almacenado. El stock debería consultarse mediante una VISTA (`VIEW`) que agrupe y sume el histórico del `kardex`.
```sql
ALTER TABLE producto DROP COLUMN stock_actual;
```

**3. Modificar tabla `compra`:**
Eliminar la columna total. El valor de la compra se debe calcular dinámicamente.
```sql
ALTER TABLE compra DROP COLUMN total;
```

**4. Modificar tabla `factura`:**
Eliminar las columnas de totales.
```sql
ALTER TABLE factura DROP COLUMN subtotal;
ALTER TABLE factura DROP COLUMN impuesto;
ALTER TABLE factura DROP COLUMN total;
```

---

## 6. Conclusión y Recomendación

El esquema actual presenta un nivel maduro de diseño relacional. 

**Recomendación Arquitectónica:**
*   **Sobre la 1NF:** **Se recomienda fuertemente aplicar el cambio propuesto para la tabla `cliente`**. Dividir el nombre mejorará la calidad de los datos, facilitará reportes alfabéticos y estandarizará el diseño con la tabla de empleados.
*   **Sobre la 3NF:** **NO se recomienda aplicar los cambios estrictos de la 3NF**. Eliminar los totales de facturas y el stock actual degradará significativamente el rendimiento del sistema cuando la base de datos crezca. Se sugiere mantener estas desnormalizaciones controladas y garantizar la integridad de los datos exclusivamente mediante transacciones y **Stored Procedures**, tal y como parece ser la directriz del proyecto (`SP_CRUD_GUIDELINES.md`).
