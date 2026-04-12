from flask import Blueprint, render_template, redirect

farmacia_bp = Blueprint("/famacia", __name__)

@farmacia_bp.route("/farmacia")
def farmaciaInicio():
    return render_template("farmacia/inicioFarmacia.html")

@farmacia_bp.route("/historial_farmacia")
def farmaciaHistorial():
    return render_template("farmacia/validacionReceta.html")