import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/order_provider.dart';
import '../core/ferro_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final op = Provider.of<OrderProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lp.translate('requests'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          if (op.hasActiveOrder) ...[
            _buildSectionHeader(lp.translate('activeRequests')),
            const SizedBox(height: 12),
            _buildOrderCard(context, op.activeOrder!, lp, true),
            const SizedBox(height: 24),
          ],
          _buildSectionHeader(lp.translate('completedRequests')),
          const SizedBox(height: 12),
          ...op.pastOrders.map((order) => _buildOrderCard(context, order, lp, false)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: FerroColors.textPrimary,
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, LanguageProvider lp, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FerroColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? FerroColors.amber.withOpacity(0.5) : FerroColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getOrderTypeName(order.type, lp),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, h:mm a').format(order.date),
                    style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
              _buildStatusBadge(order.status, lp),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.car, size: 16, color: FerroColors.textMuted),
              const SizedBox(width: 8),
              Text(
                _getVehicleText(order),
                style: const TextStyle(color: FerroColors.textPrimary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showOrderDetails(context, order, lp),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? FerroColors.amber : FerroColors.black,
              foregroundColor: isActive ? FerroColors.black : FerroColors.textPrimary,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: isActive ? BorderSide.none : const BorderSide(color: FerroColors.border),
              ),
            ),
            child: Text(lp.translate('viewDetails')),
          ),
        ],
      ),
    );
  }

  String _getVehicleText(Order order) {
    if (order.carBrand != null && order.carModel != null) {
      return '${order.carBrand} ${order.carModel}';
    }
    if (order.carModel != null) {
      return order.carModel!;
    }
    if (order.details != null && order.details!.containsKey('vehicleType')) {
      return order.details!['vehicleType'];
    }
    return 'Vehicle Details';
  }

  String _getOrderTypeName(OrderType type, LanguageProvider lp) {
    switch (type) {
      case OrderType.towTruck: return lp.translate('towTruck');
      case OrderType.spareParts: return lp.translate('spareParts');
      case OrderType.workshop: return lp.translate('workshop');
      case OrderType.carTransport: return lp.translate('carTransport');
      case OrderType.roadsideAssistance: return lp.translate('roadsideAssistance');
    }
  }

  Widget _buildStatusBadge(OrderStatus status, LanguageProvider lp) {
    Color color;
    String labelKey;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.amber;
        labelKey = 'pending';
        break;
      case OrderStatus.onTheWay:
        color = Colors.blue;
        labelKey = 'orderStatus_onTheWay';
        break;
      case OrderStatus.completed:
        color = Colors.green;
        labelKey = 'completed';
        break;
      default:
        color = Colors.grey;
        labelKey = status.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        lp.translate(labelKey),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order, LanguageProvider lp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FerroColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: FerroColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_getOrderTypeName(order.type, lp), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  _buildStatusBadge(order.status, lp),
                ],
              ),
              const SizedBox(height: 8),
              Text('#${order.id}', style: const TextStyle(color: FerroColors.textMuted)),
              const Divider(height: 48, color: FerroColors.border),
              _buildDetailItem(LucideIcons.calendar, lp.translate('date'), DateFormat('MMM d, yyyy - h:mm a').format(order.date)),
              _buildDetailItem(LucideIcons.car, lp.translate('vehicleType'), _getVehicleText(order)),
              if (order.locationA != null)
                _buildDetailItem(LucideIcons.mapPin, lp.translate('locationA'), order.locationA!),
              if (order.locationB != null)
                _buildDetailItem(LucideIcons.mapPin, lp.translate('locationB'), order.locationB!),
              const Divider(height: 48, color: FerroColors.border),
              if (order.type == OrderType.spareParts) ...[
                if (order.totalPrice != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lp.translate('totalSpent'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FerroColors.amber)),
                      Text('${order.totalPrice} ${lp.translate('currency')}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FerroColors.amber)),
                    ],
                  ),
                ] else ...[
                  Text(lp.translate('waitingApproval'), style: const TextStyle(color: FerroColors.textMuted)),
                ],
              ],
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: FerroColors.amber),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: FerroColors.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
