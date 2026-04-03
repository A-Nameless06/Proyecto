from flask import Blueprint, render_template
from utils.decorador import login_requerido, rol_requerido

paciente_bp = Blueprint("paciente", __name__, url_prefix="/paciente")

@paciente_bp.route("/dashboard")
@login_requerido
@rol_requerido("Paciente")
def dashboard():
    return render_template("paciente/inicioPaciente.html")


@paciente_bp.route("/historial")
@login_requerido
@rol_requerido("Paciente")
def historial():
    return render_template("paciente/historialPaciente.html")


@paciente_bp.route("/citas")
@login_requerido
@rol_requerido("Paciente")
def citas():
    return render_template("paciente/citasPaciente.html")


@paciente_bp.route("/perfil")
@login_requerido
@rol_requerido("Paciente")
def perfil():
    return render_template("paciente/perfilPaciente.html")

