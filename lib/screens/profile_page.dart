import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final ap = Provider.of<AuthProvider>(context);
    final user = ap.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lp.translate('profile'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.edit, size: 16, color: Colors.grey),
                label: Text(lp.translate('edit'), style: const TextStyle(color: Colors.grey)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F1F1F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.user, size: 48, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.role.name.toUpperCase() ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoCard(
            context,
            lp.translate('personalInfo'),
            [
              _buildInfoItem(LucideIcons.mail, lp.translate('email'), user?.email ?? ''),
              _buildInfoItem(LucideIcons.phone, lp.translate('phone'), user?.phone ?? ''),
              if (user?.location != null)
                _buildInfoItem(LucideIcons.mapPin, lp.translate('city'), user!.location!),
              if (user?.personalCode != null)
                _buildInfoItem(LucideIcons.hash, lp.translate('personalCode'), user!.personalCode!),
            ],
          ),
          const SizedBox(height: 16),
          if (user?.role == UserRole.customer && user?.carBrand != null) ...[
            _buildInfoCard(
              context,
              lp.translate('vehicleType'),
              [
                _buildBusinessRow(lp.translate('carBrand'), user!.carBrand!),
                _buildBusinessRow(lp.translate('carModel'), user!.carModel!),
                _buildBusinessRow(lp.translate('carYear'), user!.carYear!),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (user?.role == UserRole.driver || user?.role == UserRole.supplier) ...[
            _buildInfoCard(
              context,
              lp.translate('businessInfo'),
              [
                if (user?.role == UserRole.driver && user?.driverType != null)
                  _buildBusinessRow(lp.translate('vehicleType'), user!.driverType!.name),
                _buildBusinessRow('ID', '#${user?.id}'),
              ],
            ),
            const SizedBox(height: 16),
          ],
          _buildInfoCard(
            context,
            lp.translate('documents'),
            [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: Text(
                  lp.isRTL ? 'عرض المستندات' : 'View Documents',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
