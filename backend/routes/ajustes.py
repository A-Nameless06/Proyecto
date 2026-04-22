from flask import Blueprint, render_template, redirect, url_for, session
from utils.decorador import login_requerido, rol_requerido

ajuste_bp = Blueprint("ajustes", __name__)

@login_requerido
@ajuste_bp.route("/ajustes")
def ajustes():
    if "rol" not in session:
        return redirect("/auth/login")
    
    rol = session["rol"]

    if rol == "Paciente":
        return render_template("paciente/ajustesPaciente.html")

    elif rol == "Doctor":
        return render_template("doctor/ajustesDoctor.html")

    elif rol == "Recepcionista":
        return render_template("recepcionista/ajustesRecepcionista.html")

    elif rol == "Farmaceutico":
        return render_template("farmacia/ajustesFarmaceutico.html")

    return redirect("/auth/login")