from flask import Blueprint, render_template, session, redirect
from utils.decorador import login_requerido, rol_requerido

cancelacion_bp = Blueprint("cancelacion", __name__)

@cancelacion_bp.route("/cancelacion")
@login_requerido
@rol_requerido
def cancelacion():
    
    if "rol" not in session:
        return redirect("/auth/login")

    rol = session["rol"]

    if rol == "Paciente":
        return render_template("paciente/cancelarCita.html")

    elif rol == "Doctor":
        return render_template("doctor/inicioDoctor.html")

    elif rol == "Recepcionista":
        return render_template("recepcionista/inicioRecepcion.html")

    return redirect("/auth/login")