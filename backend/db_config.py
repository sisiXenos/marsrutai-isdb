# Database connection configurations
DB_CONFIGS = {
    "db11": {
        "host": "db11",
        "database": "spatial",
        "user": "user11",
        "password": "user",
        "port": 5432
    },
    "db12": {
        "host": "db12",
        "database": "spatial",
        "user": "user12",
        "password": "user",
        "port": 5432
    },
    "db21": {
        "host": "db21",
        "database": "business",
        "user": "user21",
        "password": "user",
        "port": 5432
    },
    "db22": {
        "host": "db22",
        "database": "business",
        "user": "user22",
        "password": "user",
        "port": 5432
    }
}

# Route distribution by marsruto_tipas (route type)
# marsruto_tipas_id = 1 (Maršrutinis) → DB11 (spatial) + DB21 (business)
# marsruto_tipas_id = 2 (Tarpmiestinis) → DB12 (spatial) + DB22 (business)

def get_spatial_db_for_route_type(marsruto_tipas_id):
    """Return the spatial database name for a given route type"""
    if marsruto_tipas_id == 1:  # Maršrutinis
        return "db11"
    elif marsruto_tipas_id == 2:  # Tarpmiestinis
        return "db12"
    else:
        return None

def get_business_db_for_route_type(marsruto_tipas_id):
    """Return the business database name for a given route type"""
    if marsruto_tipas_id == 1:  # Maršrutinis
        return "db21"
    elif marsruto_tipas_id == 2:  # Tarpmiestinis
        return "db22"
    else:
        return None

# Legacy functions for backward compatibility - now need to query the database
def get_spatial_db_for_route(marsrutas_id):
    """Return the spatial database name for a given route ID (deprecated - use get_spatial_db_for_route_type)"""
    # This requires querying the database to find the route type
    # For now, try both databases
    return None  # Will be handled by query logic

def get_business_db_for_route(marsrutas_id):
    """Return the business database name for a given route ID (deprecated - use get_business_db_for_route_type)"""
    # This requires querying the database to find the route type
    # For now, try both databases
    return None  # Will be handled by query logic

def get_all_spatial_dbs():
    """Return all spatial database names"""
    return ["db11", "db12"]

def get_all_business_dbs():
    """Return all business database names"""
    return ["db21", "db22"]
