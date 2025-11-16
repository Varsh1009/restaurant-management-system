"""
Restaurant Management System - Main Application
Group: NarayananSKumariS
"""

from functools import wraps
from flask import Flask, render_template, request, jsonify, session, redirect, url_for
from flask_cors import CORS
import pymysql
from datetime import datetime, date
import os
from dotenv import load_dotenv
import traceback

# Load environment variables
load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY', 'your-secret-key-here-change-in-production')
CORS(app)

# Database configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', ''),
    'database': os.getenv('DB_NAME', 'restaurant_management'),
    'cursorclass': pymysql.cursors.DictCursor,
    'autocommit': False
}

# ============================================
# DATABASE CONNECTION HELPER
# ============================================

def get_db_connection():
    """Create and return a database connection"""
    try:
        connection = pymysql.connect(**DB_CONFIG)
        return connection
    except pymysql.MySQLError as e:
        print(f"Database connection error: {e}")
        raise

def execute_query(query, params=None, fetch_one=False, fetch_all=True, commit=False):
    """
    Execute a database query with error handling
    Returns: dict with 'success', 'data', and 'message' keys
    """
    connection = None
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            cursor.execute(query, params or ())
            
            if commit:
                connection.commit()
                return {
                    'success': True,
                    'data': cursor.lastrowid if cursor.lastrowid else None,
                    'message': 'Operation successful'
                }
            
            if fetch_one:
                data = cursor.fetchone()
            elif fetch_all:
                data = cursor.fetchall()
            else:
                data = None
            
            return {
                'success': True,
                'data': data,
                'message': 'Query executed successfully'
            }
    
    except pymysql.MySQLError as e:
        if connection:
            connection.rollback()
        error_msg = str(e)
        print(f"Database error: {error_msg}")
        return {
            'success': False,
            'data': None,
            'message': f'Database error: {error_msg}'
        }
    
    except Exception as e:
        if connection:
            connection.rollback()
        error_msg = str(e)
        print(f"Unexpected error: {error_msg}")
        print(traceback.format_exc())
        return {
            'success': False,
            'data': None,
            'message': f'Unexpected error: {error_msg}'
        }
    
    finally:
        if connection:
            connection.close()

def call_procedure(proc_name, params=None):
    """Call a stored procedure with error handling"""
    connection = None
    try:
        connection = get_db_connection()
        with connection.cursor() as cursor:
            cursor.callproc(proc_name, params or ())
            connection.commit()
            
            # Try to fetch results if any
            try:
                result = cursor.fetchall()
            except:
                result = None
            
            return {
                'success': True,
                'data': result,
                'message': 'Procedure executed successfully'
            }
    
    except pymysql.MySQLError as e:
        if connection:
            connection.rollback()
        error_msg = str(e)
        print(f"Procedure error: {error_msg}")
        return {
            'success': False,
            'data': None,
            'message': f'Procedure error: {error_msg}'
        }
    
    finally:
        if connection:
            connection.close()

# ============================================
# AUTHENTICATION AND AUTHORIZATION
# ============================================

