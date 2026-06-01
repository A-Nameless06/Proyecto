-- ============================================
-- BASE DE DATOS: CentroMedicoRASA
-- VERSIÓN COMPLETA CON AUTENTICACIÓN UNIFICADA
-- ============================================

-- Crear la base de datos
CREATE DATABASE CentroMedicoRASA;
GO

USE CentroMedicoRASA;
GO

-- ============================================
-- 1. TABLAS PRINCIPALES
-- ============================================

-- Tabla: PACIENTE (con campos de autenticación)
CREATE TABLE PACIENTE (
    Id_paciente        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
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
    Alergias           VARCHAR(200),
    -- Campos de autenticación
    usuario            VARCHAR(50) NULL UNIQUE,
    password_hash      VARCHAR(255) NULL,
    Activo             BIT DEFAULT 1,
    Ultimo_acceso      DATETIME NULL
);
GO

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
GO

-- Tabla: ESPECIALIDAD
CREATE TABLE ESPECIALIDAD (
    Id_especialidad    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre             VARCHAR(50) NOT NULL,
    Costo_Consulta     MONEY,
    Descripcion        VARCHAR(200)
);
GO

-- Tabla: HORARIO
CREATE TABLE HORARIO (
    Id_Horario         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Hora_Inicio        TIME NOT NULL,
    Hora_Fin           TIME NOT NULL,
    Dia                VARCHAR(20)
);
GO

-- Tabla: EMPLEADO (con autenticación unificada)
CREATE TABLE EMPLEADO (
    Id_empleado        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre             VARCHAR(50) NOT NULL,
    Apellido_Paterno   VARCHAR(50),
    Apellido_Materno   VARCHAR(50),
    Tipo_empleo        VARCHAR(20),
    Curp               VARCHAR(20) NOT NULL UNIQUE,
    Correo             VARCHAR(100) NOT NULL UNIQUE,
    Telefono           VARCHAR(20),
    Fecha_contratacion DATE,
    -- Campos de autenticación
    usuario            VARCHAR(50) NULL UNIQUE,
    password_hash      VARCHAR(255) NULL,
    Rol                VARCHAR(50) NOT NULL, -- 'Doctor', 'Recepcionista', 'Administrador'
    Activo             BIT DEFAULT 1,
    Ultimo_acceso      DATETIME NULL
);
GO

-- Tabla: DOCTOR
CREATE TABLE DOCTOR (
    Id_doctor          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_empleado        INT NOT NULL,
    Id_especialidad    INT NOT NULL,
    Id_Horario         INT NOT NULL,
    Consultorio_asignado INT NULL
);
GO

-- Tabla: RECEPCIONISTA
CREATE TABLE RECEPCIONISTA (
    Id_Recepcionista   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_empleado        INT NOT NULL,
    Hora_Inicio        TIME NOT NULL,
    Hora_Fin           TIME NOT NULL
);
GO

-- Tabla: CONSULTORIO
CREATE TABLE CONSULTORIO (
    Id_consultorio     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_Doctor          INT NOT NULL,
    Numero             INT,
    Piso               INT,
    Descripcion        VARCHAR(100)
);
GO

-- Tabla: MEDICAMENTO
CREATE TABLE MEDICAMENTO (
    Id_medicamento     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre             VARCHAR(50) NOT NULL,
    Descripcion        VARCHAR(100),
    Concentracion      VARCHAR(50),
    Precio             MONEY,
    Stock              INT DEFAULT 0
);
GO

-- Tabla: ALMACEN
CREATE TABLE ALMACEN (
    Id_Almacen         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_medicamento     INT NOT NULL,
    Existencias        INT,
    Tipo               VARCHAR(20)
);
GO

-- Tabla: SERVICIO
CREATE TABLE SERVICIO (
    Id_servicio        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre             VARCHAR(50),
    Costo              DECIMAL(10,2),
    Descripcion        VARCHAR(200)
);
GO

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
GO

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
GO

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
GO

-- Tabla: CITA_SERVICIO
CREATE TABLE CITA_SERVICIO (
    Id_cita_servicio   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_cita            INT NOT NULL,
    Id_servicio        INT NOT NULL,
    Cantidad           INT NOT NULL,
    Subtotal           DECIMAL(10,2) NOT NULL
);
GO

