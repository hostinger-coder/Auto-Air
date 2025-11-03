import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AutoAir/providers/device_provider.dart';
import 'package:AutoAir/features/devices/models/device_model.dart';
import 'package:AutoAir/utils/app_assets.dart';
import 'package:AutoAir/widgets/app_background.dart';
import 'package:AutoAir/themes/custom_colors.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeviceProvider>(context, listen: false).fetchDevices();
    });
  }

  Future<void> _handleRefresh() async {
    await Provider.of<DeviceProvider>(context, listen: false).fetchDevices();
  }

  Future<void> _handleProceed() async {
    final provider = Provider.of<DeviceProvider>(context, listen: false);
    final selectedDevice = provider.selectedDevice;

    if (selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a device to proceed.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await provider.persistActiveDevice(selectedDevice);

    if (!mounted) return;

    final bool isConfigured = selectedDevice.config.wifi.ssid != null &&
        selectedDevice.config.wifi.ssid!.isNotEmpty;

    if (isConfigured) {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
    } else {
      Navigator.pushNamed(context, '/system_time');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 100.0),
              children: [
                _buildHeader(theme, isDarkMode),
                const SizedBox(height: 32),
                _buildDeviceListHeader(isDarkMode),
                const SizedBox(height: 16),
                _buildDeviceListBody(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildFooter(theme, isDarkMode),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildDeviceListHeader(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Devices',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        TextButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/add_device'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Device'),
          style: TextButton.styleFrom(
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            backgroundColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        )
      ],
    );
  }

  Widget _buildDeviceListBody() {
    return Consumer<DeviceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.devices.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (provider.error != null && provider.devices.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Text(
                'Error loading devices. Pull to refresh.',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
          );
        }
        if (provider.devices.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_other, size: 48, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  Text(
                    'No devices found',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a new device to get started.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: provider.devices.map((device) {
            final isSelected = provider.selectedDevice == device;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () => provider.selectDevice(device),
                borderRadius: BorderRadius.circular(12),
                child: DeviceCard(
                  device: device,
                  isSelected: isSelected,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFooter(ThemeData theme, bool isDarkMode) {
    final customColors = theme.extension<CustomColors>()!;
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: customColors.primaryAction,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: _handleProceed,
        child: const Text('Proceed'),
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final Device device;
  final bool isSelected;

  const DeviceCard({
    Key? key,
    required this.device,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final customColors = theme.extension<CustomColors>()!;

    final cardColor = isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white;
    final borderColor = isSelected
        ? customColors.primaryAction
        : (isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey.shade300);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isDarkMode ? [] : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.device_hub, color: textColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  device.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: isDarkMode ? Colors.white24 : Colors.grey.shade200),
          ),
          _buildStatusWidget(),
          const SizedBox(height: 12),
          _buildInfoRow('Serial #:', device.serialNumber, textColor, subtextColor),
          const SizedBox(height: 8),
          if (device.config.wifi.ipAddress != null)
            _buildInfoRow('IP Address:', device.config.wifi.ipAddress!, textColor, subtextColor),
          const SizedBox(height: 8),
          if (device.description != null && device.description!.isNotEmpty)
            _buildInfoRow('Description:', device.description!, textColor, subtextColor),
        ],
      ),
    );
  }

  Widget _buildStatusWidget() {
    Color statusColor;
    String statusText;

    switch (device.status) {
      case DeviceStatus.online:
        statusColor = Colors.green;
        statusText = 'Online';
        break;
      case DeviceStatus.offline:
        statusColor = Colors.red;
        statusText = 'Offline';
        break;
      case DeviceStatus.updating:
        statusColor = Colors.blue;
        statusText = 'Updating';
        break;
    }

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            'Status:',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ),
        Icon(Icons.circle, color: statusColor, size: 10),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
              color: statusColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor, Color subtextColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(color: subtextColor, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ),
      ],
    );
  }
}