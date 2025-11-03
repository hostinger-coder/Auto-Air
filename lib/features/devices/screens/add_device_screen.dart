import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AutoAir/providers/device_provider.dart';
import 'package:AutoAir/utils/app_assets.dart';
import 'package:AutoAir/widgets/app_background.dart';
import 'package:AutoAir/themes/custom_colors.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({Key? key}) : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _pinController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _serialNumberController.dispose();
    _pinController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveDevice() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    try {
      await deviceProvider.addDevice(
        name: _nameController.text,
        serialNumber: _serialNumberController.text,
        pin: _pinController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final customColors = theme.extension<CustomColors>()!;
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Add New Device', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image.asset(AppAssets.logo, height: 60),
                    const SizedBox(height: 8),
                    Text(
                      'AutoAir',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildTextFormField(
                      controller: _nameController,
                      label: 'Device Name',
                      hint: 'e.g., Living Room AC',
                      isRequired: true,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 24),
                    _buildTextFormField(
                      controller: _serialNumberController,
                      label: 'Serial Number',
                      hint: 'e.g., AA-LIV-0001',
                      isRequired: true,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 24),
                    _buildTextFormField(
                      controller: _pinController,
                      label: 'PIN',
                      hint: 'Enter device PIN',
                      isRequired: true,
                      isDarkMode: isDarkMode,
                      isObscured: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    _buildTextFormField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'e.g., Main unit in living room',
                      isRequired: false,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customColors.primaryAction,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      onPressed: _isLoading ? null : _saveDevice,
                      child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Device'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isRequired,
    required bool isDarkMode,
    bool isObscured = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final subtextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(color: subtextColor, fontSize: 16)),
            if (isRequired) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscured,
          keyboardType: keyboardType,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          decoration: _buildInputDecoration(isDarkMode, hint),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) return 'This field is required';
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(bool isDarkMode, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDarkMode ? Colors.grey.shade900.withOpacity(0.5) : Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade400 : Colors.deepPurple),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}