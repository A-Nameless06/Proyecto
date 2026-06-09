-- ============================================
-- BASE DE DATOS: CentroMedicoRASA
-- ============================================

-- Crear la base de datos
CREATE DATABASE CentroMedicoRASA;
GO

USE CentroMedicoRASA;
GO

-- ============================================
-- 1. TABLAS PRINCIPALES
-- ============================================

--Tabla: Usuario --NUEVO
CREATE TABLE USUARIO ( 
    Id_usuario      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    usuario         VARCHAR(50)  NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    Rol             VARCHAR(20)  NOT NULL,  -- 'Paciente','Recepcionista','Administrador','Farmaceutico'
    Activo          BIT          NOT NULL DEFAULT 1,
    Ultimo_acceso   DATETIME     NULL
);

-- Tabla: PACIENTE (con campos de autenticación)
CREATE TABLE PACIENTE (
    Id_paciente        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_usuario         INT NOT NULL,
    Nombre             VARCHAR(50) NOT NULL,
    Apellido_Paterno   VARCHAR(50) NOT NULL,
    Apellido_Materno   VARCHAR(50),
    Curp               VARCHAR(20) NOT NULL UNIQUE,
    Telefono           VARCHAR(15),
    Correo             VARCHAR(100),
    Fecha_nacimiento   DATE,
    Edad               INT,
    Estatura           DECIMAL(5,2),
    Peso               DECIMAL(5,2),
    Tipo_sangre        VARCHAR(5),
    Alergias           VARCHAR(200)
);

-- Tabla: HISTORIA_MEDICO
CREATE TABLE HISTORIA_MEDICO (
    Id_historial       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_paciente        INT NOT NULL,
    Tipo_sangre        VARCHAR(10),
    Estatura           DECIMAL(5,2),
    Peso               DECIMAL(5,2),
    Edad               INT,
    Alergias           VARCHAR(200),
    Fecha_registro     DATETIME DEFAULT GETDATE()
);

-- Tabla: ESPECIALIDAD
CREATE TABLE ESPECIALIDAD (
    Id_especialidad    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre             VARCHAR(50) NOT NULL,
    Costo_Consulta     MONEY,
    Descripcion        VARCHAR(200)
);

-- Tabla: HORARIO
CREATE TABLE HORARIO (
    Id_Horario         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Hora_Inicio        TIME NOT NULL,
    Hora_Fin           TIME NOT NULL,
    Dia                VARCHAR(20)
);


-- Tabla: EMPLEADO (con autenticación unificada)
CREATE TABLE EMPLEADO (
    Id_empleado        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_usuario         INT NOT NULL,
    Nombre             VARCHAR(50) NOT NULL,
    Apellido_Paterno   VARCHAR(50),
    Apellido_Materno   VARCHAR(50),
    Tipo_empleo        VARCHAR(20),
    Curp               VARCHAR(20) NOT NULL UNIQUE,
    Correo             VARCHAR(100) NOT NULL UNIQUE,
    Telefono           VARCHAR(20),
    Fecha_contratacion DATE
);

-- Tabla: DOCTOR
CREATE TABLE DOCTOR (
    Id_doctor          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_empleado        INT NOT NULL,
    Id_especialidad    INT NOT NULL,
    Id_Horario         INT NOT NULL,
    Consultorio_asignado INT NULL
);

-- Tabla: Horario Empleado
CREATE TABLE EMPLEADO_HORARIO (
    Id_empleado INT,
    Id_Horario INT,
    PRIMARY KEY (Id_empleado, Id_Horario),
    FOREIGN KEY (Id_empleado) REFERENCES EMPLEADO(Id_empleado),
    FOREIGN KEY (Id_Horario) REFERENCES HORARIO(Id_Horario)
);

-- Tabla: RECEPCIONISTA
CREATE TABLE RECEPCIONISTA (
    Id_Recepcionista   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_empleado        INT NOT NULL,
    Hora_Inicio        TIME NOT NULL,
    Hora_Fin           TIME NOT NULL
);

-- Tabla: CONSULTORIO
CREATE TABLE CONSULTORIO (
    Id_consultorio     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_Doctor          INT NOT NULL,
    Numero             INT,
    Piso               INT,
    Descripcion        VARCHAR(100)
);

