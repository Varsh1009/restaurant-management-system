from flask import Flask, render_template, request, redirect, url_for, session, flash, make_response
from app.config import Config
from app.auth import Auth, login_required, role_required
from app.models import (OrderModel, CustomerModel, InventoryModel, MenuModel, 
                       TableModel, ReservationModel, DeliveryModel, 
                       DashboardModel, ReportModel,
                       StaffModel, ShiftModel, VehicleModel)  
from app.database import Database
from datetime import date
import csv
from io import StringIO
import traceback  
app = Flask(__name__)
app.config.from_object(Config)

# ==================== AUTH ROUTES ====================

@app.route('/')
def index():
    # Check if customer is logged in
    if 'customer' in session:
        return redirect(url_for('customer_menu'))
    # Check if staff is logged in
    if 'user' in session:
        return redirect(url_for('dashboard'))
    # ✅ FIXED: Go to unified login page first
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        try:
            login_type = request.form.get('login_type', 'staff')
            print(f"=== LOGIN TYPE: {login_type} ===")  # DEBUG
            
            if login_type == 'staff':
                # STAFF LOGIN
                username = request.form.get('username', '').strip()
                password = request.form.get('password', '').strip()
                
                print(f"Staff login attempt: {username}")  # DEBUG
                
                if not username or not password:
                    flash('Please enter both username and password', 'danger')
                    return render_template('login.html')
                
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
                    print(f"Staff login successful")  # DEBUG
                    return redirect(url_for('dashboard'))
                else:
                    flash('Invalid staff username or password', 'danger')
                    print("Staff login failed")  # DEBUG
            
            else:
                # CUSTOMER LOGIN
                email = request.form.get('email', '').strip()
                phone = request.form.get('phone_number', '').strip()
                
                print(f"Customer login: {email}, {phone}")  # DEBUG
                
                if not email or not phone:
                    flash('Please enter both email and phone number', 'danger')
                    return render_template('login.html')
                
                customers = CustomerModel.get_all()
                customer = None
                
                for c in customers:
                    if c['email'].lower() == email.lower() and c['phone_number'] == phone:
                        customer = c
                        break
                
                if customer:
                    session['customer'] = {
                        'customer_id': customer['customer_id'],
                        'first_name': customer['first_name'],
                        'email': customer['email']
                    }
                    flash(f"Welcome back, {customer['first_name']}!", 'success')
                    print("Customer login successful")  # DEBUG
                    return redirect(url_for('customer_menu'))
                else:
                    flash('Invalid customer email or phone. Try again or sign up.', 'danger')
                    print("Customer login failed")  # DEBUG
        
        except Exception as e:
            print(f"Login error: {e}")  # DEBUG
            traceback.print_exc()
            flash(f'Login error: {str(e)}', 'danger')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('Logged out successfully', 'info')
    return redirect(url_for('login'))

# ==================== DASHBOARD ====================

@app.route('/dashboard')
@login_required
def dashboard():
    try:
        user = session['user']
        location_id = user['location_id']
        
        stats = DashboardModel.get_stats(location_id)
        recent_orders = DashboardModel.get_recent_orders(location_id, 10)
        
        return render_template('dashboard.html', user=user, stats=stats, recent_orders=recent_orders)
    
    except Exception as e:
        flash(f'Error loading dashboard: {str(e)}', 'danger')
        return redirect(url_for('login'))

# ==================== ORDERS ====================

