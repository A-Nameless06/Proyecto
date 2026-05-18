from flask import Flask, app, jsonify, render_template, redirect
from datetime import timedelta
from database.db import get_connection
from utils.decorador import login_requerido, rol_requerido
from routes.auth import auth_bp
from routes.citas import citas_bp
from routes.dashboard import dashboard_bp
from routes.index import index_bp
from routes.paciente import paciente_bp
from routes.doctor import doctor_bp
from routes.recepcionista import recepcion_bp
from routes.soporte import soporte_bp
from routes.farmacia import farmacia_bp
from routes.ajustes import ajuste_bp
from routes.cancelacion import cancelacion_bp

def create_app():
    app = Flask(__name__)
    app.secret_key = "Hospital_ESCOM_BD_Proyecto_2026"
    app.permanent_session_lifetime = timedelta(minutes=30)

    app.register_blueprint(auth_bp)
    app.register_blueprint(citas_bp)
    app.register_blueprint(dashboard_bp)
    app.register_blueprint(index_bp)
    app.register_blueprint(paciente_bp)
    app.register_blueprint(doctor_bp)
    app.register_blueprint(recepcion_bp)
    app.register_blueprint(soporte_bp)
    app.register_blueprint(farmacia_bp)
    app.register_blueprint(ajuste_bp)
    app.register_blueprint(cancelacion_bp)

    @app.route("/")
    def index():
        return render_template("RASA/index.html")

    @app.errorhandler(404)
    def pagina_no_encontrada(error):
        return render_template("404.html"), 404
    
    @app.errorhandler(403)
    def acceso_prohibido(error):
        return render_template("403.html"), 403
    
    @app.errorhandler(500)
    def acceso_prohibido(error):
        return render_template("500.html"), 500

    #ruta de prueba
    app.route("/bitacora")
    @login_requerido
    @rol_requerido("Admin")
    def ver_bitacora():
        from utils.bitacora import BITACORA
        return {"bitacora": BITACORA}
    
    # ── TEST DE CONEXIÓN ──────────────────────────────────────
    @app.route('/ping')
    def ping():
        try:
            conn = get_connection()
            conn.close()
            return jsonify({"status": "ok", "mensaje": "Conexión exitosa a RASA_DB"})
        except Exception as e:
            return jsonify({"status": "error", "detalle": str(e)}), 500

    # ── ESPECIALIDADES ────────────────────────────────────────
    @app.route('/especialidades')
    def get_especialidades():
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id_especialidad, nombre, costo FROM Especialidades")
        rows = cursor.fetchall()
        conn.close()
        return jsonify([
            {"id": r[0], "nombre": r[1], "costo": float(r[2])} for r in rows
        ])

    # ── DOCTORES ──────────────────────────────────────────────
    @app.route('/doctores')
    def get_doctores():
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT u.nombre_completo, e.nombre AS especialidad,
                c.nombre_numero, d.turno
            FROM Doctores d
            JOIN Empleados em ON d.id_empleado = em.id_empleado
            JOIN Usuarios u   ON em.id_usuario = u.id_usuario
            JOIN Especialidades e ON d.id_especialidad = e.id_especialidad
            JOIN Consultorios c   ON d.id_consultorio = c.id_consultorio
        """)
        rows = cursor.fetchall()
        conn.close()
        return jsonify([
            {"doctor": r[0], "especialidad": r[1],
            "consultorio": r[2], "turno": r[3]} for r in rows
        ])

    # ── CITAS ─────────────────────────────────────────────────
    @app.route('/citas')
    def get_citas():
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT c.folio_cita, p_u.nombre_completo AS paciente,
                d_u.nombre_completo AS doctor,
                c.fecha_cita, c.hora_cita,
                c.estatus_cita, c.monto_pago
            FROM Citas c
            JOIN Pacientes p   ON c.id_paciente = p.id_paciente
            JOIN Usuarios p_u  ON p.id_usuario = p_u.id_usuario
            JOIN Doctores d    ON c.id_doctor = d.id_doctor
            JOIN Empleados em  ON d.id_empleado = em.id_empleado
            JOIN Usuarios d_u  ON em.id_usuario = d_u.id_usuario
        """)
        rows = cursor.fetchall()
        conn.close()
        return jsonify([
            {
                "folio": r[0], "paciente": r[1], "doctor": r[2],
                "fecha": str(r[3]), "hora": str(r[4]),
                "estatus": r[5], "monto": float(r[6])
            } for r in rows
        ])

    # ── INVENTARIO FARMACIA ───────────────────────────────────
    @app.route('/farmacia')
    def get_farmacia():
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("""
            SELECT nombre, categoria, stock, precio_unitario
            FROM Inventario_Farmacia
            ORDER BY categoria
        """)
        rows = cursor.fetchall()
        conn.close()
        return jsonify([
            {"nombre": r[0], "categoria": r[1],
            "stock": r[2], "precio": float(r[3])} for r in rows
        ])
    
    
    return app

if __name__ == "__main__":
    app = create_app()
    app.run(debug=True)