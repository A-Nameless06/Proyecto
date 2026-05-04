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
def farmaciaHistorialVentas():
    return render_template("farmacia/historial.html")

@farmacia_bp.route("/ventas")
@login_requerido
@rol_requerido("Farmaceutico")
def farmaciaVender():
    return render_template("farmacia/venta.html")

@farmacia_bp.route("/proveedores")
@login_requerido
@rol_requerido("Farmaceutico")
def proveedores():
    return render_template("farmacia/proveedores.html")

@farmacia_bp.route("/exito")
@login_requerido
@rol_requerido("Farmaceutico")
def pedidoExitoso():
    return render_template("farmacia/pedidoExito.html")