-- ============================================
-- Restaurant Management System - Complete Database Dump
-- Group: NarayananSKumariS
-- ============================================

DROP DATABASE IF EXISTS restaurant_management;
CREATE DATABASE restaurant_management;
USE restaurant_management;

-- ============================================
-- TABLE CREATION
-- ============================================

-- 1. Restaurant_Locations Table
CREATE TABLE Restaurant_Locations (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    location_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    manager_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_city (city),
    INDEX idx_manager (manager_id)
) ENGINE=InnoDB;

-- 2. Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    loyalty_points INT DEFAULT 0 CHECK (loyalty_points >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_loyalty (loyalty_points)
) ENGINE=InnoDB;

-- 3. Staff Table
CREATE TABLE Staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    role ENUM('Manager', 'Waiter', 'Chef', 'Driver', 'Coordinator') NOT NULL,
    hourly_wage DECIMAL(10, 2) NOT NULL CHECK (hourly_wage > 0),
    hire_date DATE NOT NULL,
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_role (role),
    INDEX idx_location (location_id)
) ENGINE=InnoDB;

-- 4. Menu_Items Table
CREATE TABLE Menu_Items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    description TEXT,
    category ENUM('Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Side') NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    preparation_time INT NOT NULL CHECK (preparation_time > 0) COMMENT 'Time in minutes',
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_available (is_available)
) ENGINE=InnoDB;

