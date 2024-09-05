-- Crear usuario y asignar permisos
CREATE USER admin WITH ENCRYPTED PASSWORD '12345';
GRANT ALL PRIVILEGES ON DATABASE erpapp TO admin;
\c erpapp;
ALTER SCHEMA public OWNER TO admin;

-- -------------------------
-- Autenticación y Usuarios
-- -------------------------
CREATE TABLE auth_usuarios (
    id_usuario INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(256) NOT NULL,
    email VARCHAR(100) UNIQUE,
    fecha_creacion DATE DEFAULT CURRENT_TIMESTAMP,
    activo CHAR(1) DEFAULT 'Y'
);

CREATE TABLE auth_roles (
    id_rol INT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(100)
);

CREATE TABLE auth_permisos (
    id_permiso INT PRIMARY KEY,
    nombre_permiso VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(100)
);

CREATE TABLE auth_usuario_roles (
    id_usuario INT REFERENCES auth_usuarios(id_usuario),
    id_rol INT REFERENCES auth_roles(id_rol),
    PRIMARY KEY (id_usuario, id_rol)
);

CREATE TABLE auth_rol_permisos (
    id_rol INT REFERENCES auth_roles(id_rol),
    id_permiso INT REFERENCES auth_permisos(id_permiso),
    PRIMARY KEY (id_rol, id_permiso)
);

-- -------------------------
-- CRM
-- -------------------------
CREATE TABLE CRM_PERSONAS_FISICAS (
    persona_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(15),
    fecha_nacimiento DATE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    direccion TEXT,
    ciudad VARCHAR(50),
    codigo_postal VARCHAR(10),
    pais VARCHAR(50)
);

CREATE TABLE CRM_PERSONAS_MORALES (
    empresa_id SERIAL PRIMARY KEY,
    nombre_empresa VARCHAR(100) UNIQUE NOT NULL,
    rfc VARCHAR(20) UNIQUE NOT NULL,
    correo_electronico VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(15),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    direccion TEXT,
    ciudad VARCHAR(50),
    codigo_postal VARCHAR(10),
    pais VARCHAR(50)
);