-- Tabla: MEDICAMENTO
CREATE TABLE MEDICAMENTO (
    Id_medicamento     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre             VARCHAR(50) NOT NULL,
    Descripcion        VARCHAR(100),
    Concentracion      VARCHAR(50),
    Precio             MONEY,
    Stock              INT DEFAULT 0
);

-- Tabla: ALMACEN
CREATE TABLE ALMACEN (
    Id_Almacen         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_medicamento     INT NOT NULL,
    Existencias        INT,
    Tipo               VARCHAR(20)
);

-- Tabla: SERVICIO
CREATE TABLE SERVICIO (
    Id_servicio        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre             VARCHAR(50),
    Costo              DECIMAL(10,2),
    Descripcion        VARCHAR(200)
);

-- Tabla: RECETA
CREATE TABLE RECETA (
    Id_receta          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_paciente        INT NOT NULL,
    Id_doctor          INT NOT NULL,
    Fecha              DATE NOT NULL,
    Diagnostico        VARCHAR(200) NOT NULL,
    Tratamiento        VARCHAR(200),
    Indicaciones       VARCHAR(200)
);

-- Tabla: RECETA_MEDICINA
CREATE TABLE RECETA_MEDICINA (
    Id_receta_medicina INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_receta          INT NOT NULL,
    Id_medicamento     INT NOT NULL,
    Dosis              DECIMAL(10,2) NOT NULL,
    Frecuencia         VARCHAR(50) NOT NULL,
    Indicaciones       VARCHAR(200),
    Cantidad           INT DEFAULT 1
);


-- Tabla: CITA
CREATE TABLE CITA (
    Id_cita            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_paciente        INT NOT NULL,
    Id_doctor          INT NOT NULL,
    Id_consultorio     INT NOT NULL,
    Id_receta          INT NULL,
    Fecha_cita         DATE NOT NULL,
    hora_cita          TIME NOT NULL,
    Dia                INT,
    Mes                INT,
    Estatus            BIT NOT NULL DEFAULT 1, -- 1 = Activa, 0 = Cancelada
    Diagnostico        VARCHAR(200),
    Tratamiento        VARCHAR(200),
    Hora_Fin           TIME NULL
);

-- Tabla: CITA_SERVICIO
CREATE TABLE CITA_SERVICIO (
    Id_cita_servicio   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_cita            INT NOT NULL,
    Id_servicio        INT NOT NULL,
    Cantidad           INT NOT NULL,
    Subtotal           DECIMAL(10,2) NOT NULL
);

-- Tabla: TICKET
CREATE TABLE TICKET (
    Id_ticket          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_cita            INT NOT NULL,
    Fecha              DATE NOT NULL,
    Subtotal           DECIMAL(10,2),
    Monto_total        DECIMAL(10,2),
    Estatus_pago       VARCHAR(20) DEFAULT 'Pendiente'
);

-- Tabla: PAGO
CREATE TABLE PAGO (
    Id_pago            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_cita            INT NOT NULL,
    Id_Doctor          INT NOT NULL,
    Id_ticket          INT NULL,
    Monto              DECIMAL(10,2) NOT NULL,
    Fecha_pago         DATE NOT NULL,
    Estatus            BIT NOT NULL,
    Linea_pago         VARCHAR(50) NOT NULL
);

-- Tabla: BITACORA_CITA
CREATE TABLE BITACORA_CITA (
    Id_bitacora        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_cita            INT NOT NULL,
    Id_Recepcionista   INT NOT NULL,
    Estatus_cita       BIT NOT NULL,
    Monto_devuelto     DECIMAL(10,2) NOT NULL,
    Inicio             TIME NOT NULL,
    Fin                TIME NOT NULL,
    Fecha_cambio       DATETIME DEFAULT GETDATE()
);

-- Tabla: FARMACEUTICO
CREATE TABLE FARMACEUTICO (
    Id_farmaceutico    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre             VARCHAR(50) NOT NULL,
    Apellido_Paterno   VARCHAR(50),
    Apellido_Materno   VARCHAR(50),
    Telefono           VARCHAR(15),
    Correo             VARCHAR(100)
);

-- ============================================
-- 2. LLAVES FORÁNEAS
-- ============================================

-- PACIENTE -> USUARIO
ALTER TABLE PACIENTE ADD FOREIGN KEY (Id_usuario) REFERENCES USUARIO(Id_usuario); --NUEVO

