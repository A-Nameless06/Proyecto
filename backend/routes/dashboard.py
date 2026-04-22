from flask import Blueprint, render_template, session, redirect
from utils.decorador import login_requerido, rol_requerido

dashboard_bp = Blueprint("dashboard", __name__)

@login_requerido
@dashboard_bp.route("/dashboard")
def dashboard():

    if "rol" not in session:
        return redirect("/auth/login")

    rol = session["rol"]

    if rol == "Paciente":
        return render_template("paciente/inicioPaciente.html")

    elif rol == "Doctor":
        return render_template("doctor/inicioDoctor.html")

    elif rol == "Recepcionista":
        return render_template("recepcionista/inicioRecepcion.html")

    elif rol == "Farmaceutico":
        return render_template("farmacia/inicioFarmacia.html")

    return redirect("/auth/login")