def login_required(f):
    """Decorator to require login"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

def manager_required(f):
    """Decorator to require manager role"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        if session.get('role') != 'Manager':
            return jsonify({'success': False, 'message': 'Manager access required'}), 403
        return f(*args, **kwargs)
    return decorated_function

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Login page"""
    if request.method == 'GET':
        return render_template('login.html')
    
    try:
        data = request.get_json()
        email = data.get('email')
        
        query = """
            SELECT s.staff_id, s.first_name, s.last_name, s.email, s.role, 
                   rl.location_name, s.location_id
            FROM Staff s
            JOIN Restaurant_Locations rl ON s.location_id = rl.location_id
            WHERE s.email = %s AND s.status = 'Active'
        """
        result = execute_query(query, (email,), fetch_one=True)
        
        if result['success'] and result['data']:
            user = result['data']
            session['user_id'] = user['staff_id']
            session['user_name'] = f"{user['first_name']} {user['last_name']}"
            session['role'] = user['role']
            session['location_id'] = user['location_id']
            session['location_name'] = user['location_name']
            
            return jsonify({
                'success': True,
                'message': 'Login successful',
                'user': {
                    'name': session['user_name'],
                    'role': session['role'],
                    'location': session['location_name']
                }
            })
        else:
            return jsonify({'success': False, 'message': 'Invalid credentials'}), 401
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/logout')
def logout():
    """Logout user"""
    session.clear()
    return redirect(url_for('login'))

@app.route('/api/current-user')
def current_user():
    """Get current logged-in user info"""
    if 'user_id' in session:
        return jsonify({
            'success': True,
            'user': {
                'id': session['user_id'],
                'name': session['user_name'],
                'role': session['role'],
                'location': session['location_name']
            }
        })
    else:
        return jsonify({'success': False, 'message': 'Not logged in'}), 401

# ============================================
# ROUTES - HOME AND DASHBOARD
# ============================================

@app.route('/')
@login_required
def index():
    """Home page"""
    return render_template('index.html')

@app.route('/dashboard')
@login_required
def dashboard():
    """Main dashboard"""
    return render_template('dashboard.html')

# ============================================
# CUSTOMERS - CRUD OPERATIONS
# ============================================

@app.route('/customers')
@login_required
def customers():
    """Customers page"""
    return render_template('customers.html')

@app.route('/api/customers', methods=['GET'])
@login_required
def get_customers():
    """READ - Get all customers"""
    try:
        search = request.args.get('search', '')
        
        if search:
            query = """
                SELECT customer_id, first_name, last_name, email, phone_number, 
                       loyalty_points, city, state
                FROM Customers 
                WHERE first_name LIKE %s OR last_name LIKE %s OR email LIKE %s
                ORDER BY loyalty_points DESC
            """
            result = execute_query(query, (f'%{search}%', f'%{search}%', f'%{search}%'))
        else:
            query = """
                SELECT customer_id, first_name, last_name, email, phone_number, 
                       loyalty_points, city, state
                FROM Customers 
                ORDER BY loyalty_points DESC
            """
            result = execute_query(query)
        
        if result['success']:
            return jsonify({'success': True, 'data': result['data']})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/customers/<int:customer_id>', methods=['GET'])
@login_required
def get_customer(customer_id):
    """READ - Get single customer"""
    try:
        query = "SELECT * FROM Customers WHERE customer_id = %s"
        result = execute_query(query, (customer_id,), fetch_one=True)
        
        if result['success']:
            if result['data']:
                return jsonify({'success': True, 'data': result['data']})
            else:
                return jsonify({'success': False, 'message': 'Customer not found'}), 404
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/customers', methods=['POST'])
@login_required
def create_customer():
    """CREATE - Add new customer"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['first_name', 'last_name', 'email', 'phone_number']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'success': False, 'message': f'{field} is required'}), 400
        
        query = """
            INSERT INTO Customers (first_name, last_name, email, phone_number, 
                                 address, city, state, zip_code)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        params = (
            data['first_name'], data['last_name'], data['email'], data['phone_number'],
            data.get('address'), data.get('city'), data.get('state'), data.get('zip_code')
        )
        
        result = execute_query(query, params, commit=True)
        
        if result['success']:
            return jsonify({
                'success': True, 
                'message': 'Customer created successfully',
                'customer_id': result['data']
            }), 201
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/customers/<int:customer_id>', methods=['PUT'])
@login_required
def update_customer(customer_id):
    """UPDATE - Update customer"""
    try:
        data = request.get_json()
        
        query = """
            UPDATE Customers 
            SET first_name = %s, last_name = %s, email = %s, phone_number = %s,
                address = %s, city = %s, state = %s, zip_code = %s
            WHERE customer_id = %s
        """
        params = (
            data['first_name'], data['last_name'], data['email'], data['phone_number'],
            data.get('address'), data.get('city'), data.get('state'), data.get('zip_code'),
            customer_id
        )
        
        result = execute_query(query, params, commit=True)
        
        if result['success']:
            return jsonify({'success': True, 'message': 'Customer updated successfully'})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/customers/<int:customer_id>', methods=['DELETE'])
@login_required
def delete_customer(customer_id):
    """DELETE - Delete customer"""
    try:
        query = "DELETE FROM Customers WHERE customer_id = %s"
        result = execute_query(query, (customer_id,), commit=True)
        
        if result['success']:
            return jsonify({'success': True, 'message': 'Customer deleted successfully'})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# MENU ITEMS - CRUD OPERATIONS
# ============================================

@app.route('/menu')
@login_required
def menu():
    """Menu page"""
    return render_template('menu.html')

@app.route('/api/menu-items', methods=['GET'])
@login_required
def get_menu_items():
    """READ - Get all menu items"""
    try:
        category = request.args.get('category', '')
        
        if category:
            query = "SELECT * FROM Menu_Items WHERE category = %s ORDER BY category, item_name"
            result = execute_query(query, (category,))
        else:
            query = "SELECT * FROM Menu_Items ORDER BY category, item_name"
            result = execute_query(query)
        
        if result['success']:
            return jsonify({'success': True, 'data': result['data']})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/menu-items', methods=['POST'])
@login_required
def create_menu_item():
    """CREATE - Add new menu item"""
    try:
        data = request.get_json()
        
        required_fields = ['item_name', 'category', 'price', 'preparation_time']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'success': False, 'message': f'{field} is required'}), 400
        
        query = """
            INSERT INTO Menu_Items (item_name, description, category, price, 
                                  preparation_time, is_available)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        params = (
            data['item_name'], data.get('description'), data['category'],
            data['price'], data['preparation_time'], 
            data.get('is_available', True)
        )
        
        result = execute_query(query, params, commit=True)
        
        if result['success']:
            return jsonify({
                'success': True, 
                'message': 'Menu item created successfully',
                'item_id': result['data']
            }), 201
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/menu-items/<int:item_id>', methods=['PUT'])
@login_required
def update_menu_item(item_id):
    """UPDATE - Update menu item"""
    try:
        data = request.get_json()
        
        query = """
            UPDATE Menu_Items 
            SET item_name = %s, description = %s, category = %s, price = %s,
                preparation_time = %s, is_available = %s
            WHERE item_id = %s
        """
        params = (
            data['item_name'], data.get('description'), data['category'],
            data['price'], data['preparation_time'], 
            data.get('is_available', True), item_id
        )
        
        result = execute_query(query, params, commit=True)
        
        if result['success']:
            return jsonify({'success': True, 'message': 'Menu item updated successfully'})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/menu-items/<int:item_id>', methods=['DELETE'])
