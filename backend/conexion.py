# test_conexion.py
import pyodbc

try:
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=(localdb)\\MSSQLLocalDB;"
        "DATABASE=PRUEBA;"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )
    print("✅ Conexión exitosa")
    conn.close()
except Exception as e:
    print(f"❌ Error: {e}")