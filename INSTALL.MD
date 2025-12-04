# Installation Instructions for Graders/Instructors

**IMPORTANT:** This guide is specifically for instructors/graders running this project for evaluation.

---

## ⚡ Quick Setup (5 Minutes)

### 1. Extract Files
```bash
unzip NarayananSKumariS_project.zip
cd NarayananSKumariS_project
```

### 2. Import Database
```bash
# Method 1: Command line (recommended)
mysql -u root -p < database_dump.sql
# Enter your MySQL password when prompted

# Method 2: MySQL Workbench
# - Open MySQL Workbench
# - File → Run SQL Script
# - Select database_dump.sql
# - Click Run
```

**Note:** The dump file will:
- Drop existing `restaurant_management` database (if exists)
- Create new database with all tables
- Insert sample data
- Create all 35 stored procedures, 4 functions, 4 triggers, 1 event

### 3. Configure Database Password

**Choose ONE of these methods:**

**Method A: Create .env file (Recommended)**
```bash
# Create .env file
cp .env.example .env

# Edit .env and set your password
echo "DB_PASSWORD=your_mysql_password" >> .env
```

**Method B: Edit config.py directly**
```python
# Open app/config.py
# Line 18: Change to your MySQL password
DB_PASSWORD = os.environ.get('DB_PASSWORD') or 'your_mysql_password'
```

### 4. Install Dependencies
```bash
pip install -r requirements.txt
```

**If requirements.txt fails, install manually:**
```bash
pip install Flask==3.0.0
pip install PyMySQL==1.1.0
pip install python-dotenv==1.0.0
```

### 5. Run Application
```bash
python run.py
```

Expected output:
```
* Running on http://0.0.0.0:5002
* Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment.
```

### 6. Access Application
```
http://localhost:5002
```

---

## 🔐 Test Credentials

### Manager Account (Full Access):
- **Username:** sarah.manager
- **Password:** password123
- **Access:** Dashboard, Orders, Customers, Inventory, Reports, Deliveries

### Waiter Account:
- **Username:** tom.server
- **Password:** password123
- **Access:** Dashboard, Orders, Customers

### Coordinator Account:
- **Username:** alex.coordinator
- **Password:** password123
- **Access:** Dashboard, Deliveries

---

## ✅ Verification Checklist

After starting the app, verify:

- [ ] Login page loads at `http://localhost:5002`
- [ ] Can login with `sarah.manager` / `password123`
- [ ] Dashboard shows statistics (revenue, orders, low stock)
- [ ] Customers page shows 8 pre-loaded customers
- [ ] Orders page shows 14 pre-loaded orders
- [ ] Reports page displays 3 charts (pie, bar, line)
- [ ] Export buttons download CSV files
- [ ] Can create new customer
- [ ] Can create new order
- [ ] Customer menu accessible at `http://localhost:5002/menu`

---

## 🗄️ Database Verification

### Verify database was created:
```sql
mysql -u root -p

USE restaurant_management;

-- Check tables (should show 14 tables)
SHOW TABLES;

-- Check stored procedures (should show 35)
SHOW PROCEDURE STATUS WHERE Db = 'restaurant_management';

-- Check functions (should show 4)
SHOW FUNCTION STATUS WHERE Db = 'restaurant_management';

-- Check triggers (should show 4)
SHOW TRIGGERS;

-- Check events (should show 1)
SHOW EVENTS;

-- Verify sample data
SELECT COUNT(*) FROM Customers;  -- Should show 8
SELECT COUNT(*) FROM Orders;     -- Should show 14
SELECT COUNT(*) FROM Menu_Items; -- Should show 16
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "Module 'pymysql' not found"
```bash
pip install PyMySQL
```

### Issue 2: "Access denied for user 'root'@'localhost'"
- Check your MySQL password
- Update DB_PASSWORD in .env or config.py

### Issue 3: "Database 'restaurant_management' doesn't exist"
- Re-run: `mysql -u root -p < database_dump.sql`
- Verify: `SHOW DATABASES;` in MySQL

### Issue 4: "Procedure sp_GetAllCustomers doesn't exist"
- Database dump didn't run completely
- Check for errors during import
- Re-import the dump file

### Issue 5: "Port 5002 already in use"
- Kill existing process: `lsof -i :5002` then `kill -9 <PID>`
- Or change port in run.py: `app.run(debug=True, port=5003)`

### Issue 6: "No module named 'app'"
- Make sure you're in the project root directory
- Verify `app/` folder exists with `__init__.py`

---

## 📊 Testing CRUD Operations

### Test CREATE:
1. Login as Manager
2. Customers → New Customer
3. Fill form → Submit
4. Verify in MySQL Workbench: `SELECT * FROM Customers ORDER BY customer_id DESC LIMIT 1;`

### Test READ:
1. Navigate to Customers page
2. Should display all customers with search/filter

### Test UPDATE:
1. Click "Edit" on any customer
2. Change information → Submit
3. Verify in MySQL Workbench: `SELECT * FROM Customers WHERE customer_id = X;`

### Test DELETE:
1. Login as Manager
2. Click "Delete" on test customer
3. Confirm deletion
4. Verify in MySQL Workbench: `SELECT * FROM Customers WHERE customer_id = X;` (should return empty)

---

## 🎥 For Video Demonstration

### Recommended CRUD Operations to Demo:

1. **CREATE Customer**
   - Before: `SELECT * FROM Customers;`
   - Action: Add new customer via web interface
   - After: `SELECT * FROM Customers ORDER BY customer_id DESC LIMIT 1;`

2. **UPDATE Customer**
   - Before: `SELECT * FROM Customers WHERE customer_id = 1;`
   - Action: Edit customer #1, change phone number
   - After: `SELECT * FROM Customers WHERE customer_id = 1;`

3. **DELETE Customer**
   - Before: `SELECT * FROM Customers WHERE customer_id = 8;`
   - Action: Delete customer #8 via web interface
   - After: `SELECT * FROM Customers WHERE customer_id = 8;` (empty result)

---

## 📞 Contact

**Student:** Shrivarshini Narayanan S Kumari  
**Email:** narayanan.sk@northeastern.edu  
**Course:** CS5200 Database Management Systems  
**Semester:** Fall 2024

---

## ⏱️ Expected Setup Time

- **Database Import:** 1-2 minutes
- **Python Setup:** 2-3 minutes
- **First Run:** 30 seconds
- **Total:** ~5 minutes

---

**Thank you for evaluating this project!**