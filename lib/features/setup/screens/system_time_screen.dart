import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:AutoAir/api/api_service.dart';
import 'package:AutoAir/providers/device_provider.dart';
import 'package:AutoAir/utils/app_assets.dart';
import 'package:AutoAir/widgets/app_background.dart';

class SystemTimeScreen extends StatefulWidget {
  const SystemTimeScreen({Key? key}) : super(key: key);

  @override
  State<SystemTimeScreen> createState() => _SystemTimeScreenState();
}

class _SystemTimeScreenState extends State<SystemTimeScreen> {
  DateTime _selected = DateTime.now();
  bool _isLoading = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              surface: isDark ? Colors.black : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (res != null) {
      setState(() {
        _selected = DateTime(res.year, res.month, res.day, _selected.hour, _selected.minute);
      });
    }
  }

  Future<void> _pickTime() async {
    final res = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selected.hour, minute: _selected.minute),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              surface: isDark ? Colors.black : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (res != null) {
      setState(() {
        _selected = DateTime(_selected.year, _selected.month, _selected.day, res.hour, res.minute);
      });
    }
  }

  Future<void> _setManualTime() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final provider = Provider.of<DeviceProvider>(context, listen: false);
    final device = provider.selectedDevice;

    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device selected.'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
      return;
    }
    try {
      final iso = _selected.toUtc().toIso8601String();
      final timezone = await FlutterTimezone.getLocalTimezone();
      await ApiService().updateDeviceTimeConfig(
        deviceSerialNumber: device.serialNumber,
        isoTime: iso,
        timezone: timezone.toString(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('System time configured successfully.'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending time: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedDevice = Provider.of<DeviceProvider>(context, listen: false).selectedDevice;

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
              if (selectedDevice == null)
                _buildNoDeviceSelected(isDark)
              else
                _buildTimeSetupBody(theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDeviceSelected(bool isDark) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.amber, size: 48),
              const SizedBox(height: 16),
              Text(
                'No Device Selected',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Please go back to the device list and select a device to configure.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSetupBody(ThemeData theme, bool isDark) {
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(_selected);
    final timeStr = DateFormat('hh:mm a').format(_selected);

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'System Time Setup',
                    textAlign: TextAlign.left,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set the system time manually or connect to Wi-Fi to sync automatically.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: const Text('Date'),
                          subtitle: Text(dateStr),
                          trailing: const Icon(Icons.calendar_month),
                          onTap: _pickDate,
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: const Text('Time'),
                          subtitle: Text(timeStr),
                          trailing: const Icon(Icons.schedule),
                          onTap: _pickTime,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          title: const Text('Selected (Local)'),
                          subtitle: Text(
                            DateFormat('yyyy-MM-dd • hh:mm a').format(_selected),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                            ),
                            child: Text(
                              DateFormat('zzz').format(_selected),
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _setManualTime,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('Set Time Manually'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/wifi_onboarding');
                      },
                      child: const Text('Connect to Wi-Fi (Auto-sync)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}