@app.route('/orders')
@login_required
def orders_list():
    try:
        location_id = session['user']['location_id']
        orders = OrderModel.get_all_by_location(location_id)
        return render_template('orders/list.html', orders=orders)
    
    except Exception as e:
        flash(f'Error loading orders: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

@app.route('/orders/new', methods=['GET', 'POST'])
@login_required
def new_order():
    try:
        location_id = session['user']['location_id']
        
        if request.method == 'POST':
            try:
                customer_id = request.form['customer_id']
                order_type = request.form['order_type']
                table_id = request.form.get('table_id') if order_type == 'Dine-In' else None
                delivery_address = request.form.get('delivery_address') if order_type == 'Delivery' else None
                
                order_id = OrderModel.create(
                    customer_id, location_id, order_type, 
                    table_id, delivery_address, session['user']['staff_id']
                )
                
                flash(f'Order #{order_id} created!', 'success')
                return redirect(url_for('add_items', order_id=order_id))
            
            except Exception as e:
                flash(f'Error creating order: {str(e)}', 'danger')
        
        customers = CustomerModel.get_all()
        tables = TableModel.get_available(location_id)
        
        return render_template('orders/new.html', customers=customers, tables=tables)
    
    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')
        return redirect(url_for('orders_list'))

@app.route('/orders/<int:order_id>/add-items', methods=['GET', 'POST'])
@login_required
def add_items(order_id):
    try:
        if request.method == 'POST':
            try:
                item_id = request.form['item_id']
                quantity = request.form['quantity']
                special_requests = request.form.get('special_requests', '')
                
                OrderModel.add_item(order_id, item_id, quantity, special_requests)
                flash('Item added!', 'success')
                
                if request.form.get('action') == 'finish':
                    return redirect(url_for('orders_list'))
            
            except Exception as e:
                flash(f'Error adding item: {str(e)}', 'danger')
        
        menu_items = MenuModel.get_all_available()
        order_items = OrderModel.get_items(order_id)
        
        try:
            order_result = Database.execute_query("CALL sp_GetOrderTotal(%s)", (order_id,))
            order = order_result[0] if order_result else {'total_amount': 0}
        except Exception as e:
            flash(f'Error getting order total: {str(e)}', 'warning')
            order = {'total_amount': 0}
        
        return render_template('orders/add_items.html', order_id=order_id, 
                             menu_items=menu_items, order_items=order_items, order=order)
    
    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')
        return redirect(url_for('orders_list'))

@app.route('/orders/<int:order_id>')
@login_required
def view_order(order_id):
    try:
        order = OrderModel.get_by_id(order_id)
        
        if not order:
            flash('Order not found', 'danger')
            return redirect(url_for('orders_list'))
        
        items = OrderModel.get_items(order_id)
        payment = OrderModel.get_payment(order_id)
        
        return render_template('orders/view.html', order=order, items=items, payment=payment)
    
    except Exception as e:
        flash(f'Error viewing order: {str(e)}', 'danger')
        return redirect(url_for('orders_list'))

@app.route('/orders/<int:order_id>/update-status', methods=['POST'])
@login_required
def update_order_status(order_id):
    try:
        new_status = request.form['status']
        OrderModel.update_status(order_id, new_status)
        flash(f'Order status updated to {new_status}', 'success')
    
    except Exception as e:
        flash(f'Error updating status: {str(e)}', 'danger')
    
    return redirect(url_for('view_order', order_id=order_id))

@app.route('/orders/<int:order_id>/complete', methods=['POST'])
@login_required
def complete_order(order_id):
    try:
        payment_method = request.form['payment_method']
        tip_amount = float(request.form.get('tip_amount', 0))
        
        OrderModel.complete(order_id, payment_method, tip_amount)
        flash('Order completed successfully!', 'success')
    
    except Exception as e:
        flash(f'Error completing order: {str(e)}', 'danger')
    
    return redirect(url_for('view_order', order_id=order_id))

@app.route('/orders/<int:order_id>/cancel', methods=['POST'])
@login_required
def cancel_order(order_id):
    try:
        OrderModel.cancel(order_id)
        flash('Order cancelled', 'info')
    
    except Exception as e:
        flash(f'Error cancelling order: {str(e)}', 'danger')
    
    return redirect(url_for('orders_list'))

# ==================== CUSTOMERS ====================

@app.route('/customers')
@login_required
def customers_list():
    try:
        customers = CustomerModel.get_all()
        return render_template('customers/list.html', customers=customers)
    
    except Exception as e:
        flash(f'Error loading customers: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

@app.route('/customers/new', methods=['GET', 'POST'])
@login_required
def new_customer():
    if request.method == 'POST':
        try:
            CustomerModel.create(
                request.form['first_name'],
                request.form['last_name'],
                request.form['email'],
                request.form['phone_number'],
                request.form.get('address', ''),
                request.form.get('city', ''),
                request.form.get('state', ''),
                request.form.get('zip_code', '')
            )
            flash('Customer added!', 'success')
            return redirect(url_for('customers_list'))
        
        except Exception as e:
            flash(f'Error adding customer: {str(e)}', 'danger')
    
    return render_template('customers/new.html')

@app.route('/customers/<int:customer_id>/edit', methods=['GET', 'POST'])
@login_required
def edit_customer(customer_id):
    try:
        if request.method == 'POST':
            try:
                CustomerModel.update(
                    customer_id,
                    request.form['first_name'],
                    request.form['last_name'],
                    request.form['email'],
                    request.form['phone_number'],
                    request.form.get('address', ''),
                    request.form.get('city', ''),
                    request.form.get('state', ''),
                    request.form.get('zip_code', '')
                )
                flash('Customer updated!', 'success')
                return redirect(url_for('customers_list'))
            
            except Exception as e:
                flash(f'Error updating customer: {str(e)}', 'danger')
        
        customer = CustomerModel.get_by_id(customer_id)
        
        if not customer:
            flash('Customer not found', 'danger')
            return redirect(url_for('customers_list'))
        
        return render_template('customers/edit.html', customer=customer)
    
    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')
        return redirect(url_for('customers_list'))

@app.route('/customers/<int:customer_id>/delete', methods=['POST'])
@role_required('Manager')
def delete_customer(customer_id):
    try:
        CustomerModel.delete(customer_id)
        flash('Customer deleted', 'info')
    
    except Exception as e:
        flash(f'Error deleting customer: {str(e)}', 'danger')
    
    return redirect(url_for('customers_list'))

# ==================== INVENTORY FULL CRUD ====================

@app.route('/inventory')
@role_required('Manager')
def inventory_list():
    try:
        location_id = session['user']['location_id']
        low_stock = InventoryModel.get_low_stock(location_id)
        inventory = InventoryModel.get_by_location(location_id)
        
        return render_template('inventory/list.html', low_stock=low_stock, inventory=inventory)
    
    except Exception as e:
        flash(f'Error loading inventory: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

@app.route('/inventory/new', methods=['GET', 'POST'])
@role_required('Manager')
def new_inventory():
    """✅ NEW: Add inventory item"""
    try:
        if request.method == 'POST':
            try:
                location_id = session['user']['location_id']
                
                InventoryModel.create(
                    location_id,
                    request.form['item_name'],
                    request.form['category'],
                    float(request.form['quantity']),
                    request.form['unit'],
                    float(request.form['minimum_stock_level']),
                    request.form.get('supplier_name', ''),
                    float(request.form.get('unit_cost', 0))
                )
                
                flash('Inventory item added!', 'success')
                return redirect(url_for('inventory_list'))
            
            except Exception as e:
                flash(f'Error adding inventory: {str(e)}', 'danger')
        
        return render_template('inventory/new.html')
    
    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')
        return redirect(url_for('inventory_list'))

@app.route('/inventory/<int:inventory_id>/edit', methods=['GET', 'POST'])
@role_required('Manager')
def edit_inventory(inventory_id):
    """✅ NEW: Edit inventory item"""
    try:
        if request.method == 'POST':
            try:
                InventoryModel.update_item(
                    inventory_id,
                    request.form['item_name'],
                    request.form['category'],
                    float(request.form['quantity']),
                    request.form['unit'],
                    float(request.form['minimum_stock_level']),
                    request.form.get('supplier_name', ''),
                    float(request.form.get('unit_cost', 0))
                )
                
                flash('Inventory item updated!', 'success')
                return redirect(url_for('inventory_list'))
            
            except Exception as e:
                flash(f'Error updating inventory: {str(e)}', 'danger')
        
        item = InventoryModel.get_by_id(inventory_id)
        
        if not item:
            flash('Inventory item not found', 'danger')
            return redirect(url_for('inventory_list'))
        
        return render_template('inventory/edit.html', item=item)
    
    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')
        return redirect(url_for('inventory_list'))

@app.route('/inventory/<int:inventory_id>/update', methods=['POST'])
@role_required('Manager')
def update_inventory(inventory_id):
    """Restock inventory (quick update)"""
    try:
        quantity = float(request.form['quantity'])
        InventoryModel.restock(inventory_id, quantity)
        flash('Inventory updated!', 'success')
    
    except Exception as e:
        flash(f'Error updating inventory: {str(e)}', 'danger')
    
    return redirect(url_for('inventory_list'))

@app.route('/inventory/<int:inventory_id>/delete', methods=['POST'])
@role_required('Manager')
def delete_inventory(inventory_id):
    """✅ NEW: Delete inventory item"""
    try:
        InventoryModel.delete(inventory_id)
        flash('Inventory item deleted', 'info')
    
    except Exception as e:
        flash(f'Error deleting inventory: {str(e)}', 'danger')
    
    return redirect(url_for('inventory_list'))

# ==================== DELIVERIES ====================

@app.route('/deliveries')
@role_required('Coordinator')
def deliveries():
    try:
        location_id = session['user']['location_id']
        deliveries = DeliveryModel.get_all_by_location(location_id)
        drivers = DeliveryModel.get_available_drivers(location_id)
        
        return render_template('deliveries.html', deliveries=deliveries, drivers=drivers)
    
    except Exception as e:
        flash(f'Error loading deliveries: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

@app.route('/deliveries/<int:order_id>/assign', methods=['POST'])
@role_required('Coordinator')
def assign_driver(order_id):
    try:
        OrderModel.assign_delivery(order_id)
        flash('Driver assigned successfully!', 'success')
    
    except Exception as e:
        flash(f'Error assigning driver: {str(e)}', 'danger')
    
    return redirect(url_for('deliveries'))

# ==================== REPORTS ====================

@app.route('/reports')
@role_required('Manager')
def reports():
    try:
        location_id = session['user']['location_id']
        
        channel_data = ReportModel.get_revenue_by_channel(location_id)
        daily_trend = ReportModel.get_daily_trend(location_id)
        top_items = ReportModel.get_top_items(location_id)
        top_customers = ReportModel.get_top_customers()
        
        return render_template('reports/home.html', 
                             channel_data=channel_data,
                             daily_trend=daily_trend,
                             top_customers=top_customers,
                             top_items=top_items)
    
    except Exception as e:
        flash(f'Error loading reports: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

# ==================== EXPORT ROUTES ====================

@app.route('/reports/export-revenue-csv')
@role_required('Manager')
def export_revenue_csv():
    try:
        location_id = session['user']['location_id']
        channel_data = ReportModel.get_revenue_by_channel(location_id)
        
        si = StringIO()
        writer = csv.writer(si)
        writer.writerow(['Order Type', 'Total Revenue', 'Order Count', 'Average Order Value'])
        
        for row in channel_data:
            writer.writerow([row['order_type'], f"${row['revenue']:.2f}",
                           row['order_count'], f"${row['avg_order_value']:.2f}"])
        
        output = make_response(si.getvalue())
        output.headers["Content-Disposition"] = "attachment; filename=revenue_by_channel.csv"
        output.headers["Content-type"] = "text/csv"
        return output
    
    except Exception as e:
        flash(f'Error exporting: {str(e)}', 'danger')
        return redirect(url_for('reports'))

@app.route('/reports/export-items-csv')
@role_required('Manager')
def export_items_csv():
    try:
        location_id = session['user']['location_id']
        top_items = ReportModel.get_top_items(location_id)
        
        si = StringIO()
        writer = csv.writer(si)
        writer.writerow(['Rank', 'Item Name', 'Quantity Sold', 'Total Revenue'])
        
        for idx, row in enumerate(top_items, 1):
            writer.writerow([idx, row['item_name'], row['total_quantity'],
                           f"${row['total_revenue']:.2f}"])
        
        output = make_response(si.getvalue())
        output.headers["Content-Disposition"] = "attachment; filename=top_selling_items.csv"
        output.headers["Content-type"] = "text/csv"
        return output
    
    except Exception as e:
        flash(f'Error exporting: {str(e)}', 'danger')
        return redirect(url_for('reports'))

@app.route('/reports/export-customers-csv')
@role_required('Manager')
def export_customers_csv():
    try:
        top_customers = ReportModel.get_top_customers()
        
        si = StringIO()
        writer = csv.writer(si)
        writer.writerow(['Rank', 'Name', 'Loyalty Points', 'Total Orders'])
        
        for idx, row in enumerate(top_customers, 1):
            writer.writerow([idx, f"{row['first_name']} {row['last_name']}",
                           row['loyalty_points'], row['total_orders']])
        
        output = make_response(si.getvalue())
        output.headers["Content-Disposition"] = "attachment; filename=top_customers.csv"
        output.headers["Content-type"] = "text/csv"
        return output
    
    except Exception as e:
        flash(f'Error exporting: {str(e)}', 'danger')
        return redirect(url_for('reports'))

@app.route('/inventory/export-csv')
@role_required('Manager')
def export_inventory_csv():
    try:
        location_id = session['user']['location_id']
        inventory = InventoryModel.get_by_location(location_id)
        
        si = StringIO()
        writer = csv.writer(si)
        writer.writerow(['Item', 'Category', 'Quantity', 'Unit', 'Min Stock', 
                        'Stock %', 'Supplier', 'Unit Cost'])
        
        for row in inventory:
            writer.writerow([row['item_name'], row['category'], row['quantity'],
                           row['unit'], row['minimum_stock_level'],
                           f"{row['stock_percentage']:.1f}%",
                           row.get('supplier_name', 'N/A'),
                           f"${row['unit_cost']:.2f}"])
        
        output = make_response(si.getvalue())
        output.headers["Content-Disposition"] = "attachment; filename=inventory.csv"
        output.headers["Content-type"] = "text/csv"
        return output
    
    except Exception as e:
        flash(f'Error exporting: {str(e)}', 'danger')
        return redirect(url_for('inventory_list'))

@app.route('/customers/export-csv')
@role_required('Manager')
def export_customers_all_csv():
    try:
        customers = CustomerModel.get_all()
        
        si = StringIO()
        writer = csv.writer(si)
        writer.writerow(['ID', 'First Name', 'Last Name', 'Email', 'Phone', 'Loyalty Points'])
        
        for row in customers:
            writer.writerow([row['customer_id'], row['first_name'], row['last_name'],
                           row['email'], row['phone_number'], row['loyalty_points']])
        
        output = make_response(si.getvalue())
        output.headers["Content-Disposition"] = "attachment; filename=all_customers.csv"
        output.headers["Content-type"] = "text/csv"
        return output
    
    except Exception as e:
        flash(f'Error exporting: {str(e)}', 'danger')
        return redirect(url_for('customers_list'))

# ==================== RESERVATIONS ====================

@app.route('/reservations')
@login_required
def reservations_list():
    try:
        location_id = session['user']['location_id']
        reservations = ReservationModel.get_all(location_id)  # ✅ FIXED: Use get_all instead of get_upcoming
        
        return render_template('reservations/list.html', reservations=reservations)
    
    except Exception as e:
        flash(f'Error loading reservations: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

@app.route('/reservations/new', methods=['GET', 'POST'])
@login_required
def new_reservation():
    try:
        location_id = session['user']['location_id']
        
        if request.method == 'POST':
            try:
                ReservationModel.create(
                    request.form['customer_id'],
                    request.form['table_id'],
                    request.form['reservation_date'],
                    request.form['reservation_time'],
                    request.form['party_size'],
                    request.form.get('special_requests', '')
                )
                flash('Reservation created!', 'success')
                return redirect(url_for('reservations_list'))
            
            except Exception as e:
                flash(f'Error creating reservation: {str(e)}', 'danger')
        
        customers = CustomerModel.get_all()
        tables = TableModel.get_by_location(location_id)
        today = date.today().isoformat()
        
        return render_template('reservations/new.html', customers=customers, tables=tables, today=today)
    
    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')
        return redirect(url_for('reservations_list'))

# ==================== STAFF VIEW ====================

@app.route('/staff')
@role_required('Manager')
def staff_list():
    """✅ NEW: View all staff"""
    try:
        staff = StaffModel.get_all()
        return render_template('staff/list.html', staff=staff)
    
    except Exception as e:
        flash(f'Error loading staff: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

# ==================== SHIFTS VIEW ====================

@app.route('/shifts')
@role_required('Manager')
def shifts_list():
    """✅ NEW: View shifts schedule"""
    try:
        location_id = session['user']['location_id']
        shifts = ShiftModel.get_upcoming(location_id)
        return render_template('shifts/list.html', shifts=shifts)
    
    except Exception as e:
        flash(f'Error loading shifts: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

# ==================== VEHICLES VIEW ====================

@app.route('/vehicles')
@role_required(['Manager', 'Coordinator'])  # ✅ CHANGED: Allow Coordinator access
def vehicles_list():
    """ View all vehicles"""
    try:
        vehicles = VehicleModel.get_all()
        return render_template('vehicles/list.html', vehicles=vehicles)
    
    except Exception as e:
        flash(f'Error loading vehicles: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

# ==================== DELIVERY AGENTS VIEW ====================

@app.route('/delivery-agents')
@role_required(['Manager', 'Coordinator'])  
def delivery_agents_list():
    """✅ NEW: View all delivery agents"""
    try:
        agents = DeliveryModel.get_all_agents()
        return render_template('delivery_agents/list.html', agents=agents)
    
    except Exception as e:
        flash(f'Error loading delivery agents: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

# ==================== CUSTOMER PORTAL ====================

@app.route('/customer')
def customer_home():
    """✅ NEW: Customer homepage"""
    return render_template('customer/home.html')

@app.route('/customer/signup', methods=['GET', 'POST'])
def customer_signup():
    """✅ NEW: Customer signup"""
    if request.method == 'POST':
        try:
            customer_id = CustomerModel.create(
                request.form['first_name'],
                request.form['last_name'],
                request.form['email'],
                request.form['phone_number'],
                request.form.get('address', ''),
                request.form.get('city', ''),
                request.form.get('state', ''),
                request.form.get('zip_code', '')
            )
            
            # Auto-login after signup
            session['customer'] = {
                'customer_id': customer_id,
                'first_name': request.form['first_name'],
                'email': request.form['email']
            }
            
            flash(f"Welcome {request.form['first_name']}! Account created!", 'success')
            return redirect(url_for('customer_menu'))
        
        except Exception as e:
            flash(f'Error creating account: {str(e)}', 'danger')
    
    return render_template('customer/signup.html')



@app.route('/customer/logout')
def customer_logout():
    """✅ NEW: Customer logout"""
    session.pop('customer', None)
    flash('Logged out successfully', 'info')
    return redirect(url_for('customer_home'))

@app.route('/menu')
def customer_menu():
    try:
        items = MenuModel.get_all_available()
        
        menu = {}
        for item in items:
            category = item['category']
            if category not in menu:
                menu[category] = []
            menu[category].append(item)
        
        return render_template('customer/menu.html', menu=menu)
    
    except Exception as e:
        flash(f'Error loading menu: {str(e)}', 'danger')
        return redirect(url_for('customer_home'))

@app.route('/menu/add-to-cart', methods=['POST'])
def add_to_cart():
    try:
        if 'cart' not in session:
            session['cart'] = []
        
        item = {
            'item_id': request.form['item_id'],
            'item_name': request.form['item_name'],
            'price': float(request.form['price']),
            'quantity': int(request.form.get('quantity', 1))
        }
        
        found = False
        for cart_item in session['cart']:
            if cart_item['item_id'] == item['item_id']:
                cart_item['quantity'] += item['quantity']
                found = True
                break
        
        if not found:
            session['cart'].append(item)
        
        session.modified = True
        flash('Item added to cart!', 'success')
    
    except Exception as e:
        flash(f'Error adding to cart: {str(e)}', 'danger')
    
    return redirect(url_for('customer_menu'))

@app.route('/cart')
def view_cart():
    try:
        cart = session.get('cart', [])
        total = sum(item['price'] * item['quantity'] for item in cart)
        return render_template('customer/cart.html', cart=cart, total=total)
    
    except Exception as e:
        flash(f'Error viewing cart: {str(e)}', 'danger')
        return redirect(url_for('customer_menu'))

@app.route('/checkout', methods=['GET', 'POST'])
def checkout():
    print("=== CHECKOUT ROUTE CALLED ===")  # DEBUG
    try:
        cart = session.get('cart', [])
        print(f"Cart has {len(cart)} items")  # DEBUG
        
        if not cart:
            flash('Your cart is empty!', 'warning')
            return redirect(url_for('customer_menu'))
        
        if request.method == 'POST':
            print("=== POST REQUEST ===")  # DEBUG
            print(f"Form keys: {list(request.form.keys())}")  # DEBUG
            
            try:
                customer_id = request.form.get('customer_id', '').strip()
                print(f"Customer ID from form: '{customer_id}'")  # DEBUG
                
                # Create/Find Customer
                if not customer_id:
                    print("No customer selected, creating new...")  # DEBUG
                    
                    try:
                        email = request.form.get('email', '').strip()
                        phone = request.form.get('phone_number', '').strip()
                        first_name = request.form.get('first_name', '').strip()
                        last_name = request.form.get('last_name', '').strip()
                        
                        print(f"New customer data: {first_name} {last_name}, {email}, {phone}")  # DEBUG
                        
                        # Validate required fields
                        if not all([first_name, last_name, email, phone]):
                            flash('Please fill in all required customer fields', 'danger')
                            raise ValueError("Missing required customer fields")
                        
                        # Check for existing customer by email
                        customers = CustomerModel.get_all()
                        existing = None
                        for c in customers:
                            if c['email'].lower() == email.lower():
                                existing = c
                                break
                        
                        if existing:
                            customer_id = existing['customer_id']
                            print(f"Using existing customer ID: {customer_id}")  # DEBUG
                            flash(f'Welcome back, {existing["first_name"]}!', 'info')
                        else:
                            # Create new customer
                            print("Calling CustomerModel.create()...")  # DEBUG
                            customer_id = CustomerModel.create(
                                first_name,
                                last_name,
                                email,
                                phone,
                                request.form.get('address', ''),
                                request.form.get('city', ''),
                                request.form.get('state', ''),
                                request.form.get('zip_code', '')
                            )
                            print(f"New customer created with ID: {customer_id}")  # DEBUG
                            flash('Account created!', 'success')
                    
                    except Exception as e:
                        print(f"ERROR in customer creation: {e}")  # DEBUG
                        import traceback
                        traceback.print_exc()
                        flash(f'Error creating customer: {str(e)}', 'danger')
                        raise
                
                print(f"Using customer_id: {customer_id}")  # DEBUG
                
                # Get order details
                order_type = request.form.get('order_type', '').strip()
                delivery_address = request.form.get('delivery_address', '').strip() if order_type == 'Delivery' else None
                
                print(f"Order type: {order_type}")  # DEBUG
                
                # Validate order type
                if not order_type:
                    flash('Please select order type (Pickup or Delivery)', 'danger')
                    raise ValueError("Missing order type")
                
                # Create Order - Use SIMPLE SQL INSERT instead of problematic OUT parameter
                try:
                    print("Creating order with direct SQL...")  # DEBUG
                    
                    connection = Database.get_connection()
                    cursor = connection.cursor()
                    
                    # Direct INSERT
                    cursor.execute("""
                        INSERT INTO Orders (customer_id, location_id, order_type, total_amount, delivery_address, status)
                        VALUES (%s, 1, %s, 0.00, %s, 'Pending')
                    """, (customer_id, order_type, delivery_address))
                    
                    order_id = cursor.lastrowid
                    print(f"Order created with ID: {order_id}")  # DEBUG
                    
                    connection.commit()
                    cursor.close()
                    connection.close()
                    
                except Exception as e:
                    print(f"ERROR creating order: {e}")  # DEBUG
                    traceback.print_exc()
                    flash(f'Error creating order: {str(e)}', 'danger')
                    raise
                
                # Add Items to Order
                try:
                    print(f"Adding {len(cart)} items to order {order_id}...")  # DEBUG
                    
                    for idx, item in enumerate(cart):
                        print(f"Item {idx+1}: {item['item_name']} x {item['quantity']}")  # DEBUG
                        
                        Database.execute_query("""
                            CALL sp_AddCustomerOrderItem(%s, %s, %s, %s)
                        """, (order_id, item['item_id'], item['quantity'], item['price']), fetch=False)
                    
                    print("All items added successfully!")  # DEBUG
                    
                except Exception as e:
                    print(f"ERROR adding items: {e}")  # DEBUG
                    traceback.print_exc()
                    flash(f'Error adding items: {str(e)}', 'danger')
                    raise
                
                # Success!
                session.pop('cart', None)
                print(f"=== ORDER {order_id} COMPLETED SUCCESSFULLY ===")  # DEBUG
                
                flash(f'Order #{order_id} placed successfully!', 'success')
                return redirect(url_for('order_confirmation', order_id=order_id))
            
            except Exception as e:
                print(f"=== CHECKOUT ERROR: {e} ===")  # DEBUG
                flash(f'Error during checkout: {str(e)}', 'danger')
        
        # GET request - show checkout form
        try:
            customers = CustomerModel.get_all()
        except Exception as e:
            flash(f'Error loading customers: {str(e)}', 'warning')
            customers = []
        
        total = sum(item['price'] * item['quantity'] for item in cart)
        
        return render_template('customer/checkout.html', cart=cart, total=total, customers=customers)
    
    except Exception as e:
        print(f"=== OUTER ERROR: {e} ===")  # DEBUG
        import traceback
        traceback.print_exc()
        flash(f'Error in checkout: {str(e)}', 'danger')
        return redirect(url_for('customer_menu'))

@app.route('/order/<int:order_id>/confirmation')
def order_confirmation(order_id):
    try:
        order = OrderModel.get_by_id(order_id)
        
        if not order:
            flash('Order not found', 'danger')
            return redirect(url_for('customer_menu'))
        
        return render_template('customer/confirmation.html', order=order)
    
    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')
        return redirect(url_for('customer_menu'))

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5002)