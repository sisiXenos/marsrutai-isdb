from flask import Flask, jsonify
from flask_cors import CORS
import psycopg2
import json

app = Flask(__name__)
CORS(app, origins=["http://localhost:8088"])

DB_A = {"host": "fragment_a", "database": "spatial", "user": "usera", "password": "user"}
DB_B = {"host": "fragment_b", "database": "business", "user": "userb", "password": "user"}

@app.route("/")
def home():
    return "Flask API veikia! Eik į /api/marsrutai_combined"

@app.route("/api/marsrutai_combined")
def get_routes_combined():
    # 1️⃣ Prisijungimas prie Fragment A (erdviniai)
    connA = psycopg2.connect(**DB_A)
    curA = connA.cursor()
    curA.execute("SELECT marsrutas_id, ST_AsGeoJSON(kelias) FROM marsrutai_spatial;")
    routes_data = curA.fetchall()
    curA.close()
    connA.close()

    # 2️⃣ Prisijungimas prie Fragment B (atributai)
    connB = psycopg2.connect(**DB_B)
    curB = connB.cursor()
    curB.execute("SELECT marsrutas_id, pavadinimas, marsruto_tipas_id, aptarnavimas_id FROM marsrutai_business;")
    business_data = {row[0]: {"pavadinimas": row[1], "marsruto_tipas_id": row[2], "aptarnavimas_id": row[3]} for row in curB.fetchall()}
    curB.close()
    connB.close()

    # 3️⃣ Kombinavimas į GeoJSON FeatureCollection
    features = []
    for rid, geojson_str in routes_data:
        geometry = json.loads(geojson_str)  # saugus GeoJSON konvertavimas
        properties = {"marsrutas_id": rid}
        if rid in business_data:
            properties.update(business_data[rid])
        feature = {
            "type": "Feature",
            "geometry": geometry,
            "properties": properties
        }
        features.append(feature)

    geojson_collection = {
        "type": "FeatureCollection",
        "features": features
    }

    return jsonify(geojson_collection)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
