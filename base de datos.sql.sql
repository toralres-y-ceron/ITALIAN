CREATE DATABASE IF NOT EXISTS italian
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE italian;

CREATE TABLE IF NOT EXISTS usuarios (
	id_usuario INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
	apellido VARCHAR(100) NOT NULL,
	correo VARCHAR(150) NOT NULL UNIQUE,
	telefono VARCHAR(30),
	contrasena VARCHAR(255) NOT NULL,
	rol ENUM('admin', 'cliente') NOT NULL DEFAULT 'cliente',
	creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS destinos (
	id_destino INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	pais VARCHAR(100) NOT NULL,
	ciudad VARCHAR(100) NOT NULL,
	descripcion TEXT,
	UNIQUE KEY uq_destino (pais, ciudad)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS viajes (
	id_viaje INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	id_destino INT UNSIGNED NOT NULL,
	tipo ENUM('nacional', 'internacional') NOT NULL,
	nombre VARCHAR(150) NOT NULL,
	descripcion TEXT,
	fecha_salida DATE NOT NULL,
	fecha_regreso DATE NOT NULL,
	precio DECIMAL(10, 2) NOT NULL,
	cupos INT UNSIGNED NOT NULL DEFAULT 0,
	estado ENUM('disponible', 'agotado', 'cancelado', 'finalizado') NOT NULL DEFAULT 'disponible',
	creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT chk_viaje_fechas CHECK (fecha_regreso >= fecha_salida),
	CONSTRAINT chk_viaje_precio CHECK (precio >= 0),
	CONSTRAINT fk_viaje_destino FOREIGN KEY (id_destino)
		REFERENCES destinos (id_destino)
		ON UPDATE CASCADE
		ON DELETE RESTRICT,
	INDEX idx_viajes_tipo (tipo),
	INDEX idx_viajes_fecha (fecha_salida),
	INDEX idx_viajes_estado (estado)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS reservas (
	id_reserva INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	id_usuario INT UNSIGNED NOT NULL,
	id_viaje INT UNSIGNED NOT NULL,
	cantidad_personas INT UNSIGNED NOT NULL DEFAULT 1,
	total DECIMAL(10, 2) NOT NULL,
	estado ENUM('pendiente', 'confirmada', 'cancelada') NOT NULL DEFAULT 'pendiente',
	fecha_reserva TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT chk_reserva_personas CHECK (cantidad_personas > 0),
	CONSTRAINT chk_reserva_total CHECK (total >= 0),
	CONSTRAINT fk_reserva_usuario FOREIGN KEY (id_usuario)
		REFERENCES usuarios (id_usuario)
		ON UPDATE CASCADE
		ON DELETE RESTRICT,
	CONSTRAINT fk_reserva_viaje FOREIGN KEY (id_viaje)
		REFERENCES viajes (id_viaje)
		ON UPDATE CASCADE
		ON DELETE RESTRICT,
	INDEX idx_reservas_usuario (id_usuario),
	INDEX idx_reservas_viaje (id_viaje),
	INDEX idx_reservas_estado (estado)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pagos (
	id_pago INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	id_reserva INT UNSIGNED NOT NULL,
	monto DECIMAL(10, 2) NOT NULL,
	metodo ENUM('efectivo', 'tarjeta', 'transferencia') NOT NULL,
	estado ENUM('pendiente', 'aprobado', 'rechazado', 'reembolsado') NOT NULL DEFAULT 'pendiente',
	referencia VARCHAR(100) UNIQUE,
	fecha_pago TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT chk_pago_monto CHECK (monto >= 0),
	CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva)
		REFERENCES reservas (id_reserva)
		ON UPDATE CASCADE
		ON DELETE RESTRICT,
	INDEX idx_pagos_reserva (id_reserva),
	INDEX idx_pagos_estado (estado)
) ENGINE=InnoDB;