-- Tabla: TICKET
CREATE TABLE TICKET (
    Id_ticket          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Id_cita            INT NOT NULL,
    Fecha              DATE NOT NULL,
    Subtotal           DECIMAL(10,2),
    Monto_total        DECIMAL(10,2),
    Estatus_pago       VARCHAR(20) DEFAULT 'Pendiente'
);
GO

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
GO

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
GO

-- Tabla: FARMACEUTICO
CREATE TABLE FARMACEUTICO (
    Id_farmaceutico    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nombre             VARCHAR(50) NOT NULL,
    Apellido_Paterno   VARCHAR(50),
    Apellido_Materno   VARCHAR(50),
    Telefono           VARCHAR(15),
    Correo             VARCHAR(100)
);
GO

-- ============================================
-- 2. LLAVES FORÁNEAS
-- ============================================

-- HISTORIA_MEDICO → PACIENTE
ALTER TABLE HISTORIA_MEDICO ADD FOREIGN KEY (Id_paciente) REFERENCES PACIENTE(Id_paciente);
GO

-- ALMACEN → MEDICAMENTO
ALTER TABLE ALMACEN ADD FOREIGN KEY (Id_medicamento) REFERENCES MEDICAMENTO(Id_medicamento);
GO

-- DOCTOR → EMPLEADO
ALTER TABLE DOCTOR ADD FOREIGN KEY (Id_empleado) REFERENCES EMPLEADO(Id_empleado);
GO

-- DOCTOR → ESPECIALIDAD
ALTER TABLE DOCTOR ADD FOREIGN KEY (Id_especialidad) REFERENCES ESPECIALIDAD(Id_especialidad);
GO

-- DOCTOR → HORARIO
ALTER TABLE DOCTOR ADD FOREIGN KEY (Id_Horario) REFERENCES HORARIO(Id_Horario);
GO

-- RECEPCIONISTA → EMPLEADO
ALTER TABLE RECEPCIONISTA ADD FOREIGN KEY (Id_empleado) REFERENCES EMPLEADO(Id_empleado);
GO

-- CONSULTORIO → DOCTOR
ALTER TABLE CONSULTORIO ADD FOREIGN KEY (Id_Doctor) REFERENCES DOCTOR(Id_doctor);
GO

-- RECETA → PACIENTE
ALTER TABLE RECETA ADD FOREIGN KEY (Id_paciente) REFERENCES PACIENTE(Id_paciente);
GO

-- RECETA → DOCTOR
ALTER TABLE RECETA ADD FOREIGN KEY (Id_doctor) REFERENCES DOCTOR(Id_doctor);
GO

-- RECETA_MEDICINA → RECETA
ALTER TABLE RECETA_MEDICINA ADD FOREIGN KEY (Id_receta) REFERENCES RECETA(Id_receta);
GO

-- RECETA_MEDICINA → MEDICAMENTO
ALTER TABLE RECETA_MEDICINA ADD FOREIGN KEY (Id_medicamento) REFERENCES MEDICAMENTO(Id_medicamento);
GO

-- CITA → PACIENTE
ALTER TABLE CITA ADD FOREIGN KEY (Id_paciente) REFERENCES PACIENTE(Id_paciente);
GO

-- CITA → DOCTOR
ALTER TABLE CITA ADD FOREIGN KEY (Id_doctor) REFERENCES DOCTOR(Id_doctor);
GO

-- CITA → CONSULTORIO
ALTER TABLE CITA ADD FOREIGN KEY (Id_consultorio) REFERENCES CONSULTORIO(Id_consultorio);
GO

-- CITA → RECETA
ALTER TABLE CITA ADD FOREIGN KEY (Id_receta) REFERENCES RECETA(Id_receta);
GO

-- CITA_SERVICIO → CITA
ALTER TABLE CITA_SERVICIO ADD FOREIGN KEY (Id_cita) REFERENCES CITA(Id_cita);
GO

-- CITA_SERVICIO → SERVICIO
ALTER TABLE CITA_SERVICIO ADD FOREIGN KEY (Id_servicio) REFERENCES SERVICIO(Id_servicio);
GO

