import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../core/ferro_colors.dart';
import '../widgets/ferro_logo.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/order_provider.dart';
import 'service_request_forms.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final ap = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: FerroColors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${lp.translate('welcomeBack')}, ${ap.user?.name ?? ''}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: FerroColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildQuickActions(context, lp),
            const SizedBox(height: 24),
            Text(
              lp.translate('stats'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FerroColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(lp.translate('activeRequests'), '3', LucideIcons.activity, FerroColors.amber),
                _buildStatCard(lp.translate('completedRequests'), '12', LucideIcons.checkCircle, FerroColors.success),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, LanguageProvider lp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lp.translate('requestService'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: FerroColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                context,
                lp.translate('towTruck'),
                LucideIcons.truck,
                FerroColors.amber,
                () => _showServiceSelection(context, lp),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildServiceCard(
                context,
                lp.translate('spareParts'),
                LucideIcons.settings,
                Colors.blue,
                () => _showServiceSelection(context, lp),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          context,
          lp.translate('workshop'),
          LucideIcons.wrench,
          Colors.green,
          () => _showServiceSelection(context, lp),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: FerroColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FerroColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: FerroColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceSelection(BuildContext context, LanguageProvider lp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: FerroColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: FerroColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                lp.translate('requestService'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: FerroColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildServiceOption(
                      context,
                      lp.translate('towTruckService'),
                      LucideIcons.truck,
                      FerroColors.amber,
                      () => _navigateToForm(context, OrderType.towTruck),
                    ),
                    const SizedBox(height: 12),
                    _buildServiceOption(
                      context,
                      lp.translate('sparePartsService'),
                      LucideIcons.settings,
                      Colors.blue,
                      () => _navigateToForm(context, OrderType.spareParts),
                    ),
                    const SizedBox(height: 12),
                    _buildServiceOption(
                      context,
                      lp.translate('workshopService'),
                      LucideIcons.wrench,
                      Colors.green,
                      () => _navigateToForm(context, OrderType.workshop),
                    ),
                    const SizedBox(height: 12),
                    _buildServiceOption(
                      context,
                      lp.translate('carTransport'),
                      LucideIcons.car,
                      Colors.purple,
                      () => _navigateToForm(context, OrderType.carTransport),
                    ),
                    const SizedBox(height: 12),
                    _buildServiceOption(
                      context,
                      lp.translate('roadsideAssistance'),
                      LucideIcons.alertTriangle,
                      Colors.red,
                      () => _navigateToForm(context, OrderType.roadsideAssistance),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToForm(BuildContext context, OrderType type) {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceRequestForms(serviceType: type),
      ),
    );
  }

  Widget _buildServiceOption(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FerroColors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FerroColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: FerroColors.textPrimary, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, color: FerroColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FerroColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FerroColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: FerroColors.textPrimary,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: FerroColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
