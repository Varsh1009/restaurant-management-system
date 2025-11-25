import pymysql

try:
    conn = pymysql.connect(
        host='localhost',
        user='root',
        password='Shri2009!',  # Use whatever worked
        database='restaurant_management'
    )
    
    cursor = conn.cursor()
    
    # Test customers
    cursor.execute("SELECT COUNT(*) FROM Customers")
    result = cursor.fetchone()
    print(f"✅ Found {result[0]} customers")
    
    # Test login credentials (correct case)
    cursor.execute("SELECT username, password_hash FROM User_Credentials")
    users = cursor.fetchall()
    print(f"✅ Login users:")
    for user in users:
        print(f"   - {user[0]} / {user[1]}")
    
    # Test staff
    cursor.execute("SELECT first_name, last_name, role FROM Staff LIMIT 3")
    staff = cursor.fetchall()
    print(f"✅ Sample staff:")
    for s in staff:
        print(f"   - {s[0]} {s[1]} ({s[2]})")
    
    cursor.close()
    conn.close()
    print("\n🎉 ALL TESTS PASSED!")
    
except Exception as e:
    print(f"❌ ERROR: {e}")