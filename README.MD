# Restaurant Management System

A comprehensive database-driven web application for managing restaurant operations including orders, customers, inventory, deliveries, and analytics.

**Group:** NarayananSKumariS  
**Course:** CS5200 Database Management Systems  
**Semester:** Fall 2024

---

## 📋 Prerequisites

Before running this application, ensure you have:

- **Python 3.8+** installed ([Download](https://www.python.org/downloads/))
- **MySQL 8.0+** installed and running ([Download](https://dev.mysql.com/downloads/))
- **pip** (Python package installer)
- **Git** (optional, for cloning)

---

## 🚀 Quick Start Guide

### Step 1: Extract Project Files

```bash
# Extract the zip file
unzip NarayananSKumariS_project.zip
cd NarayananSKumariS_project
```

### Step 2: Set Up Database

```bash
# Login to MySQL (you'll be prompted for your MySQL root password)
mysql -u root -p

# Once logged in, exit MySQL
exit

# Import the database dump
mysql -u root -p < database_dump.sql
```

**Note:** When prompted, enter your MySQL root password.

### Step 3: Configure Environment

**Option A: Using .env file (Recommended)**
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env and set your MySQL password
# Example: DB_PASSWORD=your_password_here
nano .env   # or use any text editor
```

**Option B: Modify config.py directly**
```python
# Open app/config.py and update line 18:
DB_PASSWORD = os.environ.get('DB_PASSWORD') or 'YOUR_MYSQL_PASSWORD'
```

### Step 4: Install Python Dependencies

```bash
# Install required packages
pip install -r requirements.txt
```

If you encounter any issues, install packages individually:
```bash
pip install Flask==3.0.0
pip install PyMySQL==1.1.0
pip install python-dotenv==1.0.0
```

### Step 5: Run the Application

```bash
# Start the Flask application
python run.py
```

You should see:
```
* Running on http://0.0.0.0:5002
* Debug mode: on
```

### Step 6: Access the Application

Open your web browser and navigate to:
```
http://localhost:5002
```

---

## 👥 Default Login Credentials

### Staff Accounts:

| Role | Username | Password |
|------|----------|----------|
| **Manager** | sarah.manager | password123 |
| **Waiter** | tom.server | password123 |
| **Coordinator** | alex.coordinator | password123 |

### Customer Portal:
- Access menu at: `http://localhost:5002/menu`
- No login required for browsing
- Create account during checkout

---

## 📁 Project Structure

```
NarayananSKumariS_project/
├── app/
│   ├── __init__.py
│   ├── auth.py              # Authentication & authorization
│   ├── config.py            # Application configuration
│   ├── database.py          # Database connection handler
│   └── models.py            # Data models (all use stored procedures)
├── templates/
│   ├── base.html            # Base template with navigation
│   ├── login.html           # Login page
│   ├── dashboard.html       # Main dashboard
│   ├── deliveries.html      # Delivery management
│   ├── customers/           # Customer management pages
│   │   ├── list.html
│   │   ├── new.html
│   │   └── edit.html
│   ├── orders/              # Order management pages
│   │   ├── list.html
│   │   ├── new.html
│   │   ├── view.html
│   │   └── add_items.html
│   ├── inventory/           # Inventory management
│   │   └── list.html
│   ├── reports/             # Analytics & reports
│   │   └── home.html
│   └── customer/            # Customer-facing portal
│       ├── menu.html
│       ├── cart.html
│       ├── checkout.html
│       └── confirmation.html
├── static/
│   ├── css/
│   │   └── style.css        # Custom CSS (NO Bootstrap)
│   └── js/
│       └── main.js          # JavaScript utilities
├── database_dump.sql        # Complete database schema & data
├── requirements.txt         # Python dependencies
├── run.py                   # Main application entry point
├── .env.example             # Environment variables template
└── README.md                # This file
```

---

## 🛠️ Technical Specifications

### Backend Technologies:
- **Language:** Python 3.8+
- **Framework:** Flask 3.0.0
- **Database:** MySQL 8.0
- **Database Driver:** PyMySQL 1.1.0
- **Environment Management:** python-dotenv 1.0.0

### Frontend Technologies:
- **HTML5** with Jinja2 templating
- **Custom CSS** (No Bootstrap or external CSS frameworks)
- **Vanilla JavaScript** (No jQuery or external JS frameworks)
- **Plotly.js 2.27.0** (for data visualizations)

### Database Design:
- **Tables:** 14 (fully normalized to 3NF)
- **Stored Procedures:** 35
- **Functions:** 4
- **Triggers:** 4
- **Views:** 4
- **Events:** 1

---

## 🎯 Key Features

### For Managers:
- ✅ Dashboard with real-time statistics
- ✅ Customer management (CRUD operations)
- ✅ Order management with search & filters
- ✅ Inventory tracking with low-stock alerts
- ✅ Analytics & reports with interactive charts
- ✅ CSV export functionality (5 different reports)

### For Waiters:
- ✅ Create and manage orders
- ✅ View customer information
- ✅ Add items to orders
- ✅ Process payments

### For Coordinators:
- ✅ View delivery orders
- ✅ Assign drivers to deliveries
- ✅ Track driver status and ratings

### For Customers:
- ✅ Browse menu by category
- ✅ Add items to cart
- ✅ Place pickup or delivery orders
- ✅ Create customer account
- ✅ Order confirmation

---

## 🗄️ Database Schema Overview

### Core Tables:
1. **Restaurant_Locations** - Multi-location support
2. **Customers** - Customer information with loyalty points
3. **Staff** - Employee management with roles
4. **Menu_Items** - Restaurant menu catalog
5. **Orders** - Order management (Dine-In, Pickup, Delivery)
6. **Order_Items** - Order line items
7. **Payments** - Payment processing
8. **Inventory** - Stock management
9. **Tables** - Table/seating management
10. **Reservations** - Table reservation system
11. **Delivery_Agents** - Driver management
12. **Vehicles** - Delivery vehicle tracking
13. **Shifts** - Staff scheduling
14. **User_Credentials** - Authentication

---

## 🔒 Security Features

- ✅ Role-based access control (Manager, Waiter, Coordinator)
- ✅ Session-based authentication
- ✅ Password storage (Note: Uses simple hash for demo - use bcrypt in production)
- ✅ SQL injection prevention (parameterized queries)
- ✅ Input validation (client-side and server-side)

---

## 📊 Analytics & Reporting

- **Revenue by Channel** - Pie chart showing Dine-In vs Pickup vs Delivery
- **Top Selling Items** - Bar chart of best-performing menu items
- **Daily Revenue Trend** - Line chart showing revenue over time
- **Top Customers** - Loyalty program rankings
- **CSV Exports** - Download data for external analysis

---

## 🐛 Troubleshooting

### Database Connection Error

**Error:** `pymysql.err.OperationalError: (2003, "Can't connect to MySQL server")`

**Solution:**
1. Verify MySQL is running: `mysql -u root -p`
2. Check DB_PASSWORD in .env or config.py
3. Verify MySQL is on port 3306: `SHOW VARIABLES LIKE 'port';`

### Import Error / Module Not Found

**Error:** `ModuleNotFoundError: No module named 'flask'`

**Solution:**
```bash
pip install -r requirements.txt
# or
pip install Flask PyMySQL python-dotenv
```

### Stored Procedure Not Found

**Error:** `Procedure 'restaurant_management.sp_GetAllCustomers' doesn't exist`

**Solution:**
1. Verify database was imported correctly
2. Re-run: `mysql -u root -p < database_dump.sql`
3. Check procedures exist: `SHOW PROCEDURE STATUS WHERE Db = 'restaurant_management';`

### Port Already in Use

**Error:** `OSError: [Errno 48] Address already in use`

**Solution:**
```bash
# Find process using port 5002
lsof -i :5002

# Kill the process or change port in run.py
# Change: app.run(debug=True, host='0.0.0.0', port=5003)
```

---

## 📝 Testing the Application

### Quick Test Checklist:

1. **Login Test**
   - Go to `http://localhost:5002`
   - Login as: `sarah.manager` / `password123`
   - Should redirect to dashboard

2. **Customer CRUD Test**
   - Navigate to Customers
   - Click "New Customer" → Add customer
   - Click "Edit" → Update customer
   - Click "Delete" → Remove customer (Manager only)

3. **Order Test**
   - Navigate to Orders → New Order
   - Select customer, order type, add items
   - Complete order with payment

4. **Reports Test**
   - Navigate to Reports (Manager only)
   - Verify charts load
   - Click export buttons → Download CSVs

5. **Customer Portal Test**
   - Go to `http://localhost:5002/menu`
   - Add items to cart
   - Checkout and place order

---

## 📧 Support

For questions or issues:
- **Developer:** Shrivarshini Narayanan S Kumari
- **Email:** narayanan.sk@northeastern.edu
- **Course:** CS5200 - Database Management Systems
- **Institution:** Northeastern University

---

## 📄 License

This project is submitted as coursework for CS5200. All rights reserved.