@login_required
def delete_menu_item(item_id):
    """DELETE - Delete menu item"""
    try:
        query = "DELETE FROM Menu_Items WHERE item_id = %s"
        result = execute_query(query, (item_id,), commit=True)
        
        if result['success']:
            return jsonify({'success': True, 'message': 'Menu item deleted successfully'})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# ORDERS - CRUD WITH STORED PROCEDURES
# ============================================

@app.route('/orders')
@login_required
def orders():
    """Orders page"""
    return render_template('orders.html')

@app.route('/api/orders', methods=['GET'])
@login_required
def get_orders():
    """READ - Get all orders"""
    try:
        status = request.args.get('status', '')
        order_type = request.args.get('order_type', '')
        
        query = """
            SELECT o.order_id, o.order_date, o.order_type, o.status, o.total_amount,
                   CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
                   rl.location_name,
                   CONCAT(s.first_name, ' ', s.last_name) AS staff_name
            FROM Orders o
            JOIN Customers c ON o.customer_id = c.customer_id
            JOIN Restaurant_Locations rl ON o.location_id = rl.location_id
            LEFT JOIN Staff s ON o.staff_id = s.staff_id
            WHERE 1=1
        """
        params = []
        
        if status:
            query += " AND o.status = %s"
            params.append(status)
        
        if order_type:
            query += " AND o.order_type = %s"
            params.append(order_type)
        
        query += " ORDER BY o.order_date DESC LIMIT 100"
        
        result = execute_query(query, tuple(params) if params else None)
        
        if result['success']:
            # Convert datetime to string for JSON serialization
            for order in result['data']:
                if 'order_date' in order and order['order_date']:
                    order['order_date'] = order['order_date'].strftime('%Y-%m-%d %H:%M:%S')
            return jsonify({'success': True, 'data': result['data']})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/orders/<int:order_id>', methods=['GET'])
