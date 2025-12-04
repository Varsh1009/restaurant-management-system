from app.database import Database

class OrderModel:
    """Order operations - ALL using stored procedures"""
    
    @staticmethod
    def get_all_by_location(location_id):
        """Get all orders for a location"""
        try:
            return Database.call_procedure('sp_GetOrdersByLocation', (location_id,))
        except Exception as e:
            print(f"Error getting orders: {e}")
            raise
    
    @staticmethod
    def get_by_id(order_id):
        """Get order details by ID"""
        try:
            result = Database.call_procedure('sp_GetOrderDetails', (order_id,))
            return result[0] if result else None
        except Exception as e:
            print(f"Error getting order details: {e}")
            raise
    
    @staticmethod
    def get_items(order_id):
        """Get items in an order"""
        try:
            return Database.call_procedure('sp_GetOrderItems', (order_id,))
        except Exception as e:
            print(f"Error getting order items: {e}")
            raise
    
    @staticmethod
    def create(customer_id, location_id, order_type, table_id, delivery_address, staff_id):
        """Create new order"""
        try:
            result = Database.call_procedure('sp_ProcessOrder', 
                (customer_id, location_id, order_type, table_id, delivery_address, staff_id))
            return result[0]['order_id'] if result else None
        except Exception as e:
            print(f"Error creating order: {e}")
            raise
    
    @staticmethod
    def add_item(order_id, item_id, quantity, special_requests):
        """Add item to order"""
        try:
            Database.call_procedure('sp_AddOrderItem', (order_id, item_id, quantity, special_requests))
            return True
        except Exception as e:
            print(f"Error adding item: {e}")
            raise
    
    @staticmethod
    def update_status(order_id, status):
        """Update order status"""
        try:
            Database.call_procedure('sp_UpdateOrderStatus', (order_id, status))
            return True
        except Exception as e:
            print(f"Error updating status: {e}")
            raise
    
    @staticmethod
    def complete(order_id, payment_method, tip_amount):
        """Complete order with payment"""
        try:
            Database.call_procedure('sp_CompleteOrder', (order_id, payment_method, tip_amount))
            return True
        except Exception as e:
            print(f"Error completing order: {e}")
            raise
    
    @staticmethod
    def cancel(order_id):
        """Cancel an order"""
        try:
            Database.call_procedure('sp_CancelOrder', (order_id,))
            return True
        except Exception as e:
            print(f"Error cancelling order: {e}")
            raise
    
    @staticmethod
    def assign_delivery(order_id):
        """Assign delivery driver to order"""
        try:
            Database.call_procedure('sp_AssignDelivery', (order_id,))
            return True
        except Exception as e:
            print(f"Error assigning delivery: {e}")
            raise
    
    @staticmethod
    def get_payment(order_id):
        """Get payment details for an order"""
        try:
            result = Database.call_procedure('sp_GetPaymentByOrder', (order_id,))
            return result[0] if result else None
        except Exception as e:
            print(f"Error getting payment: {e}")
            raise


class CustomerModel:
    """Customer operations - ALL using stored procedures"""
    
    @staticmethod
    def get_all():
        """Get all customers"""
        try:
            return Database.call_procedure('sp_GetAllCustomers', ())
        except Exception as e:
            print(f"Error getting customers: {e}")
            raise
    
    @staticmethod
    def get_by_id(customer_id):
        """Get customer by ID"""
        try:
            result = Database.call_procedure('sp_GetCustomerById', (customer_id,))
            return result[0] if result else None
        except Exception as e:
            print(f"Error getting customer: {e}")
            raise
    
    @staticmethod
    def create(first_name, last_name, email, phone, address, city, state, zip_code):
        """Create new customer"""
        try:
            result = Database.call_procedure('sp_AddCustomer', 
                (first_name, last_name, email, phone, address, city, state, zip_code))
            return result[0]['customer_id'] if result else None
        except Exception as e:
            print(f"Error adding customer: {e}")
            raise
    
    @staticmethod
    def update(customer_id, first_name, last_name, email, phone, address, city, state, zip_code):
        """Update customer information"""
        try:
            Database.call_procedure('sp_UpdateCustomer', 
                (customer_id, first_name, last_name, email, phone, address, city, state, zip_code))
            return True
        except Exception as e:
            print(f"Error updating customer: {e}")
            raise
    
    @staticmethod
    def delete(customer_id):
        """Delete customer"""
        try:
            Database.call_procedure('sp_DeleteCustomer', (customer_id,))
            return True
        except Exception as e:
            print(f"Error deleting customer: {e}")
            raise


