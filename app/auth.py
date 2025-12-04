from functools import wraps
from flask import session, redirect, url_for, flash
from app.database import Database

class Auth:
    @staticmethod
    def login_user(username, password):
        """Authenticate user and return user info using stored procedure"""
        try:
            result = Database.call_procedure('sp_AuthenticateUser', (username, password))
            if result:
                return result[0]
            return None
        except Exception as e:
            print(f"Login error: {e}")
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
    def has_role(roles):
        """Check if current user has specific role(s) - supports single role or list"""
        user = Auth.get_current_user()
        if not user:
            return False
        
        user_role = user.get('role')
        
        # If roles is a list, check if user's role is in the list
        if isinstance(roles, list):
            return user_role in roles
        
        # If single role string, check exact match
        return user_role == roles

def login_required(f):
    """Decorator to require login for routes"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not Auth.is_authenticated():
            flash('Please log in to access this page.', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

def role_required(roles):
    """Decorator to require specific role(s) for routes - supports single role or list"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not Auth.is_authenticated():
                flash('Please log in to access this page.', 'warning')
                return redirect(url_for('login'))
            if not Auth.has_role(roles):
                flash('You do not have permission to access this page.', 'danger')
                return redirect(url_for('dashboard'))
            return f(*args, **kwargs)
        return decorated_function
    return decorator