@login_required
def get_order_details(order_id):
    """READ - Get order with items"""
    try:
        # Get order details
        order_query = """
            SELECT o.*, 
                   CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
                   c.email AS customer_email,
                   rl.location_name
            FROM Orders o
            JOIN Customers c ON o.customer_id = c.customer_id
            JOIN Restaurant_Locations rl ON o.location_id = rl.location_id
            WHERE o.order_id = %s
        """
        order_result = execute_query(order_query, (order_id,), fetch_one=True)
        
        if not order_result['success'] or not order_result['data']:
            return jsonify({'success': False, 'message': 'Order not found'}), 404
        
        # Get order items
        items_query = """
            SELECT oi.*, mi.item_name, mi.category
            FROM Order_Items oi
            JOIN Menu_Items mi ON oi.item_id = mi.item_id
            WHERE oi.order_id = %s
        """
        items_result = execute_query(items_query, (order_id,))
        
        order_data = order_result['data']
        if 'order_date' in order_data and order_data['order_date']:
            order_data['order_date'] = order_data['order_date'].strftime('%Y-%m-%d %H:%M:%S')
        order_data['items'] = items_result['data'] if items_result['success'] else []
        
        return jsonify({'success': True, 'data': order_data})
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/orders', methods=['POST'])
@login_required
def create_order():
    """CREATE - Create new order using stored procedure"""
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ['customer_id', 'location_id', 'order_type']
        for field in required_fields:
            if field not in data:
                return jsonify({'success': False, 'message': f'{field} is required'}), 400
        
        # Call stored procedure
        params = (
            data['customer_id'],
            data['location_id'],
            data['order_type'],
            data.get('table_id'),
            data.get('delivery_address'),
            data.get('staff_id')
        )
        
        result = call_procedure('sp_ProcessOrder', params)
        
        if result['success']:
            # Get the order_id from result
            order_id = result['data'][0]['order_id'] if result['data'] else None
            return jsonify({
                'success': True, 
                'message': 'Order created successfully',
                'order_id': order_id
            }), 201
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/orders/<int:order_id>/items', methods=['POST'])
@login_required
def add_order_item(order_id):
    """CREATE - Add item to order using stored procedure"""
    try:
        data = request.get_json()
        
        params = (
            order_id,
            data['item_id'],
            data['quantity'],
            data.get('special_requests')
        )
        
        result = call_procedure('sp_AddOrderItem', params)
        
        if result['success']:
            return jsonify({'success': True, 'message': 'Item added to order'})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/orders/<int:order_id>/complete', methods=['POST'])
@login_required
def complete_order(order_id):
    """UPDATE - Complete order and process payment"""
    try:
        data = request.get_json()
        
        params = (
            order_id,
            data['payment_method'],
            data.get('tip_amount', 0)
        )
        
        result = call_procedure('sp_CompleteOrder', params)
        
        if result['success']:
            return jsonify({'success': True, 'message': 'Order completed successfully'})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/orders/<int:order_id>', methods=['DELETE'])
@login_required
def cancel_order(order_id):
    """DELETE/UPDATE - Cancel order"""
    try:
        query = "UPDATE Orders SET status = 'Cancelled' WHERE order_id = %s"
        result = execute_query(query, (order_id,), commit=True)
        
        if result['success']:
            return jsonify({'success': True, 'message': 'Order cancelled successfully'})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# INVENTORY - CRUD OPERATIONS
# ============================================

@app.route('/inventory')
@login_required
def inventory():
    """Inventory page"""
    return render_template('inventory.html')