-- TICKET → CITA
ALTER TABLE TICKET ADD FOREIGN KEY (Id_cita) REFERENCES CITA(Id_cita);
GO

-- PAGO → CITA
ALTER TABLE PAGO ADD FOREIGN KEY (Id_cita) REFERENCES CITA(Id_cita);
GO

-- PAGO → DOCTOR
ALTER TABLE PAGO ADD FOREIGN KEY (Id_Doctor) REFERENCES DOCTOR(Id_doctor);
GO

-- PAGO → TICKET
ALTER TABLE PAGO ADD FOREIGN KEY (Id_ticket) REFERENCES TICKET(Id_ticket);
GO

-- BITACORA_CITA → CITA
ALTER TABLE BITACORA_CITA ADD FOREIGN KEY (Id_cita) REFERENCES CITA(Id_cita);
GO

-- BITACORA_CITA → RECEPCIONISTA
ALTER TABLE BITACORA_CITA ADD FOREIGN KEY (Id_Recepcionista) REFERENCES RECEPCIONISTA(Id_Recepcionista);
GO

-- ============================================
-- 3. PROCEDIMIENTOS ALMACENADOS
-- ============================================

-- Procedimiento de autenticación unificada
CREATE PROCEDURE sp_AutenticarUsuario
    @Identificador VARCHAR(100),
    @Password VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Buscar en EMPLEADOS
    SELECT 
        Id_empleado AS Id,
        Nombre,
        Apellido_Paterno,
        Apellido_Materno,
        Rol AS Tipo,
        Correo AS Email,
        'empleado' AS Origen,
        Activo
    FROM EMPLEADO
    WHERE (usuario = @Identificador OR Correo = @Identificador)
      AND password_hash = @Password  -- En producción usar HASH
    
    UNION ALL
    
    -- Buscar en PACIENTES
    SELECT 
        Id_paciente AS Id,
        Nombre,
        Apellido_Paterno,
        Apellido_Materno,
        'Paciente' AS Tipo,
        Correo AS Email,
        'paciente' AS Origen,
        Activo
    FROM PACIENTE
    WHERE (usuario = @Identificador OR Curp = @Identificador)
      AND password_hash = @Password;
END
GO

-- Procedimiento para registrar login
CREATE PROCEDURE sp_RegistrarLogin
    @Id INT,
    @Origen VARCHAR(20)
AS
BEGIN
    IF @Origen = 'empleado'
    BEGIN
        UPDATE EMPLEADO SET Ultimo_acceso = GETDATE() WHERE Id_empleado = @Id;
    END
    ELSE IF @Origen = 'paciente'
    BEGIN
        UPDATE PACIENTE SET Ultimo_acceso = GETDATE() WHERE Id_paciente = @Id;
    END
END
GO

-- ============================================
-- 4. DATOS DE PRUEBA
-- ============================================

-- 4.1 Insertar Especialidades
INSERT INTO ESPECIALIDAD (Nombre, Costo_Consulta, Descripcion) VALUES
('Cardiología', 1500.00, 'Especialidad médica del corazón'),
('Dermatología', 1300.00, 'Especialidad de la piel'),
('Ginecología', 800.00, 'Salud de la mujer'),
('Medicina General', 120.00, 'Atención primaria'),
('Nefrología', 800.00, 'Especialidad de los riñones'),
('Nutriología', 500.00, 'Nutrición y dietética'),
('Oftalmología', 500.00, 'Especialidad de los ojos'),
('Oncología', 1200.00, 'Tratamiento del cáncer'),
('Ortopedia', 300.00, 'Huesos y articulaciones'),
('Pediatría', 700.00, 'Atención infantil'),
('Laboratorio Clínico', 400.00, 'Análisis clínicos');
GO

-- 4.2 Insertar Horarios
INSERT INTO HORARIO (Hora_Inicio, Hora_Fin, Dia) VALUES
('08:00', '14:00', 'Lunes'),
('14:00', '20:00', 'Lunes'),
('08:00', '14:00', 'Martes'),
('14:00', '20:00', 'Martes'),
('08:00', '14:00', 'Miércoles'),
('14:00', '20:00', 'Miércoles'),
('08:00', '14:00', 'Jueves'),
('14:00', '20:00', 'Jueves'),
('08:00', '14:00', 'Viernes'),
('14:00', '20:00', 'Viernes');
GO

