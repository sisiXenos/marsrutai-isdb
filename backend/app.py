from flask import Flask, jsonify, request
from flask_cors import CORS
import logging
from crud_operations import (
    MarsrutaiCRUD, 
    VairuotojaiCRUD, 
    TransportCRUD,
    StoteleCRUD
)

app = Flask(__name__)
CORS(app, origins=["http://localhost:8088", "http://localhost:8000"])

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route("/")
def home():
    return jsonify({
        "message": "Distributed Database CRUD API",
        "endpoints": {
            "routes": "/api/marsrutai",
            "drivers": "/api/vairuotojai",
            "transport": "/api/transport",
            "stops": "/api/stoteles"
        }
    })

# ==================== MARSRUTAI (Routes) CRUD ====================

@app.route("/api/marsrutai", methods=['GET'])
def get_marsrutai():
    """Get all routes or a specific route"""
    marsrutas_id = request.args.get('id', type=int)
    try:
        result = MarsrutaiCRUD.read(marsrutas_id)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error getting routes: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/marsrutai", methods=['POST'])
def create_marsrutas():
    """Create a new route"""
    try:
        data = request.json
        result = MarsrutaiCRUD.create(data)
        status_code = 201 if result.get('success') else 400
        return jsonify(result), status_code
    except Exception as e:
        logger.error(f"Error creating route: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/marsrutai/<int:marsrutas_id>", methods=['PUT'])
def update_marsrutas(marsrutas_id):
    """Update an existing route"""
    try:
        data = request.json
        result = MarsrutaiCRUD.update(marsrutas_id, data)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error updating route: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/marsrutai/<int:marsrutas_id>", methods=['DELETE'])
def delete_marsrutas(marsrutas_id):
    """Delete a route"""
    try:
        result = MarsrutaiCRUD.delete(marsrutas_id)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error deleting route: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

# ==================== VAIRUOTOJAI (Drivers) CRUD ====================

@app.route("/api/vairuotojai", methods=['GET'])
def get_vairuotojai():
    """Get all drivers or a specific driver"""
    vairuotojas_id = request.args.get('id', type=int)
    try:
        result = VairuotojaiCRUD.read(vairuotojas_id)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error getting drivers: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/vairuotojai", methods=['POST'])
def create_vairuotojas():
    """Create a new driver"""
    try:
        data = request.json
        result = VairuotojaiCRUD.create(data)
        status_code = 201 if result.get('success') else 400
        return jsonify(result), status_code
    except Exception as e:
        logger.error(f"Error creating driver: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/vairuotojai/<int:vairuotojas_id>", methods=['PUT'])
def update_vairuotojas(vairuotojas_id):
    """Update an existing driver"""
    try:
        data = request.json
        result = VairuotojaiCRUD.update(vairuotojas_id, data)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error updating driver: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/vairuotojai/<int:vairuotojas_id>", methods=['DELETE'])
def delete_vairuotojas(vairuotojas_id):
    """Delete a driver"""
    try:
        result = VairuotojaiCRUD.delete(vairuotojas_id)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error deleting driver: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

# ==================== TRANSPORTO PRIEMONES (Transport) CRUD ====================

@app.route("/api/transport", methods=['GET'])
def get_transport():
    """Get all transport vehicles or a specific one"""
    priemone_id = request.args.get('id', type=int)
    try:
        result = TransportCRUD.read(priemone_id)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error getting transport: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/transport", methods=['POST'])
def create_transport():
    """Create a new transport vehicle"""
    try:
        data = request.json
        result = TransportCRUD.create(data)
        status_code = 201 if result.get('success') else 400
        return jsonify(result), status_code
    except Exception as e:
        logger.error(f"Error creating transport: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/transport/<int:priemone_id>", methods=['PUT'])
def update_transport(priemone_id):
    """Update an existing transport vehicle"""
    try:
        data = request.json
        result = TransportCRUD.update(priemone_id, data)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error updating transport: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/transport/<int:priemone_id>", methods=['DELETE'])
def delete_transport(priemone_id):
    """Delete a transport vehicle"""
    try:
        result = TransportCRUD.delete(priemone_id)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error deleting transport: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

# ==================== STOTELES (Stops) CRUD ====================

@app.route("/api/stoteles", methods=['GET'])
def get_stoteles():
    """Get all stops or a specific stop"""
    stotele_id = request.args.get('id', type=int)
    try:
        result = StoteleCRUD.read(stotele_id)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error getting stops: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/stoteles", methods=['POST'])
def create_stotele():
    """Create a new stop"""
    try:
        data = request.json
        result = StoteleCRUD.create(data)
        status_code = 201 if result.get('success') else 400
        return jsonify(result), status_code
    except Exception as e:
        logger.error(f"Error creating stop: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/stoteles/<int:stotele_id>", methods=['PUT'])
def update_stotele(stotele_id):
    """Update an existing stop"""
    try:
        data = request.json
        result = StoteleCRUD.update(stotele_id, data)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error updating stop: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/stoteles/<int:stotele_id>", methods=['DELETE'])
def delete_stotele(stotele_id):
    """Delete a stop"""
    try:
        result = StoteleCRUD.delete(stotele_id)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error deleting stop: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

@app.route("/api/stoteles/marsrutas/<int:marsrutas_id>", methods=['GET'])
def get_stoteles_by_route(marsrutas_id):
    """Get all stops for a specific route"""
    try:
        result = StoteleCRUD.get_stoteles_for_route(marsrutas_id)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error getting stops for route {marsrutas_id}: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

# ==================== GeoJSON endpoint for map visualization ====================

@app.route("/api/marsrutai/geojson", methods=['GET'])
def get_marsrutai_geojson():
    """Get routes in GeoJSON format for map display"""
    try:
        result = MarsrutaiCRUD.read()
        
        if not result.get('success'):
            return jsonify(result), 400
        
        features = []
        for route in result['data']:
            if route.get('kelias'):
                feature = {
                    "type": "Feature",
                    "geometry": route['kelias'],
                    "properties": {
                        "marsrutas_id": route['marsrutas_id'],
                        "pavadinimas": route.get('pavadinimas'),
                        "atstumas_km": route.get('atstumas_km'),
                        "trukme_min": route.get('trukme_min'),
                        "aktyvus": route.get('aktyvus')
                    }
                }
                features.append(feature)
        
        geojson = {
            "type": "FeatureCollection",
            "features": features
        }
        
        return jsonify(geojson)
    except Exception as e:
        logger.error(f"Error getting GeoJSON: {str(e)}")
        return jsonify({"success": False, "error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
