import 'package:flutter/material.dart';

enum OrderType { towTruck, spareParts, workshop, carTransport, roadsideAssistance }
enum OrderStatus { 
  pending, 
  onTheWay, 
  arrived, 
  pickedUp, 
  loaded, 
  delivered, 
  completed, 
  cancelled 
}

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final OrderType type;
  OrderStatus status;
  final DateTime date;
  final String? carBrand;
  final String? carModel;
  final String? locationA;
  final String? locationB;
  final Map<String, double>? prices; // For spare parts: original, chinese, alternative
  final double? driverPrice;
  final double? commission;
  final double? totalPrice;
  final Map<String, dynamic>? details;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.type,
    required this.status,
    required this.date,
    this.carBrand,
    this.carModel,
    this.locationA,
    this.locationB,
    this.prices,
    this.driverPrice,
    this.commission,
    this.totalPrice,
    this.details,
  });
}

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [
    Order(
      id: '1',
      customerId: 'user123',
      customerName: 'Ahmed Ali',
      type: OrderType.towTruck,
      status: OrderStatus.onTheWay,
      date: DateTime.now().subtract(const Duration(hours: 1)),
      carBrand: 'Toyota',
      carModel: 'Camry',
      locationA: 'Point A',
      locationB: 'Point B',
      driverPrice: 150,
      commission: 30,
      totalPrice: 180,
    ),
    Order(
      id: '2',
      customerId: 'user123',
      customerName: 'Ahmed Ali',
      type: OrderType.spareParts,
      status: OrderStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 2)),
      carBrand: 'Mercedes',
      carModel: 'E300',
      prices: {'original': 1200, 'chinese': 450, 'alternative': 700},
    ),
  ];

  List<Order> get orders => _orders;

  Order? get activeOrder {
    try {
      return _orders.firstWhere((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled);
    } catch (_) {
      return null;
    }
  }

  List<Order> get pastOrders => _orders.where((o) => o.status == OrderStatus.completed || o.status == OrderStatus.cancelled).toList();

  bool get hasActiveOrder => activeOrder != null;

  void addOrder(Order order) {
    if (hasActiveOrder) {
      throw Exception('activeOrderConstraint');
    }
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = status;
      notifyListeners();
    }
  }
}
