import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    
    # Database Configuration
    DB_HOST = os.environ.get('DB_HOST') or 'localhost'
    DB_USER = os.environ.get('DB_USER') or 'root'
    DB_PASSWORD = os.environ.get('DB_PASSWORD') or 'Shri2009!'
    DB_NAME = os.environ.get('DB_NAME') or 'restaurant_management'
    DB_PORT = int(os.environ.get('DB_PORT', 3306))
    
    # Application Settings
    ITEMS_PER_PAGE = 10
    SESSION_TIMEOUT = 3600  # 1 hour