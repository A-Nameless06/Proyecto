-- Procedimiento almacenado para crear un nuevo paciente
USE CentroMedicoRASA;
GO

CREATE PROCEDURE sp_CrearPaciente
    @usuario          VARCHAR(50),
    @password_hash    VARCHAR(255),
    @Nombre           VARCHAR(50),
    @Apellido_Paterno VARCHAR(50),
    @Apellido_Materno VARCHAR(50)  = NULL,
    @Curp             VARCHAR(20),
    @Telefono         VARCHAR(15)  = NULL,
    @Correo           VARCHAR(100) = NULL,
    @Fecha_nacimiento DATE         = NULL,
    @Tipo_sangre      VARCHAR(5)   = NULL,
    @Alergias         VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_usuario INT;

    -- Insertar en USUARIO
    INSERT INTO USUARIO (usuario, password_hash, Rol)
    VALUES (@usuario, @password_hash, 'Paciente');

    SET @id_usuario = SCOPE_IDENTITY();

    -- Insertar en PACIENTE ligado al usuario
    INSERT INTO PACIENTE (
        Id_usuario,
        Nombre,
        Apellido_Paterno,
        Apellido_Materno,
        Curp,
        Telefono,
        Correo,
        Fecha_nacimiento,
        Tipo_sangre,
        Alergias
    )
    VALUES (
        @id_usuario,
        @Nombre,
        @Apellido_Paterno,
        @Apellido_Materno,
        @Curp,
        @Telefono,
        @Correo,
        @Fecha_nacimiento,
        @Tipo_sangre,
        @Alergias
    );

END;
GO



-- Procedimiento almacenado para crear un nuevo empleado (Doctor o Recepcionista)

CREATE PROCEDURE sp_CrearEmpleado
    @usuario            VARCHAR(50),
    @password_hash      VARCHAR(255),
    @Rol                VARCHAR(20),
    @Nombre             VARCHAR(50),
    @Apellido_Paterno   VARCHAR(50),
    @Apellido_Materno   VARCHAR(50)  = NULL,
    @Curp               VARCHAR(20),
    @Correo             VARCHAR(100),
    @Telefono           VARCHAR(20)  = NULL,
    @Tipo_empleo        VARCHAR(20)  = NULL,
    @Fecha_contratacion DATE         = NULL,
    @Id_especialidad    INT          = NULL,  -- Solo para Doctor
    @Id_Horario         INT          = NULL,  -- Solo para Doctor
    @Hora_Inicio        TIME         = NULL,  -- Solo para Recepcionista
    @Hora_Fin           TIME         = NULL   -- Solo para Recepcionista
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_usuario  INT;
    DECLARE @id_empleado INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la contraseña no sea NULL (si es NULL, poner un valor por defecto)
        DECLARE @final_password VARCHAR(255);
        SET @final_password = ISNULL(@password_hash, 'SIN_CONTRASENA');

        -- ── 1. Crear usuario ─────────────────────────────────────────
        INSERT INTO USUARIO (usuario, password_hash, Rol, Activo, Ultimo_acceso)
        VALUES (@usuario, @final_password, @Rol, 1, GETDATE());

        SET @id_usuario = SCOPE_IDENTITY();

        -- ── 2. Crear empleado ────────────────────────────────────────
        INSERT INTO EMPLEADO (
            Id_usuario,
            Nombre,
            Apellido_Paterno,
            Apellido_Materno,
            Tipo_empleo,
            Curp,
            Correo,
            Telefono,
            Fecha_contratacion
        )
        VALUES (
            @id_usuario,
            @Nombre,
            @Apellido_Paterno,
            @Apellido_Materno,
            @Rol,  -- Usamos el Rol como Tipo_empleo
            @Curp,
            @Correo,
            @Telefono,
            @Fecha_contratacion
        );

        SET @id_empleado = SCOPE_IDENTITY();

        -- ── 3. Si es Doctor, insertar en tabla DOCTOR ────────────────
        IF @Rol = 'Doctor'
        BEGIN
            IF @Id_especialidad IS NULL OR @Id_Horario IS NULL
            BEGIN
                RAISERROR('Para rol Doctor son obligatorios Id_especialidad e Id_Horario.', 16, 1);
                RETURN;
            END

            INSERT INTO DOCTOR (Id_empleado, Id_especialidad, Id_Horario)
            VALUES (@id_empleado, @Id_especialidad, @Id_Horario);
        END

        -- ── 4. Si es Recepcionista, insertar en tabla RECEPCIONISTA ──
        IF @Rol = 'Recepcionista'
        BEGIN
            IF @Hora_Inicio IS NULL OR @Hora_Fin IS NULL
            BEGIN
                -- Valores por defecto si no se proporcionan
                SET @Hora_Inicio = ISNULL(@Hora_Inicio, '08:00:00');
                SET @Hora_Fin = ISNULL(@Hora_Fin, '16:00:00');
            END

            INSERT INTO RECEPCIONISTA (Id_empleado, Hora_Inicio, Hora_Fin)
            VALUES (@id_empleado, @Hora_Inicio, @Hora_Fin);
        END

        -- ── 5. Si es Administrador, solo necesita usuario y empleado ──
        -- No requiere inserción en tablas adicionales

        COMMIT TRANSACTION;
        
        SELECT @id_empleado AS Id_empleado, @id_usuario AS Id_usuario;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;


