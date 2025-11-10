from database import DatabaseManager
from db_config import (
    get_spatial_db_for_route, 
    get_business_db_for_route,
    get_spatial_db_for_route_type,
    get_business_db_for_route_type,
    get_all_spatial_dbs,
    get_all_business_dbs
)
import json
import logging

logger = logging.getLogger(__name__)

class MarsrutaiCRUD:
    """CRUD operations for Marsrutai (Routes) with distributed database sync"""
    
    @staticmethod
    def create(data):
        """
        Create a new route in both spatial and business databases
        Segmented by marsruto_tipas_id:
        - marsruto_tipas_id = 1 (Maršrutinis) → DB11 + DB21
        - marsruto_tipas_id = 2 (Tarpmiestinis) → DB12 + DB22
        
        data: {
            'marsrutas_id': int,
            'kelias': str (WKT format),
            'atstumas_km': float,
            'trukme_min': float,
            'aktyvus': bool,
            'pavadinimas': str,
            'marsruto_tipas_id': int,
            'aptarnavimas_id': int
        }
        """
        marsrutas_id = data['marsrutas_id']
        marsruto_tipas_id = data['marsruto_tipas_id']
        
        # Determine which databases to use based on route type
        spatial_db = get_spatial_db_for_route_type(marsruto_tipas_id)
        business_db = get_business_db_for_route_type(marsruto_tipas_id)
        
        if not spatial_db or not business_db:
            raise ValueError(f"Invalid route type: {marsruto_tipas_id}. Must be 1 (Maršrutinis) or 2 (Tarpmiestinis)")
        
        logger.info(f"Creating route {marsrutas_id} with type {marsruto_tipas_id} in {spatial_db}/{business_db}")
        
        queries = {
            spatial_db: [(
                """INSERT INTO marsrutai_spatial 
                   (marsrutas_id, kelias, atstumas_km, trukme_min, aktyvus) 
                   VALUES (%s, ST_GeomFromText(%s, 4326), %s, %s, %s)""",
                (marsrutas_id, data['kelias'], data['atstumas_km'], 
                 data['trukme_min'], data['aktyvus'])
            )],
            business_db: [(
                """INSERT INTO marsrutai_business 
                   (marsrutas_id, pavadinimas, marsruto_tipas_id, aptarnavimas_id) 
                   VALUES (%s, %s, %s, %s)""",
                (marsrutas_id, data['pavadinimas'], 
                 data['marsruto_tipas_id'], data['aptarnavimas_id'])
            )]
        }
        
        results, errors = DatabaseManager.execute_many_queries(queries)
        
        if errors:
            return {"success": False, "errors": errors}
        return {"success": True, "marsrutas_id": marsrutas_id, "databases_used": f"{spatial_db}/{business_db}"}
    
    @staticmethod
    def read(marsrutas_id=None):
        """
        Read route(s) - combining spatial and business data from all databases
        If a route exists in multiple database pairs, all instances are returned
        """
        if marsrutas_id:
            # Read specific route - search in ALL databases and return all instances
            results = []
            
            # Try DB11/DB21 (Maršrutinis routes)
            try:
                spatial_data = DatabaseManager.execute_query(
                    "db11",
                    """SELECT marsrutas_id, ST_AsGeoJSON(kelias) as kelias, 
                              atstumas_km, trukme_min, aktyvus 
                       FROM marsrutai_spatial WHERE marsrutas_id = %s""",
                    (marsrutas_id,)
                )
                
                if spatial_data:
                    business_data = DatabaseManager.execute_query(
                        "db21",
                        """SELECT marsrutas_id, pavadinimas, 
                                  marsruto_tipas_id, aptarnavimas_id 
                           FROM marsrutai_business WHERE marsrutas_id = %s""",
                        (marsrutas_id,)
                    )
                    
                    if business_data:
                        result = dict(spatial_data[0])
                        result.update(business_data[0])
                        if result['kelias']:
                            result['kelias'] = json.loads(result['kelias'])
                        result['database_location'] = 'DB11/DB21 (Maršrutinis)'
                        results.append(result)
            except Exception as e:
                logger.error(f"Error searching in DB11/DB21: {e}")
            
            # Also try DB12/DB22 (Tarpmiestinis routes) - don't stop even if found in DB11/DB21
            try:
                spatial_data = DatabaseManager.execute_query(
                    "db12",
                    """SELECT marsrutas_id, ST_AsGeoJSON(kelias) as kelias, 
                              atstumas_km, trukme_min, aktyvus 
                       FROM marsrutai_spatial WHERE marsrutas_id = %s""",
                    (marsrutas_id,)
                )
                
                if spatial_data:
                    business_data = DatabaseManager.execute_query(
                        "db22",
                        """SELECT marsrutas_id, pavadinimas, 
                                  marsruto_tipas_id, aptarnavimas_id 
                           FROM marsrutai_business WHERE marsrutas_id = %s""",
                        (marsrutas_id,)
                    )
                    
                    if business_data:
                        result = dict(spatial_data[0])
                        result.update(business_data[0])
                        if result['kelias']:
                            result['kelias'] = json.loads(result['kelias'])
                        result['database_location'] = 'DB12/DB22 (Tarpmiestinis)'
                        results.append(result)
            except Exception as e:
                logger.error(f"Error searching in DB12/DB22: {e}")
            
            if results:
                # If route exists in multiple locations, return all instances
                if len(results) > 1:
                    return {
                        "success": True, 
                        "data": results,
                        "multi_location": True,
                        "count": len(results),
                        "message": f"Route {marsrutas_id} found in {len(results)} database pairs"
                    }
                else:
                    # Single location - return as before for backward compatibility
                    return {"success": True, "data": results[0]}
            
            return {"success": False, "error": "Route not found"}
        else:
            # Read all routes from all databases
            all_routes = []
            
            # Get all routes from DB11/DB21 (Maršrutinis)
            try:
                spatial_data = DatabaseManager.execute_query(
                    "db11",
                    """SELECT marsrutas_id, ST_AsGeoJSON(kelias) as kelias, 
                              atstumas_km, trukme_min, aktyvus 
                       FROM marsrutai_spatial ORDER BY marsrutas_id"""
                )
                
                for spatial_row in spatial_data:
                    mid = spatial_row['marsrutas_id']
                    business_data = DatabaseManager.execute_query(
                        "db21",
                        """SELECT pavadinimas, marsruto_tipas_id, aptarnavimas_id 
                           FROM marsrutai_business WHERE marsrutas_id = %s""",
                        (mid,)
                    )
                    
                    if business_data:
                        result = dict(spatial_row)
                        result.update(business_data[0])
                        if result['kelias']:
                            result['kelias'] = json.loads(result['kelias'])
                        result['database_location'] = 'DB11/DB21 (Maršrutinis)'
                        all_routes.append(result)
            except Exception as e:
                logger.error(f"Error reading from DB11/DB21: {e}")
            
            # Get all routes from DB12/DB22 (Tarpmiestinis)
            try:
                spatial_data = DatabaseManager.execute_query(
                    "db12",
                    """SELECT marsrutas_id, ST_AsGeoJSON(kelias) as kelias, 
                              atstumas_km, trukme_min, aktyvus 
                       FROM marsrutai_spatial ORDER BY marsrutas_id"""
                )
                
                for spatial_row in spatial_data:
                    mid = spatial_row['marsrutas_id']
                    business_data = DatabaseManager.execute_query(
                        "db22",
                        """SELECT pavadinimas, marsruto_tipas_id, aptarnavimas_id 
                           FROM marsrutai_business WHERE marsrutas_id = %s""",
                        (mid,)
                    )
                    
                    if business_data:
                        result = dict(spatial_row)
                        result.update(business_data[0])
                        if result['kelias']:
                            result['kelias'] = json.loads(result['kelias'])
                        result['database_location'] = 'DB12/DB22 (Tarpmiestinis)'
                        all_routes.append(result)
            except Exception as e:
                logger.error(f"Error reading from DB12/DB22: {e}")
            
            return {"success": True, "data": all_routes}
    
    @staticmethod
    def update(marsrutas_id, data):
        """
        Update a route in both spatial and business databases
        First finds which databases contain the route, then updates
        data can contain any combination of spatial and business attributes
        """
        # First, find which databases contain this route
        route_info = MarsrutaiCRUD.read(marsrutas_id)
        
        if not route_info.get('success'):
            return {"success": False, "error": f"Route {marsrutas_id} not found"}
        
        # Get the route type to determine which databases to update
        marsruto_tipas_id = route_info['data']['marsruto_tipas_id']
        spatial_db = get_spatial_db_for_route_type(marsruto_tipas_id)
        business_db = get_business_db_for_route_type(marsruto_tipas_id)
        
        if not spatial_db or not business_db:
            raise ValueError(f"Invalid route type: {marsruto_tipas_id}")
        
        logger.info(f"Updating route {marsrutas_id} (type {marsruto_tipas_id}) in {spatial_db}/{business_db}")
        
        queries = {}
        
        # Update spatial attributes if present
        spatial_fields = ['kelias', 'atstumas_km', 'trukme_min', 'aktyvus']
        spatial_updates = {k: v for k, v in data.items() if k in spatial_fields}
        
        if spatial_updates:
            set_parts = []
            values = []
            
            for key, value in spatial_updates.items():
                if key == 'kelias':
                    set_parts.append("kelias = ST_GeomFromText(%s, 4326)")
                else:
                    set_parts.append(f"{key} = %s")
                values.append(value)
            
            values.append(marsrutas_id)
            queries[spatial_db] = [(
                f"UPDATE marsrutai_spatial SET {', '.join(set_parts)} WHERE marsrutas_id = %s",
                tuple(values)
            )]
        
        # Update business attributes if present
        business_fields = ['pavadinimas', 'marsruto_tipas_id', 'aptarnavimas_id']
        business_updates = {k: v for k, v in data.items() if k in business_fields}
        
        if business_updates:
            set_parts = [f"{key} = %s" for key in business_updates.keys()]
            values = list(business_updates.values())
            values.append(marsrutas_id)
            
            queries[business_db] = [(
                f"UPDATE marsrutai_business SET {', '.join(set_parts)} WHERE marsrutas_id = %s",
                tuple(values)
            )]
        
        if not queries:
            return {"success": False, "error": "No valid fields to update"}
        
        results, errors = DatabaseManager.execute_many_queries(queries)
        
        if errors:
            return {"success": False, "errors": errors}
        return {"success": True, "marsrutas_id": marsrutas_id}
    
    @staticmethod
    def delete(marsrutas_id):
        """
        Delete a route from both spatial and business databases
        First finds which databases contain the route, then deletes
        """
        # First, find which databases contain this route
        route_info = MarsrutaiCRUD.read(marsrutas_id)
        
        if not route_info.get('success'):
            return {"success": False, "error": f"Route {marsrutas_id} not found"}
        
        # Get the route type to determine which databases to delete from
        marsruto_tipas_id = route_info['data']['marsruto_tipas_id']
        spatial_db = get_spatial_db_for_route_type(marsruto_tipas_id)
        business_db = get_business_db_for_route_type(marsruto_tipas_id)
        
        if not spatial_db or not business_db:
            raise ValueError(f"Invalid route type: {marsruto_tipas_id}")
        
        logger.info(f"Deleting route {marsrutas_id} (type {marsruto_tipas_id}) from {spatial_db}/{business_db}")
            raise ValueError(f"Invalid route ID: {marsrutas_id}")
        
        queries = {
            spatial_db: [(
                "DELETE FROM marsrutai_spatial WHERE marsrutas_id = %s",
                (marsrutas_id,)
            )],
            business_db: [(
                "DELETE FROM marsrutai_business WHERE marsrutas_id = %s",
                (marsrutas_id,)
            )]
        }
        
        results, errors = DatabaseManager.execute_many_queries(queries)
        
        if errors:
            return {"success": False, "errors": errors}
        return {"success": True, "message": f"Route {marsrutas_id} deleted"}