@app.route('/api/inventory', methods=['GET'])
@login_required
def get_inventory():
    """READ - Get all inventory items"""
    try:
        location_id = request.args.get('location_id', '')
        low_stock = request.args.get('low_stock', '')
        
        if low_stock == 'true':
            query = """
                SELECT i.*, rl.location_name
                FROM Inventory i
                JOIN Restaurant_Locations rl ON i.location_id = rl.location_id
                WHERE i.quantity < i.minimum_stock_level
                ORDER BY (i.quantity / i.minimum_stock_level) ASC
            """
            result = execute_query(query)
        elif location_id:
            query = """
                SELECT i.*, rl.location_name
                FROM Inventory i
                JOIN Restaurant_Locations rl ON i.location_id = rl.location_id
                WHERE i.location_id = %s
                ORDER BY i.item_name
            """
            result = execute_query(query, (location_id,))
        else:
            query = """
                SELECT i.*, rl.location_name
                FROM Inventory i
                JOIN Restaurant_Locations rl ON i.location_id = rl.location_id
                ORDER BY rl.location_name, i.item_name
            """
            result = execute_query(query)
        
        if result['success']:
            # Convert date to string
            for item in result['data']:
                if 'last_restocked_date' in item and item['last_restocked_date']:
                    item['last_restocked_date'] = item['last_restocked_date'].strftime('%Y-%m-%d')
            return jsonify({'success': True, 'data': result['data']})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/inventory', methods=['POST'])
