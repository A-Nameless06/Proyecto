from flask import Blueprint, render_template, redirect

index_bp = Blueprint("/index",__name__)

@index_bp.route("/doctores")
def doctores():
    return render_template("RASA/doctores.html")

@index_bp.route("/contacto")
def contacto():
    return render_template("RASA/contacto.html")

@index_bp.route("/especialidades")
def especialidades():
    return render_template("RASA/especialidades.html")

@index_bp.route("/privacidad")
def privacidad():
    return render_template("RASA/privacidad.html")