-- ====================================================================
-- CREACIÓN DE LA BASE DE DATOS R.A.S.A.
-- ====================================================================
CREATE DATABASE RASA_DB;
GO

USE RASA_DB;
GO

-- ====================================================================
-- 1. CREACIÓN DE TABLAS CATÁLOGO
-- ====================================================================

CREATE TABLE Especialidades (
    id_especialidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    costo DECIMAL(10,2) NOT NULL
);

CREATE TABLE Consultorios (
    id_consultorio INT IDENTITY(1,1) PRIMARY KEY,
    nombre_numero VARCHAR(20) NOT NULL,
    ala_ubicacion VARCHAR(50)
);

CREATE TABLE Inventario_Farmacia (
    id_item INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    precio_unitario DECIMAL(10,2) NOT NULL
);

-- ====================================================================
-- 2. CREACIÓN DE TABLAS DE USUARIOS Y ROLES
-- ====================================================================

CREATE TABLE Usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    correo VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- Para la prueba usaremos texto plano, en prod usar Hash
    rol VARCHAR(20) CHECK (rol IN ('Paciente', 'Doctor', 'Recepcionista', 'Farmaceutico')) NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL
);

CREATE TABLE Pacientes (
    id_paciente INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL FOREIGN KEY REFERENCES Usuarios(id_usuario),
    folio_paciente VARCHAR(20) UNIQUE NOT NULL,
    fecha_nacimiento DATE,
    telefono VARCHAR(15),
    -- Historial Médico Básico
    tipo_sangre VARCHAR(5),
    alergias VARCHAR(255),
    padecimientos_previos VARCHAR(255),
    peso DECIMAL(5,2),
    estatura INT
);

CREATE TABLE Empleados (
    id_empleado INT IDENTITY(1,1) PRIMARY KEY,
    id_usuario INT NOT NULL FOREIGN KEY REFERENCES Usuarios(id_usuario),
    num_empleado VARCHAR(20) UNIQUE NOT NULL,
    curp VARCHAR(18) UNIQUE
);

CREATE TABLE Doctores (
    id_doctor INT IDENTITY(1,1) PRIMARY KEY,
    id_empleado INT NOT NULL FOREIGN KEY REFERENCES Empleados(id_empleado),
    id_especialidad INT NOT NULL FOREIGN KEY REFERENCES Especialidades(id_especialidad),
    id_consultorio INT NOT NULL FOREIGN KEY REFERENCES Consultorios(id_consultorio),
    cedula_general VARCHAR(20) NOT NULL,
    cedula_especialidad VARCHAR(20) NOT NULL,
    turno VARCHAR(15) CHECK (turno IN ('matutino', 'vespertino')) NOT NULL
);

-- ====================================================================
-- 3. CREACIÓN DE TABLAS TRANSACCIONALES (CITAS Y RECETAS)
-- ====================================================================

