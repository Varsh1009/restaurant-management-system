from flask import Flask, render_template, request, redirect, url_for, session, flash
from app.config import Config
from app.auth import Auth, login_required, role_required
from app.models import (OrderModel, CustomerModel, InventoryModel, MenuModel, 
                       TableModel, ReservationModel, DeliveryModel, 
                       DashboardModel, ReportModel)
from app.database import Database
from datetime import date

app = Flask(__name__)
app.config.from_object(Config)

# ==================== AUTH ROUTES ====================

@app.route('/')
def index():
    if 'user' in session:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        try:
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
        except Exception as e:
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
        
        # Get stats using stored procedure
        stats = DashboardModel.get_stats(location_id)
        
        # Get recent orders using stored procedure
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
        
        # Get orders using stored procedure
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
                
                # Create order using stored procedure
                order_id = OrderModel.create(
                    customer_id, location_id, order_type, 
                    table_id, delivery_address, session['user']['staff_id']
                )
                
                flash(f'Order #{order_id} created!', 'success')
                return redirect(url_for('add_items', order_id=order_id))
            
            except Exception as e:
                flash(f'Error creating order: {str(e)}', 'danger')
        
        # Get customers using stored procedure
        customers = CustomerModel.get_all()
        
        # Get available tables using stored procedure
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
                
                # Add item using stored procedure
                OrderModel.add_item(order_id, item_id, quantity, special_requests)
                flash('Item added!', 'success')
                
                if request.form.get('action') == 'finish':
                    return redirect(url_for('orders_list'))
            
            except Exception as e:
                flash(f'Error adding item: {str(e)}', 'danger')
        
        # Get menu items using stored procedure
        menu_items = MenuModel.get_all_available()
        
        # Get current order items using stored procedure
        order_items = OrderModel.get_items(order_id)
        
        # Get order total (simple query for display)
        try:
            order_result = Database.execute_query("SELECT total_amount FROM Orders WHERE order_id = %s", (order_id,))
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
        # Get order details using stored procedure
        order = OrderModel.get_by_id(order_id)
        
        if not order:
            flash('Order not found', 'danger')
            return redirect(url_for('orders_list'))
        
        # Get order items using stored procedure
        items = OrderModel.get_items(order_id)
        
        # Get payment using stored procedure
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
        
        # Update using stored procedure
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
        
        # Complete using stored procedure
        OrderModel.complete(order_id, payment_method, tip_amount)
        flash('Order completed successfully!', 'success')
    
    except Exception as e:
        flash(f'Error completing order: {str(e)}', 'danger')
    
    return redirect(url_for('view_order', order_id=order_id))

@app.route('/orders/<int:order_id>/cancel', methods=['POST'])
@login_required
def cancel_order(order_id):
    try:
        # Cancel using stored procedure
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
        # Get customers using stored procedure
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
            # Create customer using stored procedure
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
                # Update customer using stored procedure
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
        
        # Get customer using stored procedure
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
        # Delete customer using stored procedure
        CustomerModel.delete(customer_id)
        flash('Customer deleted', 'info')
    
    except Exception as e:
        flash(f'Error deleting customer: {str(e)}', 'danger')
    
    return redirect(url_for('customers_list'))

# ==================== INVENTORY ====================

