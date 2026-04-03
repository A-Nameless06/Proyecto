from flask import Blueprint, render_template
from utils.decorador import login_requerido, rol_requerido

doctor_bp = Blueprint("doctor", __name__, url_prefix="/doctor")

@doctor_bp.route("/dashboard")
@login_requerido
@rol_requerido("Doctor")
def dashboard():
    return render_template("doctor/inicioDoctor.html")


@doctor_bp.route("/pacientes")
@login_requerido
@rol_requerido("Doctor")
def pacientes():
    return render_template("doctor/pacientes.html")