CREATE TABLE Citas (
    folio_cita VARCHAR(30) PRIMARY KEY,
    id_paciente INT NOT NULL FOREIGN KEY REFERENCES Pacientes(id_paciente),
    id_doctor INT NOT NULL FOREIGN KEY REFERENCES Doctores(id_doctor),
    fecha_cita DATE NOT NULL,
    hora_cita TIME NOT NULL,
    estatus_cita VARCHAR(30) CHECK (estatus_cita IN ('Agendada pendiente de pago', 'Pagada pendiente por atender', 'Cancelada Falta de pago', 'Cancelada Paciente', 'Cancelada Doctor', 'Atendida', 'No acudió', 'En Espera')) NOT NULL,
    monto_pago DECIMAL(10,2) NOT NULL,
    fecha_creacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Recetas (
    folio_receta VARCHAR(30) PRIMARY KEY,
    folio_cita VARCHAR(30) NOT NULL FOREIGN KEY REFERENCES Citas(folio_cita),
    diagnostico TEXT NOT NULL,
    tratamiento TEXT,
    observaciones TEXT,
    fecha_emision DATETIME DEFAULT GETDATE()
);

-- ====================================================================
-- 4. CREACIÓN DE BITÁCORAS (SEGURIDAD Y AUDITORÍA)
-- ====================================================================

CREATE TABLE Bitacora_Estatus_Cita (
    id_bitacora INT IDENTITY(1,1) PRIMARY KEY,
    folio_cita VARCHAR(30) NOT NULL,
    fecha_mov DATETIME DEFAULT GETDATE(),
    estatus_cita VARCHAR(30),
    fecha_cita DATE,
    id_especialidad INT,
    costo DECIMAL(10,2),
    politica_cancela VARCHAR(50),
    monto_devuelto DECIMAL(10,2)
);

CREATE TABLE Bitacora_Historial_Citas (
    id_historial INT IDENTITY(1,1) PRIMARY KEY,
    usuario_movimiento VARCHAR(100),
    maquina_ip VARCHAR(50),
    folio_cita VARCHAR(30),
    fecha_cita DATE,
    hora_cita TIME,
    id_paciente INT,
    folio_receta VARCHAR(30),
    id_doctor INT,
    estatus_consulta VARCHAR(30),
    especialidad VARCHAR(50),
    consultorio VARCHAR(20)
);

-- ====================================================================
-- 5. INSERCIÓN DE DATOS DE PRUEBA (DUMMY DATA)
-- ====================================================================

-- Insertar Especialidades (Con los precios exactos del frontend)
INSERT INTO Especialidades (nombre, costo) VALUES 
('Cardiología', 1500.00), ('Dermatología', 1300.00), ('Ginecología', 800.00), 
('Medicina General', 120.00), ('Nefrología', 800.00), ('Nutriología', 500.00), 
('Oftalmología', 500.00), ('Oncología', 1200.00), ('Ortopedia', 300.00), 
('Pediatría', 700.00);

-- Insertar Consultorios
INSERT INTO Consultorios (nombre_numero, ala_ubicacion) VALUES 
('Consultorio 101', 'Ala Norte'), ('Consultorio 102', 'Ala Norte'),
('Consultorio 201', 'Ala Sur'), ('Consultorio 202', 'Ala Sur');

-- Insertar Usuarios de Prueba (1 Paciente, 1 Recepcionista, 1 Farmacéutico, 2 Doctores)
INSERT INTO Usuarios (correo, password_hash, rol, nombre_completo) VALUES 
('j.perez@gmail.com', '12345', 'Paciente', 'Juan Pérez'),
('a.martinez@rasa.com', 'admin123', 'Recepcionista', 'Ana Martínez'),
('e.rivas@rasa.com', 'admin123', 'Farmaceutico', 'Elena Rivas'),
('r.sanchez@rasa.com', 'doc123', 'Doctor', 'Dr. Roberto Sánchez'),
('l.torres@rasa.com', 'doc123', 'Doctor', 'Dr. Luis Torres');

-- Asignar el Paciente
INSERT INTO Pacientes (id_usuario, folio_paciente, fecha_nacimiento, telefono, tipo_sangre, alergias) VALUES 
(1, 'PAC-001', '1990-05-15', '5512345678', 'O+', 'Ninguna');

-- Asignar Empleados (Recepcionista, Farmacéutico y Doctores)
INSERT INTO Empleados (id_usuario, num_empleado, curp) VALUES 
(2, 'EMP-001', 'MART800101XXXXXX'),
(3, 'EMP-002', 'RIVA850202XXXXXX'),
(4, 'MED-092', 'SANR800514XXXXXX'),
(5, 'MED-093', 'TORL750820XXXXXX');

-- Asignar los Doctores a su especialidad y turno
-- Dr. Roberto Sánchez (Cardiología - Matutino)
INSERT INTO Doctores (id_empleado, id_especialidad, id_consultorio, cedula_general, cedula_especialidad, turno) VALUES 
(3, 1, 1, '8892314', 'ESP-455612', 'matutino');

-- Dr. Luis Torres (Cardiología - Vespertino)
INSERT INTO Doctores (id_empleado, id_especialidad, id_consultorio, cedula_general, cedula_especialidad, turno) VALUES 
(4, 1, 2, '7781234', 'ESP-998877', 'vespertino');

-- Insertar Inventario de Farmacia
INSERT INTO Inventario_Farmacia (nombre, categoria, stock, precio_unitario) VALUES 
('Paracetamol 500mg', 'Medicamento', 12, 25.00),
('Ibuprofeno 400mg', 'Medicamento', 85, 35.50),
('Amoxicilina 500mg', 'Antibiótico', 3, 70.00),
('Jeringas (Caja 100u)', 'Insumo Médico', 4, 150.00);

-- Insertar una Cita de Prueba
INSERT INTO Citas (folio_cita, id_paciente, id_doctor, fecha_cita, hora_cita, estatus_cita, monto_pago) VALUES 
('HOSP-2026-8842', 1, 1, '2026-05-14', '10:00:00', 'Pagada pendiente por atender', 1500.00);
GO