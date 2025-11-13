CREATE DATABASE restaurant_management;
USE restaurant_management;

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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

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
    loyalty_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. Staff Table
CREATE TABLE Staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    role ENUM('Manager', 'Waiter', 'Chef', 'Driver', 'Coordinator') NOT NULL,
    hourly_wage DECIMAL(10, 2) NOT NULL,
    hire_date DATE NOT NULL,
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) ON DELETE CASCADE
);

-- 4. Menu_Items Table
CREATE TABLE Menu_Items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    description TEXT,
    category ENUM('Appetizer', 'Main Course', 'Dessert', 'Beverage', 'Side') NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    preparation_time INT NOT NULL COMMENT 'Time in minutes',
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 5. Tables Table
CREATE TABLE Tables (
    table_id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT NOT NULL,
    table_number VARCHAR(10) NOT NULL,
    seating_capacity INT NOT NULL,
    status ENUM('Available', 'Occupied', 'Reserved') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) ON DELETE CASCADE,
    UNIQUE KEY unique_table_location (location_id, table_number)
);

-- 6. Reservations Table
CREATE TABLE Reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    table_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size INT NOT NULL,
    status ENUM('Confirmed', 'Cancelled', 'Completed', 'No-show') DEFAULT 'Confirmed',
    special_requests TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (table_id) REFERENCES Tables(table_id) ON DELETE CASCADE
);

-- 7. Vehicles Table
CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT NOT NULL,
    vehicle_number VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type ENUM('Car', 'Bike', 'Scooter') NOT NULL,
    registration_number VARCHAR(50) UNIQUE NOT NULL,
    status ENUM('Available', 'In Use', 'Maintenance') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) ON DELETE CASCADE
);

-- 8. Delivery_Agents Table
CREATE TABLE Delivery_Agents (
    agent_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT NOT NULL,
    vehicle_id INT,
    current_status ENUM('Available', 'On Delivery', 'Off Duty') DEFAULT 'Available',
    current_location VARCHAR(255),
    total_deliveries INT DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 5.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id) ON DELETE SET NULL
);

-- 9. Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    location_id INT NOT NULL,
    table_id INT,
    order_type ENUM('Dine-In', 'Pickup', 'Delivery') NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('Pending', 'Preparing', 'Ready', 'In Transit', 'Delivered', 'Completed', 'Cancelled') DEFAULT 'Pending',
    staff_id INT,
    delivery_agent_id INT,
    delivery_address VARCHAR(255),
    delivery_time DATETIME,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) ON DELETE CASCADE,
    FOREIGN KEY (table_id) REFERENCES Tables(table_id) ON DELETE SET NULL,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) ON DELETE SET NULL,
    FOREIGN KEY (delivery_agent_id) REFERENCES Delivery_Agents(agent_id) ON DELETE SET NULL
);

-- 10. Order_Items Table
CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    special_requests TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Menu_Items(item_id) ON DELETE CASCADE
);

-- 11. Payments Table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Digital Wallet') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    transaction_id VARCHAR(100),
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tip_amount DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE
);

-- 12. Inventory Table
CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    location_id INT NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    minimum_stock_level DECIMAL(10, 2) NOT NULL,
    supplier_name VARCHAR(100),
    unit_cost DECIMAL(10, 2),
    last_restocked_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) ON DELETE CASCADE
);

-- 13. Shifts Table
CREATE TABLE Shifts (
    shift_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT NOT NULL,
    location_id INT NOT NULL,
    shift_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    break_duration INT DEFAULT 0 COMMENT 'Break in minutes',
    status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-show') DEFAULT 'Scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES Restaurant_Locations(location_id) ON DELETE CASCADE
);

-- Add foreign key constraint for manager_id in Restaurant_Locations
ALTER TABLE Restaurant_Locations
ADD FOREIGN KEY (manager_id) REFERENCES Staff(staff_id) ON DELETE SET NULL;