@login_required
def create_inventory_item():
    """CREATE - Add inventory item"""
    try:
        data = request.get_json()
        
        query = """
            INSERT INTO Inventory (location_id, item_name, category, quantity, unit,
                                 minimum_stock_level, supplier_name, unit_cost)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        params = (
            data['location_id'], data['item_name'], data['category'],
            data['quantity'], data['unit'], data['minimum_stock_level'],
            data.get('supplier_name'), data.get('unit_cost')
        )
        
        result = execute_query(query, params, commit=True)
        
        if result['success']:
            return jsonify({
                'success': True, 
                'message': 'Inventory item created successfully'
            }), 201
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/inventory/<int:inventory_id>', methods=['PUT'])
@login_required
def update_inventory_item(inventory_id):
    """UPDATE - Update inventory item"""
    try:
        data = request.get_json()
        
        query = """
            UPDATE Inventory 
            SET item_name = %s, category = %s, quantity = %s, unit = %s,
                minimum_stock_level = %s, supplier_name = %s, unit_cost = %s
            WHERE inventory_id = %s
        """
        params = (
            data['item_name'], data['category'], data['quantity'], data['unit'],
            data['minimum_stock_level'], data.get('supplier_name'), 
            data.get('unit_cost'), inventory_id
        )
        
        result = execute_query(query, params, commit=True)
        
        if result['success']:
            return jsonify({'success': True, 'message': 'Inventory updated successfully'})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/inventory/<int:inventory_id>/restock', methods=['POST'])
@login_required
def restock_inventory(inventory_id):
    """UPDATE - Restock inventory using stored procedure"""
    try:
        data = request.get_json()
        quantity = data.get('quantity_received', 0)
        
        result = call_procedure('sp_UpdateInventory', (inventory_id, quantity))
        
        if result['success']:
            return jsonify({'success': True, 'message': 'Inventory restocked successfully'})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/inventory/<int:inventory_id>', methods=['DELETE'])
@login_required
def delete_inventory_item(inventory_id):
    """DELETE - Delete inventory item"""
    try:
        query = "DELETE FROM Inventory WHERE inventory_id = %s"
        result = execute_query(query, (inventory_id,), commit=True)
        
        if result['success']:
            return jsonify({'success': True, 'message': 'Inventory item deleted successfully'})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# ANALYTICS AND REPORTS
# ============================================

@app.route('/analytics')
@login_required
@manager_required
def analytics():
    """Analytics page - Manager only"""
    return render_template('analytics.html')

@app.route('/api/analytics/revenue-by-channel', methods=['GET'])
@login_required
def revenue_by_channel():
    """Complex query - Revenue analysis by order channel"""
    try:
        start_date = request.args.get('start_date', '2024-11-01')
        end_date = request.args.get('end_date', '2024-11-30')
        
        query = """
            SELECT 
                o.order_type,
                COUNT(*) AS order_count,
                SUM(o.total_amount) AS total_revenue,
                AVG(o.total_amount) AS avg_order_value,
                SUM(p.tip_amount) AS total_tips
            FROM Orders o
            LEFT JOIN Payments p ON o.order_id = p.order_id
            WHERE DATE(o.order_date) BETWEEN %s AND %s
            AND o.status IN ('Completed', 'Delivered')
            GROUP BY o.order_type
            ORDER BY total_revenue DESC
        """
        
        result = execute_query(query, (start_date, end_date))
        
        if result['success']:
            return jsonify({'success': True, 'data': result['data']})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/analytics/top-menu-items', methods=['GET'])
@login_required
def top_menu_items():
    """Complex query - Most ordered menu items"""
    try:
        limit = request.args.get('limit', 10)
        
        query = """
            SELECT 
                mi.item_id,
                mi.item_name,
                mi.category,
                mi.price,
                SUM(oi.quantity) AS total_ordered,
                SUM(oi.subtotal) AS total_revenue,
                COUNT(DISTINCT oi.order_id) AS order_count
            FROM Order_Items oi
            JOIN Menu_Items mi ON oi.item_id = mi.item_id
            JOIN Orders o ON oi.order_id = o.order_id
            WHERE o.status IN ('Completed', 'Delivered')
            GROUP BY mi.item_id, mi.item_name, mi.category, mi.price
            ORDER BY total_ordered DESC
            LIMIT %s
        """
        
        result = execute_query(query, (limit,))
        
        if result['success']:
            return jsonify({'success': True, 'data': result['data']})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/analytics/delivery-performance', methods=['GET'])
@login_required
def delivery_performance():
    """Complex query - Delivery cost vs revenue analysis"""
    try:
        query = """
            SELECT 
                o.order_id,
                o.order_date,
                o.total_amount AS revenue,
                CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
                CONCAT(da_staff.first_name, ' ', da_staff.last_name) AS driver_name,
                s.hourly_wage * 0.75 AS estimated_delivery_cost,
                (o.total_amount - (s.hourly_wage * 0.75)) AS net_profit
            FROM Orders o
            JOIN Customers c ON o.customer_id = c.customer_id
            LEFT JOIN Delivery_Agents da ON o.delivery_agent_id = da.agent_id
            LEFT JOIN Staff da_staff ON da.staff_id = da_staff.staff_id
            LEFT JOIN Staff s ON da.staff_id = s.staff_id
            WHERE o.order_type = 'Delivery'
            AND o.status IN ('Delivered', 'Completed')
            ORDER BY o.order_date DESC
            LIMIT 50
        """
        
        result = execute_query(query)
        
        if result['success']:
            # Convert datetime to string
            for row in result['data']:
                if 'order_date' in row and row['order_date']:
                    row['order_date'] = row['order_date'].strftime('%Y-%m-%d %H:%M:%S')
            return jsonify({'success': True, 'data': result['data']})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# HELPER ROUTES
# ============================================

@app.route('/api/locations', methods=['GET'])
@login_required
def get_locations():
    """Get all restaurant locations"""
    try:
        query = "SELECT * FROM Restaurant_Locations ORDER BY location_name"
        result = execute_query(query)
        
        if result['success']:
            return jsonify({'success': True, 'data': result['data']})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/staff', methods=['GET'])
@login_required
def get_staff():
    """Get all staff members"""
    try:
        role = request.args.get('role', '')
        
        if role:
            query = """
                SELECT s.*, rl.location_name 
                FROM Staff s
                JOIN Restaurant_Locations rl ON s.location_id = rl.location_id
                WHERE s.role = %s AND s.status = 'Active'
                ORDER BY s.first_name
            """
            result = execute_query(query, (role,))
        else:
            query = """
                SELECT s.*, rl.location_name 
                FROM Staff s
                JOIN Restaurant_Locations rl ON s.location_id = rl.location_id
                WHERE s.status = 'Active'
                ORDER BY s.role, s.first_name
            """
            result = execute_query(query)
        
        if result['success']:
            return jsonify({'success': True, 'data': result['data']})
        else:
            return jsonify({'success': False, 'message': result['message']}), 400
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

# ============================================
# ERROR HANDLERS
# ============================================

@app.errorhandler(404)
def not_found(error):
    return jsonify({'success': False, 'message': 'Resource not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'success': False, 'message': 'Internal server error'}), 500

# ============================================
# MAIN
# ============================================

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5002)