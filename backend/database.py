import psycopg2
from psycopg2.extras import RealDictCursor
from db_config import DB_CONFIGS
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DatabaseManager:
    """Manages connections to distributed databases"""
    
    @staticmethod
    def get_connection(db_name):
        """Get a connection to a specific database"""
        try:
            config = DB_CONFIGS[db_name]
            conn = psycopg2.connect(**config, cursor_factory=RealDictCursor)
            return conn
        except Exception as e:
            logger.error(f"Error connecting to {db_name}: {str(e)}")
            raise
    
    @staticmethod
    def execute_query(db_name, query, params=None, fetch=True):
        """Execute a query on a specific database"""
        conn = None
        try:
            conn = DatabaseManager.get_connection(db_name)
            cursor = conn.cursor()
            cursor.execute(query, params or ())
            
            if fetch:
                result = cursor.fetchall()
            else:
                result = None
            
            conn.commit()
            cursor.close()
            return result
        except Exception as e:
            if conn:
                conn.rollback()
            logger.error(f"Error executing query on {db_name}: {str(e)}")
            raise
        finally:
            if conn:
                conn.close()
    
    @staticmethod
    def execute_many_queries(queries_by_db):
        """
        Execute multiple queries across different databases
        queries_by_db: dict of {db_name: [(query, params), ...]}
        """
        results = {}
        errors = []
        
        for db_name, queries in queries_by_db.items():
            conn = None
            try:
                conn = DatabaseManager.get_connection(db_name)
                cursor = conn.cursor()
                
                for query, params in queries:
                    cursor.execute(query, params or ())
                
                conn.commit()
                cursor.close()
                results[db_name] = "success"
            except Exception as e:
                if conn:
                    conn.rollback()
                error_msg = f"Error on {db_name}: {str(e)}"
                logger.error(error_msg)
                errors.append(error_msg)
            finally:
                if conn:
                    conn.close()
        
        return results, errors
