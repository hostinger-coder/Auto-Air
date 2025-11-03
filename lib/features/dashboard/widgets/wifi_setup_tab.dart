import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:AutoAir/api/api_service.dart';
import 'package:AutoAir/providers/device_provider.dart';

class WifiSetupTab extends StatefulWidget {
  const WifiSetupTab({Key? key}) : super(key: key);

  @override
  State<WifiSetupTab> createState() => _WifiSetupTabState();
}

class _WifiSetupTabState extends State<WifiSetupTab> {
  final _formKey = GlobalKey<FormState>();
  bool _useStaticIp = false;
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ipAddressController = TextEditingController();
  final _subnetController = TextEditingController();
  final _gatewayController = TextEditingController();

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _ipAddressController.dispose();
    _subnetController.dispose();
    _gatewayController.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    if (!(_formKey.currentState?.validate() ?? false) || !mounted) return;

    setState(() => _isLoading = true);

    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final device = deviceProvider.selectedDevice;

    if (device == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No device is selected for configuration.'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      await ApiService().updateDeviceWifiConfig(
        deviceSerialNumber: device.serialNumber,
        ssid: _ssidController.text,
        password: _passwordController.text,
        isStatic: _useStaticIp,
        ipAddress: _ipAddressController.text,
        subnet: _subnetController.text,
        gateway: _gatewayController.text,
      );
      _onSuccess();
    } on DioException catch (e) {
      if (e.response?.statusCode == 503 && e.response?.data['message'].contains('Device unreachable')) {
        _onSuccess();
      } else {
        String errorMessage = "An unknown error occurred.";
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          errorMessage = e.response!.data['message'];
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send credentials: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSuccess() async {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wi-Fi credentials sent successfully.'), backgroundColor: Colors.green),
      );
    }

    await deviceProvider.fetchDevices();

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_ssidController, 'Wi-Fi Name (SSID)', isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(_passwordController, 'Password', isObscured: true, isRequired: true),
            const SizedBox(height: 8),
            _buildStaticIpCheckbox(),
            if (_useStaticIp) ..._buildStaticIpFields(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleConnect,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Connect & Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isObscured = false, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscured ? _isPasswordObscured : false,
          decoration: InputDecoration(
            suffixIcon: isObscured
                ? IconButton(
              icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
            )
                : null,
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStaticIpCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _useStaticIp,
          onChanged: (value) => setState(() => _useStaticIp = value ?? false),
          side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
        ),
        GestureDetector(
          onTap: () => setState(() => _useStaticIp = !_useStaticIp),
          child: Text('Use Static IP', style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  List<Widget> _buildStaticIpFields() {
    return [
      const SizedBox(height: 16),
      _buildTextField(_ipAddressController, 'IP Address', isRequired: _useStaticIp),
      const SizedBox(height: 16),
      _buildTextField(_subnetController, 'Subnet Mask', isRequired: _useStaticIp),
      const SizedBox(height: 16),
      _buildTextField(_gatewayController, 'Gateway', isRequired: _useStaticIp),
    ];
  }
}