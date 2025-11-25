import pymysql
from app.config import Config
from contextlib import contextmanager

class Database:
    @staticmethod
    def get_connection():
        """Create and return a database connection"""
        try:
            connection = pymysql.connect(
                host=Config.DB_HOST,
                user=Config.DB_USER,
                password=Config.DB_PASSWORD,
                database=Config.DB_NAME,
                port=Config.DB_PORT,
                cursorclass=pymysql.cursors.DictCursor,
                autocommit=False
            )
            return connection
        except pymysql.Error as e:
            print(f"Database connection error: {e}")
            raise
    
    @staticmethod
    @contextmanager
    def get_cursor(commit=False):
        """Context manager for database operations"""
        connection = Database.get_connection()
        cursor = connection.cursor()
        try:
            yield cursor
            if commit:
                connection.commit()
        except Exception as e:
            connection.rollback()
            print(f"Database operation error: {e}")
            raise
        finally:
            cursor.close()
            connection.close()
    
    @staticmethod
    def execute_query(query, params=None, fetch=True):
        """Execute a single query and return results"""
        with Database.get_cursor(commit=not fetch) as cursor:
            cursor.execute(query, params or ())
            if fetch:
                return cursor.fetchall()
            return cursor.rowcount
    
    @staticmethod
    def call_procedure(proc_name, params=None):
        """Call a stored procedure - FIXED VERSION"""
        connection = Database.get_connection()
        cursor = connection.cursor()
        try:
            cursor.callproc(proc_name, params or ())
            
            # Fetch the result directly (PyMySQL doesn't have stored_results())
            result = cursor.fetchall()
            
            connection.commit()
            cursor.close()
            connection.close()
            
            return result
            
        except Exception as e:
            connection.rollback()
            cursor.close()
            connection.close()
            print(f"Procedure error: {e}")
            raise
    
    @staticmethod
    def execute_function(func_name, params=None):
        """Execute a stored function"""
        param_placeholders = ', '.join(['%s'] * len(params)) if params else ''
        query = f"SELECT {func_name}({param_placeholders}) as result"
        result = Database.execute_query(query, params)
        return result[0]['result'] if result else None