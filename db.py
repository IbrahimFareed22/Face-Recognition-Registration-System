import pyodbc

try:
    conn = pyodbc.connect('Driver={SQL Server};Server=DESKTOP-HD3JDRK;Database=FaceAuthDB;Trusted_Connection=yes;')
    print("Connected successfully!")
    conn.close()
except Exception as e:
    print("Connection failed:", e)
