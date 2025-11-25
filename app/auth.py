from functools import wraps
from flask import session, redirect, url_for, flash
from app.database import Database

class Auth:
    @staticmethod
    def login_user(username, password):
        """Authenticate user and return user info"""
        query = """
            SELECT uc.credential_id, uc.staff_id, uc.username, 
                   s.first_name, s.last_name, s.role, s.location_id,
                   rl.location_name
            FROM User_Credentials uc
            JOIN Staff s ON uc.staff_id = s.staff_id
            JOIN Restaurant_Locations rl ON s.location_id = rl.location_id
            WHERE uc.username = %s AND uc.password_hash = %s AND s.status = 'Active'
        """
        
        result = Database.execute_query(query, (username, password))
        
        if result:
            user = result[0]
            # Update last login
            update_query = "UPDATE User_Credentials SET last_login = NOW() WHERE credential_id = %s"
            Database.execute_query(update_query, (user['credential_id'],), fetch=False)
            return user
        return None
    
    @staticmethod
    def get_current_user():
        """Get current logged-in user from session"""
        return session.get('user')
    
    @staticmethod
    def logout_user():
        """Clear user session"""
        session.clear()
    
    @staticmethod
    def is_authenticated():
        """Check if user is logged in"""
        return 'user' in session
    
    @staticmethod
    def has_role(role):
        """Check if current user has specific role"""
        user = Auth.get_current_user()
        return user and user.get('role') == role

def login_required(f):
    """Decorator to require login for routes"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not Auth.is_authenticated():
            flash('Please log in to access this page.', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

def role_required(role):
    """Decorator to require specific role for routes"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not Auth.is_authenticated():
                flash('Please log in to access this page.', 'warning')
                return redirect(url_for('login'))
            if not Auth.has_role(role):
                flash('You do not have permission to access this page.', 'danger')
                return redirect(url_for('dashboard'))
            return f(*args, **kwargs)
        return decorated_function
    return decorator