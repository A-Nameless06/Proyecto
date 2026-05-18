from flask import Blueprint, render_template
from utils.decorador import login_requerido, rol_requerido

recepcion_bp = Blueprint("recepcion", __name__, url_prefix="/recepcion")

@recepcion_bp.route("/agenda")
@login_requerido
@rol_requerido("Recepcionista")
def agenda():
    return render_template("recepcionista/agendaCita.html")

@recepcion_bp.route("/caja")
@login_requerido
@rol_requerido("Recepcionista")
def caja():
    return render_template("recepcionista/caja.html")

@recepcion_bp.route("/horarios")
@login_requerido
@rol_requerido("Recepcionista")
def horarios():
    return render_template("recepcionista/horarios.html")

@recepcion_bp.route("/pacientes")
@login_requerido
@rol_requerido("Recepcionista")
def pacientes():
    return render_template("recepcionista/pacientes.html")

@recepcion_bp.route("/consultorios")
@login_requerido
@rol_requerido("Recepcionista")
def consultorios():
    return render_template("recepcionista/consultorios.html")

@recepcion_bp.route("/doctores")
@login_requerido
@rol_requerido("Recepcionista")
def doctores():
    return render_template("recepcionista/doctores.html")

@recepcion_bp.route("/agendar-cita")
@login_requerido
@rol_requerido("Recepcionista")
def agendar_cita():
    return render_template("recepcionista/agendarCita.html")

@recepcion_bp.route("/nuevo-doctor")
@login_requerido
@rol_requerido("Recepcionista")
def nuevo_doctor():
    return render_template("recepcionista/nuevoDoctor.html")