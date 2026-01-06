import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../core/ferro_colors.dart';

class ServiceRequestForms extends StatefulWidget {
  final OrderType serviceType;

  const ServiceRequestForms({super.key, required this.serviceType});

  @override
  State<ServiceRequestForms> createState() => _ServiceRequestFormsState();
}

class _ServiceRequestFormsState extends State<ServiceRequestForms> {
  final _formKey = GlobalKey<FormState>();
  
  // Common Controllers
  final _locationAController = TextEditingController(); // Pickup / Current Location
  final _locationBController = TextEditingController(); // Dropoff / Delivery Address
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  // Specific State Variables
  String? _selectedVehicleType;
  String? _selectedVehicleCondition;
  String? _selectedPaymentMethod = 'cash';
  
  // Spare Parts Specific
  final _carDetailsController = TextEditingController();
  final _vinController = TextEditingController();
  final _partNameController = TextEditingController();
  String? _selectedPartCategory;
  String? _selectedPreferredPartType;

  // Workshop Specific
  String? _selectedServiceType;
  String? _selectedUrgencyLevel;

  // Car Transport Specific
  String? _selectedTransportType;

  // Roadside Assistance Specific
  String? _selectedAssistanceType;

  // Demo Data Lists
  final List<String> _vehicleTypes = ['sedan', 'suv', 'pickup', 'van'];
  final List<String> _vehicleConditions = ['accident', 'breakdown', 'stuck'];
  final List<String> _paymentMethods = ['cash', 'online'];
  
  final List<String> _partCategories = ['engine', 'electrical', 'body', 'suspension'];
  final List<String> _preferredPartTypes = ['original', 'aftermarket', 'any'];
  
  final List<String> _workshopServiceTypes = ['simpleRepair', 'partReplacement', 'tireInflation', 'batteryService', 'oilFluids'];
  final List<String> _urgencyLevels = ['normalUrgency', 'urgent'];

  final List<String> _transportTypes = ['openTransport', 'closedTransport'];
  final List<String> _assistanceTypes = ['jumpStart', 'flatTire', 'fuelDelivery', 'lockedCar'];