class InventoryModel:
    """Inventory operations - ALL using stored procedures"""
    
    @staticmethod
    def get_by_location(location_id):
        """Get all inventory for a location"""
        try:
            return Database.call_procedure('sp_GetInventoryByLocation', (location_id,))
        except Exception as e:
            print(f"Error getting inventory: {e}")
            raise
    
    @staticmethod
    def get_low_stock(location_id):
        """Get low stock items"""
        try:
            return Database.call_procedure('sp_GetLowStock', (location_id,))
        except Exception as e:
            print(f"Error getting low stock: {e}")
            raise
    
    @staticmethod
    def restock(inventory_id, quantity):
        """Restock inventory item (quick update)"""
        try:
            Database.call_procedure('sp_UpdateInventory', (inventory_id, quantity))
            return True
        except Exception as e:
            print(f"Error restocking: {e}")
            raise
    
    # ✅ NEW METHODS FOR FULL CRUD
    @staticmethod
    def get_by_id(inventory_id):
        """Get single inventory item by ID"""
        try:
            result = Database.call_procedure('sp_GetInventoryItemById', (inventory_id,))
            return result[0] if result else None
        except Exception as e:
            print(f"Error getting inventory item: {e}")
            raise
    
    @staticmethod
    def create(location_id, item_name, category, quantity, unit, 
               minimum_stock_level, supplier_name, unit_cost):
        """Create new inventory item"""
        try:
            result = Database.call_procedure('sp_AddInventoryItem', 
                (location_id, item_name, category, quantity, unit, 
                 minimum_stock_level, supplier_name, unit_cost))
            return result[0]['inventory_id'] if result else None
        except Exception as e:
            print(f"Error adding inventory item: {e}")
            raise
    
    @staticmethod
    def update_item(inventory_id, item_name, category, quantity, unit,
                    minimum_stock_level, supplier_name, unit_cost):
        """Update inventory item details (full edit)"""
        try:
            Database.call_procedure('sp_UpdateInventoryItem',
                (inventory_id, item_name, category, quantity, unit,
                 minimum_stock_level, supplier_name, unit_cost))
            return True
        except Exception as e:
            print(f"Error updating inventory item: {e}")
            raise
    
    @staticmethod
    def delete(inventory_id):
        """Delete inventory item"""
        try:
            Database.call_procedure('sp_DeleteInventoryItem', (inventory_id,))
            return True
        except Exception as e:
            print(f"Error deleting inventory item: {e}")
            raise


class MenuModel:
    """Menu operations - ALL using stored procedures"""
    
    @staticmethod
    def get_all_available():
        """Get all available menu items"""
        try:
            return Database.call_procedure('sp_GetAvailableMenuItems', ())
        except Exception as e:
            print(f"Error getting menu: {e}")
            raise


class TableModel:
    """Table operations - ALL using stored procedures"""
    
    @staticmethod
    def get_available(location_id):
        """Get available tables for a location"""
        try:
            return Database.call_procedure('sp_GetAvailableTables', (location_id,))
        except Exception as e:
            print(f"Error getting available tables: {e}")
            raise
    
    @staticmethod
    def get_by_location(location_id):
        """Get all tables for a location"""
        try:
            return Database.call_procedure('sp_GetTablesByLocation', (location_id,))
        except Exception as e:
            print(f"Error getting tables: {e}")
            raise


class ReservationModel:
    """Reservation operations - ALL using stored procedures"""
    
    @staticmethod
    def get_upcoming(location_id):
        """Get upcoming reservations for a location"""
        try:
            return Database.call_procedure('sp_GetUpcomingReservations', (location_id,))
        except Exception as e:
            print(f"Error getting reservations: {e}")
            raise
    
    @staticmethod
    def get_all(location_id):
        """✅ NEW: Get all reservations (including past)"""
        try:
            return Database.call_procedure('sp_GetAllReservations', (location_id,))
        except Exception as e:
            print(f"Error getting all reservations: {e}")
            raise
    
    @staticmethod
    def create(customer_id, table_id, date, time, party_size, special_requests):
        """Create new reservation"""
        try:
            result = Database.call_procedure('sp_CreateReservation', 
                (customer_id, table_id, date, time, party_size, special_requests))
            return result[0]['reservation_id'] if result else None
        except Exception as e:
            print(f"Error creating reservation: {e}")
            raise