-- EMPLEADO -> USUARIO
ALTER TABLE EMPLEADO ADD FOREIGN KEY (Id_usuario) REFERENCES USUARIO(Id_usuario); --NUEVO

-- HISTORIA_MEDICO → PACIENTE
ALTER TABLE HISTORIA_MEDICO ADD FOREIGN KEY (Id_paciente) REFERENCES PACIENTE(Id_paciente);

-- ALMACEN → MEDICAMENTO
ALTER TABLE ALMACEN ADD FOREIGN KEY (Id_medicamento) REFERENCES MEDICAMENTO(Id_medicamento);

-- DOCTOR → EMPLEADO
ALTER TABLE DOCTOR ADD FOREIGN KEY (Id_empleado) REFERENCES EMPLEADO(Id_empleado);

-- DOCTOR → ESPECIALIDAD
ALTER TABLE DOCTOR ADD FOREIGN KEY (Id_especialidad) REFERENCES ESPECIALIDAD(Id_especialidad);

-- DOCTOR → HORARIO
ALTER TABLE DOCTOR ADD FOREIGN KEY (Id_Horario) REFERENCES HORARIO(Id_Horario);

-- RECEPCIONISTA → EMPLEADO
ALTER TABLE RECEPCIONISTA ADD FOREIGN KEY (Id_empleado) REFERENCES EMPLEADO(Id_empleado);

-- CONSULTORIO → DOCTOR
ALTER TABLE CONSULTORIO ADD FOREIGN KEY (Id_Doctor) REFERENCES DOCTOR(Id_doctor);

-- RECETA → PACIENTE
ALTER TABLE RECETA ADD FOREIGN KEY (Id_paciente) REFERENCES PACIENTE(Id_paciente);

-- RECETA → DOCTOR
ALTER TABLE RECETA ADD FOREIGN KEY (Id_doctor) REFERENCES DOCTOR(Id_doctor);

-- RECETA_MEDICINA → RECETA
ALTER TABLE RECETA_MEDICINA ADD FOREIGN KEY (Id_receta) REFERENCES RECETA(Id_receta);

-- RECETA_MEDICINA → MEDICAMENTO
ALTER TABLE RECETA_MEDICINA ADD FOREIGN KEY (Id_medicamento) REFERENCES MEDICAMENTO(Id_medicamento);

-- CITA → PACIENTE
ALTER TABLE CITA ADD FOREIGN KEY (Id_paciente) REFERENCES PACIENTE(Id_paciente);

-- CITA → DOCTOR
ALTER TABLE CITA ADD FOREIGN KEY (Id_doctor) REFERENCES DOCTOR(Id_doctor);

-- CITA → CONSULTORIO
ALTER TABLE CITA ADD FOREIGN KEY (Id_consultorio) REFERENCES CONSULTORIO(Id_consultorio);

-- CITA → RECETA
ALTER TABLE CITA ADD FOREIGN KEY (Id_receta) REFERENCES RECETA(Id_receta);

-- CITA_SERVICIO → CITA
ALTER TABLE CITA_SERVICIO ADD FOREIGN KEY (Id_cita) REFERENCES CITA(Id_cita);

-- CITA_SERVICIO → SERVICIO
ALTER TABLE CITA_SERVICIO ADD FOREIGN KEY (Id_servicio) REFERENCES SERVICIO(Id_servicio);

-- TICKET → CITA
ALTER TABLE TICKET ADD FOREIGN KEY (Id_cita) REFERENCES CITA(Id_cita);

-- PAGO → CITA
ALTER TABLE PAGO ADD FOREIGN KEY (Id_cita) REFERENCES CITA(Id_cita);

-- PAGO → DOCTOR
ALTER TABLE PAGO ADD FOREIGN KEY (Id_Doctor) REFERENCES DOCTOR(Id_doctor);

-- PAGO → TICKET
ALTER TABLE PAGO ADD FOREIGN KEY (Id_ticket) REFERENCES TICKET(Id_ticket);

-- BITACORA_CITA → CITA
ALTER TABLE BITACORA_CITA ADD FOREIGN KEY (Id_cita) REFERENCES CITA(Id_cita);

-- BITACORA_CITA → RECEPCIONISTA
ALTER TABLE BITACORA_CITA ADD FOREIGN KEY (Id_Recepcionista) REFERENCES RECEPCIONISTA(Id_Recepcionista);
