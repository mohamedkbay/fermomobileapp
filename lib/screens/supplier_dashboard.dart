import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../core/ferro_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SupplierDashboard extends StatelessWidget {
  const SupplierDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final ap = Provider.of<AuthProvider>(context);
    final op = Provider.of<OrderProvider>(context);

    // Show spare parts requests
    final sparePartsOrders = op.orders.where((o) => o.type == OrderType.spareParts && o.status != OrderStatus.completed && o.status != OrderStatus.cancelled).toList();

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
              lp.translate('spareParts'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FerroColors.textPrimary),
            ),
            const SizedBox(height: 16),
            if (sparePartsOrders.isEmpty)
              const Center(child: Text('No active spare parts requests', style: TextStyle(color: FerroColors.textMuted)))
            else
              ...sparePartsOrders.map((order) => _buildSupplierOrderCard(context, order, lp, op)),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierOrderCard(BuildContext context, Order order, LanguageProvider lp, OrderProvider op) {
    bool hasPrices = order.prices != null;

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
          _buildInfoRow(LucideIcons.settings, 'Spare Part Name (Demo)'),
          const Divider(height: 32, color: FerroColors.border),
          if (!hasPrices)
            ElevatedButton(
              onPressed: () => _showPriceOfferDialog(context, order, lp, op),
              style: ElevatedButton.styleFrom(
                backgroundColor: FerroColors.amber,
                foregroundColor: FerroColors.black,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(lp.translate('setPrice')),
            )
          else ...[
            Text(lp.translate('waitingApproval'), style: const TextStyle(color: FerroColors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPriceDetail(lp.translate('priceOriginal'), order.prices!['original']!, lp),
            _buildPriceDetail(lp.translate('priceChinese'), order.prices!['chinese']!, lp),
            _buildPriceDetail(lp.translate('priceAlternative'), order.prices!['alternative']!, lp),
          ],
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

  Widget _buildPriceDetail(String label, double price, LanguageProvider lp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: FerroColors.textMuted, fontSize: 13)),
          Text('$price ${lp.translate('currency')}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status, LanguageProvider lp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(lp.translate(status.name), style: const TextStyle(color: Colors.amber, fontSize: 11)),
    );
  }

  void _showPriceOfferDialog(BuildContext context, Order order, LanguageProvider lp, OrderProvider op) {
    final originalCtrl = TextEditingController();
    final chineseCtrl = TextEditingController();
    final alternativeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FerroColors.card,
        title: Text(lp.translate('setPrice'), style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriceField(originalCtrl, lp.translate('priceOriginal'), lp),
            _buildPriceField(chineseCtrl, lp.translate('priceChinese'), lp),
            _buildPriceField(alternativeCtrl, lp.translate('priceAlternative'), lp),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Update with dummy prices
              Navigator.pop(context);
            },
            child: const Text('Send Offer'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(TextEditingController controller, String label, LanguageProvider lp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: FerroColors.textMuted),
          hintText: lp.translate('currency'),
          hintStyle: const TextStyle(color: FerroColors.textMuted, fontSize: 12),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: FerroColors.border)),
        ),
      ),
    );
  }
}
