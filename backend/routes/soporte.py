from flask import Blueprint, render_template, redirect, url_for
from utils.decorador import login_requerido, rol_requerido

soporte_bp = Blueprint("soporte", __name__)

@soporte_bp.route("/soporte")
def soporte():
    return redirect(url_for("index"))