from flask import Blueprint, render_template, session, redirect
from utils.decorador import login_requerido
from database.db import get_coneccion

dashboard_bp = Blueprint("dashboard", __name__)


@dashboard_bp.route("/dashboard")
@login_requerido
def dashboard():
    rol = session.get("rol")

    if rol == "Paciente":
        return _dashboard_paciente()
    elif rol == "Doctor":
        return _dashboard_doctor()
    elif rol == "Recepcionista":
        return _dashboard_recepcion()
    elif rol == "Farmaceutico":
        return _dashboard_farmacia()
    elif rol == "Administrador":
        return render_template("administracion/inicioAdmin.html")

    return redirect("/auth/login")


# ─────────────────────────────────────────────
# PACIENTE
# ─────────────────────────────────────────────
def _dashboard_paciente():
    id_paciente = session.get("id_entidad")

    with get_coneccion() as conn:
        cursor = conn.cursor()

        # Ficha médica — todo está en PACIENTE directamente
        cursor.execute("""
            SELECT
                p.Nombre,
                p.Apellido_Paterno,
                p.Apellido_Materno,
                p.Correo,
                p.Telefono,
                p.Fecha_nacimiento,
                p.Tipo_sangre,
                p.Alergias,
                p.Peso,
                p.Estatura,
                ISNULL(p.Edad,
                    DATEDIFF(YEAR, p.Fecha_nacimiento, GETDATE())
                ) AS Edad
            FROM PACIENTE p
            WHERE p.Id_paciente = ?
        """, id_paciente)
        ficha = cursor.fetchone()

        # Contadores de citas
        # Estatus BIT: 1=Activa, 0=Cancelada
        # Para "completadas" usamos Diagnostico no nulo (ya tuvo consulta)
        cursor.execute("""
            SELECT
                COUNT(CASE WHEN Estatus = 1 AND Fecha_cita >= CAST(GETDATE() AS DATE)
                           THEN 1 END)                          AS confirmadas,
                COUNT(CASE WHEN Estatus = 1 AND Fecha_cita < CAST(GETDATE() AS DATE)
                            AND Diagnostico IS NOT NULL
                           THEN 1 END)                          AS completadas,
                COUNT(CASE WHEN Estatus = 0 THEN 1 END)         AS canceladas
            FROM CITA
            WHERE Id_paciente = ?
        """, id_paciente)
        contadores = cursor.fetchone()

        # Próximas citas activas (máx 5)
        cursor.execute("""
            SELECT TOP 5
                c.Id_cita,
                c.Fecha_cita,
                c.hora_cita,
                c.Hora_Fin,
                c.Estatus,
                c.Diagnostico,
                e.Nombre + ' ' + e.Apellido_Paterno          AS nombre_doctor,
                esp.Nombre                                    AS especialidad,
                con.Numero                                    AS consultorio
            FROM CITA c
            JOIN DOCTOR d         ON c.Id_doctor      = d.Id_doctor
            JOIN EMPLEADO e       ON d.Id_empleado     = e.Id_empleado
            JOIN ESPECIALIDAD esp ON d.Id_especialidad = esp.Id_especialidad
            LEFT JOIN CONSULTORIO con ON c.Id_consultorio = con.Id_consultorio
            WHERE c.Id_paciente = ?
              AND c.Estatus = 1
              AND c.Fecha_cita >= CAST(GETDATE() AS DATE)
            ORDER BY c.Fecha_cita, c.hora_cita
        """, id_paciente)
        proximas_citas = cursor.fetchall()

    return render_template(
        "paciente/inicioPaciente.html",
        ficha=ficha,
        contadores=contadores,
        citas=proximas_citas,
        nombre_completo=session.get("nombre_completo")
    )