-- 4.3 Insertar Médicos (Empleados)
INSERT INTO EMPLEADO (
    Nombre, Apellido_Paterno, Apellido_Materno, Tipo_empleo, Curp, 
    Correo, Telefono, Fecha_contratacion, usuario, 
    password_hash, Rol, Activo
) VALUES
-- Cardiología (contraseña: TempPass123)
('Roberto', 'Sánchez', 'Martínez', 'Doctor', 'SAMR800514HDFXXXXX', 
 'r.sanchez@rasa-med.com', '5551230001', '2020-01-15', 'r.sanchez', 
 'pbkdf2:sha256:260000$123456$hash_temp', 'Doctor', 1),
('Ana', 'Valdez', 'Luna', 'Doctor', 'VALA850312MDFXXXXX', 
 'a.valdez@rasa-med.com', '5551230002', '2020-03-10', 'a.valdez', 
 'pbkdf2:sha256:260000$123456$hash_temp', 'Doctor', 1),
('Luis', 'Torres', 'Mendoza', 'Doctor', 'TOLL821105HDFXXXXX', 
 'l.torres@rasa-med.com', '5551230003', '2019-11-20', 'l.torres', 
 'pbkdf2:sha256:260000$123456$hash_temp', 'Doctor', 1),
('Carmen', 'Ríos', 'Gómez', 'Doctor', 'RICC880721MDFXXXXX', 
 'c.rios@rasa-med.com', '5551230004', '2021-02-14', 'c.rios', 
 'pbkdf2:sha256:260000$123456$hash_temp', 'Doctor', 1),

-- Dermatología
('Laura', 'Gómez', 'Fernández', 'Doctor', 'GOLL900115MDFXXXXX', 
 'l.gomez@rasa-med.com', '5551230005', '2018-06-01', 'l.gomez', 
 'pbkdf2:sha256:260000$123456$hash_temp', 'Doctor', 1),

-- Ginecología
('Patricia', 'Luna', 'Campos', 'Doctor', 'LUPP860518MDFXXXXX', 
 'p.luna@rasa-med.com', '5551230009', '2016-04-22', 'p.luna', 
 'pbkdf2:sha256:260000$123456$hash_temp', 'Doctor', 1),

-- Medicina General
('Carlos', 'Rivera', 'Noriega', 'Doctor', 'RICC801010HDFXXXXX', 
 'c.rivera@rasa-med.com', '5551230013', '2017-06-17', 'c.rivera', 
 'pbkdf2:sha256:260000$123456$hash_temp', 'Doctor', 1),

-- Administrador
('Admin', 'Sistema', NULL, 'Administrador', 'ADMS900101HDFXXXXX', 
 'admin@rasa-med.com', '5559999999', '2020-01-01', 'admin', 
 'pbkdf2:sha256:260000$123456$hash_temp', 'Administrador', 1),

-- Recepcionista
('María', 'García', 'López', 'Recepcionista', 'GALM850101MDFXXXXX', 
 'recepcion@rasa-med.com', '5558888888', '2021-01-15', 'recepcion', 
 'pbkdf2:sha256:260000$123456$hash_temp', 'Recepcionista', 1);
GO

-- 4.4 Insertar DOCTOR (relación empleado-especialidad)
INSERT INTO DOCTOR (Id_empleado, Id_especialidad, Id_Horario)
SELECT 
    e.Id_empleado,
    esp.Id_especialidad,
    1  -- Horario por defecto: Lunes 08:00-14:00
FROM EMPLEADO e
CROSS JOIN ESPECIALIDAD esp
WHERE e.Rol = 'Doctor' 
  AND (
    (e.Nombre = 'Roberto' AND esp.Nombre = 'Cardiología') OR
    (e.Nombre = 'Ana' AND esp.Nombre = 'Cardiología') OR
    (e.Nombre = 'Luis' AND esp.Nombre = 'Cardiología') OR
    (e.Nombre = 'Carmen' AND esp.Nombre = 'Cardiología') OR
    (e.Nombre = 'Laura' AND esp.Nombre = 'Dermatología') OR
    (e.Nombre = 'Patricia' AND esp.Nombre = 'Ginecología') OR
    (e.Nombre = 'Carlos' AND esp.Nombre = 'Medicina General')
  );
