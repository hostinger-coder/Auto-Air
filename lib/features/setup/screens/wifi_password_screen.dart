import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:AutoAir/api/api_service.dart';
import 'package:AutoAir/providers/device_provider.dart';
import 'package:AutoAir/widgets/app_background.dart';

class WifiPasswordScreen extends StatefulWidget {
  const WifiPasswordScreen({Key? key}) : super(key: key);

  @override
  State<WifiPasswordScreen> createState() => _WifiPasswordScreenState();
}

class _WifiPasswordScreenState extends State<WifiPasswordScreen> {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ssid = ModalRoute.of(context)?.settings.arguments as String?;
    if (ssid != null && ssid.isNotEmpty) {
      _ssidController.text = ssid;
    }
  }

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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final device = deviceProvider.selectedDevice;

    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device is selected for configuration.'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send credentials: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSuccess() async {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wi-Fi credentials sent successfully.'), backgroundColor: Colors.green),
    );

    await deviceProvider.fetchDevices();

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                      ),
                      const Spacer(),
                      Text(
                        'Connect to Wi-Fi',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    children: [
                      _buildTextField(_ssidController, 'Wi-Fi Name', hint: 'Enter network name (SSID)', isRequired: true),
                      const SizedBox(height: 16),
                      _buildTextField(_passwordController, 'Password', hint: 'Enter network password', isObscured: true, isRequired: true),
                      const SizedBox(height: 8),
                      _buildStaticIpCheckbox(isDark),
                      if (_useStaticIp) ..._buildStaticIpFields(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleConnect,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Connect'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {required String hint, bool isObscured = false, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscured ? _isPasswordObscured : false,
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildStaticIpCheckbox(bool isDark) {
    return Row(
      children: [
        Checkbox(
          value: _useStaticIp,
          onChanged: (value) => setState(() => _useStaticIp = value ?? false),
          side: BorderSide(color: isDark ? Colors.white70 : Colors.black87),
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
      _buildTextField(_ipAddressController, 'IP Address', hint: 'e.g., 192.1.1.100', isRequired: _useStaticIp),
      const SizedBox(height: 16),
      _buildTextField(_subnetController, 'Subnet Mask', hint: 'e.g., 255.255.255.0', isRequired: _useStaticIp),
      const SizedBox(height: 16),
      _buildTextField(_gatewayController, 'Gateway', hint: 'e.g., 192.1.1.1', isRequired: _useStaticIp),
    ];
  }
}