@app.route('/inventory')
@role_required('Manager')
def inventory_list():
    try:
        location_id = session['user']['location_id']
        
        # Get low stock using stored procedure
        low_stock = InventoryModel.get_low_stock(location_id)
        
        # Get all inventory using stored procedure
        inventory = InventoryModel.get_by_location(location_id)
        
        return render_template('inventory/list.html', low_stock=low_stock, inventory=inventory)
    
    except Exception as e:
        flash(f'Error loading inventory: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

@app.route('/inventory/<int:inventory_id>/update', methods=['POST'])
@role_required('Manager')
def update_inventory(inventory_id):
    try:
        quantity = float(request.form['quantity'])
        
        # Restock using stored procedure
        InventoryModel.restock(inventory_id, quantity)
        flash('Inventory updated!', 'success')
    
    except Exception as e:
        flash(f'Error updating inventory: {str(e)}', 'danger')
    
    return redirect(url_for('inventory_list'))

# ==================== DELIVERIES ====================

@app.route('/deliveries')
@role_required('Coordinator')
def deliveries():
    try:
        location_id = session['user']['location_id']
        
        # Get deliveries using stored procedure
        deliveries = DeliveryModel.get_all_by_location(location_id)
        
        # Get available drivers using stored procedure
        drivers = DeliveryModel.get_available_drivers(location_id)
        
        return render_template('deliveries.html', deliveries=deliveries, drivers=drivers)
    
    except Exception as e:
        flash(f'Error loading deliveries: {str(e)}', 'danger')
        return redirect(url_for('dashboard'))

@app.route('/deliveries/<int:order_id>/assign', methods=['POST'])
@role_required('Coordinator')
def assign_driver(order_id):
    try:
        # Assign driver using stored procedure
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
        
        # Get all report data using stored procedures
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

# ==================== RESERVATIONS ====================

@app.route('/reservations')
@login_required
def reservations_list():
    try:
        location_id = session['user']['location_id']
        
        # Get reservations using stored procedure
        reservations = ReservationModel.get_upcoming(location_id)
        
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
                # Create reservation using stored procedure
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
        
        # Get customers using stored procedure
        customers = CustomerModel.get_all()
        
        # Get tables using stored procedure
        tables = TableModel.get_by_location(location_id)
        
        today = date.today().isoformat()
        
        return render_template('reservations/new.html', customers=customers, tables=tables, today=today)
    
    except Exception as e:
        flash(f'Error: {str(e)}', 'danger')
        return redirect(url_for('reservations_list'))

# ==================== CUSTOMER PORTAL ====================

@app.route('/menu')
def customer_menu():
    try:
        # Get menu using stored procedure
        items = MenuModel.get_all_available()
        
        # Group by category
        menu = {}
        for item in items:
            category = item['category']
            if category not in menu:
                menu[category] = []
            menu[category].append(item)
        
        return render_template('customer/menu.html', menu=menu)
    
    except Exception as e:
        flash(f'Error loading menu: {str(e)}', 'danger')
        return render_template('error.html', error=str(e)) if app.debug else redirect(url_for('index'))

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
        
        # Check if item already in cart
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
    try:
        cart = session.get('cart', [])
        if not cart:
            flash('Your cart is empty!', 'warning')
            return redirect(url_for('customer_menu'))
        
        if request.method == 'POST':
            try:
                customer_id = request.form.get('customer_id')
                
                # Create new customer if needed using stored procedure
                if not customer_id:
                    try:
                        customer_id = CustomerModel.create(
                            request.form['first_name'],
                            request.form['last_name'],
                            request.form['email'],
                            request.form['phone_number'],
                            request.form.get('address', ''),
                            '', '', ''
                        )
                    except Exception as e:
                        flash(f'Error creating customer: {str(e)}', 'danger')
                        raise
                
                # Create order
                order_type = request.form['order_type']
                delivery_address = request.form.get('delivery_address') if order_type == 'Delivery' else None
                total = sum(item['price'] * item['quantity'] for item in cart)
                
                # Insert order (customer portal has no staff_id)
                try:
                    Database.execute_query("""
                        INSERT INTO Orders (customer_id, location_id, order_type, total_amount, delivery_address)
                        VALUES (%s, 1, %s, %s, %s)
                    """, (customer_id, order_type, total, delivery_address), fetch=False)
                    
                    order_id = Database.execute_query("SELECT LAST_INSERT_ID() as id")[0]['id']
                except Exception as e:
                    flash(f'Error creating order: {str(e)}', 'danger')
                    raise
                
                # Add order items
                try:
                    for item in cart:
                        Database.execute_query("""
                            INSERT INTO Order_Items (order_id, item_id, quantity, unit_price, subtotal)
                            VALUES (%s, %s, %s, %s, %s)
                        """, (order_id, item['item_id'], item['quantity'], item['price'], 
                              item['price'] * item['quantity']), fetch=False)
                except Exception as e:
                    flash(f'Error adding items: {str(e)}', 'danger')
                    raise
                
                # Clear cart
                session.pop('cart', None)
                flash(f'Order #{order_id} placed successfully!', 'success')
                return redirect(url_for('order_confirmation', order_id=order_id))
            
            except Exception as e:
                flash(f'Error during checkout: {str(e)}', 'danger')
        
        # Get existing customers using stored procedure
        try:
            customers = CustomerModel.get_all()
        except Exception as e:
            flash(f'Error loading customers: {str(e)}', 'warning')
            customers = []
        
        total = sum(item['price'] * item['quantity'] for item in cart)
        
        return render_template('customer/checkout.html', cart=cart, total=total, customers=customers)
    
    except Exception as e:
        flash(f'Error in checkout: {str(e)}', 'danger')
        return redirect(url_for('customer_menu'))

@app.route('/order/<int:order_id>/confirmation')
def order_confirmation(order_id):
    try:
        # Get order details using stored procedure
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