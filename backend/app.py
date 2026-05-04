from flask import Flask, render_template, redirect
from datetime import timedelta
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
    
    
    return app

if __name__ == "__main__":
    app = create_app()
    app.run(debug=True)