# ─────────────────────────────────────────────
# DOCTOR
# ─────────────────────────────────────────────
def _dashboard_doctor():
    id_empleado = session.get("id_entidad")

    with get_coneccion() as conn:
        cursor = conn.cursor()

        # Datos del turno
        cursor.execute("""
            SELECT
                esp.Nombre       AS especialidad,
                con.Numero       AS consultorio,
                con.Piso,
                h.Hora_Inicio    AS turno_inicio,
                h.Hora_Fin       AS turno_fin,
                h.Dia
            FROM DOCTOR d
            JOIN ESPECIALIDAD esp     ON d.Id_especialidad    = esp.Id_especialidad
            LEFT JOIN CONSULTORIO con ON d.Id_doctor          = con.Id_Doctor
            LEFT JOIN HORARIO h       ON d.Id_Horario         = h.Id_Horario
            WHERE d.Id_empleado = ?
        """, id_empleado)
        turno = cursor.fetchone()

        # Id_doctor para las siguientes consultas
        cursor.execute(
            "SELECT Id_doctor FROM DOCTOR WHERE Id_empleado = ?", id_empleado
        )
        row = cursor.fetchone()
        id_doctor = row.Id_doctor if row else None

        # Contadores del día
        # Estatus=1 activa, Diagnostico IS NOT NULL = atendida
        cursor.execute("""
            SELECT
                COUNT(*)                                                        AS total_hoy,
                COUNT(CASE WHEN Diagnostico IS NULL AND Estatus = 1 THEN 1 END) AS pendientes,
                COUNT(CASE WHEN Diagnostico IS NOT NULL             THEN 1 END) AS atendidos
            FROM CITA
            WHERE Id_doctor = ?
              AND CAST(Fecha_cita AS DATE) = CAST(GETDATE() AS DATE)
        """, id_doctor)
        contadores = cursor.fetchone()

        # Pacientes pendientes de hoy (sin diagnóstico = no atendidos aún)
        cursor.execute("""
            SELECT
                c.Id_cita,
                c.hora_cita,
                c.Diagnostico,
                p.Nombre + ' ' + p.Apellido_Paterno AS nombre_paciente,
                p.Tipo_sangre,
                ISNULL(p.Edad,
                    DATEDIFF(YEAR, p.Fecha_nacimiento, GETDATE())
                ) AS edad_paciente
            FROM CITA c
            JOIN PACIENTE p ON c.Id_paciente = p.Id_paciente
            WHERE c.Id_doctor = ?
              AND c.Estatus = 1
              AND c.Diagnostico IS NULL
              AND CAST(c.Fecha_cita AS DATE) = CAST(GETDATE() AS DATE)
            ORDER BY c.hora_cita
        """, id_doctor)
        sala_espera = cursor.fetchall()

        siguiente = sala_espera[0] if sala_espera else None

    return render_template(
        "doctor/inicioDoctor.html",
        turno=turno,
        contadores=contadores,
        sala_espera=sala_espera,
        siguiente=siguiente,
        nombre_completo=session.get("nombre_completo")
    )


# ─────────────────────────────────────────────
# RECEPCIÓN
# ─────────────────────────────────────────────
def _dashboard_recepcion():
    with get_coneccion() as conn:
        cursor = conn.cursor()

        # KPIs del día
        cursor.execute("""
            SELECT
                COUNT(CASE WHEN Estatus = 1 AND Diagnostico IS NOT NULL
                           THEN 1 END)  AS pacientes_activos,
                COUNT(CASE WHEN Estatus = 1 AND Diagnostico IS NULL
                           THEN 1 END)  AS pacientes_espera,
                COUNT(*)                AS citas_hoy
            FROM CITA
            WHERE CAST(Fecha_cita AS DATE) = CAST(GETDATE() AS DATE)
        """)
        kpis = cursor.fetchone()

        # Agenda del día con iniciales para avatar
        cursor.execute("""
            SELECT TOP 10
                p.Nombre + ' ' + p.Apellido_Paterno              AS nombre_paciente,
                ep.Nombre + ' ' + ep.Apellido_Paterno            AS nombre_doctor,
                c.hora_cita,
                c.Estatus,
                c.Diagnostico,
                c.Id_cita,
                LEFT(p.Nombre, 1) + LEFT(p.Apellido_Paterno, 1)  AS iniciales
            FROM CITA c
            JOIN PACIENTE p   ON c.Id_paciente = p.Id_paciente
            JOIN DOCTOR d     ON c.Id_doctor   = d.Id_doctor
            JOIN EMPLEADO ep  ON d.Id_empleado = ep.Id_empleado
            WHERE CAST(c.Fecha_cita AS DATE) = CAST(GETDATE() AS DATE)
            ORDER BY c.hora_cita
        """)
        agenda = cursor.fetchall()

    return render_template(
        "recepcionista/inicioRecepcion.html",
        kpis=kpis,
        agenda=agenda,
        nombre_completo=session.get("nombre_completo")
    )


# ─────────────────────────────────────────────
# FARMACIA
# ─────────────────────────────────────────────
def _dashboard_farmacia():
    with get_coneccion() as conn:
        cursor = conn.cursor()

        # Tu tabla MEDICAMENTO no tiene columna Tipo ni Requiere_receta
        # Usamos ALMACEN.Tipo para separar libre vs controlado
        cursor.execute("""
            SELECT
                m.Nombre,
                m.Descripcion,
                m.Concentracion,
                m.Precio,
                m.Stock,
                a.Tipo
            FROM MEDICAMENTO m
            LEFT JOIN ALMACEN a ON m.Id_medicamento = a.Id_medicamento
            WHERE a.Tipo = 'libre'
            ORDER BY m.Nombre
        """)
        libres = cursor.fetchall()

        cursor.execute("""
            SELECT
                m.Nombre,
                m.Descripcion,
                m.Concentracion,
                m.Precio,
                m.Stock,
                a.Tipo
            FROM MEDICAMENTO m
            LEFT JOIN ALMACEN a ON m.Id_medicamento = a.Id_medicamento
            WHERE a.Tipo = 'controlado'
            ORDER BY m.Nombre
        """)
        controlados = cursor.fetchall()

    return render_template(
        "farmacia/inicioFarmacia.html",
        libres=libres,
        controlados=controlados,
        nombre_completo=session.get("nombre_completo")
    )