class DeliveryModel:
    """Delivery operations - ALL using stored procedures"""
    
    @staticmethod
    def get_all_by_location(location_id):
        """Get all delivery orders for a location"""
        try:
            return Database.call_procedure('sp_GetDeliveriesByLocation', (location_id,))
        except Exception as e:
            print(f"Error getting deliveries: {e}")
            raise
    
    @staticmethod
    def get_available_drivers(location_id):
        """Get available drivers for a location"""
        try:
            return Database.call_procedure('sp_GetAvailableDrivers', (location_id,))
        except Exception as e:
            print(f"Error getting available drivers: {e}")
            raise
    
    @staticmethod
    def get_all_agents():
        """✅ NEW: Get all delivery agents with details"""
        try:
            return Database.call_procedure('sp_GetAllDeliveryAgents', ())
        except Exception as e:
            print(f"Error getting all delivery agents: {e}")
            raise


class DashboardModel:
    """Dashboard operations - ALL using stored procedures"""
    
    @staticmethod
    def get_stats(location_id):
        """Get dashboard statistics"""
        try:
            result = Database.call_procedure('sp_GetDashboardStats', (location_id,))
            if result:
                return {
                    'today_revenue': float(result[0]['today_revenue']),
                    'today_orders': result[0]['today_orders'],
                    'pending_orders': result[0]['pending_orders'],
                    'low_stock': result[0]['low_stock']
                }
            return {
                'today_revenue': 0.0,
                'today_orders': 0,
                'pending_orders': 0,
                'low_stock': 0
            }
        except Exception as e:
            print(f"Error getting dashboard stats: {e}")
            raise
    
    @staticmethod
    def get_recent_orders(location_id, limit=10):
        """Get recent orders for dashboard"""
        try:
            return Database.call_procedure('sp_GetRecentOrders', (location_id, limit))
        except Exception as e:
            print(f"Error getting recent orders: {e}")
            raise


class ReportModel:
    """Report and analytics operations - ALL using stored procedures"""
    
    @staticmethod
    def get_revenue_by_channel(location_id):
        """Get revenue breakdown by order type"""
        try:
            return Database.call_procedure('sp_GetRevenueByChannel', (location_id,))
        except Exception as e:
            print(f"Error getting channel revenue: {e}")
            raise
    
    @staticmethod
    def get_daily_trend(location_id):
        """Get daily revenue trend"""
        try:
            return Database.call_procedure('sp_GetDailyRevenueTrend', (location_id,))
        except Exception as e:
            print(f"Error getting daily trend: {e}")
            raise
    
    @staticmethod
    def get_top_items(location_id):
        """Get top selling items"""
        try:
            return Database.call_procedure('sp_GetTopSellingItems', (location_id,))
        except Exception as e:
            print(f"Error getting top items: {e}")
            raise
    
    @staticmethod
    def get_top_customers():
        """Get top customers by loyalty points"""
        try:
            return Database.call_procedure('sp_GetTopCustomers', ())
        except Exception as e:
            print(f"Error getting top customers: {e}")
            raise


# ==================== ✅ NEW MODEL CLASSES ====================

class StaffModel:
    """Staff operations - ALL using stored procedures"""
    
    @staticmethod
    def get_all():
        """Get all staff across all locations"""
        try:
            return Database.call_procedure('sp_GetAllStaff', ())
        except Exception as e:
            print(f"Error getting staff: {e}")
            raise
    
    @staticmethod
    def get_by_location(location_id):
        """Get staff by location"""
        try:
            return Database.call_procedure('sp_GetStaffByLocation', (location_id,))
        except Exception as e:
            print(f"Error getting staff by location: {e}")
            raise


class ShiftModel:
    """Shift operations - ALL using stored procedures"""
    
    @staticmethod
    def get_all(location_id):
        """Get all shifts for a location"""
        try:
            return Database.call_procedure('sp_GetAllShifts', (location_id,))
        except Exception as e:
            print(f"Error getting shifts: {e}")
            raise
    
    @staticmethod
    def get_upcoming(location_id):
        """Get upcoming shifts for a location"""
        try:
            return Database.call_procedure('sp_GetUpcomingShifts', (location_id,))
        except Exception as e:
            print(f"Error getting upcoming shifts: {e}")
            raise


class VehicleModel:
    """Vehicle operations - ALL using stored procedures"""
    
    @staticmethod
    def get_all():
        """Get all vehicles across all locations"""
        try:
            return Database.call_procedure('sp_GetAllVehicles', ())
        except Exception as e:
            print(f"Error getting vehicles: {e}")
            raise
    
    @staticmethod
    def get_by_location(location_id):
        """Get vehicles by location"""
        try:
            return Database.call_procedure('sp_GetVehiclesByLocation', (location_id,))
        except Exception as e:
            print(f"Error getting vehicles by location: {e}")
            raise