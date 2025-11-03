import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:wifi_scan/wifi_scan.dart';
import 'package:AutoAir/utils/app_assets.dart';
import 'package:AutoAir/widgets/app_background.dart';

class WifiScanScreen extends StatefulWidget {
  const WifiScanScreen({Key? key}) : super(key: key);

  @override
  State<WifiScanScreen> createState() => _WifiScanScreenState();
}

class _WifiScanScreenState extends State<WifiScanScreen> {
  List<WiFiAccessPoint> _accessPoints = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (await _checkPermissionsAndServices()) {
      await _executeScan();
    }

    if(mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _checkPermissionsAndServices() async {
    final permissionStatus = await Permission.locationWhenInUse.request();
    if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
      setState(() => _error = "Location permission is required to scan for Wi-Fi networks.");
      return false;
    }

    final location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() => _error = "Please enable Location/GPS in your phone's settings.");
        return false;
      }
    }
    return true;
  }

  Future<void> _executeScan() async {
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan != CanStartScan.yes) {
      setState(() => _error = "Wi-Fi scanning is not available on this device.");
      return;
    }

    await WiFiScan.instance.startScan();
    final results = await WiFiScan.instance.getScannedResults();
    if(mounted) {
      setState(() => _accessPoints = results);
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
                    Image.asset(AppAssets.logo, height: 36),
                    const SizedBox(width: 8),
                    Text(
                      'AutoAir',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Available Networks',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a Wi-Fi network to connect your device.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black87, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(isDark)),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Wi-Fi Manually'),
                onPressed: () => Navigator.pushNamed(context, '/wifi_password'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade300)),
        ),
      );
    }
    if (_accessPoints.isEmpty) {
      return const Center(child: Text('No Wi-Fi networks found. Pull to refresh.'));
    }

    return RefreshIndicator(
      onRefresh: _startScan,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _accessPoints.length,
        itemBuilder: (context, index) {
          final ap = _accessPoints[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: ListTile(
              title: Text(ap.ssid.isNotEmpty ? ap.ssid : '(hidden network)'),
              trailing: Icon(_getWifiIcon(ap.level)),
              onTap: () => Navigator.pushNamed(context, '/wifi_password', arguments: ap.ssid),
            ),
          );
        },
      ),
    );
  }

  IconData _getWifiIcon(int level) {
    if (level > -60) return Icons.wifi;
    if (level > -75) return Icons.wifi_2_bar;
    return Icons.wifi_1_bar;
  }
}