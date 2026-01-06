import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../core/ferro_colors.dart';
import '../widgets/ferro_logo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  
  // Customer fields
  final _vehicleBrandController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  
  // Driver fields
  final _workingAreaController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  String _driverType = 'towDriver'; // towDriver or deliveryDriver
  String _towTruckType = 'normal'; // normal or flatbed
  String _deliveryVehicleType = 'motorbike'; // motorbike or car
  
  // Supplier fields
  final _storeNameController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _commercialRegisterController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final ap = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const FerroLogo(size: 30),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                lp.translate('signUp'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: FerroColors.textPrimary,
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: lp.isRTL ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  lp.translate('selectRole'),
                  style: const TextStyle(color: FerroColors.textMuted, fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildRoleCard(UserRole.customer, lp.translate('customer'), Icons.person),
                  const SizedBox(width: 12),
                  _buildRoleCard(UserRole.driver, lp.translate('driver'), Icons.local_shipping),
                  const SizedBox(width: 12),
                  _buildRoleCard(UserRole.supplier, lp.translate('supplier'), Icons.store),
                ],
              ),
              const SizedBox(height: 32),
              _buildFormByRole(lp),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                    activeColor: FerroColors.amber,
                    checkColor: FerroColors.black,
                  ),
                  Expanded(
                    child: Text(
                      lp.translate('acceptTerms'),
                      style: const TextStyle(color: FerroColors.textPrimary, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: (_isLoading || !_acceptTerms) ? null : () async {
                  setState(() => _isLoading = true);
                  // Implementation for registration logic...
                  if (mounted) {
                    setState(() => _isLoading = false);
                    _showSuccessDialog(lp);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FerroColors.amber,
                  foregroundColor: FerroColors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: FerroColors.black)
                  : Text(lp.translate('signUp'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(lp.translate('alreadyHaveAccount'), style: const TextStyle(color: FerroColors.textMuted)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      lp.translate('login'),
                      style: const TextStyle(color: FerroColors.amber, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(LanguageProvider lp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: FerroColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _selectedRole == UserRole.customer 
            ? lp.translate('welcomeBack') 
            : lp.translate('pendingReviewTitle'),
          style: const TextStyle(color: FerroColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedRole == UserRole.customer ? Icons.check_circle : Icons.hourglass_empty,
              color: _selectedRole == UserRole.customer ? FerroColors.success : FerroColors.amber,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedRole == UserRole.customer 
                ? "تم تفعيل حسابك بنجاح" 
                : lp.translate('pendingReviewMsg'),
              style: const TextStyle(color: FerroColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to login
            },
            child: Text(lp.translate('continueBtn'), style: const TextStyle(color: FerroColors.amber)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormByRole(LanguageProvider lp) {
    switch (_selectedRole) {
      case UserRole.customer:
        return _buildCustomerForm(lp);
      case UserRole.driver:
        return _buildDriverForm(lp);
      case UserRole.supplier:
        return _buildSupplierForm(lp);
    }
  }

  Widget _buildCustomerForm(LanguageProvider lp) {
    return Column(
      children: [
        _buildTextField(controller: _nameController, label: lp.translate('fullName'), hintText: lp.translate('fullNameHint'), icon: Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(controller: _emailController, label: lp.translate('email'), hintText: lp.translate('emailHint'), icon: Icons.email_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _phoneController, label: lp.translate('phone'), hintText: lp.translate('phoneHint'), icon: Icons.phone_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _passwordController, label: lp.translate('password'), hintText: lp.translate('passwordHint'), icon: Icons.lock_outline, isPassword: true),
        const SizedBox(height: 16),
        _buildTextField(controller: _confirmPasswordController, label: lp.translate('confirmPassword'), hintText: lp.translate('confirmPasswordHint'), icon: Icons.lock_clock_outlined, isPassword: true),
        const SizedBox(height: 16),
        _buildTextField(controller: _cityController, label: lp.translate('city'), hintText: lp.translate('cityHint'), icon: Icons.location_city_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _vehicleBrandController, label: lp.translate('vehicleBrand'), hintText: lp.translate('vehicleBrandHint'), icon: Icons.directions_car_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _vehicleModelController, label: lp.translate('vehicleModel'), hintText: lp.translate('vehicleModelHint'), icon: Icons.model_training_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _vehicleYearController, label: lp.translate('vehicleYear'), hintText: lp.translate('vehicleYearHint'), icon: Icons.calendar_today_outlined),
      ],
    );
  }

  Widget _buildDriverForm(LanguageProvider lp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lp.translate('driverType'), style: const TextStyle(color: FerroColors.textMuted, fontSize: 14)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTypeChip('towDriver', lp.translate('towDriver'), Icons.build_outlined),
            const SizedBox(width: 8),
            _buildTypeChip('deliveryDriver', lp.translate('deliveryDriver'), Icons.delivery_dining),
          ],
        ),
        const SizedBox(height: 24),
        _buildTextField(controller: _nameController, label: lp.translate('fullName'), hintText: lp.translate('fullNameHint'), icon: Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(controller: _emailController, label: lp.translate('email'), hintText: lp.translate('emailHint'), icon: Icons.email_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _phoneController, label: lp.translate('phone'), hintText: lp.translate('phoneHint'), icon: Icons.phone_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _passwordController, label: lp.translate('password'), hintText: lp.translate('passwordHint'), icon: Icons.lock_outline, isPassword: true),
        const SizedBox(height: 16),
        _buildTextField(controller: _confirmPasswordController, label: lp.translate('confirmPassword'), hintText: lp.translate('confirmPasswordHint'), icon: Icons.lock_clock_outlined, isPassword: true),
        const SizedBox(height: 16),
        _buildTextField(controller: _cityController, label: lp.translate('city'), hintText: lp.translate('cityHint'), icon: Icons.location_city_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _workingAreaController, label: lp.translate('workingArea'), hintText: lp.translate('workingAreaHint'), icon: Icons.map_outlined),
        const SizedBox(height: 16),
        if (_driverType == 'towDriver') ...[
          _buildDropdownField(lp.translate('towTruckType'), _towTruckType, {
            'normal': lp.translate('normal'),
            'flatbed': lp.translate('flatbed'),
          }, (val) => setState(() => _towTruckType = val!)),
          const SizedBox(height: 16),
        ] else ...[
          _buildDropdownField(lp.translate('vehicleType'), _deliveryVehicleType, {
            'motorbike': lp.translate('motorbike'),
            'car': lp.translate('car'),
          }, (val) => setState(() => _deliveryVehicleType = val!)),
          const SizedBox(height: 16),
        ],
        _buildTextField(controller: _plateNumberController, label: lp.translate('plateNumber'), hintText: lp.translate('plateNumberHint'), icon: Icons.featured_play_list_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _licenseNumberController, label: lp.translate('licenseNumber'), hintText: lp.translate('licenseNumberHint'), icon: Icons.badge_outlined),
        const SizedBox(height: 24),
        _buildUploadBtn(lp.translate('uploadLicense'), Icons.upload_file),
        const SizedBox(height: 12),
        _buildUploadBtn(lp.translate('uploadPhotos'), Icons.add_a_photo),
      ],
    );
  }

  Widget _buildSupplierForm(LanguageProvider lp) {
    return Column(
      children: [
        _buildTextField(controller: _storeNameController, label: lp.translate('storeName'), hintText: lp.translate('storeNameHint'), icon: Icons.store_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _storePhoneController, label: lp.translate('storePhone'), hintText: lp.translate('phoneHint'), icon: Icons.phone_android_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _ownerNameController, label: lp.translate('ownerName'), hintText: lp.translate('fullNameHint'), icon: Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextField(controller: _ownerPhoneController, label: lp.translate('ownerPhone'), hintText: lp.translate('phoneHint'), icon: Icons.phone_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _emailController, label: lp.translate('email'), hintText: lp.translate('emailHint'), icon: Icons.email_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _passwordController, label: lp.translate('password'), hintText: lp.translate('passwordHint'), icon: Icons.lock_outline, isPassword: true),
        const SizedBox(height: 16),
        _buildTextField(controller: _confirmPasswordController, label: lp.translate('confirmPassword'), hintText: lp.translate('confirmPasswordHint'), icon: Icons.lock_clock_outlined, isPassword: true),
        const SizedBox(height: 16),
        _buildTextField(controller: _cityController, label: lp.translate('city'), hintText: lp.translate('cityHint'), icon: Icons.location_city_outlined),
        const SizedBox(height: 24),
        _buildUploadBtn(lp.translate('storeLocation'), Icons.map),
        const SizedBox(height: 16),
        _buildTextField(controller: _specializationController, label: lp.translate('specialization'), hintText: "تويوتا، قطع غيار استهلاكية، إلخ", icon: Icons.category_outlined),
        const SizedBox(height: 16),
        _buildTextField(controller: _commercialRegisterController, label: lp.translate('commercialRegister'), hintText: "0000000000", icon: Icons.assignment_outlined),
        const SizedBox(height: 24),
        _buildUploadBtn(lp.translate('uploadCR'), Icons.upload_file),
      ],
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _driverType == type;
    return Expanded(
      child: ActionChip(
        onPressed: () => setState(() => _driverType = type),
        avatar: Icon(icon, color: isSelected ? FerroColors.black : FerroColors.textMuted, size: 18),
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? FerroColors.black : FerroColors.textMuted,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: isSelected ? FerroColors.amber : FerroColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isSelected ? FerroColors.amber : FerroColors.border),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, Map<String, String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: FerroColors.textMuted, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: FerroColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: FerroColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: FerroColors.card,
              style: const TextStyle(color: FerroColors.textPrimary),
              items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBtn(String label, IconData icon) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: FerroColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FerroColors.border, style: BorderStyle.solid),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: FerroColors.textMuted),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: FerroColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(UserRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? FerroColors.amber.withOpacity(0.1) : FerroColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? FerroColors.amber : FerroColors.border,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? FerroColors.amber : FerroColors.textMuted,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? FerroColors.amber : FerroColors.textMuted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: FerroColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: FerroColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: FerroColors.textMuted),
        prefixIcon: Icon(icon, color: FerroColors.textMuted),
        filled: true,
        fillColor: FerroColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FerroColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FerroColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FerroColors.amber),
        ),
      ),
    );
  }
}