-- 5. Tables Table
CREATE TABLE Tables (
    table_id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT NOT NULL,
    table_number VARCHAR(10) NOT NULL,
    seating_capacity INT NOT NULL CHECK (seating_capacity > 0),
    status ENUM('Available', 'Occupied', 'Reserved') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    UNIQUE KEY unique_table_location (location_id, table_number),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- 6. Reservations Table
CREATE TABLE Reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    table_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size INT NOT NULL CHECK (party_size > 0),
    status ENUM('Confirmed', 'Cancelled', 'Completed', 'No-show') DEFAULT 'Confirmed',
    special_requests TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (table_id) REFERENCES Tables(table_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_date (reservation_date),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- 7. Vehicles Table
CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT NOT NULL,
    vehicle_number VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type ENUM('Car', 'Bike', 'Scooter') NOT NULL,
    registration_number VARCHAR(50) UNIQUE NOT NULL,
    status ENUM('Available', 'In Use', 'Maintenance') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- 8. Delivery_Agents Table
CREATE TABLE Delivery_Agents (
    agent_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT NOT NULL UNIQUE,
    vehicle_id INT,
    current_status ENUM('Available', 'On Delivery', 'Off Duty') DEFAULT 'Available',
    current_location VARCHAR(255),
    total_deliveries INT DEFAULT 0 CHECK (total_deliveries >= 0),
    rating DECIMAL(3, 2) DEFAULT 5.00 CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    INDEX idx_status (current_status)
) ENGINE=InnoDB;

-- 9. Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    location_id INT NOT NULL,
    table_id INT,
    order_type ENUM('Dine-In', 'Pickup', 'Delivery') NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    status ENUM('Pending', 'Preparing', 'Ready', 'In Transit', 'Delivered', 'Completed', 'Cancelled') DEFAULT 'Pending',
    staff_id INT,
    delivery_agent_id INT,
    delivery_address VARCHAR(255),
    delivery_time DATETIME,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (table_id) REFERENCES Tables(table_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    FOREIGN KEY (delivery_agent_id) REFERENCES Delivery_Agents(agent_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    INDEX idx_order_type (order_type),
    INDEX idx_order_date (order_date),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- 10. Order_Items Table
CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    special_requests TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Menu_Items(item_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_order (order_id)
) ENGINE=InnoDB;

-- 11. Payments Table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Digital Wallet') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    transaction_id VARCHAR(100),
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tip_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (tip_amount >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_status (payment_status),
    INDEX idx_date (payment_date)
) ENGINE=InnoDB;

-- 12. Inventory Table
CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL CHECK (quantity >= 0),
    unit VARCHAR(20) NOT NULL,
    minimum_stock_level DECIMAL(10, 2) NOT NULL CHECK (minimum_stock_level >= 0),
    supplier_name VARCHAR(100),
    unit_cost DECIMAL(10, 2) CHECK (unit_cost >= 0),
    last_restocked_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_location (location_id),
    INDEX idx_quantity (quantity)
) ENGINE=InnoDB;

-- 13. Shifts Table
CREATE TABLE Shifts (
    shift_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT NOT NULL,
    location_id INT NOT NULL,
    shift_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    break_duration INT DEFAULT 0 CHECK (break_duration >= 0) COMMENT 'Break in minutes',
    status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-show') DEFAULT 'Scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_date (shift_date),
    INDEX idx_staff (staff_id)
) ENGINE=InnoDB;

-- 14. User_Credentials Table
CREATE TABLE User_Credentials (
    credential_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT NOT NULL UNIQUE,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    last_login DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_username (username)
) ENGINE=InnoDB;

-- Add foreign key constraint for manager_id
ALTER TABLE Restaurant_Locations
ADD FOREIGN KEY (manager_id) REFERENCES Staff(staff_id) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE;

-- ============================================
-- SAMPLE DATA INSERTION
-- ============================================

-- ============================================
-- SAMPLE DATA INSERTION - UPDATED TO 2025
-- ============================================

-- Insert Restaurant Locations
INSERT INTO Restaurant_Locations (location_name, address, city, state, zip_code, phone_number, opening_time, closing_time) VALUES
('Downtown Bistro', '123 Main St', 'Boston', 'MA', '02108', '617-555-0001', '10:00:00', '22:00:00'),
('Harbor View', '456 Ocean Ave', 'Boston', 'MA', '02110', '617-555-0002', '11:00:00', '23:00:00'),
('Cambridge Corner', '789 Mass Ave', 'Cambridge', 'MA', '02139', '617-555-0003', '09:00:00', '21:00:00');

-- Insert Customers
INSERT INTO Customers (first_name, last_name, email, phone_number, address, city, state, zip_code, loyalty_points) VALUES
('John', 'Doe', 'john.doe@email.com', '617-555-1001', '789 Park Ave', 'Boston', 'MA', '02115', 150),
('Jane', 'Smith', 'jane.smith@email.com', '617-555-1002', '321 Oak St', 'Cambridge', 'MA', '02139', 200),
('Mike', 'Johnson', 'mike.j@email.com', '617-555-1003', '654 Elm St', 'Somerville', 'MA', '02144', 75),
('Emily', 'Brown', 'emily.b@email.com', '617-555-1004', '987 Pine St', 'Boston', 'MA', '02116', 300),
('David', 'Lee', 'david.l@email.com', '617-555-1005', '147 Cedar Ave', 'Brookline', 'MA', '02446', 50),
('Sarah', 'Wilson', 'sarah.w@email.com', '617-555-1006', '258 Birch Rd', 'Cambridge', 'MA', '02140', 175),
('Robert', 'Taylor', 'robert.t@email.com', '617-555-1007', '369 Maple Dr', 'Boston', 'MA', '02117', 120),
('Lisa', 'Anderson', 'lisa.a@email.com', '617-555-1008', '741 Walnut St', 'Somerville', 'MA', '02145', 90);

-- Insert Staff
INSERT INTO Staff (location_id, first_name, last_name, email, phone_number, role, hourly_wage, hire_date, status) VALUES
(1, 'Sarah', 'Manager', 'sarah.m@restaurant.com', '617-555-2001', 'Manager', 25.00, '2023-01-15', 'Active'),
(1, 'Tom', 'Server', 'tom.s@restaurant.com', '617-555-2002', 'Waiter', 15.00, '2023-03-20', 'Active'),
(1, 'Lisa', 'Chef', 'lisa.c@restaurant.com', '617-555-2003', 'Chef', 22.00, '2023-02-10', 'Active'),
(1, 'Mark', 'Driver', 'mark.d@restaurant.com', '617-555-2004', 'Driver', 18.00, '2023-04-05', 'Active'),
(2, 'Emily', 'Manager', 'emily.m@restaurant.com', '617-555-2005', 'Manager', 25.00, '2023-01-20', 'Active'),
(2, 'James', 'Waiter', 'james.w@restaurant.com', '617-555-2006', 'Waiter', 15.00, '2023-05-10', 'Active'),
(2, 'Anna', 'Chef', 'anna.c@restaurant.com', '617-555-2007', 'Chef', 22.00, '2023-03-15', 'Active'),
(2, 'Chris', 'Driver', 'chris.d@restaurant.com', '617-555-2008', 'Driver', 18.00, '2023-06-01', 'Active'),
(3, 'Michael', 'Manager', 'michael.m@restaurant.com', '617-555-2009', 'Manager', 26.00, '2023-02-01', 'Active'),
(3, 'Rachel', 'Waiter', 'rachel.w@restaurant.com', '617-555-2010', 'Waiter', 16.00, '2023-04-15', 'Active'),
(1, 'Alex', 'Coordinator', 'alex.co@restaurant.com', '617-555-2011', 'Coordinator', 20.00, '2023-07-01', 'Active');

-- Update manager references
UPDATE Restaurant_Locations SET manager_id = 1 WHERE location_id = 1;
UPDATE Restaurant_Locations SET manager_id = 5 WHERE location_id = 2;
UPDATE Restaurant_Locations SET manager_id = 9 WHERE location_id = 3;

-- Insert Menu Items
INSERT INTO Menu_Items (item_name, description, category, price, preparation_time, is_available) VALUES
('Caesar Salad', 'Fresh romaine with parmesan and croutons', 'Appetizer', 8.99, 10, TRUE),
('Bruschetta', 'Toasted bread with tomatoes and basil', 'Appetizer', 7.99, 8, TRUE),
('Mozzarella Sticks', 'Crispy fried mozzarella with marinara', 'Appetizer', 9.99, 12, TRUE),
('Grilled Salmon', 'Atlantic salmon with vegetables', 'Main Course', 24.99, 20, TRUE),
('Margherita Pizza', 'Classic tomato and mozzarella', 'Main Course', 16.99, 15, TRUE),
('Chicken Alfredo', 'Fettuccine with creamy alfredo sauce', 'Main Course', 18.99, 18, TRUE),
('Ribeye Steak', '12oz prime ribeye with sides', 'Main Course', 32.99, 25, TRUE),
('Vegetarian Pasta', 'Penne with seasonal vegetables', 'Main Course', 15.99, 16, TRUE),
('Chocolate Cake', 'Rich chocolate layer cake', 'Dessert', 7.99, 5, TRUE),
('Tiramisu', 'Classic Italian dessert', 'Dessert', 8.99, 5, TRUE),
('Cheesecake', 'New York style cheesecake', 'Dessert', 7.49, 5, TRUE),
('Iced Tea', 'Freshly brewed iced tea', 'Beverage', 2.99, 2, TRUE),
('Lemonade', 'Fresh squeezed lemonade', 'Beverage', 3.49, 3, TRUE),
('Coffee', 'Premium brewed coffee', 'Beverage', 2.49, 3, TRUE),
('French Fries', 'Crispy golden fries', 'Side', 4.99, 8, TRUE),
('Garlic Bread', 'Toasted garlic bread', 'Side', 4.49, 6, TRUE);

-- Insert User Credentials
INSERT INTO User_Credentials (staff_id, username, password_hash) VALUES
(1, 'sarah.manager', 'password123'),
(2, 'tom.server', 'password123'),
(11, 'alex.coordinator', 'password123'),
(5, 'emily.manager', 'password123'),
(9, 'michael.manager', 'password123'),
(3, 'lisa.chef', 'password123'),
(6, 'james.waiter', 'password123'),
(7, 'anna.chef', 'password123');

-- Insert Tables
INSERT INTO Tables (location_id, table_number, seating_capacity, status) VALUES
(1, 'T1', 2, 'Available'),
(1, 'T2', 4, 'Available'),
(1, 'T3', 4, 'Available'),
(1, 'T4', 6, 'Available'),
(1, 'T5', 2, 'Available'),
(2, 'T1', 4, 'Available'),
(2, 'T2', 4, 'Available'),
(2, 'T3', 6, 'Available'),
(2, 'T4', 2, 'Available'),
(3, 'T1', 4, 'Available'),
(3, 'T2', 6, 'Available'),
(3, 'T3', 4, 'Available');

-- Insert Vehicles
INSERT INTO Vehicles (location_id, vehicle_number, vehicle_type, registration_number, status) VALUES
(1, 'V001', 'Bike', 'MA-123-ABC', 'Available'),
(1, 'V002', 'Car', 'MA-456-DEF', 'Available'),
(2, 'V003', 'Bike', 'MA-789-GHI', 'Available'),
(3, 'V004', 'Scooter', 'MA-321-JKL', 'Available');

-- Insert Delivery Agents
INSERT INTO Delivery_Agents (staff_id, vehicle_id, current_status, total_deliveries, rating) VALUES
(4, 1, 'Available', 45, 4.8),
(8, 3, 'Available', 32, 4.6);

-- Insert Inventory (Updated to 2025)
INSERT INTO Inventory (location_id, item_name, category, quantity, unit, minimum_stock_level, supplier_name, unit_cost, last_restocked_date) VALUES
(1, 'Salmon Fillet', 'Seafood', 50, 'lbs', 20, 'Fresh Seafood Co', 12.50, '2025-11-10'),
(1, 'Romaine Lettuce', 'Vegetables', 30, 'heads', 10, 'Green Farms', 1.50, '2025-11-12'),
(1, 'Pizza Dough', 'Bakery', 40, 'balls', 15, 'Italian Supplies', 2.00, '2025-11-11'),
(1, 'Chocolate', 'Bakery', 8, 'lbs', 10, 'Sweet Suppliers', 8.00, '2025-11-09'),
(1, 'Potatoes', 'Vegetables', 100, 'lbs', 30, 'Farm Fresh', 0.75, '2025-11-10'),
(1, 'Chicken Breast', 'Meat', 60, 'lbs', 25, 'Quality Meats', 5.50, '2025-11-11'),
(2, 'Salmon Fillet', 'Seafood', 45, 'lbs', 20, 'Fresh Seafood Co', 12.50, '2025-11-11'),
(2, 'Mozzarella Cheese', 'Dairy', 35, 'lbs', 15, 'Dairy Best', 6.00, '2025-11-10'),
(2, 'Tomatoes', 'Vegetables', 50, 'lbs', 20, 'Green Farms', 2.00, '2025-11-12'),
(3, 'Pasta', 'Dry Goods', 80, 'lbs', 30, 'Italian Supplies', 1.75, '2025-11-09');

-- Insert Orders (Updated to 2025)
INSERT INTO Orders (customer_id, location_id, table_id, order_type, order_date, total_amount, status, staff_id, delivery_agent_id, delivery_address) VALUES
(1, 1, 1, 'Dine-In', '2025-11-01 12:30:00', 45.96, 'Completed', 2, NULL, NULL),
(2, 1, NULL, 'Delivery', '2025-11-01 18:45:00', 52.47, 'Delivered', 2, 1, '321 Oak St, Cambridge, MA 02139'),
(3, 2, 6, 'Dine-In', '2025-11-02 19:15:00', 67.95, 'Completed', 6, NULL, NULL),
(4, 1, NULL, 'Pickup', '2025-11-03 13:20:00', 33.97, 'Completed', 2, NULL, NULL),
(5, 2, NULL, 'Delivery', '2025-11-04 20:00:00', 71.96, 'Delivered', 6, 2, '147 Cedar Ave, Brookline, MA 02446'),
(6, 3, 10, 'Dine-In', '2025-11-05 14:30:00', 89.94, 'Completed', 10, NULL, NULL),
(7, 1, 2, 'Dine-In', '2025-11-06 17:45:00', 56.96, 'Completed', 2, NULL, NULL),
(8, 2, NULL, 'Pickup', '2025-11-07 12:15:00', 41.96, 'Completed', 6, NULL, NULL),
(1, 1, NULL, 'Delivery', '2025-11-08 19:30:00', 48.96, 'Delivered', 2, 1, '789 Park Ave, Boston, MA 02115'),
(2, 3, 11, 'Dine-In', '2025-11-09 13:00:00', 75.94, 'Completed', 10, NULL, NULL),
(3, 1, 3, 'Dine-In', '2025-11-10 18:20:00', 64.95, 'Completed', 2, NULL, NULL),
(4, 2, NULL, 'Delivery', '2025-11-11 20:15:00', 59.96, 'Delivered', 6, 2, '987 Pine St, Boston, MA 02116'),
(5, 1, NULL, 'Pickup', '2025-11-12 14:45:00', 37.97, 'Completed', 2, NULL, NULL),
(6, 3, NULL, 'Delivery', '2025-11-13 19:00:00', 82.95, 'In Transit', 10, 2, '258 Birch Rd, Cambridge, MA 02140');

-- Insert Order Items
INSERT INTO Order_Items (order_id, item_id, quantity, unit_price, subtotal, special_requests) VALUES
(1, 1, 2, 8.99, 17.98, NULL),
(1, 4, 1, 24.99, 24.99, 'Medium rare'),
(1, 12, 1, 2.99, 2.99, NULL),
(2, 5, 2, 16.99, 33.98, 'Extra cheese'),
(2, 9, 2, 7.99, 15.98, NULL),
(2, 13, 1, 2.49, 2.49, NULL),
(3, 7, 2, 32.99, 65.98, 'Well done'),
(3, 12, 2, 2.99, 5.98, NULL),
(4, 6, 2, 18.99, 37.98, NULL),
(5, 4, 2, 24.99, 49.98, NULL),
(5, 2, 2, 7.99, 15.98, NULL),
(5, 14, 2, 2.99, 5.98, NULL),
(6, 7, 2, 32.99, 65.98, NULL),
(6, 10, 2, 8.99, 17.98, NULL),
(6, 14, 2, 2.99, 5.98, NULL),
(7, 5, 2, 16.99, 33.98, NULL),
(7, 1, 2, 8.99, 17.98, NULL),
(7, 15, 1, 4.99, 4.99, NULL),
(8, 6, 2, 18.99, 37.98, NULL),
(8, 11, 1, 7.49, 7.49, NULL),
(9, 4, 1, 24.99, 24.99, NULL),
(9, 2, 2, 7.99, 15.98, NULL),
(9, 16, 1, 4.49, 4.49, NULL),
(9, 12, 1, 2.99, 2.99, NULL),
(10, 7, 2, 32.99, 65.98, NULL),
(10, 9, 1, 7.99, 7.99, NULL),
(10, 13, 2, 2.49, 4.98, NULL),
(11, 5, 2, 16.99, 33.98, NULL),
(11, 4, 1, 24.99, 24.99, NULL),
(11, 15, 1, 4.99, 4.99, NULL),
(11, 12, 1, 2.99, 2.99, NULL),
(12, 6, 2, 18.99, 37.98, NULL),
(12, 3, 2, 9.99, 19.98, NULL),
(12, 13, 1, 2.49, 2.49, NULL),
(13, 5, 2, 16.99, 33.98, NULL),
(13, 11, 1, 7.49, 7.49, NULL),
(14, 7, 2, 32.99, 65.98, NULL),
(14, 1, 1, 8.99, 8.99, NULL),
(14, 10, 1, 8.99, 8.99, NULL);

-- Insert Payments (Updated to 2025)
INSERT INTO Payments (order_id, payment_method, amount, payment_status, transaction_id, payment_date, tip_amount) VALUES
(1, 'Credit Card', 45.96, 'Completed', 'TXN001', '2025-11-01 13:00:00', 8.00),
(2, 'Digital Wallet', 52.47, 'Completed', 'TXN002', '2025-11-01 19:15:00', 10.00),
(3, 'Cash', 67.95, 'Completed', NULL, '2025-11-02 20:00:00', 12.00),
(4, 'Debit Card', 33.97, 'Completed', 'TXN004', '2025-11-03 13:45:00', 5.00),
(5, 'Credit Card', 71.96, 'Completed', 'TXN005', '2025-11-04 20:30:00', 14.00),
(6, 'Cash', 89.94, 'Completed', NULL, '2025-11-05 15:15:00', 15.00),
(7, 'Credit Card', 56.96, 'Completed', 'TXN007', '2025-11-06 18:30:00', 10.00),
(8, 'Digital Wallet', 41.96, 'Completed', 'TXN008', '2025-11-07 12:45:00', 7.00),
(9, 'Credit Card', 48.96, 'Completed', 'TXN009', '2025-11-08 20:00:00', 9.00),
(10, 'Debit Card', 75.94, 'Completed', 'TXN010', '2025-11-09 13:45:00', 13.00),
(11, 'Cash', 64.95, 'Completed', NULL, '2025-11-10 19:00:00', 11.00),
(12, 'Credit Card', 59.96, 'Completed', 'TXN012', '2025-11-11 20:45:00', 11.00),
(13, 'Digital Wallet', 37.97, 'Completed', 'TXN013', '2025-11-12 15:15:00', 6.00),
(14, 'Credit Card', 82.95, 'Pending', NULL, '2025-11-13 19:30:00', 0.00);

-- Insert Reservations (Updated to December 2025 - Future dates)
INSERT INTO Reservations (customer_id, table_id, reservation_date, reservation_time, party_size, status, special_requests) VALUES
(1, 1, '2025-12-10', '18:00:00', 2, 'Confirmed', 'Window seat preferred'),
(2, 3, '2025-12-10', '19:00:00', 4, 'Confirmed', 'Birthday celebration'),
(3, 6, '2025-12-15', '18:30:00', 4, 'Confirmed', NULL),
(4, 8, '2025-12-15', '19:30:00', 6, 'Confirmed', 'Anniversary dinner'),
(5, 10, '2025-12-20', '18:00:00', 4, 'Confirmed', NULL);

-- Insert Shifts (Updated to December 2025 - Mix of completed and upcoming)
INSERT INTO Shifts (staff_id, location_id, shift_date, start_time, end_time, break_duration, status) VALUES
-- Past completed shifts (Nov/early Dec)
(1, 1, '2025-11-28', '09:00:00', '17:00:00', 30, 'Completed'),
(2, 1, '2025-11-28', '10:00:00', '18:00:00', 30, 'Completed'),
(3, 1, '2025-11-28', '11:00:00', '20:00:00', 30, 'Completed'),
(4, 1, '2025-11-28', '16:00:00', '22:00:00', 0, 'Completed'),
(5, 2, '2025-11-28', '09:00:00', '17:00:00', 30, 'Completed'),
(6, 2, '2025-11-28', '11:00:00', '19:00:00', 30, 'Completed'),
(7, 2, '2025-11-28', '12:00:00', '21:00:00', 30, 'Completed'),
(9, 3, '2025-11-28', '09:00:00', '17:00:00', 30, 'Completed'),
(10, 3, '2025-11-28', '10:00:00', '18:00:00', 30, 'Completed'),

-- Upcoming scheduled shifts (Dec 2025 - current week and future)
(1, 1, '2025-12-03', '09:00:00', '17:00:00', 30, 'Scheduled'),
(2, 1, '2025-12-03', '10:00:00', '18:00:00', 30, 'Scheduled'),
(3, 1, '2025-12-03', '11:00:00', '20:00:00', 30, 'Scheduled'),
(4, 1, '2025-12-03', '16:00:00', '22:00:00', 0, 'Scheduled'),

(1, 1, '2025-12-04', '09:00:00', '17:00:00', 30, 'Scheduled'),
(2, 1, '2025-12-04', '10:00:00', '18:00:00', 30, 'Scheduled'),
(3, 1, '2025-12-04', '11:00:00', '20:00:00', 30, 'Scheduled'),

(5, 2, '2025-12-04', '09:00:00', '17:00:00', 30, 'Scheduled'),
(6, 2, '2025-12-04', '11:00:00', '19:00:00', 30, 'Scheduled'),
(7, 2, '2025-12-04', '12:00:00', '21:00:00', 30, 'Scheduled'),

(9, 3, '2025-12-05', '09:00:00', '17:00:00', 30, 'Scheduled'),
(10, 3, '2025-12-05', '10:00:00', '18:00:00', 30, 'Scheduled'),

(1, 1, '2025-12-06', '09:00:00', '17:00:00', 30, 'Scheduled'),
(2, 1, '2025-12-06', '10:00:00', '18:00:00', 30, 'Scheduled'),
(5, 2, '2025-12-06', '09:00:00', '17:00:00', 30, 'Scheduled'),
(9, 3, '2025-12-06', '09:00:00', '17:00:00', 30, 'Scheduled');

-- ============================================
-- STORED PROCEDURES
-- ============================================

DELIMITER //

-- ==================== ORDER PROCEDURES ====================

-- 1. Process new order
CREATE PROCEDURE sp_ProcessOrder(
    IN p_customer_id INT,
    IN p_location_id INT,
    IN p_order_type ENUM('Dine-In', 'Pickup', 'Delivery'),
    IN p_table_id INT,
    IN p_delivery_address VARCHAR(255),
    IN p_staff_id INT
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error processing order';
    END;
    
    START TRANSACTION;
    
    INSERT INTO Orders (customer_id, location_id, table_id, order_type, total_amount, status, staff_id, delivery_address)
    VALUES (p_customer_id, p_location_id, p_table_id, p_order_type, 0.00, 'Pending', p_staff_id, p_delivery_address);
    
    SET v_order_id = LAST_INSERT_ID();
    
    IF p_order_type = 'Dine-In' AND p_table_id IS NOT NULL THEN
        UPDATE Tables SET status = 'Occupied' WHERE table_id = p_table_id;
    END IF;
    
    COMMIT;
    
    SELECT v_order_id AS order_id;
END //

-- 2. Add item to order
CREATE PROCEDURE sp_AddOrderItem(
    IN p_order_id INT,
    IN p_item_id INT,
    IN p_quantity INT,
    IN p_special_requests TEXT
)
BEGIN
    DECLARE v_unit_price DECIMAL(10, 2);
    DECLARE v_subtotal DECIMAL(10, 2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error adding order item';
    END;
    
    START TRANSACTION;
    
    SELECT price INTO v_unit_price FROM Menu_Items WHERE item_id = p_item_id;
    SET v_subtotal = v_unit_price * p_quantity;
    
    INSERT INTO Order_Items (order_id, item_id, quantity, unit_price, subtotal, special_requests)
    VALUES (p_order_id, p_item_id, p_quantity, v_unit_price, v_subtotal, p_special_requests);
    
    UPDATE Orders 
    SET total_amount = (SELECT SUM(subtotal) FROM Order_Items WHERE order_id = p_order_id)
    WHERE order_id = p_order_id;
    
    COMMIT;
END //

-- 3. Complete order with payment
CREATE PROCEDURE sp_CompleteOrder(
    IN p_order_id INT,
    IN p_payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Digital Wallet'),
    IN p_tip_amount DECIMAL(10, 2)
)
BEGIN
    DECLARE v_total_amount DECIMAL(10, 2);
    DECLARE v_table_id INT;
    DECLARE v_agent_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error completing order';
    END;
    
    START TRANSACTION;
    
    SELECT total_amount, table_id, delivery_agent_id 
    INTO v_total_amount, v_table_id, v_agent_id
    FROM Orders WHERE order_id = p_order_id;
    
    INSERT INTO Payments (order_id, payment_method, amount, payment_status, tip_amount)
    VALUES (p_order_id, p_payment_method, v_total_amount, 'Completed', p_tip_amount);
    
    UPDATE Orders SET status = 'Completed' WHERE order_id = p_order_id;
    
    IF v_table_id IS NOT NULL THEN
        UPDATE Tables SET status = 'Available' WHERE table_id = v_table_id;
    END IF;
    
    IF v_agent_id IS NOT NULL THEN
        UPDATE Delivery_Agents 
        SET current_status = 'Available',
            total_deliveries = total_deliveries + 1
        WHERE agent_id = v_agent_id;
    END IF;
    
    COMMIT;
    
    SELECT 'Order completed successfully' AS message;
END //

-- 4. Assign delivery driver
CREATE PROCEDURE sp_AssignDelivery(IN p_order_id INT)
BEGIN
    DECLARE v_agent_id INT;
    DECLARE v_location_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error assigning delivery';
    END;
    
    START TRANSACTION;
    
    SELECT location_id INTO v_location_id FROM Orders WHERE order_id = p_order_id;
    
    SELECT da.agent_id INTO v_agent_id
    FROM Delivery_Agents da
    JOIN Staff s ON da.staff_id = s.staff_id
    WHERE da.current_status = 'Available' 
    AND s.location_id = v_location_id
    LIMIT 1;
    
    IF v_agent_id IS NOT NULL THEN
        UPDATE Orders 
        SET delivery_agent_id = v_agent_id, status = 'Preparing'
        WHERE order_id = p_order_id;
        
        UPDATE Delivery_Agents 
        SET current_status = 'On Delivery'
        WHERE agent_id = v_agent_id;
        
        SELECT CONCAT('Order assigned to agent ', v_agent_id) AS message;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No available delivery agents';
    END IF;
    
    COMMIT;
END //

-- 5. Get orders by location
CREATE PROCEDURE sp_GetOrdersByLocation(IN p_location_id INT)
BEGIN
    SELECT o.order_id, o.order_type, o.total_amount, o.status, o.order_date,
           CONCAT(c.first_name, ' ', c.last_name) as customer_name, 
           c.phone_number
    FROM Orders o
    JOIN Customers c ON o.customer_id = c.customer_id
    WHERE o.location_id = p_location_id
    ORDER BY o.order_date DESC;
END //

-- 6. Get order details
CREATE PROCEDURE sp_GetOrderDetails(IN p_order_id INT)
BEGIN
    SELECT o.order_id, o.order_type, o.total_amount, o.status, o.order_date,
           o.delivery_address, o.special_instructions,
           CONCAT(c.first_name, ' ', c.last_name) as customer_name,
           c.email, c.phone_number,
           t.table_number,
           CONCAT(s.first_name, ' ', s.last_name) as staff_name
    FROM Orders o
    JOIN Customers c ON o.customer_id = c.customer_id
    LEFT JOIN Tables t ON o.table_id = t.table_id
    LEFT JOIN Staff s ON o.staff_id = s.staff_id
    WHERE o.order_id = p_order_id;
END //

-- 7. Get order items
CREATE PROCEDURE sp_GetOrderItems(IN p_order_id INT)
BEGIN
    SELECT oi.order_item_id, mi.item_name, mi.category,
           oi.quantity, oi.unit_price, oi.subtotal, oi.special_requests
    FROM Order_Items oi
    JOIN Menu_Items mi ON oi.item_id = mi.item_id
    WHERE oi.order_id = p_order_id;
END //

-- 8. Update order status
CREATE PROCEDURE sp_UpdateOrderStatus(
    IN p_order_id INT,
    IN p_status VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error updating order status';
    END;
    
    START TRANSACTION;
    UPDATE Orders SET status = p_status WHERE order_id = p_order_id;
    COMMIT;
END //

-- 9. Cancel order
CREATE PROCEDURE sp_CancelOrder(IN p_order_id INT)
BEGIN
    DECLARE v_table_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error cancelling order';
    END;
    
    START TRANSACTION;
    
    SELECT table_id INTO v_table_id FROM Orders WHERE order_id = p_order_id;
    
    UPDATE Orders SET status = 'Cancelled' WHERE order_id = p_order_id;
    
    IF v_table_id IS NOT NULL THEN
        UPDATE Tables SET status = 'Available' WHERE table_id = v_table_id;
    END IF;
    
    COMMIT;
END //

-- ==================== CUSTOMER PROCEDURES ====================

-- 10. Get all customers
CREATE PROCEDURE sp_GetAllCustomers()
BEGIN
    SELECT customer_id, first_name, last_name, email, phone_number, loyalty_points
    FROM Customers 
    ORDER BY loyalty_points DESC;
END //

-- 11. Get customer by ID
CREATE PROCEDURE sp_GetCustomerById(IN p_customer_id INT)
BEGIN
    SELECT * FROM Customers WHERE customer_id = p_customer_id;
END //

-- 12. Add customer
CREATE PROCEDURE sp_AddCustomer(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(15),
    IN p_address VARCHAR(255),
    IN p_city VARCHAR(50),
    IN p_state VARCHAR(50),
    IN p_zip VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error adding customer';
    END;
    
    START TRANSACTION;
    
    INSERT INTO Customers (first_name, last_name, email, phone_number, 
                          address, city, state, zip_code)
    VALUES (p_first_name, p_last_name, p_email, p_phone, 
            p_address, p_city, p_state, p_zip);
    
    COMMIT;
    
    SELECT LAST_INSERT_ID() as customer_id;
END //

-- 13. Update customer
CREATE PROCEDURE sp_UpdateCustomer(
    IN p_customer_id INT,
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(15),
    IN p_address VARCHAR(255),
    IN p_city VARCHAR(50),
    IN p_state VARCHAR(50),
    IN p_zip VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error updating customer';
    END;
    
    START TRANSACTION;
    
    UPDATE Customers 
    SET first_name = p_first_name, last_name = p_last_name,
        email = p_email, phone_number = p_phone,
        address = p_address, city = p_city, 
        state = p_state, zip_code = p_zip
    WHERE customer_id = p_customer_id;
    
    COMMIT;
END //

-- 14. Delete customer
CREATE PROCEDURE sp_DeleteCustomer(IN p_customer_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error deleting customer';
    END;
    
    START TRANSACTION;
    DELETE FROM Customers WHERE customer_id = p_customer_id;
    COMMIT;
END //

-- ==================== INVENTORY PROCEDURES ====================

-- 15. Update inventory
CREATE PROCEDURE sp_UpdateInventory(
    IN p_inventory_id INT,
    IN p_quantity_received DECIMAL(10, 2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error updating inventory';
    END;
    
    START TRANSACTION;
    
    UPDATE Inventory 
    SET quantity = quantity + p_quantity_received,
        last_restocked_date = CURDATE()
    WHERE inventory_id = p_inventory_id;
    
    COMMIT;
    
    SELECT 'Inventory updated successfully' AS message;
END //

-- 16. Get inventory by location
CREATE PROCEDURE sp_GetInventoryByLocation(IN p_location_id INT)
BEGIN
    SELECT inventory_id, item_name, category, 
           COALESCE(quantity, 0) as quantity, 
           unit, 
           COALESCE(minimum_stock_level, 0) as minimum_stock_level,
           supplier_name, 
           COALESCE(unit_cost, 0) as unit_cost, 
           last_restocked_date,
           CASE 
               WHEN minimum_stock_level > 0 THEN 
                   ROUND((COALESCE(quantity, 0) / minimum_stock_level) * 100, 2)
               ELSE 0
           END as stock_percentage
    FROM Inventory 
    WHERE location_id = p_location_id 
    ORDER BY category, item_name;
END //

-- 17. Get low stock items
CREATE PROCEDURE sp_GetLowStock(IN p_location_id INT)
BEGIN
    SELECT inventory_id, item_name, 
           COALESCE(quantity, 0) as quantity, 
           unit, 
           COALESCE(minimum_stock_level, 0) as minimum_stock_level,
           supplier_name,
           CASE 
               WHEN minimum_stock_level > 0 THEN 
                   ROUND((COALESCE(quantity, 0) / minimum_stock_level) * 100, 2)
               ELSE 0
           END as stock_percentage
    FROM Inventory
    WHERE location_id = p_location_id 
    AND COALESCE(quantity, 0) < COALESCE(minimum_stock_level, 0)
    AND minimum_stock_level > 0
    ORDER BY stock_percentage ASC;
END //

-- ==================== MENU & TABLE PROCEDURES ====================

-- 18. Get available menu items
CREATE PROCEDURE sp_GetAvailableMenuItems()
BEGIN
    SELECT item_id, item_name, description, category, price, preparation_time
    FROM Menu_Items
    WHERE is_available = TRUE
    ORDER BY category, item_name;
END //

-- 19. Get available tables
CREATE PROCEDURE sp_GetAvailableTables(IN p_location_id INT)
BEGIN
    SELECT table_id, table_number, seating_capacity
    FROM Tables
    WHERE location_id = p_location_id AND status = 'Available'
    ORDER BY table_number;
END //

-- 20. Get all tables by location
CREATE PROCEDURE sp_GetTablesByLocation(IN p_location_id INT)
BEGIN
    SELECT table_id, table_number, seating_capacity, status
    FROM Tables
    WHERE location_id = p_location_id
    ORDER BY table_number;
END //

-- ==================== RESERVATION PROCEDURES ====================

-- 21. Get upcoming reservations
CREATE PROCEDURE sp_GetUpcomingReservations(IN p_location_id INT)
BEGIN
    SELECT r.reservation_id, r.reservation_date, r.reservation_time, 
           r.party_size, r.status, r.special_requests,
           CONCAT(c.first_name, ' ', c.last_name) as customer_name,
           c.phone_number,
           t.table_number
    FROM Reservations r
    JOIN Customers c ON r.customer_id = c.customer_id
    JOIN Tables t ON r.table_id = t.table_id
    WHERE t.location_id = p_location_id
    AND r.reservation_date >= CURDATE()
    ORDER BY r.reservation_date, r.reservation_time;
END //

-- 22. Create reservation
CREATE PROCEDURE sp_CreateReservation(
    IN p_customer_id INT,
    IN p_table_id INT,
    IN p_date DATE,
    IN p_time TIME,
    IN p_party_size INT,
    IN p_special_requests TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error creating reservation';
    END;
    
    START TRANSACTION;
    
    INSERT INTO Reservations (customer_id, table_id, reservation_date, 
                             reservation_time, party_size, special_requests)
    VALUES (p_customer_id, p_table_id, p_date, p_time, p_party_size, p_special_requests);
    
    COMMIT;
    
    SELECT LAST_INSERT_ID() as reservation_id;
END //

-- ==================== PAYMENT PROCEDURES ====================

-- 23. Get payment by order
CREATE PROCEDURE sp_GetPaymentByOrder(IN p_order_id INT)
BEGIN
    SELECT payment_method, amount, payment_status, payment_date, tip_amount
    FROM Payments
    WHERE order_id = p_order_id;
END //

-- ==================== DELIVERY PROCEDURES ====================

-- 24. Get deliveries by location
CREATE PROCEDURE sp_GetDeliveriesByLocation(IN p_location_id INT)
BEGIN
    SELECT o.order_id, o.delivery_address, o.status, o.order_date, o.total_amount,
           CONCAT(c.first_name, ' ', c.last_name) as customer_name,
           c.phone_number,
           CONCAT(s.first_name, ' ', s.last_name) as driver_name,
           da.current_status as driver_status
    FROM Orders o
    JOIN Customers c ON o.customer_id = c.customer_id
    LEFT JOIN Delivery_Agents da ON o.delivery_agent_id = da.agent_id
    LEFT JOIN Staff s ON da.staff_id = s.staff_id
    WHERE o.order_type = 'Delivery' 
    AND o.location_id = p_location_id
    ORDER BY o.order_date DESC;
END //

-- 25. Get available drivers
CREATE PROCEDURE sp_GetAvailableDrivers(IN p_location_id INT)
BEGIN
    SELECT da.agent_id, 
           CONCAT(s.first_name, ' ', s.last_name) as driver_name,
           da.current_status, da.rating
    FROM Delivery_Agents da
    JOIN Staff s ON da.staff_id = s.staff_id
    WHERE s.location_id = p_location_id AND s.status = 'Active';
END //

-- ==================== DASHBOARD PROCEDURES ====================

-- 26. Get dashboard statistics
CREATE PROCEDURE sp_GetDashboardStats(IN p_location_id INT)
BEGIN
    SELECT 
        COALESCE(SUM(CASE WHEN DATE(order_date) = CURDATE() 
                         AND status IN ('Completed', 'Delivered') 
                         THEN total_amount ELSE 0 END), 0) as today_revenue,
        COUNT(CASE WHEN DATE(order_date) = CURDATE() THEN 1 END) as today_orders,
        COUNT(CASE WHEN status = 'Pending' THEN 1 END) as pending_orders,
        (SELECT COUNT(*) FROM Inventory 
         WHERE location_id = p_location_id 
         AND quantity < minimum_stock_level) as low_stock
    FROM Orders
    WHERE location_id = p_location_id;
END //

-- 27. Get recent orders
CREATE PROCEDURE sp_GetRecentOrders(
    IN p_location_id INT,
    IN p_limit INT
)
BEGIN
    SELECT o.order_id, o.order_type, o.total_amount, o.status, o.order_date,
           CONCAT(c.first_name, ' ', c.last_name) as customer_name
    FROM Orders o
    JOIN Customers c ON o.customer_id = c.customer_id
    WHERE o.location_id = p_location_id
    ORDER BY o.order_date DESC
    LIMIT p_limit;
END //

-- ==================== REPORT PROCEDURES ====================

-- 28. Get revenue by channel
CREATE PROCEDURE sp_GetRevenueByChannel(IN p_location_id INT)
BEGIN
    SELECT order_type, 
           SUM(total_amount) as revenue,
           COUNT(*) as order_count,
           AVG(total_amount) as avg_order_value
    FROM Orders
    WHERE location_id = p_location_id 
    AND status IN ('Completed', 'Delivered')
    GROUP BY order_type;
END //

-- 29. Get daily revenue trend


CREATE PROCEDURE sp_GetDailyRevenueTrend(IN p_location_id INT)
BEGIN
    SELECT DATE(order_date) as date,
           order_type,
           SUM(total_amount) as revenue
    FROM Orders
    WHERE location_id = p_location_id 
    AND status IN ('Completed', 'Delivered')
    GROUP BY DATE(order_date), order_type
    ORDER BY DATE(order_date) DESC
    LIMIT 90;
END //



-- 30. Get top selling items
CREATE PROCEDURE sp_GetTopSellingItems(IN p_location_id INT)
BEGIN
    SELECT mi.item_name,
           SUM(oi.quantity) as total_quantity,
           SUM(oi.subtotal) as total_revenue
    FROM Order_Items oi
    JOIN Menu_Items mi ON oi.item_id = mi.item_id
    JOIN Orders o ON oi.order_id = o.order_id
    WHERE o.location_id = p_location_id
    AND o.status IN ('Completed', 'Delivered')
    GROUP BY mi.item_name
    ORDER BY total_revenue DESC
    LIMIT 10;
END //

-- 31. Get top customers
CREATE PROCEDURE sp_GetTopCustomers()
BEGIN
    SELECT customer_id, first_name, last_name, loyalty_points,
           (SELECT COUNT(*) FROM Orders WHERE customer_id = c.customer_id) as total_orders
    FROM Customers c
    ORDER BY loyalty_points DESC
    LIMIT 10;
END //

-- ==================== NEW PROCEDURES FOR CUSTOMER PORTAL ====================

-- 32. Get order total (for add_items page)
CREATE PROCEDURE sp_GetOrderTotal(IN p_order_id INT)
BEGIN
    SELECT total_amount FROM Orders WHERE order_id = p_order_id;
END //

-- 33. Create customer order (for checkout - customer portal)
CREATE PROCEDURE sp_CreateCustomerOrder(
    IN p_customer_id INT,
    IN p_order_type ENUM('Pickup', 'Delivery'),
    IN p_delivery_address VARCHAR(255),
    OUT p_order_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error creating customer order';
    END;
    
    START TRANSACTION;
    
    INSERT INTO Orders (customer_id, location_id, order_type, total_amount, delivery_address)
    VALUES (p_customer_id, 1, p_order_type, 0.00, p_delivery_address);
    
    SET p_order_id = LAST_INSERT_ID();
    
    COMMIT;
END //

-- 34. Add customer order item (for checkout)
CREATE PROCEDURE sp_AddCustomerOrderItem(
    IN p_order_id INT,
    IN p_item_id INT,
    IN p_quantity INT,
    IN p_unit_price DECIMAL(10,2)
)
BEGIN
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error adding customer order item';
    END;
    
    START TRANSACTION;
    
    SET v_subtotal = p_unit_price * p_quantity;
    
    INSERT INTO Order_Items (order_id, item_id, quantity, unit_price, subtotal)
    VALUES (p_order_id, p_item_id, p_quantity, p_unit_price, v_subtotal);
    
    UPDATE Orders 
    SET total_amount = (SELECT SUM(subtotal) FROM Order_Items WHERE order_id = p_order_id)
    WHERE order_id = p_order_id;
    
    COMMIT;
END //

-- ==================== AUTHENTICATION PROCEDURES ====================

-- 35. Authenticate user login
CREATE PROCEDURE sp_AuthenticateUser(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE v_credential_id INT;
    
    -- Get user info
    SELECT uc.credential_id, uc.staff_id, uc.username, 
           s.first_name, s.last_name, s.role, s.location_id,
           rl.location_name
    FROM User_Credentials uc
    JOIN Staff s ON uc.staff_id = s.staff_id
    JOIN Restaurant_Locations rl ON s.location_id = rl.location_id
    WHERE uc.username = p_username 
    AND uc.password_hash = p_password 
    AND s.status = 'Active';
    
    -- Update last login time
    SELECT credential_id INTO v_credential_id
    FROM User_Credentials
    WHERE username = p_username;
    
    IF v_credential_id IS NOT NULL THEN
        UPDATE User_Credentials 
        SET last_login = NOW() 
        WHERE credential_id = v_credential_id;
    END IF;
END //
-- ==================== INVENTORY FULL CRUD PROCEDURES ====================

-- 36. Add inventory item
CREATE PROCEDURE sp_AddInventoryItem(
    IN p_location_id INT,
    IN p_item_name VARCHAR(100),
    IN p_category VARCHAR(50),
    IN p_quantity DECIMAL(10,2),
    IN p_unit VARCHAR(20),
    IN p_minimum_stock_level DECIMAL(10,2),
    IN p_supplier_name VARCHAR(100),
    IN p_unit_cost DECIMAL(10,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error adding inventory item';
    END;
    
    START TRANSACTION;
    
    INSERT INTO Inventory (location_id, item_name, category, quantity, unit, 
                          minimum_stock_level, supplier_name, unit_cost, last_restocked_date)
    VALUES (p_location_id, p_item_name, p_category, p_quantity, p_unit,
            p_minimum_stock_level, p_supplier_name, p_unit_cost, CURDATE());
    
    COMMIT;
    
    SELECT LAST_INSERT_ID() as inventory_id;
END //

-- 37. Get inventory item by ID
CREATE PROCEDURE sp_GetInventoryItemById(IN p_inventory_id INT)
BEGIN
    SELECT * FROM Inventory WHERE inventory_id = p_inventory_id;
END //

-- 38. Update inventory item (full edit)
CREATE PROCEDURE sp_UpdateInventoryItem(
    IN p_inventory_id INT,
    IN p_item_name VARCHAR(100),
    IN p_category VARCHAR(50),
    IN p_quantity DECIMAL(10,2),
    IN p_unit VARCHAR(20),
    IN p_minimum_stock_level DECIMAL(10,2),
    IN p_supplier_name VARCHAR(100),
    IN p_unit_cost DECIMAL(10,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error updating inventory item';
    END;
    
    START TRANSACTION;
    
    UPDATE Inventory 
    SET item_name = p_item_name,
        category = p_category,
        quantity = p_quantity,
        unit = p_unit,
        minimum_stock_level = p_minimum_stock_level,
        supplier_name = p_supplier_name,
        unit_cost = p_unit_cost
    WHERE inventory_id = p_inventory_id;
    
    COMMIT;
END //

-- 39. Delete inventory item
CREATE PROCEDURE sp_DeleteInventoryItem(IN p_inventory_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error deleting inventory item';
    END;
    
    START TRANSACTION;
    DELETE FROM Inventory WHERE inventory_id = p_inventory_id;
    COMMIT;
END //

-- ==================== STAFF VIEW PROCEDURES ====================

-- 40. Get all staff
CREATE PROCEDURE sp_GetAllStaff()
BEGIN
    SELECT s.staff_id, s.first_name, s.last_name, s.email, s.phone_number,
           s.role, s.hourly_wage, s.hire_date, s.status,
           rl.location_name
    FROM Staff s
    JOIN Restaurant_Locations rl ON s.location_id = rl.location_id
    ORDER BY s.location_id, s.role, s.last_name;
END //

-- 41. Get staff by location
CREATE PROCEDURE sp_GetStaffByLocation(IN p_location_id INT)
BEGIN
    SELECT staff_id, first_name, last_name, email, phone_number,
           role, hourly_wage, hire_date, status
    FROM Staff
    WHERE location_id = p_location_id
    ORDER BY role, last_name;
END //

-- ==================== SHIFTS VIEW PROCEDURES ====================

-- 42. Get all shifts
CREATE PROCEDURE sp_GetAllShifts(IN p_location_id INT)
BEGIN
    SELECT sh.shift_id, sh.shift_date, sh.start_time, sh.end_time, 
           sh.break_duration, sh.status,
           CONCAT(s.first_name, ' ', s.last_name) as staff_name,
           s.role
    FROM Shifts sh
    JOIN Staff s ON sh.staff_id = s.staff_id
    WHERE sh.location_id = p_location_id
    ORDER BY sh.shift_date DESC, sh.start_time;
END //

-- 43. Get upcoming shifts
CREATE PROCEDURE sp_GetUpcomingShifts(IN p_location_id INT)
BEGIN
    SELECT sh.shift_id, sh.shift_date, sh.start_time, sh.end_time, 
           sh.break_duration, sh.status,
           CONCAT(s.first_name, ' ', s.last_name) as staff_name,
           s.role
    FROM Shifts sh
    JOIN Staff s ON sh.staff_id = s.staff_id
    WHERE sh.location_id = p_location_id
    AND sh.shift_date >= CURDATE()
    ORDER BY sh.shift_date, sh.start_time;
END //

-- ==================== VEHICLES VIEW PROCEDURES ====================

-- 44. Get all vehicles
CREATE PROCEDURE sp_GetAllVehicles()
BEGIN
    SELECT v.vehicle_id, v.vehicle_number, v.vehicle_type, 
           v.registration_number, v.status,
           rl.location_name
    FROM Vehicles v
    JOIN Restaurant_Locations rl ON v.location_id = rl.location_id
    ORDER BY v.location_id, v.vehicle_number;
END //

-- 45. Get vehicles by location
CREATE PROCEDURE sp_GetVehiclesByLocation(IN p_location_id INT)
BEGIN
    SELECT vehicle_id, vehicle_number, vehicle_type, 
           registration_number, status
    FROM Vehicles
    WHERE location_id = p_location_id
    ORDER BY vehicle_number;
END //

-- ==================== RESERVATION LIST PROCEDURE ====================

-- 46. Get all reservations (for listing page)
CREATE PROCEDURE sp_GetAllReservations(IN p_location_id INT)
BEGIN
    SELECT r.reservation_id, r.reservation_date, r.reservation_time, 
           r.party_size, r.status, r.special_requests,
           CONCAT(c.first_name, ' ', c.last_name) as customer_name,
           c.phone_number,
           t.table_number
    FROM Reservations r
    JOIN Customers c ON r.customer_id = c.customer_id
    JOIN Tables t ON r.table_id = t.table_id
    WHERE t.location_id = p_location_id
    ORDER BY r.reservation_date DESC, r.reservation_time DESC;
END //

-- ==================== DELIVERY AGENTS DETAILS ====================

-- 47. Get all delivery agents with details
CREATE PROCEDURE sp_GetAllDeliveryAgents()
BEGIN
    SELECT da.agent_id, da.current_status, da.total_deliveries, da.rating,
           CONCAT(s.first_name, ' ', s.last_name) as agent_name,
           s.phone_number,
           v.vehicle_number, v.vehicle_type,
           rl.location_name
    FROM Delivery_Agents da
    JOIN Staff s ON da.staff_id = s.staff_id
    LEFT JOIN Vehicles v ON da.vehicle_id = v.vehicle_id
    JOIN Restaurant_Locations rl ON s.location_id = rl.location_id
    ORDER BY rl.location_name, s.last_name;
END //

-- 48. Get delivery agents by location
CREATE PROCEDURE sp_GetDeliveryAgentsByLocation(IN p_location_id INT)
BEGIN
    SELECT da.agent_id, da.current_status, da.total_deliveries, da.rating,
           CONCAT(s.first_name, ' ', s.last_name) as agent_name,
           s.phone_number,
           v.vehicle_number, v.vehicle_type
    FROM Delivery_Agents da
    JOIN Staff s ON da.staff_id = s.staff_id
    LEFT JOIN Vehicles v ON da.vehicle_id = v.vehicle_id
    WHERE s.location_id = p_location_id
    ORDER BY s.last_name;
END //

DELIMITER ;
-- ============================================
-- FUNCTIONS
-- ============================================

DELIMITER //

-- Function 1: Calculate order total
CREATE FUNCTION fn_CalculateOrderTotal(p_order_id INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10, 2);
    
    SELECT COALESCE(SUM(subtotal), 0.00) INTO v_total
    FROM Order_Items
    WHERE order_id = p_order_id;
    
    RETURN v_total;
END //

-- Function 2: Get delivery cost
CREATE FUNCTION fn_GetDeliveryCost(p_order_id INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_cost DECIMAL(10, 2);
    DECLARE v_hourly_wage DECIMAL(10, 2);
    DECLARE v_estimated_hours DECIMAL(10, 2) DEFAULT 0.75;
    
    SELECT s.hourly_wage INTO v_hourly_wage
    FROM Orders o
    JOIN Delivery_Agents da ON o.delivery_agent_id = da.agent_id
    JOIN Staff s ON da.staff_id = s.staff_id
    WHERE o.order_id = p_order_id;
    
    IF v_hourly_wage IS NOT NULL THEN
        SET v_cost = v_hourly_wage * v_estimated_hours;
    ELSE
        SET v_cost = 0.00;
    END IF;
    
    RETURN v_cost;
END //

-- Function 3: Get channel revenue
CREATE FUNCTION fn_GetChannelRevenue(
    p_order_type VARCHAR(20),
    p_start_date DATE,
    p_end_date DATE
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_revenue DECIMAL(10, 2);
    
    SELECT COALESCE(SUM(total_amount), 0.00) INTO v_revenue
    FROM Orders
    WHERE order_type = p_order_type
    AND DATE(order_date) BETWEEN p_start_date AND p_end_date
    AND status IN ('Completed', 'Delivered');
    
    RETURN v_revenue;
END //

-- Function 4: Get customer tier
CREATE FUNCTION fn_GetCustomerTier(p_customer_id INT)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_points INT;
    DECLARE v_tier VARCHAR(20);
    
    SELECT loyalty_points INTO v_points
    FROM Customers
    WHERE customer_id = p_customer_id;
    
    IF v_points >= 500 THEN
        SET v_tier = 'Platinum';
    ELSEIF v_points >= 250 THEN
        SET v_tier = 'Gold';
    ELSEIF v_points >= 100 THEN
        SET v_tier = 'Silver';
    ELSE
        SET v_tier = 'Bronze';
    END IF;
    
    RETURN v_tier;
END //

DELIMITER ;

-- ============================================
-- TRIGGERS
-- ============================================

DELIMITER //

-- Trigger 1: Update inventory on order completion
CREATE TRIGGER trg_UpdateInventoryOnOrder
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'Completed' AND OLD.status != 'Completed' THEN
        INSERT INTO Inventory (location_id, item_name, category, quantity, unit, minimum_stock_level)
        VALUES (NEW.location_id, 'Order Log', 'System', 0, 'count', 0)
        ON DUPLICATE KEY UPDATE quantity = quantity;
    END IF;
END //

-- Trigger 2: Add loyalty points after payment
CREATE TRIGGER trg_AddLoyaltyPoints
AFTER INSERT ON Payments
FOR EACH ROW
BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_points INT;
    
    SELECT customer_id INTO v_customer_id
    FROM Orders
    WHERE order_id = NEW.order_id;
    
    SET v_points = FLOOR(NEW.amount);
    
    UPDATE Customers
    SET loyalty_points = loyalty_points + v_points
    WHERE customer_id = v_customer_id;
END //

-- Trigger 3: Check low stock
CREATE TRIGGER trg_CheckLowStock
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    DECLARE v_warning VARCHAR(255);
    
    IF NEW.quantity < NEW.minimum_stock_level THEN
        SET v_warning = CONCAT('Low stock alert for ', NEW.item_name, ' at location ', NEW.location_id);
    END IF;
END //

-- Trigger 4: Validate order
CREATE TRIGGER trg_ValidateOrder
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    IF NEW.order_type = 'Delivery' AND NEW.delivery_address IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Delivery address required for delivery orders';
    END IF;
    
    IF NEW.order_type = 'Dine-In' AND NEW.table_id IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Table ID required for dine-in orders';
    END IF;
END //

DELIMITER ;

-- ============================================
-- VIEWS FOR REPORTING
-- ============================================

-- View 1: Daily Revenue by Channel
CREATE VIEW vw_DailyRevenueByChannel AS
SELECT 
    DATE(order_date) AS order_date,
    order_type,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value
FROM Orders
WHERE status IN ('Completed', 'Delivered')
GROUP BY DATE(order_date), order_type;

-- View 2: Top Customers
CREATE VIEW vw_TopCustomers AS
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name,
    email,
    loyalty_points,
    fn_GetCustomerTier(customer_id) AS tier,
    (SELECT COUNT(*) FROM Orders WHERE customer_id = c.customer_id) AS total_orders
FROM Customers c
ORDER BY loyalty_points DESC;

-- View 3: Low Stock Items
CREATE VIEW vw_LowStockItems AS
SELECT 
    i.inventory_id,
    rl.location_name,
    i.item_name,
    i.quantity,
    i.unit,
    i.minimum_stock_level,
    i.supplier_name,
    ROUND((i.quantity / i.minimum_stock_level) * 100, 2) AS stock_percentage
FROM Inventory i
JOIN Restaurant_Locations rl ON i.location_id = rl.location_id
WHERE i.quantity < i.minimum_stock_level
ORDER BY stock_percentage ASC;

-- View 4: Staff Performance
CREATE VIEW vw_StaffPerformance AS
SELECT 
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    s.role,
    rl.location_name,
    COUNT(o.order_id) AS orders_handled,
    COALESCE(SUM(o.total_amount), 0) AS total_sales
FROM Staff s
LEFT JOIN Orders o ON s.staff_id = o.staff_id
LEFT JOIN Restaurant_Locations rl ON s.location_id = rl.location_id
WHERE s.status = 'Active'
GROUP BY s.staff_id, s.first_name, s.last_name, s.role, rl.location_name;

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_orders_customer ON Orders(customer_id);
CREATE INDEX idx_orders_location ON Orders(location_id);
CREATE INDEX idx_orderitems_item ON Order_Items(item_id);
CREATE INDEX idx_payments_order ON Payments(order_id);
CREATE INDEX idx_inventory_location ON Inventory(location_id);

-- ============================================
-- SCHEDULED EVENTS
-- ============================================

DELIMITER //

-- Event: Auto-cleanup old reservations (runs daily at 2 AM)
CREATE EVENT IF NOT EXISTS evt_CleanupOldReservations
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 DAY
DO
BEGIN
    -- Update old 'No-show' reservations to 'Cancelled' after 7 days
    UPDATE Reservations
    SET status = 'Cancelled'
    WHERE status = 'No-show'
    AND reservation_date < DATE_SUB(CURDATE(), INTERVAL 7 DAY);
    
    -- Update completed reservations older than 30 days
    UPDATE Reservations
    SET status = 'Completed'
    WHERE status = 'Confirmed'
    AND reservation_date < DATE_SUB(CURDATE(), INTERVAL 1 DAY);
END //

DELIMITER ;

-- Enable event scheduler
SET GLOBAL event_scheduler = ON;

-- ============================================
-- END OF DATABASE DUMP
-- ============================================