GO

-- 4.5 Insertar CONSULTORIOS
INSERT INTO CONSULTORIO (Id_Doctor, Numero, Piso, Descripcion)
SELECT 
    d.Id_doctor,
    ROW_NUMBER() OVER (ORDER BY d.Id_doctor) + 100 AS Numero,
    1 AS Piso,
    'Consultorio de ' + esp.Nombre
FROM DOCTOR d
INNER JOIN ESPECIALIDAD esp ON d.Id_especialidad = esp.Id_especialidad;
GO

-- 4.6 Insertar PACIENTES (con credenciales, contraseña: TempPass123)
INSERT INTO PACIENTE (
    Nombre, Apellido_Paterno, Apellido_Materno, Curp, Telefono, 
    Correo, usuario, password_hash, Fecha_nacimiento, Activo
) VALUES 
(
    'Carlos', 'Ramírez', 'Soto', 'RASC900101HDFMTL09', '5551001001',
    'carlos.ramirez@email.com', 'carlos.ramirez', 
    'pbkdf2:sha256:260000$123456$hash_temp', '1990-01-01', 1
),
(
    'Laura', 'Mendoza', 'Ríos', 'MERL850215MDFNRS04', '5551001002',
    'laura.mendoza@email.com', 'laura.mendoza',
    'pbkdf2:sha256:260000$123456$hash_temp', '1985-02-15', 1
),
(
    'Jorge', 'Gutiérrez', 'Vega', 'GUVJ780320HDFTRR07', '5551001003',
    'jorge.gutierrez@email.com', 'jorge.gutierrez',
    'pbkdf2:sha256:260000$123456$hash_temp', '1978-03-20', 1
),
(
    'Ana', 'Torres', 'Leal', 'TOLA920510MDFRRN02', '5551001004',
    'ana.torres@email.com', 'ana.torres',
    'pbkdf2:sha256:260000$123456$hash_temp', '1992-05-10', 1
);
GO

-- 4.7 Insertar HISTORIA_MEDICO
INSERT INTO HISTORIA_MEDICO (Id_paciente, Tipo_sangre, Estatura, Peso, Edad, Alergias)
SELECT Id_paciente, 
       CASE WHEN Id_paciente = 1 THEN 'O+' WHEN Id_paciente = 2 THEN 'A+' WHEN Id_paciente = 3 THEN 'B+' ELSE 'O-' END,
       CASE WHEN Id_paciente = 1 THEN 1.75 WHEN Id_paciente = 2 THEN 1.65 WHEN Id_paciente = 3 THEN 1.80 ELSE 1.60 END,
       CASE WHEN Id_paciente = 1 THEN 75 WHEN Id_paciente = 2 THEN 60 WHEN Id_paciente = 3 THEN 82 ELSE 55 END,
       DATEDIFF(YEAR, Fecha_nacimiento, GETDATE()),
       'Ninguna'
FROM PACIENTE;
GO

-- 4.8 Insertar MEDICAMENTOS
INSERT INTO MEDICAMENTO (Nombre, Descripcion, Concentracion, Precio, Stock) VALUES
('Paracetamol', 'Analgésico', '500mg', 50.00, 1000),
('Ibuprofeno', 'Antiinflamatorio', '400mg', 80.00, 800),
('Amoxicilina', 'Antibiótico', '500mg', 120.00, 500),
('Omeprazol', 'Antiacido', '20mg', 90.00, 600),
('Losartán', 'Antihipertensivo', '50mg', 150.00, 300);
GO

-- 4.9 Insertar SERVICIOS
INSERT INTO SERVICIO (Nombre, Costo, Descripcion) VALUES
('Consulta General', 500.00, 'Consulta médica general'),
('Ultrasonido', 800.00, 'Estudio de ultrasonido'),
('Laboratorio', 350.00, 'Análisis clínicos básicos'),
('Rayos X', 600.00, 'Estudio radiológico'),
('Electrocardiograma', 700.00, 'Estudio del corazón');
GO

