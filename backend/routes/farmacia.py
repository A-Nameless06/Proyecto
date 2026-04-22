from flask import Blueprint, render_template, redirect
from utils.decorador import login_requerido, rol_requerido

farmacia_bp = Blueprint("famacia", __name__, url_prefix="/farmacia")


@farmacia_bp.route("/validacion")
@login_requerido
@rol_requerido("Farmaceutico")
def farmaciaValidacion():
    return render_template("farmacia/validacionReceta.html")

@farmacia_bp.route("/historialVentas")
@login_requerido
@rol_requerido("Farmaceutico")
def farmaciaVentas():
    return render_template("farmacia/historial.html")