  @override
  void initState() {
    super.initState();
    // Auto-fill user data
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone; // Assuming phone exists in user model, otherwise empty
    }
  }

  @override
  void dispose() {
    _locationAController.dispose();
    _locationBController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    
    _carDetailsController.dispose();
    _vinController.dispose();
    _partNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: FerroColors.black,
      appBar: AppBar(
        backgroundColor: FerroColors.black,
        iconTheme: const IconThemeData(color: FerroColors.textPrimary),
        title: Text(
          _getServiceTitle(lp),
          style: const TextStyle(color: FerroColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(lp.translate('customerDetails')),
              const SizedBox(height: 16),
              _buildTextField(lp.translate('fullName'), _nameController, readOnly: true),
              const SizedBox(height: 12),
              _buildTextField(lp.translate('phoneNumber'), _phoneController, readOnly: true), // Editable? For now readonly if from profile
              
              const SizedBox(height: 24),
              _buildSectionTitle(lp.translate('requestDetails')),
              const SizedBox(height: 16),
              
              // Dynamic Fields based on Service Type
              ..._buildServiceSpecificFields(lp),

              const SizedBox(height: 24),
              _buildSectionTitle(lp.translate('paymentMethod')),
              const SizedBox(height: 16),
              _buildPaymentSelector(lp),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FerroColors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitRequest,
                  child: Text(
                    lp.translate('confirmRequest'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getServiceTitle(LanguageProvider lp) {
    switch (widget.serviceType) {
      case OrderType.towTruck:
        return lp.translate('towTruckService');
      case OrderType.spareParts:
        return lp.translate('sparePartsService');
      case OrderType.workshop:
        return lp.translate('workshopService');
      case OrderType.carTransport:
        return lp.translate('carTransport');
      case OrderType.roadsideAssistance:
        return lp.translate('roadsideAssistance');
    }
  }

  List<Widget> _buildServiceSpecificFields(LanguageProvider lp) {
    switch (widget.serviceType) {
      case OrderType.towTruck:
        return [
          _buildTextField(lp.translate('pickupLocation'), _locationAController, icon: LucideIcons.mapPin),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('dropoffLocation'), _locationBController, icon: LucideIcons.mapPin),
          const SizedBox(height: 12),
          _buildDropdown(
            label: lp.translate('vehicleType'),
            value: _selectedVehicleType,
            items: _vehicleTypes,
            onChanged: (val) => setState(() => _selectedVehicleType = val),
            lp: lp,
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            label: lp.translate('vehicleCondition'),
            value: _selectedVehicleCondition,
            items: _vehicleConditions,
            onChanged: (val) => setState(() => _selectedVehicleCondition = val),
            lp: lp,
          ),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('notes'), _notesController, maxLines: 3),
          const SizedBox(height: 12),
          _buildPhotoUploadButton(lp),
        ];

      case OrderType.spareParts:
        return [
          _buildTextField(lp.translate('carMakeModel'), _carDetailsController, icon: LucideIcons.car),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('vin'), _vinController, icon: LucideIcons.fileText),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('requiredPart'), _partNameController, icon: LucideIcons.package),
          const SizedBox(height: 12),
          _buildDropdown(
            label: lp.translate('partCategory'),
            value: _selectedPartCategory,
            items: _partCategories,
            onChanged: (val) => setState(() => _selectedPartCategory = val),
            lp: lp,
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            label: lp.translate('preferredPartType'),
            value: _selectedPreferredPartType,
            items: _preferredPartTypes,
            onChanged: (val) => setState(() => _selectedPreferredPartType = val),
            lp: lp,
          ),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('notes'), _notesController, maxLines: 3),
          const SizedBox(height: 12),
          _buildPhotoUploadButton(lp),
        ];

      case OrderType.workshop:
        return [
          _buildTextField(lp.translate('currentLocation'), _locationAController, icon: LucideIcons.mapPin),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('carMakeModel'), _carDetailsController, icon: LucideIcons.car),
          const SizedBox(height: 12),
          _buildDropdown(
            label: lp.translate('serviceType'),
            value: _selectedServiceType,
            items: _workshopServiceTypes,
            onChanged: (val) => setState(() => _selectedServiceType = val),
            lp: lp,
          ),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('problemDescription'), _notesController, maxLines: 3),
          const SizedBox(height: 12),
          _buildDropdown(
            label: lp.translate('urgencyLevel'),
            value: _selectedUrgencyLevel,
            items: _urgencyLevels,
            onChanged: (val) => setState(() => _selectedUrgencyLevel = val),
            lp: lp,
          ),
          const SizedBox(height: 12),
          _buildPhotoUploadButton(lp),
        ];

      case OrderType.carTransport:
        return [
          _buildTextField(lp.translate('pickupLocation'), _locationAController, icon: LucideIcons.mapPin),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('dropoffLocation'), _locationBController, icon: LucideIcons.mapPin),
          const SizedBox(height: 12),
          _buildDropdown(
            label: lp.translate('transportType'),
            value: _selectedTransportType,
            items: _transportTypes,
            onChanged: (val) => setState(() => _selectedTransportType = val),
            lp: lp,
          ),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('carMakeModel'), _carDetailsController, icon: LucideIcons.car),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('notes'), _notesController, maxLines: 3),
        ];

      case OrderType.roadsideAssistance:
        return [
          _buildTextField(lp.translate('currentLocation'), _locationAController, icon: LucideIcons.mapPin),
          const SizedBox(height: 12),
          _buildDropdown(
            label: lp.translate('assistanceType'),
            value: _selectedAssistanceType,
            items: _assistanceTypes,
            onChanged: (val) => setState(() => _selectedAssistanceType = val),
            lp: lp,
          ),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('carMakeModel'), _carDetailsController, icon: LucideIcons.car),
          const SizedBox(height: 12),
          _buildTextField(lp.translate('notes'), _notesController, maxLines: 3),
          const SizedBox(height: 12),
          _buildPhotoUploadButton(lp),
        ];
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: FerroColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, int maxLines = 1, IconData? icon}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      style: const TextStyle(color: FerroColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: FerroColors.textMuted),
        prefixIcon: icon != null ? Icon(icon, color: FerroColors.textMuted) : null,
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
      validator: (value) {
        if (!readOnly && (value == null || value.isEmpty)) {
          return 'Required field'; // Simple validation
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required LanguageProvider lp,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(lp.translate(item), style: const TextStyle(color: FerroColors.textPrimary)),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: FerroColors.card,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: FerroColors.textMuted),
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
      validator: (value) => value == null ? 'Required' : null,
    );
  }

  Widget _buildPaymentSelector(LanguageProvider lp) {
    return Row(
      children: _paymentMethods.map((method) {
        final isSelected = _selectedPaymentMethod == method;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = method),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? FerroColors.amber.withOpacity(0.2) : FerroColors.card,
                border: Border.all(
                  color: isSelected ? FerroColors.amber : FerroColors.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  lp.translate(method),
                  style: TextStyle(
                    color: isSelected ? FerroColors.amber : FerroColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhotoUploadButton(LanguageProvider lp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: FerroColors.border, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
        color: FerroColors.card,
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.camera, color: FerroColors.textMuted, size: 32),
          const SizedBox(height: 8),
          Text(
            lp.translate('uploadPhoto'),
            style: const TextStyle(color: FerroColors.textMuted),
          ),
        ],
      ),
    );
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      Map<String, dynamic> details = {
        'paymentMethod': _selectedPaymentMethod,
        'phone': _phoneController.text,
        'notes': _notesController.text,
      };

      // Populate details based on type
      switch (widget.serviceType) {
        case OrderType.towTruck:
          details.addAll({
            'vehicleType': _selectedVehicleType,
            'vehicleCondition': _selectedVehicleCondition,
          });
          break;
        case OrderType.spareParts:
          details.addAll({
            'carDetails': _carDetailsController.text,
            'vin': _vinController.text,
            'partName': _partNameController.text,
            'partCategory': _selectedPartCategory,
            'preferredPartType': _selectedPreferredPartType,
          });
          break;
        case OrderType.workshop:
          details.addAll({
            'carDetails': _carDetailsController.text,
            'serviceType': _selectedServiceType,
            'urgencyLevel': _selectedUrgencyLevel,
          });
          break;
        case OrderType.carTransport:
          details.addAll({
            'transportType': _selectedTransportType,
            'carDetails': _carDetailsController.text,
          });
          break;
        case OrderType.roadsideAssistance:
          details.addAll({
            'assistanceType': _selectedAssistanceType,
            'carDetails': _carDetailsController.text,
          });
          break;
      }

      final newOrder = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: user?.id ?? 'guest',
        customerName: _nameController.text,
        type: widget.serviceType,
        status: OrderStatus.pending,
        date: DateTime.now(),
        locationA: _locationAController.text.isNotEmpty ? _locationAController.text : null,
        locationB: _locationBController.text.isNotEmpty ? _locationBController.text : null,
        carModel: _carDetailsController.text.isNotEmpty ? _carDetailsController.text : null,
        details: details,
        totalPrice: 0, // Pending quote
      );

      orderProvider.addOrder(newOrder);
      Navigator.pop(context); // Close form
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request submitted successfully!')), // Translate this later
      );
    }
  }
}
