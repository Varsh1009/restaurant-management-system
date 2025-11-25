from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
from app.config import Config
from app.database import Database
from app.auth import Auth, login_required, role_required
import json
from datetime import datetime, timedelta

app = Flask(__name__, template_folder='../templates', static_folder='../static')
app.config.from_object(Config)

# ==================== AUTH ROUTES ====================

@app.route('/')
def index():
    if Auth.is_authenticated():
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        user = Auth.login_user(username, password)
        
        if user:
            session['user'] = {
                'staff_id': user['staff_id'],
                'username': user['username'],
                'first_name': user['first_name'],
                'last_name': user['last_name'],
                'role': user['role'],
                'location_id': user['location_id'],
                'location_name': user['location_name']
            }
            flash(f'Welcome back, {user["first_name"]}!', 'success')
            return redirect(url_for('dashboard'))
        else:
            flash('Invalid username or password', 'danger')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    Auth.logout_user()
    flash('You have been logged out successfully', 'info')
    return redirect(url_for('login'))

# ==================== DASHBOARD ROUTES ====================

@app.route('/dashboard')
@login_required
def dashboard():
    user = Auth.get_current_user()
    role = user['role']
    
    # Route to appropriate dashboard based on role
    if role == 'Manager':
        return redirect(url_for('manager_dashboard'))
    elif role == 'Coordinator':
        return redirect(url_for('coordinator_dashboard'))
    else:
        return redirect(url_for('staff_dashboard'))

@app.route('/dashboard/manager')
@role_required('Manager')
def manager_dashboard():
    user = Auth.get_current_user()
    location_id = user['location_id']
    
    # Get key metrics
    metrics = get_manager_metrics(location_id)
    
    return render_template('manager_dashboard.html', 
                         user=user, 
                         metrics=metrics)

@app.route('/dashboard/staff')
@login_required
def staff_dashboard():
    user = Auth.get_current_user()
    
    # Get today's orders
    query = """
        SELECT o.order_id, o.order_type, o.status, o.total_amount,
               CONCAT(c.first_name, ' ', c.last_name) as customer_name,
               o.order_date
        FROM Orders o
        JOIN Customers c ON o.customer_id = c.customer_id
        WHERE o.location_id = %s 
        AND DATE(o.order_date) = CURDATE()
        ORDER BY o.order_date DESC
        LIMIT 10
    """
    
    recent_orders = Database.execute_query(query, (user['location_id'],))
    
    return render_template('staff_dashboard.html', 
                         user=user, 
                         recent_orders=recent_orders)

@app.route('/dashboard/coordinator')
@role_required('Coordinator')
def coordinator_dashboard():
    user = Auth.get_current_user()
    
    # Get pending deliveries
    query = """
        SELECT o.order_id, o.delivery_address, o.status,
               CONCAT(c.first_name, ' ', c.last_name) as customer_name,
               o.order_date, o.total_amount,
               CONCAT(s.first_name, ' ', s.last_name) as driver_name,
               da.current_status as driver_status
        FROM Orders o
        JOIN Customers c ON o.customer_id = c.customer_id
        LEFT JOIN Delivery_Agents da ON o.delivery_agent_id = da.agent_id
        LEFT JOIN Staff s ON da.staff_id = s.staff_id
        WHERE o.order_type = 'Delivery' 
        AND o.location_id = %s
        AND o.status IN ('Pending', 'Preparing', 'Ready', 'In Transit')
        ORDER BY o.order_date DESC
    """
    
    deliveries = Database.execute_query(query, (user['location_id'],))
    
    # Get available drivers
    driver_query = """
        SELECT da.agent_id, CONCAT(s.first_name, ' ', s.last_name) as driver_name,
               da.current_status, da.rating, v.vehicle_number, v.vehicle_type
        FROM Delivery_Agents da
        JOIN Staff s ON da.staff_id = s.staff_id
        LEFT JOIN Vehicles v ON da.vehicle_id = v.vehicle_id
        WHERE s.location_id = %s AND s.status = 'Active'
    """
    
    drivers = Database.execute_query(driver_query, (user['location_id'],))
    
    return render_template('coordinator_dashboard.html', 
                         user=user, 
                         deliveries=deliveries,
                         drivers=drivers)

# ==================== HELPER FUNCTIONS ====================

def get_manager_metrics(location_id):
    """Get dashboard metrics for manager"""
    
    # Today's revenue
    revenue_query = """
        SELECT COALESCE(SUM(total_amount), 0) as today_revenue
        FROM Orders
        WHERE location_id = %s 
        AND DATE(order_date) = CURDATE()
        AND status IN ('Completed', 'Delivered')
    """
    today_revenue = Database.execute_query(revenue_query, (location_id,))[0]['today_revenue']
    
    # Today's orders count
    orders_query = """
        SELECT COUNT(*) as today_orders
        FROM Orders
        WHERE location_id = %s AND DATE(order_date) = CURDATE()
    """
    today_orders = Database.execute_query(orders_query, (location_id,))[0]['today_orders']
    
    # Pending orders
    pending_query = """
        SELECT COUNT(*) as pending_orders
        FROM Orders
        WHERE location_id = %s AND status = 'Pending'
    """
    pending_orders = Database.execute_query(pending_query, (location_id,))[0]['pending_orders']
    
    # Low stock items
    low_stock_query = """
        SELECT COUNT(*) as low_stock_count
        FROM Inventory
        WHERE location_id = %s AND quantity < minimum_stock_level
    """
    low_stock = Database.execute_query(low_stock_query, (location_id,))[0]['low_stock_count']
    
    # Revenue by channel (last 7 days)
    channel_query = """
        SELECT order_type, 
               COALESCE(SUM(total_amount), 0) as revenue,
               COUNT(*) as order_count
        FROM Orders
        WHERE location_id = %s 
        AND order_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
        AND status IN ('Completed', 'Delivered')
        GROUP BY order_type
    """
    channel_revenue = Database.execute_query(channel_query, (location_id,))
    
    return {
        'today_revenue': float(today_revenue),
        'today_orders': today_orders,
        'pending_orders': pending_orders,
        'low_stock': low_stock,
        'channel_revenue': channel_revenue
    }

if __name__ == '__main__':
    app.run(debug=True, port=5000)