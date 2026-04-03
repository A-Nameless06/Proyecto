from flask import Blueprint, request, jsonify, session, render_template
from middleware.auth import login_required, role_required
from db_fake import CITAS

citas_bp = Blueprint("citas", __name__, url_prefix="/citas")

@citas_bp.route("/agendar", methods=["POST"])
@login_required
@role_required(["Paciente"])
def agendar_cita():
    data = request.json

    cita = {
        "id_paciente": session["usuario_id"],
        "id_doctor": data["id_doctor"],
        "fecha": data["fecha"],
        "hora": data["hora"]
    }

    CITAS.append(cita)

    return jsonify({
        "mensaje": "Cita agendada (simulada)",
        "cita": cita
    }), 201

@citas_bp.route("/comprobante")
@login_required
@role_required("Paciente")
def comprobante_cita():
    print(session)
    return render_template("paciente/comprobanteCita.html")