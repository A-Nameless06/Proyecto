from flask import Blueprint, render_template, redirect, url_for
from utils.decorador import login_requerido, rol_requerido

ajuste_bp = Blueprint("ajustes", __name__)

@ajuste_bp.route("/ajustes")
def ajustes():
    return redirect(url_for("index"))