class VairuotojaiCRUD:
    """CRUD operations for Drivers (Vairuotojai)"""
    
    @staticmethod
    def create(data):
        """Create a new driver - stored in business databases"""
        # Drivers need to be replicated across both business databases for consistency
        queries = {}
        
        for db in get_all_business_dbs():
            queries[db] = [(
                """INSERT INTO vairuotojai 
                   (vardas, pavarde, gimimo_data, pazymejimo_nr, 
                    darbo_pradzios_data, atlyginimas) 
                   VALUES (%s, %s, %s, %s, %s, %s) RETURNING vairuotojas_id""",
                (data['vardas'], data['pavarde'], data['gimimo_data'],
                 data['pazymejimo_nr'], data['darbo_pradzios_data'], 
                 data['atlyginimas'])
            )]
        
        # Execute on first DB to get ID
        first_db = get_all_business_dbs()[0]
        result = DatabaseManager.execute_query(
            first_db,
            """INSERT INTO vairuotojai 
               (vardas, pavarde, gimimo_data, pazymejimo_nr, 
                darbo_pradzios_data, atlyginimas) 
               VALUES (%s, %s, %s, %s, %s, %s) RETURNING vairuotojas_id""",
            (data['vardas'], data['pavarde'], data['gimimo_data'],
             data['pazymejimo_nr'], data['darbo_pradzios_data'], 
             data['atlyginimas'])
        )
        
        vairuotojas_id = result[0]['vairuotojas_id']
        
        # Sync to other databases with same ID
        other_dbs = [db for db in get_all_business_dbs() if db != first_db]
        for db in other_dbs:
            DatabaseManager.execute_query(
                db,
                """INSERT INTO vairuotojai 
                   (vairuotojas_id, vardas, pavarde, gimimo_data, pazymejimo_nr, 
                    darbo_pradzios_data, atlyginimas) 
                   VALUES (%s, %s, %s, %s, %s, %s, %s)""",
                (vairuotojas_id, data['vardas'], data['pavarde'], data['gimimo_data'],
                 data['pazymejimo_nr'], data['darbo_pradzios_data'], 
                 data['atlyginimas']),
                fetch=False
            )
        
        return {"success": True, "vairuotojas_id": vairuotojas_id}
    
    @staticmethod
    def read(vairuotojas_id=None):
        """Read driver(s) from any business database"""
        # Read from first business DB (they should be synchronized)
        db = get_all_business_dbs()[0]
        
        if vairuotojas_id:
            data = DatabaseManager.execute_query(
                db,
                """SELECT * FROM vairuotojai WHERE vairuotojas_id = %s""",
                (vairuotojas_id,)
            )
            if data:
                return {"success": True, "data": dict(data[0])}
            return {"success": False, "error": "Driver not found"}
        else:
            data = DatabaseManager.execute_query(
                db,
                "SELECT * FROM vairuotojai ORDER BY vairuotojas_id"
            )
            return {"success": True, "data": [dict(row) for row in data]}
    
    @staticmethod
    def update(vairuotojas_id, data):
        """Update driver in all business databases"""
        set_parts = [f"{key} = %s" for key in data.keys()]
        values = list(data.values())
        values.append(vairuotojas_id)
        
        query = f"UPDATE vairuotojai SET {', '.join(set_parts)} WHERE vairuotojas_id = %s"
        
        queries = {}
        for db in get_all_business_dbs():
            queries[db] = [(query, tuple(values))]
        
        results, errors = DatabaseManager.execute_many_queries(queries)
        
        if errors:
            return {"success": False, "errors": errors}
        return {"success": True, "vairuotojas_id": vairuotojas_id}
    
    @staticmethod
    def delete(vairuotojas_id):
        """Delete driver from all business databases"""
        queries = {}
        for db in get_all_business_dbs():
            queries[db] = [(
                "DELETE FROM vairuotojai WHERE vairuotojas_id = %s",
                (vairuotojas_id,)
            )]
        
        results, errors = DatabaseManager.execute_many_queries(queries)
        
        if errors:
            return {"success": False, "errors": errors}
        return {"success": True, "message": f"Driver {vairuotojas_id} deleted"}


