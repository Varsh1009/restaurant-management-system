import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """
    Configuration for Restaurant Management System
    
    IMPORTANT FOR GRADERS/INSTRUCTORS:
    1. Create a .env file in the root directory (see .env.example)
    2. Set your MySQL password in DB_PASSWORD
    3. Or modify the default values below to match your MySQL setup
    """
    
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    
    # Database Configuration
    # NOTE: If you're running this for grading, please set these in a .env file
    # or update the defaults below to match your MySQL installation
    DB_HOST = os.environ.get('DB_HOST') or 'localhost'
    DB_USER = os.environ.get('DB_USER') or 'root'
    DB_PASSWORD = os.environ.get('DB_PASSWORD') or ''  # SET YOUR PASSWORD HERE OR IN .env FILE
    DB_NAME = os.environ.get('DB_NAME') or 'restaurant_management'
    DB_PORT = int(os.environ.get('DB_PORT', 3306))
    
    # Application Settings
    ITEMS_PER_PAGE = 10
    SESSION_TIMEOUT = 3600  # 1 hour