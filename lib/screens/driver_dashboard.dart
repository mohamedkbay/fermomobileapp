import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../core/ferro_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final ap = Provider.of<AuthProvider>(context);
    final op = Provider.of<OrderProvider>(context);

    // For demo: show all pending or in-progress orders that match driver type
    final availableOrders = op.orders.where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: FerroColors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${lp.translate('welcomeBack')}, ${ap.user?.name ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: FerroColors.textPrimary),
            ),
            const SizedBox(height: 24),
            Text(
              lp.translate('activeRequests'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FerroColors.textPrimary),
            ),
            const SizedBox(height: 16),
            if (availableOrders.isEmpty)
              const Center(child: Text('No active orders', style: TextStyle(color: FerroColors.textMuted)))
            else
              ...availableOrders.map((order) => _buildDriverOrderCard(context, order, lp, op)),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverOrderCard(BuildContext context, Order order, LanguageProvider lp, OrderProvider op) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FerroColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FerroColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.customerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              _buildStatusBadge(order.status, lp),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(LucideIcons.car, '${order.carBrand} ${order.carModel}'),
          if (order.locationA != null) _buildInfoRow(LucideIcons.mapPin, '${order.locationA} ➔ ${order.locationB}'),
          const Divider(height: 32, color: FerroColors.border),
          if (order.status == OrderStatus.pending)
            ElevatedButton(
              onPressed: () => _showSetPriceDialog(context, order, lp, op),
              style: ElevatedButton.styleFrom(
                backgroundColor: FerroColors.amber,
                foregroundColor: FerroColors.black,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(lp.translate('setPrice')),
            )
          else
            _buildStatusStepper(context, order, lp, op),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: FerroColors.amber),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status, LanguageProvider lp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(lp.translate(status.name), style: const TextStyle(color: Colors.blue, fontSize: 11)),
    );
  }

  void _showSetPriceDialog(BuildContext context, Order order, LanguageProvider lp, OrderProvider op) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FerroColors.card,
        title: Text(lp.translate('setPrice'), style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: lp.translate('currency'),
            hintStyle: const TextStyle(color: FerroColors.textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: FerroColors.border)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              op.updateOrderStatus(order.id, OrderStatus.onTheWay);
              Navigator.pop(context);
            },
            child: const Text('Send Price'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStepper(BuildContext context, Order order, LanguageProvider lp, OrderProvider op) {
    final List<OrderStatus> stages = order.type == OrderType.towTruck 
      ? [OrderStatus.onTheWay, OrderStatus.loaded, OrderStatus.delivered]
      : [OrderStatus.onTheWay, OrderStatus.pickedUp, OrderStatus.delivered];

    return Column(
      children: stages.map((stage) {
        bool isCurrent = order.status == stage;
        bool isDone = stages.indexOf(order.status) > stages.indexOf(stage) || order.status == OrderStatus.completed;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(
                isDone ? Icons.check_circle : (isCurrent ? Icons.radio_button_checked : Icons.radio_button_off),
                color: isDone || isCurrent ? FerroColors.amber : FerroColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                lp.translate('orderStatus_${stage.name}'),
                style: TextStyle(
                  color: isDone || isCurrent ? Colors.white : FerroColors.textMuted,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isCurrent) ...[
                const Spacer(),
                TextButton(
                  onPressed: () {
                    int nextIdx = stages.indexOf(stage) + 1;
                    if (nextIdx < stages.length) {
                      op.updateOrderStatus(order.id, stages[nextIdx]);
                    } else {
                      op.updateOrderStatus(order.id, OrderStatus.completed);
                    }
                  },
                  child: const Text('Next Stage'),
                ),
              ]
            ],
          ),
        );
      }).toList(),
    );
  }
}