CREATE TABLE CRM_CLIENTES (
    cliente_id SERIAL PRIMARY KEY,
    persona_id INT REFERENCES CRM_PERSONAS_FISICAS(persona_id) ON DELETE SET NULL,
    empresa_id INT REFERENCES CRM_PERSONAS_MORALES(empresa_id) ON DELETE SET NULL,
    estado_cliente VARCHAR(20) DEFAULT 'Nuevo',
    calificacion_cliente INT DEFAULT 0,
    comentarios TEXT,
    fecha_ultima_actividad TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE CRM_RESPONSABLES (
    responsable_id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES CRM_CLIENTES(cliente_id) ON DELETE CASCADE,
    nombre_responsable VARCHAR(100),
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE CRM_INTERACCIONES (
    interaccion_id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES CRM_CLIENTES(cliente_id) ON DELETE CASCADE,
    tipo_interaccion VARCHAR(50),
    fecha_interaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comentarios TEXT
);

CREATE TABLE CRM_ETAPAS_VENTA (
    etapa_id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES CRM_CLIENTES(cliente_id) ON DELETE CASCADE,
    etapa_actual VARCHAR(50),
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------
-- Productos e Inventario
-- -------------------------
CREATE TABLE INVENTARIO_PROVEEDORES (
    proveedor_id SERIAL PRIMARY KEY,
    nombre_proveedor VARCHAR(100) NOT NULL,
    contacto_proveedor VARCHAR(100),
    telefono_proveedor VARCHAR(15),
    direccion_proveedor TEXT,
    correo_electronico_proveedor VARCHAR(100)
);

CREATE TABLE INVENTARIO_PRODUCTOS (
    producto_id SERIAL PRIMARY KEY,
    codigo_producto VARCHAR(50) UNIQUE NOT NULL,
    nombre_producto VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio_unitario NUMERIC(12, 2) NOT NULL,
    cantidad_disponible INT NOT NULL,
    stock_minimo INT DEFAULT 0,
    stock_maximo INT DEFAULT 0,
    categoria VARCHAR(100),
    proveedor_id INT REFERENCES INVENTARIO_PROVEEDORES(proveedor_id) ON DELETE SET NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_producto VARCHAR(50) DEFAULT 'Disponible'
);

CREATE TABLE INVENTARIO_CATEGORIAS (
    categoria_id SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE INVENTARIO_MOVIMIENTOS (
    movimiento_id SERIAL PRIMARY KEY,
    producto_id INT REFERENCES INVENTARIO_PRODUCTOS(producto_id) ON DELETE CASCADE,
    tipo_movimiento VARCHAR(50),
    cantidad INT NOT NULL,
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comentarios TEXT
);

-- -------------------------
-- Órdenes
-- -------------------------
CREATE TABLE ORDENES_COTIZACIONES (
    orden_id SERIAL PRIMARY KEY,
    numero_orden VARCHAR(20) UNIQUE NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cliente_id INT REFERENCES CRM_CLIENTES(cliente_id) ON DELETE SET NULL,
    vendedor_id INT REFERENCES CRM_RESPONSABLES(responsable_id) ON DELETE SET NULL,
    equipo_ventas VARCHAR(50),
    total NUMERIC(12, 2) NOT NULL,
    estado_orden VARCHAR(50) NOT NULL,
    tipo_actividad VARCHAR(50),
    comentarios TEXT
);

CREATE TABLE ORDENES_ACTIVIDADES (
    actividad_id SERIAL PRIMARY KEY,
    orden_id INT REFERENCES ORDENES_COTIZACIONES(orden_id) ON DELETE CASCADE,
    tipo_actividad VARCHAR(50),
    descripcion TEXT,
    fecha_actividad TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ORDENES_PRODUCTOS (
    orden_producto_id SERIAL PRIMARY KEY,
    orden_id INT REFERENCES ORDENES_COTIZACIONES(orden_id) ON DELETE CASCADE,
    producto_id INT REFERENCES INVENTARIO_PRODUCTOS(producto_id) ON DELETE SET NULL,
    cantidad INT NOT NULL,
    precio_unitario NUMERIC(12, 2) NOT NULL,
    total_producto NUMERIC(12, 2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED
);

CREATE TABLE ORDENES_ESTADOS (
    estado_id SERIAL PRIMARY KEY,
    orden_id INT REFERENCES ORDENES_COTIZACIONES(orden_id) ON DELETE CASCADE,
    estado_actual VARCHAR(50),
    fecha_estado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comentarios TEXT
);

-- -------------------------
-- Documentos
-- -------------------------
CREATE TABLE DOCUMENTOS (
    documento_id SERIAL PRIMARY KEY,
    referencia_id INT,
    tipo_documento VARCHAR(50),
    nombre_documento VARCHAR(255) NOT NULL,
    fecha_emision TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archivo BYTEA,
    extension_archivo VARCHAR(10),
    comentarios TEXT
);

CREATE TABLE DOCUMENTOS_RELACIONES (
    relacion_id SERIAL PRIMARY KEY,
    documento_id INT REFERENCES DOCUMENTOS(documento_id) ON DELETE CASCADE,
    orden_id INT REFERENCES ORDENES_COTIZACIONES(orden_id) ON DELETE CASCADE,
    cliente_id INT REFERENCES CRM_CLIENTES(cliente_id) ON DELETE CASCADE,
    tipo_relacion VARCHAR(50)
);

-- -------------------------
-- Campañas de Marketing
-- -------------------------
CREATE TABLE CAMPANAS_MARKETING (
    campana_id SERIAL PRIMARY KEY,
    nombre_campana VARCHAR(255) NOT NULL,
    tipo_campana VARCHAR(50),
    descripcion TEXT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado_campana VARCHAR(50) DEFAULT 'Activa',
    presupuesto NUMERIC(12, 2),
    objetivo VARCHAR(255),
    comentarios TEXT
);

CREATE TABLE CAMPANAS_CLIENTES (
    campana_cliente_id SERIAL PRIMARY KEY,
    campana_id INT REFERENCES CAMPANAS_MARKETING(campana_id) ON DELETE CASCADE,
    cliente_id INT REFERENCES CRM_CLIENTES(cliente_id) ON DELETE CASCADE,
    estado_cliente_campana VARCHAR(50) DEFAULT 'Nuevo',
    fecha_ultimo_contacto TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resultado_campana VARCHAR(255)
);

CREATE TABLE CAMPANAS_ACTIVIDADES (
    actividad_id SERIAL PRIMARY KEY,
    campana_id INT REFERENCES CAMPANAS_MARKETING(campana_id) ON DELETE CASCADE,
    tipo_actividad VARCHAR(50),
    fecha_actividad TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    comentarios TEXT
);

-- -------------------------
-- Contabilidad
-- -------------------------
CREATE TABLE CONTABILIDAD_CUENTAS (
    cuenta_id SERIAL PRIMARY KEY,
    nombre_cuenta VARCHAR(100) NOT NULL,
    tipo_cuenta VARCHAR(50),
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE CONTABILIDAD_TRANSACCIONES (
    transaccion_id SERIAL PRIMARY KEY,
    numero_transaccion VARCHAR(20) UNIQUE NOT NULL,
    tipo_transaccion VARCHAR(50),
    fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT,
    monto NUMERIC(12, 2) NOT NULL,
    cliente_id INT REFERENCES CRM_CLIENTES(cliente_id) ON DELETE SET NULL,
    proveedor_id INT REFERENCES INVENTARIO_PROVEEDORES(proveedor_id) ON DELETE SET NULL,
    estado_transaccion VARCHAR(50) DEFAULT 'Pendiente',
    comentarios TEXT
);

CREATE TABLE CONTABILIDAD_ASIENTOS_CONTABLES (
    asiento_id SERIAL PRIMARY KEY,
    transaccion_id INT REFERENCES CONTABILIDAD_TRANSACCIONES(transaccion_id) ON DELETE CASCADE,
    cuenta_id INT REFERENCES CONTABILIDAD_CUENTAS(cuenta_id) ON DELETE CASCADE,
    tipo_asiento VARCHAR(50),
    monto NUMERIC(12, 2) NOT NULL,
    fecha_asiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------
-- Compras
-- -------------------------
CREATE TABLE COMPRAS_ORDENES (
    compra_id SERIAL PRIMARY KEY,
    numero_compra VARCHAR(20) UNIQUE NOT NULL,
    proveedor_id INT REFERENCES INVENTARIO_PROVEEDORES(proveedor_id) ON DELETE SET NULL,
    fecha_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega DATE,
    estado_compra VARCHAR(50) DEFAULT 'Pendiente',
    monto_total NUMERIC(12, 2) NOT NULL,
    comentarios TEXT
);

CREATE TABLE COMPRAS_PRODUCTOS (
    compra_producto_id SERIAL PRIMARY KEY,
    compra_id INT REFERENCES COMPRAS_ORDENES(compra_id) ON DELETE CASCADE,
    producto_id INT REFERENCES INVENTARIO_PRODUCTOS(producto_id) ON DELETE SET NULL,
    cantidad INT NOT NULL,
    precio_unitario NUMERIC(12, 2) NOT NULL,
    total_producto NUMERIC(12, 2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED
);

CREATE TABLE COMPRAS_RECEPCIONES (
    recepcion_id SERIAL PRIMARY KEY,
    compra_id INT REFERENCES COMPRAS_ORDENES(compra_id) ON DELETE CASCADE,
    fecha_recepcion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    recibido_por VARCHAR(100),
    cantidad_recibida INT NOT NULL,
    comentarios TEXT
);

-- -------------------------
-- Ventas
-- -------------------------
CREATE TABLE VENTAS_ORDENES (
    venta_id SERIAL PRIMARY KEY,
    numero_venta VARCHAR(20) UNIQUE NOT NULL,
    cliente_id INT REFERENCES CRM_CLIENTES(cliente_id) ON DELETE SET NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_venta VARCHAR(50) DEFAULT 'Pendiente',
    monto_total NUMERIC(12, 2) NOT NULL,
    comentarios TEXT
);

CREATE TABLE VENTAS_PRODUCTOS (
    venta_producto_id SERIAL PRIMARY KEY,
    venta_id INT REFERENCES VENTAS_ORDENES(venta_id) ON DELETE CASCADE,
    producto_id INT REFERENCES INVENTARIO_PRODUCTOS(producto_id) ON DELETE SET NULL,
    cantidad INT NOT NULL,
    precio_unitario NUMERIC(12, 2) NOT NULL,
    total_producto NUMERIC(12, 2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED
);

CREATE TABLE VENTAS_FACTURAS (
    factura_id SERIAL PRIMARY KEY,
    venta_id INT REFERENCES VENTAS_ORDENES(venta_id) ON DELETE CASCADE,
    numero_factura VARCHAR(20) UNIQUE NOT NULL,
    fecha_factura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    monto_factura NUMERIC(12, 2) NOT NULL,
    estado_factura VARCHAR(50) DEFAULT 'Emitida',
    comentarios TEXT
);

-- -------------------------
-- Marketing
-- -------------------------
CREATE TABLE MARKETING_LISTAS (
    lista_id SERIAL PRIMARY KEY,
    nombre_lista VARCHAR(255) NOT NULL,
    tipo_lista VARCHAR(50),
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_lista VARCHAR(50) DEFAULT 'Activa'
);

CREATE TABLE MARKETING_LISTAS_CLIENTES (
    lista_cliente_id SERIAL PRIMARY KEY,
    lista_id INT REFERENCES MARKETING_LISTAS(lista_id) ON DELETE CASCADE,
    cliente_id INT REFERENCES CRM_CLIENTES(cliente_id) ON DELETE CASCADE,
    estado_cliente_lista VARCHAR(50) DEFAULT 'Suscrito',
    fecha_suscripcion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE MARKETING_CAMPANAS (
    campana_id SERIAL PRIMARY KEY,
    lista_id INT REFERENCES MARKETING_LISTAS(lista_id) ON DELETE CASCADE,
    nombre_campana VARCHAR(255) NOT NULL,
    tipo_campana VARCHAR(50),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado_campana VARCHAR(50) DEFAULT 'Activa',
    presupuesto NUMERIC(12, 2),
    objetivo VARCHAR(255),
    comentarios TEXT
);

CREATE TABLE MARKETING_RESULTADOS (
    resultado_id SERIAL PRIMARY KEY,
    campana_id INT REFERENCES MARKETING_CAMPANAS(campana_id) ON DELETE CASCADE,
    cliente_id INT REFERENCES CRM_CLIENTES(cliente_id) ON DELETE CASCADE,
    fecha_resultado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tipo_resultado VARCHAR(50),
    comentarios TEXT
);