-- 4.10 Insertar RECEPCIONISTA
INSERT INTO RECEPCIONISTA (Id_empleado, Hora_Inicio, Hora_Fin)
SELECT Id_empleado, '08:00', '16:00'
FROM EMPLEADO 
WHERE Rol = 'Recepcionista';
GO

-- ============================================
-- 5. VISTAS ÚTILES
-- ============================================

-- Vista: Usuarios activos (empleados y pacientes)
CREATE VIEW vw_UsuariosActivos AS
SELECT 
    Id_empleado AS Id,
    Nombre + ' ' + Apellido_Paterno AS NombreCompleto,
    Correo AS Email,
    Rol AS Tipo,
    'Empleado' AS Categoria,
    Activo
FROM EMPLEADO
UNION ALL
SELECT 
    Id_paciente AS Id,
    Nombre + ' ' + Apellido_Paterno AS NombreCompleto,
    Correo AS Email,
    'Paciente' AS Tipo,
    'Paciente' AS Categoria,
    Activo
FROM PACIENTE;
GO

-- Vista: Citas activas
CREATE VIEW vw_CitasActivas AS
SELECT 
    c.Id_cita,
    p.Nombre + ' ' + p.Apellido_Paterno AS Paciente,
    e.Nombre + ' ' + e.Apellido_Paterno AS Doctor,
    esp.Nombre AS Especialidad,
    c.Fecha_cita,
    c.hora_cita,
    c.Estatus
FROM CITA c
INNER JOIN PACIENTE p ON c.Id_paciente = p.Id_paciente
INNER JOIN DOCTOR d ON c.Id_doctor = d.Id_doctor
INNER JOIN EMPLEADO e ON d.Id_empleado = e.Id_empleado
INNER JOIN ESPECIALIDAD esp ON d.Id_especialidad = esp.Id_especialidad
WHERE c.Estatus = 1 AND c.Fecha_cita >= CAST(GETDATE() AS DATE);
GO

-- ============================================
-- 6. ÍNDICES PARA OPTIMIZACIÓN
-- ============================================

-- Índices para búsquedas de autenticación
CREATE INDEX idx_empleado_usuario ON EMPLEADO(usuario);
CREATE INDEX idx_empleado_correo ON EMPLEADO(Correo);
CREATE INDEX idx_paciente_usuario ON PACIENTE(usuario);
CREATE INDEX idx_paciente_curp ON PACIENTE(Curp);

-- Índices para búsquedas de citas
CREATE INDEX idx_cita_fecha ON CITA(Fecha_cita);
CREATE INDEX idx_cita_paciente ON CITA(Id_paciente);
CREATE INDEX idx_cita_doctor ON CITA(Id_doctor);

-- ============================================
-- 7. DATOS ADICIONALES ÚTILES
-- ============================================

-- Mostrar resumen de usuarios creados
PRINT '=== RESÚMEN DE USUARIOS CREADOS ===';
PRINT '';

SELECT 'EMPLEADOS' AS Tipo, COUNT(*) AS Cantidad FROM EMPLEADO
UNION ALL
SELECT 'PACIENTES', COUNT(*) FROM PACIENTE;

PRINT '';
PRINT '=== CREDENCIALES DE PRUEBA ===';
PRINT '';
PRINT 'MÉDICOS:';
PRINT '  - Usuario: r.sanchez@rasa-med.com / Contraseña: TempPass123';
PRINT '  - Usuario: a.valdez@rasa-med.com / Contraseña: TempPass123';
PRINT '  - Usuario: l.gomez@rasa-med.com / Contraseña: TempPass123';
PRINT '';
PRINT 'PACIENTES:';
PRINT '  - Usuario: carlos.ramirez / Contraseña: TempPass123';
PRINT '  - Usuario: laura.mendoza / Contraseña: TempPass123';
PRINT '';
PRINT 'ADMINISTRADOR:';
PRINT '  - Usuario: admin@rasa-med.com / Contraseña: TempPass123';
PRINT '';
PRINT 'RECEPCIONISTA:';
PRINT '  - Usuario: recepcion@rasa-med.com / Contraseña: TempPass123';
PRINT '';
PRINT '=====================================';
GO