class TransportCRUD:
    """CRUD operations for Transport (Transporto Priemones)"""
    
    @staticmethod
    def create(data):
        """Create a new transport vehicle"""
        first_db = get_all_business_dbs()[0]
        result = DatabaseManager.execute_query(
            first_db,
            """INSERT INTO transporto_priemones 
               (kodas, vietu_sk, pagaminimo_metai, registracijos_nr, 
                paskutine_apziura_data, tipas_id, degalu_tipas_id) 
               VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING priemone_id""",
            (data['kodas'], data['vietu_sk'], data['pagaminimo_metai'],
             data['registracijos_nr'], data['paskutine_apziura_data'],
             data['tipas_id'], data['degalu_tipas_id'])
        )
        
        priemone_id = result[0]['priemone_id']
        
        # Sync to other databases
        other_dbs = [db for db in get_all_business_dbs() if db != first_db]
        for db in other_dbs:
            DatabaseManager.execute_query(
                db,
                """INSERT INTO transporto_priemones 
                   (priemone_id, kodas, vietu_sk, pagaminimo_metai, registracijos_nr, 
                    paskutine_apziura_data, tipas_id, degalu_tipas_id) 
                   VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""",
                (priemone_id, data['kodas'], data['vietu_sk'], data['pagaminimo_metai'],
                 data['registracijos_nr'], data['paskutine_apziura_data'],
                 data['tipas_id'], data['degalu_tipas_id']),
                fetch=False
            )
        
        return {"success": True, "priemone_id": priemone_id}
    
    @staticmethod
    def read(priemone_id=None):
        """Read transport vehicle(s)"""
        db = get_all_business_dbs()[0]
        
        if priemone_id:
            data = DatabaseManager.execute_query(
                db,
                "SELECT * FROM transporto_priemones WHERE priemone_id = %s",
                (priemone_id,)
            )
            if data:
                return {"success": True, "data": dict(data[0])}
            return {"success": False, "error": "Vehicle not found"}
        else:
            data = DatabaseManager.execute_query(
                db,
                "SELECT * FROM transporto_priemones ORDER BY priemone_id"
            )
            return {"success": True, "data": [dict(row) for row in data]}
    
    @staticmethod
    def update(priemone_id, data):
        """Update transport vehicle in all business databases"""
        set_parts = [f"{key} = %s" for key in data.keys()]
        values = list(data.values())
        values.append(priemone_id)
        
        query = f"UPDATE transporto_priemones SET {', '.join(set_parts)} WHERE priemone_id = %s"
        
        queries = {}
        for db in get_all_business_dbs():
            queries[db] = [(query, tuple(values))]
        
        results, errors = DatabaseManager.execute_many_queries(queries)
        
        if errors:
            return {"success": False, "errors": errors}
        return {"success": True, "priemone_id": priemone_id}
    
    @staticmethod
    def delete(priemone_id):
        """Delete transport vehicle from all business databases"""
        queries = {}
        for db in get_all_business_dbs():
            queries[db] = [(
                "DELETE FROM transporto_priemones WHERE priemone_id = %s",
                (priemone_id,)
            )]
        
        results, errors = DatabaseManager.execute_many_queries(queries)
        
        if errors:
            return {"success": False, "errors": errors}
        return {"success": True, "message": f"Vehicle {priemone_id} deleted"}


