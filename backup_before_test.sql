-- MySQL dump 10.13  Distrib 9.4.0, for macos15 (arm64)
--
-- Host: localhost    Database: restaurant_management
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Customers`
--

DROP TABLE IF EXISTS `Customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Customers` (
  `customer_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `zip_code` varchar(10) DEFAULT NULL,
  `loyalty_points` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`),
  KEY `idx_loyalty` (`loyalty_points`),
  CONSTRAINT `customers_chk_1` CHECK ((`loyalty_points` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Customers`
--

LOCK TABLES `Customers` WRITE;
/*!40000 ALTER TABLE `Customers` DISABLE KEYS */;
INSERT INTO `Customers` VALUES (1,'John','Doe','john.doe@email.com','617-555-1001','789 Park Ave','Boston','MA','02115',150,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(2,'Jane','Smith','jane.smith@email.com','617-555-1002','321 Oak St','Cambridge','MA','02139',200,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(3,'Mike','Johnson','mike.j@email.com','617-555-1003','654 Elm St','Somerville','MA','02144',75,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(4,'Emily','Brown','emily.b@email.com','617-555-1004','987 Pine St','Boston','MA','02116',300,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(5,'David','Lee','david.l@email.com','617-555-1005','147 Cedar Ave','Brookline','MA','02446',50,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(6,'Sarah','Wilson','sarah.w@email.com','617-555-1006','258 Birch Rd','Cambridge','MA','02140',175,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(7,'Robert','Taylor','robert.t@email.com','617-555-1007','369 Maple Dr','Boston','MA','02117',120,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(8,'Lisa','Anderson','lisa.a@email.com','617-555-1008','741 Walnut St','Somerville','MA','02145',90,'2025-12-04 06:47:36','2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Delivery_Agents`
--

DROP TABLE IF EXISTS `Delivery_Agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Delivery_Agents` (
  `agent_id` int NOT NULL AUTO_INCREMENT,
  `staff_id` int NOT NULL,
  `vehicle_id` int DEFAULT NULL,
  `current_status` enum('Available','On Delivery','Off Duty') DEFAULT 'Available',
  `current_location` varchar(255) DEFAULT NULL,
  `total_deliveries` int DEFAULT '0',
  `rating` decimal(3,2) DEFAULT '5.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`agent_id`),
  UNIQUE KEY `staff_id` (`staff_id`),
  KEY `vehicle_id` (`vehicle_id`),
  KEY `idx_status` (`current_status`),
  CONSTRAINT `delivery_agents_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `Staff` (`staff_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `delivery_agents_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `Vehicles` (`vehicle_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `delivery_agents_chk_1` CHECK ((`total_deliveries` >= 0)),
  CONSTRAINT `delivery_agents_chk_2` CHECK (((`rating` >= 0) and (`rating` <= 5)))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Delivery_Agents`
--

LOCK TABLES `Delivery_Agents` WRITE;
/*!40000 ALTER TABLE `Delivery_Agents` DISABLE KEYS */;
INSERT INTO `Delivery_Agents` VALUES (1,4,1,'Available',NULL,45,4.80,'2025-12-04 06:47:36'),(2,8,3,'Available',NULL,32,4.60,'2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Delivery_Agents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Inventory`
--

DROP TABLE IF EXISTS `Inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Inventory` (
  `inventory_id` int NOT NULL AUTO_INCREMENT,
  `location_id` int NOT NULL,
  `item_name` varchar(100) NOT NULL,
  `category` varchar(50) NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `minimum_stock_level` decimal(10,2) NOT NULL,
  `supplier_name` varchar(100) DEFAULT NULL,
  `unit_cost` decimal(10,2) DEFAULT NULL,
  `last_restocked_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_id`),
  KEY `idx_location` (`location_id`),
  KEY `idx_quantity` (`quantity`),
  KEY `idx_inventory_location` (`location_id`),
  CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `Restaurant_Locations` (`location_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `inventory_chk_1` CHECK ((`quantity` >= 0)),
  CONSTRAINT `inventory_chk_2` CHECK ((`minimum_stock_level` >= 0)),
  CONSTRAINT `inventory_chk_3` CHECK ((`unit_cost` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Inventory`
--

LOCK TABLES `Inventory` WRITE;
/*!40000 ALTER TABLE `Inventory` DISABLE KEYS */;
INSERT INTO `Inventory` VALUES (1,1,'Salmon Fillet','Seafood',50.00,'lbs',20.00,'Fresh Seafood Co',12.50,'2025-11-10','2025-12-04 06:47:36','2025-12-04 06:47:36'),(2,1,'Romaine Lettuce','Vegetables',30.00,'heads',10.00,'Green Farms',1.50,'2025-11-12','2025-12-04 06:47:36','2025-12-04 06:47:36'),(3,1,'Pizza Dough','Bakery',40.00,'balls',15.00,'Italian Supplies',2.00,'2025-11-11','2025-12-04 06:47:36','2025-12-04 06:47:36'),(4,1,'Chocolate','Bakery',8.00,'lbs',10.00,'Sweet Suppliers',8.00,'2025-11-09','2025-12-04 06:47:36','2025-12-04 06:47:36'),(5,1,'Potatoes','Vegetables',100.00,'lbs',30.00,'Farm Fresh',0.75,'2025-11-10','2025-12-04 06:47:36','2025-12-04 06:47:36'),(6,1,'Chicken Breast','Meat',60.00,'lbs',25.00,'Quality Meats',5.50,'2025-11-11','2025-12-04 06:47:36','2025-12-04 06:47:36'),(7,2,'Salmon Fillet','Seafood',45.00,'lbs',20.00,'Fresh Seafood Co',12.50,'2025-11-11','2025-12-04 06:47:36','2025-12-04 06:47:36'),(8,2,'Mozzarella Cheese','Dairy',35.00,'lbs',15.00,'Dairy Best',6.00,'2025-11-10','2025-12-04 06:47:36','2025-12-04 06:47:36'),(9,2,'Tomatoes','Vegetables',50.00,'lbs',20.00,'Green Farms',2.00,'2025-11-12','2025-12-04 06:47:36','2025-12-04 06:47:36'),(10,3,'Pasta','Dry Goods',80.00,'lbs',30.00,'Italian Supplies',1.75,'2025-11-09','2025-12-04 06:47:36','2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Inventory` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_CheckLowStock` AFTER UPDATE ON `inventory` FOR EACH ROW BEGIN
    DECLARE v_warning VARCHAR(255);
    
    IF NEW.quantity < NEW.minimum_stock_level THEN
        SET v_warning = CONCAT('Low stock alert for ', NEW.item_name, ' at location ', NEW.location_id);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Menu_Items`
--

DROP TABLE IF EXISTS `Menu_Items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Menu_Items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `item_name` varchar(100) NOT NULL,
  `description` text,
  `category` enum('Appetizer','Main Course','Dessert','Beverage','Side') NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `preparation_time` int NOT NULL COMMENT 'Time in minutes',
  `is_available` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`),
  KEY `idx_category` (`category`),
  KEY `idx_available` (`is_available`),
  CONSTRAINT `menu_items_chk_1` CHECK ((`price` > 0)),
  CONSTRAINT `menu_items_chk_2` CHECK ((`preparation_time` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Menu_Items`
--

LOCK TABLES `Menu_Items` WRITE;
/*!40000 ALTER TABLE `Menu_Items` DISABLE KEYS */;
INSERT INTO `Menu_Items` VALUES (1,'Caesar Salad','Fresh romaine with parmesan and croutons','Appetizer',8.99,10,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(2,'Bruschetta','Toasted bread with tomatoes and basil','Appetizer',7.99,8,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(3,'Mozzarella Sticks','Crispy fried mozzarella with marinara','Appetizer',9.99,12,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(4,'Grilled Salmon','Atlantic salmon with vegetables','Main Course',24.99,20,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(5,'Margherita Pizza','Classic tomato and mozzarella','Main Course',16.99,15,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(6,'Chicken Alfredo','Fettuccine with creamy alfredo sauce','Main Course',18.99,18,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(7,'Ribeye Steak','12oz prime ribeye with sides','Main Course',32.99,25,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(8,'Vegetarian Pasta','Penne with seasonal vegetables','Main Course',15.99,16,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(9,'Chocolate Cake','Rich chocolate layer cake','Dessert',7.99,5,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(10,'Tiramisu','Classic Italian dessert','Dessert',8.99,5,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(11,'Cheesecake','New York style cheesecake','Dessert',7.49,5,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(12,'Iced Tea','Freshly brewed iced tea','Beverage',2.99,2,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(13,'Lemonade','Fresh squeezed lemonade','Beverage',3.49,3,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(14,'Coffee','Premium brewed coffee','Beverage',2.49,3,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(15,'French Fries','Crispy golden fries','Side',4.99,8,1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(16,'Garlic Bread','Toasted garlic bread','Side',4.49,6,1,'2025-12-04 06:47:36','2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Menu_Items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Order_Items`
--

DROP TABLE IF EXISTS `Order_Items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Order_Items` (
  `order_item_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `special_requests` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_item_id`),
  KEY `idx_order` (`order_id`),
  KEY `idx_orderitems_item` (`item_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `Orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `Menu_Items` (`item_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `order_items_chk_1` CHECK ((`quantity` > 0)),
  CONSTRAINT `order_items_chk_2` CHECK ((`unit_price` >= 0)),
  CONSTRAINT `order_items_chk_3` CHECK ((`subtotal` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Order_Items`
--

LOCK TABLES `Order_Items` WRITE;
/*!40000 ALTER TABLE `Order_Items` DISABLE KEYS */;
INSERT INTO `Order_Items` VALUES (1,1,1,2,8.99,17.98,NULL,'2025-12-04 06:47:36'),(2,1,4,1,24.99,24.99,'Medium rare','2025-12-04 06:47:36'),(3,1,12,1,2.99,2.99,NULL,'2025-12-04 06:47:36'),(4,2,5,2,16.99,33.98,'Extra cheese','2025-12-04 06:47:36'),(5,2,9,2,7.99,15.98,NULL,'2025-12-04 06:47:36'),(6,2,13,1,2.49,2.49,NULL,'2025-12-04 06:47:36'),(7,3,7,2,32.99,65.98,'Well done','2025-12-04 06:47:36'),(8,3,12,2,2.99,5.98,NULL,'2025-12-04 06:47:36'),(9,4,6,2,18.99,37.98,NULL,'2025-12-04 06:47:36'),(10,5,4,2,24.99,49.98,NULL,'2025-12-04 06:47:36'),(11,5,2,2,7.99,15.98,NULL,'2025-12-04 06:47:36'),(12,5,14,2,2.99,5.98,NULL,'2025-12-04 06:47:36'),(13,6,7,2,32.99,65.98,NULL,'2025-12-04 06:47:36'),(14,6,10,2,8.99,17.98,NULL,'2025-12-04 06:47:36'),(15,6,14,2,2.99,5.98,NULL,'2025-12-04 06:47:36'),(16,7,5,2,16.99,33.98,NULL,'2025-12-04 06:47:36'),(17,7,1,2,8.99,17.98,NULL,'2025-12-04 06:47:36'),(18,7,15,1,4.99,4.99,NULL,'2025-12-04 06:47:36'),(19,8,6,2,18.99,37.98,NULL,'2025-12-04 06:47:36'),(20,8,11,1,7.49,7.49,NULL,'2025-12-04 06:47:36'),(21,9,4,1,24.99,24.99,NULL,'2025-12-04 06:47:36'),(22,9,2,2,7.99,15.98,NULL,'2025-12-04 06:47:36'),(23,9,16,1,4.49,4.49,NULL,'2025-12-04 06:47:36'),(24,9,12,1,2.99,2.99,NULL,'2025-12-04 06:47:36'),(25,10,7,2,32.99,65.98,NULL,'2025-12-04 06:47:36'),(26,10,9,1,7.99,7.99,NULL,'2025-12-04 06:47:36'),(27,10,13,2,2.49,4.98,NULL,'2025-12-04 06:47:36'),(28,11,5,2,16.99,33.98,NULL,'2025-12-04 06:47:36'),(29,11,4,1,24.99,24.99,NULL,'2025-12-04 06:47:36'),(30,11,15,1,4.99,4.99,NULL,'2025-12-04 06:47:36'),(31,11,12,1,2.99,2.99,NULL,'2025-12-04 06:47:36'),(32,12,6,2,18.99,37.98,NULL,'2025-12-04 06:47:36'),(33,12,3,2,9.99,19.98,NULL,'2025-12-04 06:47:36'),(34,12,13,1,2.49,2.49,NULL,'2025-12-04 06:47:36'),(35,13,5,2,16.99,33.98,NULL,'2025-12-04 06:47:36'),(36,13,11,1,7.49,7.49,NULL,'2025-12-04 06:47:36'),(37,14,7,2,32.99,65.98,NULL,'2025-12-04 06:47:36'),(38,14,1,1,8.99,8.99,NULL,'2025-12-04 06:47:36'),(39,14,10,1,8.99,8.99,NULL,'2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Order_Items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Orders`
--

DROP TABLE IF EXISTS `Orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `location_id` int NOT NULL,
  `table_id` int DEFAULT NULL,
  `order_type` enum('Dine-In','Pickup','Delivery') NOT NULL,
  `order_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `total_amount` decimal(10,2) NOT NULL,
  `status` enum('Pending','Preparing','Ready','In Transit','Delivered','Completed','Cancelled') DEFAULT 'Pending',
  `staff_id` int DEFAULT NULL,
  `delivery_agent_id` int DEFAULT NULL,
  `delivery_address` varchar(255) DEFAULT NULL,
  `delivery_time` datetime DEFAULT NULL,
  `special_instructions` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`),
  KEY `table_id` (`table_id`),
  KEY `staff_id` (`staff_id`),
  KEY `delivery_agent_id` (`delivery_agent_id`),
  KEY `idx_order_type` (`order_type`),
  KEY `idx_order_date` (`order_date`),
  KEY `idx_status` (`status`),
  KEY `idx_orders_customer` (`customer_id`),
  KEY `idx_orders_location` (`location_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `Customers` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `Restaurant_Locations` (`location_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`table_id`) REFERENCES `Tables` (`table_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_4` FOREIGN KEY (`staff_id`) REFERENCES `Staff` (`staff_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `orders_ibfk_5` FOREIGN KEY (`delivery_agent_id`) REFERENCES `Delivery_Agents` (`agent_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `orders_chk_1` CHECK ((`total_amount` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Orders`
--

LOCK TABLES `Orders` WRITE;
/*!40000 ALTER TABLE `Orders` DISABLE KEYS */;
INSERT INTO `Orders` VALUES (1,1,1,1,'Dine-In','2025-11-01 12:30:00',45.96,'Completed',2,NULL,NULL,NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(2,2,1,NULL,'Delivery','2025-11-01 18:45:00',52.47,'Delivered',2,1,'321 Oak St, Cambridge, MA 02139',NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(3,3,2,6,'Dine-In','2025-11-02 19:15:00',67.95,'Completed',6,NULL,NULL,NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(4,4,1,NULL,'Pickup','2025-11-03 13:20:00',33.97,'Completed',2,NULL,NULL,NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(5,5,2,NULL,'Delivery','2025-11-04 20:00:00',71.96,'Delivered',6,2,'147 Cedar Ave, Brookline, MA 02446',NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(6,6,3,10,'Dine-In','2025-11-05 14:30:00',89.94,'Completed',10,NULL,NULL,NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(7,7,1,2,'Dine-In','2025-11-06 17:45:00',56.96,'Completed',2,NULL,NULL,NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(8,8,2,NULL,'Pickup','2025-11-07 12:15:00',41.96,'Completed',6,NULL,NULL,NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(9,1,1,NULL,'Delivery','2025-11-08 19:30:00',48.96,'Delivered',2,1,'789 Park Ave, Boston, MA 02115',NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(10,2,3,11,'Dine-In','2025-11-09 13:00:00',75.94,'Completed',10,NULL,NULL,NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(11,3,1,3,'Dine-In','2025-11-10 18:20:00',64.95,'Completed',2,NULL,NULL,NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(12,4,2,NULL,'Delivery','2025-11-11 20:15:00',59.96,'Delivered',6,2,'987 Pine St, Boston, MA 02116',NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(13,5,1,NULL,'Pickup','2025-11-12 14:45:00',37.97,'Completed',2,NULL,NULL,NULL,NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(14,6,3,NULL,'Delivery','2025-11-13 19:00:00',82.95,'Pending',10,2,'258 Birch Rd, Cambridge, MA 02140',NULL,NULL,'2025-12-04 06:47:36','2025-12-04 20:01:57');
/*!40000 ALTER TABLE `Orders` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_ValidateOrder` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
    IF NEW.order_type = 'Delivery' AND NEW.delivery_address IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Delivery address required for delivery orders';
    END IF;
    
    IF NEW.order_type = 'Dine-In' AND NEW.table_id IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Table ID required for dine-in orders';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_UpdateInventoryOnOrder` AFTER UPDATE ON `orders` FOR EACH ROW BEGIN
    IF NEW.status = 'Completed' AND OLD.status != 'Completed' THEN
        INSERT INTO Inventory (location_id, item_name, category, quantity, unit, minimum_stock_level)
        VALUES (NEW.location_id, 'Order Log', 'System', 0, 'count', 0)
        ON DUPLICATE KEY UPDATE quantity = quantity;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Payments`
--

DROP TABLE IF EXISTS `Payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `payment_method` enum('Cash','Credit Card','Debit Card','Digital Wallet') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_status` enum('Pending','Completed','Failed','Refunded') DEFAULT 'Pending',
  `transaction_id` varchar(100) DEFAULT NULL,
  `payment_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tip_amount` decimal(10,2) DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `order_id` (`order_id`),
  KEY `idx_status` (`payment_status`),
  KEY `idx_date` (`payment_date`),
  KEY `idx_payments_order` (`order_id`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `Orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `payments_chk_1` CHECK ((`amount` >= 0)),
  CONSTRAINT `payments_chk_2` CHECK ((`tip_amount` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Payments`
--

LOCK TABLES `Payments` WRITE;
/*!40000 ALTER TABLE `Payments` DISABLE KEYS */;
INSERT INTO `Payments` VALUES (1,1,'Credit Card',45.96,'Completed','TXN001','2025-11-01 13:00:00',8.00,'2025-12-04 06:47:36'),(2,2,'Digital Wallet',52.47,'Completed','TXN002','2025-11-01 19:15:00',10.00,'2025-12-04 06:47:36'),(3,3,'Cash',67.95,'Completed',NULL,'2025-11-02 20:00:00',12.00,'2025-12-04 06:47:36'),(4,4,'Debit Card',33.97,'Completed','TXN004','2025-11-03 13:45:00',5.00,'2025-12-04 06:47:36'),(5,5,'Credit Card',71.96,'Completed','TXN005','2025-11-04 20:30:00',14.00,'2025-12-04 06:47:36'),(6,6,'Cash',89.94,'Completed',NULL,'2025-11-05 15:15:00',15.00,'2025-12-04 06:47:36'),(7,7,'Credit Card',56.96,'Completed','TXN007','2025-11-06 18:30:00',10.00,'2025-12-04 06:47:36'),(8,8,'Digital Wallet',41.96,'Completed','TXN008','2025-11-07 12:45:00',7.00,'2025-12-04 06:47:36'),(9,9,'Credit Card',48.96,'Completed','TXN009','2025-11-08 20:00:00',9.00,'2025-12-04 06:47:36'),(10,10,'Debit Card',75.94,'Completed','TXN010','2025-11-09 13:45:00',13.00,'2025-12-04 06:47:36'),(11,11,'Cash',64.95,'Completed',NULL,'2025-11-10 19:00:00',11.00,'2025-12-04 06:47:36'),(12,12,'Credit Card',59.96,'Completed','TXN012','2025-11-11 20:45:00',11.00,'2025-12-04 06:47:36'),(13,13,'Digital Wallet',37.97,'Completed','TXN013','2025-11-12 15:15:00',6.00,'2025-12-04 06:47:36'),(14,14,'Credit Card',82.95,'Pending',NULL,'2025-11-13 19:30:00',0.00,'2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Payments` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_AddLoyaltyPoints` AFTER INSERT ON `payments` FOR EACH ROW BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_points INT;
    
    SELECT customer_id INTO v_customer_id
    FROM Orders
    WHERE order_id = NEW.order_id;
    
    SET v_points = FLOOR(NEW.amount);
    
    UPDATE Customers
    SET loyalty_points = loyalty_points + v_points
    WHERE customer_id = v_customer_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Reservations`
--

DROP TABLE IF EXISTS `Reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Reservations` (
  `reservation_id` int NOT NULL AUTO_INCREMENT,
  `customer_id` int NOT NULL,
  `table_id` int NOT NULL,
  `reservation_date` date NOT NULL,
  `reservation_time` time NOT NULL,
  `party_size` int NOT NULL,
  `status` enum('Confirmed','Cancelled','Completed','No-show') DEFAULT 'Confirmed',
  `special_requests` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reservation_id`),
  KEY `customer_id` (`customer_id`),
  KEY `table_id` (`table_id`),
  KEY `idx_date` (`reservation_date`),
  KEY `idx_status` (`status`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `Customers` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`table_id`) REFERENCES `Tables` (`table_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reservations_chk_1` CHECK ((`party_size` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Reservations`
--

LOCK TABLES `Reservations` WRITE;
/*!40000 ALTER TABLE `Reservations` DISABLE KEYS */;
INSERT INTO `Reservations` VALUES (1,1,1,'2025-12-10','18:00:00',2,'Confirmed','Window seat preferred','2025-12-04 06:47:36'),(2,2,3,'2025-12-10','19:00:00',4,'Confirmed','Birthday celebration','2025-12-04 06:47:36'),(3,3,6,'2025-12-15','18:30:00',4,'Confirmed',NULL,'2025-12-04 06:47:36'),(4,4,8,'2025-12-15','19:30:00',6,'Confirmed','Anniversary dinner','2025-12-04 06:47:36'),(5,5,10,'2025-12-20','18:00:00',4,'Confirmed',NULL,'2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Reservations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Restaurant_Locations`
--

DROP TABLE IF EXISTS `Restaurant_Locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Restaurant_Locations` (
  `location_id` int NOT NULL AUTO_INCREMENT,
  `location_name` varchar(100) NOT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  `zip_code` varchar(10) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `opening_time` time NOT NULL,
  `closing_time` time NOT NULL,
  `manager_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`location_id`),
  KEY `idx_city` (`city`),
  KEY `idx_manager` (`manager_id`),
  CONSTRAINT `restaurant_locations_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `Staff` (`staff_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Restaurant_Locations`
--

LOCK TABLES `Restaurant_Locations` WRITE;
/*!40000 ALTER TABLE `Restaurant_Locations` DISABLE KEYS */;
INSERT INTO `Restaurant_Locations` VALUES (1,'Downtown Bistro','123 Main St','Boston','MA','02108','617-555-0001','10:00:00','22:00:00',1,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(2,'Harbor View','456 Ocean Ave','Boston','MA','02110','617-555-0002','11:00:00','23:00:00',5,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(3,'Cambridge Corner','789 Mass Ave','Cambridge','MA','02139','617-555-0003','09:00:00','21:00:00',9,'2025-12-04 06:47:36','2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Restaurant_Locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Shifts`
--

DROP TABLE IF EXISTS `Shifts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Shifts` (
  `shift_id` int NOT NULL AUTO_INCREMENT,
  `staff_id` int NOT NULL,
  `location_id` int NOT NULL,
  `shift_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `break_duration` int DEFAULT '0' COMMENT 'Break in minutes',
  `status` enum('Scheduled','Completed','Cancelled','No-show') DEFAULT 'Scheduled',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`shift_id`),
  KEY `location_id` (`location_id`),
  KEY `idx_date` (`shift_date`),
  KEY `idx_staff` (`staff_id`),
  CONSTRAINT `shifts_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `Staff` (`staff_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `shifts_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `Restaurant_Locations` (`location_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `shifts_chk_1` CHECK ((`break_duration` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Shifts`
--

LOCK TABLES `Shifts` WRITE;
/*!40000 ALTER TABLE `Shifts` DISABLE KEYS */;
INSERT INTO `Shifts` VALUES (1,1,1,'2025-11-28','09:00:00','17:00:00',30,'Completed','2025-12-04 06:47:36'),(2,2,1,'2025-11-28','10:00:00','18:00:00',30,'Completed','2025-12-04 06:47:36'),(3,3,1,'2025-11-28','11:00:00','20:00:00',30,'Completed','2025-12-04 06:47:36'),(4,4,1,'2025-11-28','16:00:00','22:00:00',0,'Completed','2025-12-04 06:47:36'),(5,5,2,'2025-11-28','09:00:00','17:00:00',30,'Completed','2025-12-04 06:47:36'),(6,6,2,'2025-11-28','11:00:00','19:00:00',30,'Completed','2025-12-04 06:47:36'),(7,7,2,'2025-11-28','12:00:00','21:00:00',30,'Completed','2025-12-04 06:47:36'),(8,9,3,'2025-11-28','09:00:00','17:00:00',30,'Completed','2025-12-04 06:47:36'),(9,10,3,'2025-11-28','10:00:00','18:00:00',30,'Completed','2025-12-04 06:47:36'),(10,1,1,'2025-12-03','09:00:00','17:00:00',30,'Scheduled','2025-12-04 06:47:36'),(11,2,1,'2025-12-03','10:00:00','18:00:00',30,'Scheduled','2025-12-04 06:47:36'),(12,3,1,'2025-12-03','11:00:00','20:00:00',30,'Scheduled','2025-12-04 06:47:36'),(13,4,1,'2025-12-03','16:00:00','22:00:00',0,'Scheduled','2025-12-04 06:47:36'),(14,1,1,'2025-12-04','09:00:00','17:00:00',30,'Scheduled','2025-12-04 06:47:36'),(15,2,1,'2025-12-04','10:00:00','18:00:00',30,'Scheduled','2025-12-04 06:47:36'),(16,3,1,'2025-12-04','11:00:00','20:00:00',30,'Scheduled','2025-12-04 06:47:36'),(17,5,2,'2025-12-04','09:00:00','17:00:00',30,'Scheduled','2025-12-04 06:47:36'),(18,6,2,'2025-12-04','11:00:00','19:00:00',30,'Scheduled','2025-12-04 06:47:36'),(19,7,2,'2025-12-04','12:00:00','21:00:00',30,'Scheduled','2025-12-04 06:47:36'),(20,9,3,'2025-12-05','09:00:00','17:00:00',30,'Scheduled','2025-12-04 06:47:36'),(21,10,3,'2025-12-05','10:00:00','18:00:00',30,'Scheduled','2025-12-04 06:47:36'),(22,1,1,'2025-12-06','09:00:00','17:00:00',30,'Scheduled','2025-12-04 06:47:36'),(23,2,1,'2025-12-06','10:00:00','18:00:00',30,'Scheduled','2025-12-04 06:47:36'),(24,5,2,'2025-12-06','09:00:00','17:00:00',30,'Scheduled','2025-12-04 06:47:36'),(25,9,3,'2025-12-06','09:00:00','17:00:00',30,'Scheduled','2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Shifts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Staff`
--

DROP TABLE IF EXISTS `Staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Staff` (
  `staff_id` int NOT NULL AUTO_INCREMENT,
  `location_id` int NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `role` enum('Manager','Waiter','Chef','Driver','Coordinator') NOT NULL,
  `hourly_wage` decimal(10,2) NOT NULL,
  `hire_date` date NOT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`staff_id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_location` (`location_id`),
  CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `Restaurant_Locations` (`location_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `staff_chk_1` CHECK ((`hourly_wage` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Staff`
--

LOCK TABLES `Staff` WRITE;
/*!40000 ALTER TABLE `Staff` DISABLE KEYS */;
INSERT INTO `Staff` VALUES (1,1,'Sarah','Manager','sarah.m@restaurant.com','617-555-2001','Manager',25.00,'2023-01-15','Active','2025-12-04 06:47:36'),(2,1,'Tom','Server','tom.s@restaurant.com','617-555-2002','Waiter',15.00,'2023-03-20','Active','2025-12-04 06:47:36'),(3,1,'Lisa','Chef','lisa.c@restaurant.com','617-555-2003','Chef',22.00,'2023-02-10','Active','2025-12-04 06:47:36'),(4,1,'Mark','Driver','mark.d@restaurant.com','617-555-2004','Driver',18.00,'2023-04-05','Active','2025-12-04 06:47:36'),(5,2,'Emily','Manager','emily.m@restaurant.com','617-555-2005','Manager',25.00,'2023-01-20','Active','2025-12-04 06:47:36'),(6,2,'James','Waiter','james.w@restaurant.com','617-555-2006','Waiter',15.00,'2023-05-10','Active','2025-12-04 06:47:36'),(7,2,'Anna','Chef','anna.c@restaurant.com','617-555-2007','Chef',22.00,'2023-03-15','Active','2025-12-04 06:47:36'),(8,2,'Chris','Driver','chris.d@restaurant.com','617-555-2008','Driver',18.00,'2023-06-01','Active','2025-12-04 06:47:36'),(9,3,'Michael','Manager','michael.m@restaurant.com','617-555-2009','Manager',26.00,'2023-02-01','Active','2025-12-04 06:47:36'),(10,3,'Rachel','Waiter','rachel.w@restaurant.com','617-555-2010','Waiter',16.00,'2023-04-15','Active','2025-12-04 06:47:36'),(11,1,'Alex','Coordinator','alex.co@restaurant.com','617-555-2011','Coordinator',20.00,'2023-07-01','Active','2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Tables`
--

DROP TABLE IF EXISTS `Tables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Tables` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `location_id` int NOT NULL,
  `table_number` varchar(10) NOT NULL,
  `seating_capacity` int NOT NULL,
  `status` enum('Available','Occupied','Reserved') DEFAULT 'Available',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `unique_table_location` (`location_id`,`table_number`),
  KEY `idx_status` (`status`),
  CONSTRAINT `tables_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `Restaurant_Locations` (`location_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tables_chk_1` CHECK ((`seating_capacity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Tables`
--

LOCK TABLES `Tables` WRITE;
/*!40000 ALTER TABLE `Tables` DISABLE KEYS */;
INSERT INTO `Tables` VALUES (1,1,'T1',2,'Available','2025-12-04 06:47:36'),(2,1,'T2',4,'Available','2025-12-04 06:47:36'),(3,1,'T3',4,'Available','2025-12-04 06:47:36'),(4,1,'T4',6,'Available','2025-12-04 06:47:36'),(5,1,'T5',2,'Available','2025-12-04 06:47:36'),(6,2,'T1',4,'Available','2025-12-04 06:47:36'),(7,2,'T2',4,'Available','2025-12-04 06:47:36'),(8,2,'T3',6,'Available','2025-12-04 06:47:36'),(9,2,'T4',2,'Available','2025-12-04 06:47:36'),(10,3,'T1',4,'Available','2025-12-04 06:47:36'),(11,3,'T2',6,'Available','2025-12-04 06:47:36'),(12,3,'T3',4,'Available','2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Tables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `User_Credentials`
--

DROP TABLE IF EXISTS `User_Credentials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `User_Credentials` (
  `credential_id` int NOT NULL AUTO_INCREMENT,
  `staff_id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`credential_id`),
  UNIQUE KEY `staff_id` (`staff_id`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_username` (`username`),
  CONSTRAINT `user_credentials_ibfk_1` FOREIGN KEY (`staff_id`) REFERENCES `Staff` (`staff_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User_Credentials`
--

LOCK TABLES `User_Credentials` WRITE;
/*!40000 ALTER TABLE `User_Credentials` DISABLE KEYS */;
INSERT INTO `User_Credentials` VALUES (1,1,'sarah.manager','password123','2025-12-04 15:00:40','2025-12-04 06:47:36','2025-12-04 20:00:40'),(2,2,'tom.server','password123',NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(3,11,'alex.coordinator','password123',NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(4,5,'emily.manager','password123',NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(5,9,'michael.manager','password123',NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(6,3,'lisa.chef','password123',NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(7,6,'james.waiter','password123',NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36'),(8,7,'anna.chef','password123',NULL,'2025-12-04 06:47:36','2025-12-04 06:47:36');
/*!40000 ALTER TABLE `User_Credentials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Vehicles`
--

DROP TABLE IF EXISTS `Vehicles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Vehicles` (
  `vehicle_id` int NOT NULL AUTO_INCREMENT,
  `location_id` int NOT NULL,
  `vehicle_number` varchar(20) NOT NULL,
  `vehicle_type` enum('Car','Bike','Scooter') NOT NULL,
  `registration_number` varchar(50) NOT NULL,
  `status` enum('Available','In Use','Maintenance') DEFAULT 'Available',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`vehicle_id`),
  UNIQUE KEY `vehicle_number` (`vehicle_number`),
  UNIQUE KEY `registration_number` (`registration_number`),
  KEY `location_id` (`location_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `vehicles_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `Restaurant_Locations` (`location_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Vehicles`
--

LOCK TABLES `Vehicles` WRITE;
/*!40000 ALTER TABLE `Vehicles` DISABLE KEYS */;
INSERT INTO `Vehicles` VALUES (1,1,'V001','Bike','MA-123-ABC','Available','2025-12-04 06:47:36'),(2,1,'V002','Car','MA-456-DEF','Available','2025-12-04 06:47:36'),(3,2,'V003','Bike','MA-789-GHI','Available','2025-12-04 06:47:36'),(4,3,'V004','Scooter','MA-321-JKL','Available','2025-12-04 06:47:36');
/*!40000 ALTER TABLE `Vehicles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_dailyrevenuebychannel`
--

DROP TABLE IF EXISTS `vw_dailyrevenuebychannel`;
/*!50001 DROP VIEW IF EXISTS `vw_dailyrevenuebychannel`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_dailyrevenuebychannel` AS SELECT 
 1 AS `order_date`,
 1 AS `order_type`,
 1 AS `order_count`,
 1 AS `total_revenue`,
 1 AS `avg_order_value`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_lowstockitems`
--

DROP TABLE IF EXISTS `vw_lowstockitems`;
/*!50001 DROP VIEW IF EXISTS `vw_lowstockitems`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_lowstockitems` AS SELECT 
 1 AS `inventory_id`,
 1 AS `location_name`,
 1 AS `item_name`,
 1 AS `quantity`,
 1 AS `unit`,
 1 AS `minimum_stock_level`,
 1 AS `supplier_name`,
 1 AS `stock_percentage`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_staffperformance`
--

DROP TABLE IF EXISTS `vw_staffperformance`;
/*!50001 DROP VIEW IF EXISTS `vw_staffperformance`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_staffperformance` AS SELECT 
 1 AS `staff_id`,
 1 AS `staff_name`,
 1 AS `role`,
 1 AS `location_name`,
 1 AS `orders_handled`,
 1 AS `total_sales`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_topcustomers`
--

DROP TABLE IF EXISTS `vw_topcustomers`;
/*!50001 DROP VIEW IF EXISTS `vw_topcustomers`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_topcustomers` AS SELECT 
 1 AS `customer_id`,
 1 AS `customer_name`,
 1 AS `email`,
 1 AS `loyalty_points`,
 1 AS `tier`,
 1 AS `total_orders`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'restaurant_management'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `evt_CleanupOldReservations` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `evt_CleanupOldReservations` ON SCHEDULE EVERY 1 DAY STARTS '2025-12-05 01:47:36' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
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
END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'restaurant_management'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_CalculateOrderTotal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_CalculateOrderTotal`(p_order_id INT) RETURNS decimal(10,2)
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10, 2);
    
    SELECT COALESCE(SUM(subtotal), 0.00) INTO v_total
    FROM Order_Items
    WHERE order_id = p_order_id;
    
    RETURN v_total;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_GetChannelRevenue` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_GetChannelRevenue`(
    p_order_type VARCHAR(20),
    p_start_date DATE,
    p_end_date DATE
) RETURNS decimal(10,2)
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE v_revenue DECIMAL(10, 2);
    
    SELECT COALESCE(SUM(total_amount), 0.00) INTO v_revenue
    FROM Orders
    WHERE order_type = p_order_type
    AND DATE(order_date) BETWEEN p_start_date AND p_end_date
    AND status IN ('Completed', 'Delivered');
    
    RETURN v_revenue;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_GetCustomerTier` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_GetCustomerTier`(p_customer_id INT) RETURNS varchar(20) CHARSET utf8mb4
    READS SQL DATA
    DETERMINISTIC
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_GetDeliveryCost` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_GetDeliveryCost`(p_order_id INT) RETURNS decimal(10,2)
    READS SQL DATA
    DETERMINISTIC
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_AddCustomer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddCustomer`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_AddCustomerOrderItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddCustomerOrderItem`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_AddInventoryItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddInventoryItem`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_AddOrderItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddOrderItem`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_AssignDelivery` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AssignDelivery`(IN p_order_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_AuthenticateUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AuthenticateUser`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_CancelOrder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CancelOrder`(IN p_order_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_CompleteOrder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CompleteOrder`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_CreateCustomerOrder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CreateCustomerOrder`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_CreateReservation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CreateReservation`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_DeleteCustomer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DeleteCustomer`(IN p_customer_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error deleting customer';
    END;
    
    START TRANSACTION;
    DELETE FROM Customers WHERE customer_id = p_customer_id;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_DeleteInventoryItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DeleteInventoryItem`(IN p_inventory_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error deleting inventory item';
    END;
    
    START TRANSACTION;
    DELETE FROM Inventory WHERE inventory_id = p_inventory_id;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetAllCustomers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAllCustomers`()
BEGIN
    SELECT customer_id, first_name, last_name, email, phone_number, loyalty_points
    FROM Customers 
    ORDER BY loyalty_points DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetAllDeliveryAgents` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAllDeliveryAgents`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetAllReservations` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAllReservations`(IN p_location_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetAllShifts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAllShifts`(IN p_location_id INT)
BEGIN
    SELECT sh.shift_id, sh.shift_date, sh.start_time, sh.end_time, 
           sh.break_duration, sh.status,
           CONCAT(s.first_name, ' ', s.last_name) as staff_name,
           s.role
    FROM Shifts sh
    JOIN Staff s ON sh.staff_id = s.staff_id
    WHERE sh.location_id = p_location_id
    ORDER BY sh.shift_date DESC, sh.start_time;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetAllStaff` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAllStaff`()
BEGIN
    SELECT s.staff_id, s.first_name, s.last_name, s.email, s.phone_number,
           s.role, s.hourly_wage, s.hire_date, s.status,
           rl.location_name
    FROM Staff s
    JOIN Restaurant_Locations rl ON s.location_id = rl.location_id
    ORDER BY s.location_id, s.role, s.last_name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetAllVehicles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAllVehicles`()
BEGIN
    SELECT v.vehicle_id, v.vehicle_number, v.vehicle_type, 
           v.registration_number, v.status,
           rl.location_name
    FROM Vehicles v
    JOIN Restaurant_Locations rl ON v.location_id = rl.location_id
    ORDER BY v.location_id, v.vehicle_number;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetAvailableDrivers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAvailableDrivers`(IN p_location_id INT)
BEGIN
    SELECT da.agent_id, 
           CONCAT(s.first_name, ' ', s.last_name) as driver_name,
           da.current_status, da.rating
    FROM Delivery_Agents da
    JOIN Staff s ON da.staff_id = s.staff_id
    WHERE s.location_id = p_location_id AND s.status = 'Active';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetAvailableMenuItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAvailableMenuItems`()
BEGIN
    SELECT item_id, item_name, description, category, price, preparation_time
    FROM Menu_Items
    WHERE is_available = TRUE
    ORDER BY category, item_name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetAvailableTables` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAvailableTables`(IN p_location_id INT)
BEGIN
    SELECT table_id, table_number, seating_capacity
    FROM Tables
    WHERE location_id = p_location_id AND status = 'Available'
    ORDER BY table_number;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetCustomerById` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCustomerById`(IN p_customer_id INT)
BEGIN
    SELECT * FROM Customers WHERE customer_id = p_customer_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetDailyRevenueTrend` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetDailyRevenueTrend`(IN p_location_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetDashboardStats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetDashboardStats`(IN p_location_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetDeliveriesByLocation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetDeliveriesByLocation`(IN p_location_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetDeliveryAgentsByLocation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetDeliveryAgentsByLocation`(IN p_location_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetInventoryByLocation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetInventoryByLocation`(IN p_location_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetInventoryItemById` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetInventoryItemById`(IN p_inventory_id INT)
BEGIN
    SELECT * FROM Inventory WHERE inventory_id = p_inventory_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetLowStock` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetLowStock`(IN p_location_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetOrderDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetOrderDetails`(IN p_order_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetOrderItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetOrderItems`(IN p_order_id INT)
BEGIN
    SELECT oi.order_item_id, mi.item_name, mi.category,
           oi.quantity, oi.unit_price, oi.subtotal, oi.special_requests
    FROM Order_Items oi
    JOIN Menu_Items mi ON oi.item_id = mi.item_id
    WHERE oi.order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetOrdersByLocation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetOrdersByLocation`(IN p_location_id INT)
BEGIN
    SELECT o.order_id, o.order_type, o.total_amount, o.status, o.order_date,
           CONCAT(c.first_name, ' ', c.last_name) as customer_name, 
           c.phone_number
    FROM Orders o
    JOIN Customers c ON o.customer_id = c.customer_id
    WHERE o.location_id = p_location_id
    ORDER BY o.order_date DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetOrderTotal` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetOrderTotal`(IN p_order_id INT)
BEGIN
    SELECT total_amount FROM Orders WHERE order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetPaymentByOrder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetPaymentByOrder`(IN p_order_id INT)
BEGIN
    SELECT payment_method, amount, payment_status, payment_date, tip_amount
    FROM Payments
    WHERE order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetRecentOrders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetRecentOrders`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetRevenueByChannel` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetRevenueByChannel`(IN p_location_id INT)
BEGIN
    SELECT order_type, 
           SUM(total_amount) as revenue,
           COUNT(*) as order_count,
           AVG(total_amount) as avg_order_value
    FROM Orders
    WHERE location_id = p_location_id 
    AND status IN ('Completed', 'Delivered')
    GROUP BY order_type;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetStaffByLocation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetStaffByLocation`(IN p_location_id INT)
BEGIN
    SELECT staff_id, first_name, last_name, email, phone_number,
           role, hourly_wage, hire_date, status
    FROM Staff
    WHERE location_id = p_location_id
    ORDER BY role, last_name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetTablesByLocation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetTablesByLocation`(IN p_location_id INT)
BEGIN
    SELECT table_id, table_number, seating_capacity, status
    FROM Tables
    WHERE location_id = p_location_id
    ORDER BY table_number;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetTopCustomers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetTopCustomers`()
BEGIN
    SELECT customer_id, first_name, last_name, loyalty_points,
           (SELECT COUNT(*) FROM Orders WHERE customer_id = c.customer_id) as total_orders
    FROM Customers c
    ORDER BY loyalty_points DESC
    LIMIT 10;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetTopSellingItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetTopSellingItems`(IN p_location_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetUpcomingReservations` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetUpcomingReservations`(IN p_location_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetUpcomingShifts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetUpcomingShifts`(IN p_location_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetVehiclesByLocation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetVehiclesByLocation`(IN p_location_id INT)
BEGIN
    SELECT vehicle_id, vehicle_number, vehicle_type, 
           registration_number, status
    FROM Vehicles
    WHERE location_id = p_location_id
    ORDER BY vehicle_number;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ProcessOrder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ProcessOrder`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_UpdateCustomer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateCustomer`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_UpdateInventory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateInventory`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_UpdateInventoryItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateInventoryItem`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_UpdateOrderStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateOrderStatus`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_dailyrevenuebychannel`
--

/*!50001 DROP VIEW IF EXISTS `vw_dailyrevenuebychannel`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_dailyrevenuebychannel` AS select cast(`orders`.`order_date` as date) AS `order_date`,`orders`.`order_type` AS `order_type`,count(0) AS `order_count`,sum(`orders`.`total_amount`) AS `total_revenue`,avg(`orders`.`total_amount`) AS `avg_order_value` from `orders` where (`orders`.`status` in ('Completed','Delivered')) group by cast(`orders`.`order_date` as date),`orders`.`order_type` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_lowstockitems`
--

/*!50001 DROP VIEW IF EXISTS `vw_lowstockitems`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_lowstockitems` AS select `i`.`inventory_id` AS `inventory_id`,`rl`.`location_name` AS `location_name`,`i`.`item_name` AS `item_name`,`i`.`quantity` AS `quantity`,`i`.`unit` AS `unit`,`i`.`minimum_stock_level` AS `minimum_stock_level`,`i`.`supplier_name` AS `supplier_name`,round(((`i`.`quantity` / `i`.`minimum_stock_level`) * 100),2) AS `stock_percentage` from (`inventory` `i` join `restaurant_locations` `rl` on((`i`.`location_id` = `rl`.`location_id`))) where (`i`.`quantity` < `i`.`minimum_stock_level`) order by round(((`i`.`quantity` / `i`.`minimum_stock_level`) * 100),2) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_staffperformance`
--

/*!50001 DROP VIEW IF EXISTS `vw_staffperformance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_staffperformance` AS select `s`.`staff_id` AS `staff_id`,concat(`s`.`first_name`,' ',`s`.`last_name`) AS `staff_name`,`s`.`role` AS `role`,`rl`.`location_name` AS `location_name`,count(`o`.`order_id`) AS `orders_handled`,coalesce(sum(`o`.`total_amount`),0) AS `total_sales` from ((`staff` `s` left join `orders` `o` on((`s`.`staff_id` = `o`.`staff_id`))) left join `restaurant_locations` `rl` on((`s`.`location_id` = `rl`.`location_id`))) where (`s`.`status` = 'Active') group by `s`.`staff_id`,`s`.`first_name`,`s`.`last_name`,`s`.`role`,`rl`.`location_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_topcustomers`
--

/*!50001 DROP VIEW IF EXISTS `vw_topcustomers`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_topcustomers` AS select `c`.`customer_id` AS `customer_id`,concat(`c`.`first_name`,' ',`c`.`last_name`) AS `customer_name`,`c`.`email` AS `email`,`c`.`loyalty_points` AS `loyalty_points`,`fn_GetCustomerTier`(`c`.`customer_id`) AS `tier`,(select count(0) from `orders` where (`orders`.`customer_id` = `c`.`customer_id`)) AS `total_orders` from `customers` `c` order by `c`.`loyalty_points` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-04 16:10:56
