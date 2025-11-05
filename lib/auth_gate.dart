// ===== lib/auth_gate.dart =====

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'api/api_service.dart';
import 'providers/device_provider.dart';
import 'providers/profile_provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _storage = const FlutterSecureStorage();
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final token = await _storage.read(key: 'auth_token');
    if (!mounted) return;

    if (token == null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    final user = await _api.authenticate();
    if (!mounted) return;

    if (user != null) {
      Provider.of<ProfileProvider>(context, listen: false).setUser(user);

      final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
      final hasDevice = await deviceProvider.loadInitialDevice();
      if (!mounted) return;

      if (hasDevice) {
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil('/device_list', (route) => false);
      }
    } else {
      await _storage.delete(key: 'auth_token');
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}