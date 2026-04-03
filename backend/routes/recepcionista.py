from flask import Blueprint, render_template
from utils.decorador import login_requerido, rol_requerido

recepcion_bp = Blueprint("recepcion", __name__, url_prefix="/recepcion")

@recepcion_bp.route("/dashboard")
@login_requerido
@rol_requerido("Recepcionista")
def dashboard():
    return render_template("recepcionista/inicioRecepcion.html")