class StoteleCRUD:
    """CRUD operations for Stops (Stoteles)"""
    
    @staticmethod
    def create(data):
        """
        Create a new stop in appropriate spatial database
        Stops with ID 1-25 go to db11, 26+ go to db12
        """
        # Determine which spatial DB based on pattern or explicit assignment
        # For simplicity, let's use a similar approach to routes
        stotele_id = data.get('stotele_id')
        
        # If creating in db11 or db12
        if stotele_id and stotele_id <= 25:
            spatial_db = "db11"
        else:
            spatial_db = "db12"
        
        result = DatabaseManager.execute_query(
            spatial_db,
            """INSERT INTO stoteles 
               (pavadinimas, stoteles_erdvine_vieta, paviljono_tipas_id) 
               VALUES (%s, ST_SetSRID(ST_Point(%s, %s), 4326), %s) 
               RETURNING stotele_id""",
            (data['pavadinimas'], data['lon'], data['lat'], 
             data['paviljono_tipas_id'])
        )
        
        new_id = result[0]['stotele_id']
        
        return {"success": True, "stotele_id": new_id}
    
    @staticmethod
    def read(stotele_id=None):
        """Read stop(s) from spatial databases"""
        if stotele_id:
            # Try to find in all spatial databases
            for db in get_all_spatial_dbs():
                data = DatabaseManager.execute_query(
                    db,
                    """SELECT stotele_id, pavadinimas, 
                              ST_X(stoteles_erdvine_vieta) as lon,
                              ST_Y(stoteles_erdvine_vieta) as lat,
                              paviljono_tipas_id
                       FROM stoteles WHERE stotele_id = %s""",
                    (stotele_id,)
                )
                if data:
                    return {"success": True, "data": dict(data[0])}
            return {"success": False, "error": "Stop not found"}
        else:
            all_stops = []
            for db in get_all_spatial_dbs():
                data = DatabaseManager.execute_query(
                    db,
                    """SELECT stotele_id, pavadinimas, 
                              ST_X(stoteles_erdvine_vieta) as lon,
                              ST_Y(stoteles_erdvine_vieta) as lat,
                              paviljono_tipas_id
                       FROM stoteles ORDER BY stotele_id"""
                )
                all_stops.extend([dict(row) for row in data])
            return {"success": True, "data": all_stops}
    
    @staticmethod
    def update(stotele_id, data):
        """Update stop in appropriate spatial database"""
        # Find which database contains this stop
        target_db = None
        for db in get_all_spatial_dbs():
            check = DatabaseManager.execute_query(
                db,
                "SELECT stotele_id FROM stoteles WHERE stotele_id = %s",
                (stotele_id,)
            )
            if check:
                target_db = db
                break
        
        if not target_db:
            return {"success": False, "error": "Stop not found"}
        
        set_parts = []
        values = []
        
        for key, value in data.items():
            if key == 'lon' or key == 'lat':
                continue  # Handle separately
            set_parts.append(f"{key} = %s")
            values.append(value)
        
        if 'lon' in data and 'lat' in data:
            set_parts.append("stoteles_erdvine_vieta = ST_SetSRID(ST_Point(%s, %s), 4326)")
            values.extend([data['lon'], data['lat']])
        
        if not set_parts:
            return {"success": False, "error": "No valid fields to update"}
        
        values.append(stotele_id)
        
        DatabaseManager.execute_query(
            target_db,
            f"UPDATE stoteles SET {', '.join(set_parts)} WHERE stotele_id = %s",
            tuple(values),
            fetch=False
        )
        
        return {"success": True, "stotele_id": stotele_id}
    
    @staticmethod
    def delete(stotele_id):
        """Delete stop from spatial database"""
        for db in get_all_spatial_dbs():
            try:
                DatabaseManager.execute_query(
                    db,
                    "DELETE FROM stoteles WHERE stotele_id = %s",
                    (stotele_id,),
                    fetch=False
                )
            except:
                pass  # Stop might not exist in this DB
        
        return {"success": True, "message": f"Stop {stotele_id} deleted"}
