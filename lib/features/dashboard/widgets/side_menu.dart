import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AutoAir/providers/device_provider.dart';
import 'package:AutoAir/features/devices/models/device_model.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final selectedDevice = deviceProvider.selectedDevice;
    final otherDevices = deviceProvider.devices.where((d) => d != selectedDevice).toList();

    return Material(
      color: const Color(0xFF1C1C1E).withOpacity(0.95),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserInfo(
                userName: 'User 1', // Placeholder
                deviceName: selectedDevice?.name ?? 'No Device',
              ),
              const SizedBox(height: 24),
              _MenuItem(
                title: 'Visit profile',
                onTap: () {},
              ),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: UniqueKey(),
                  initiallyExpanded: true,
                  tilePadding: EdgeInsets.zero,
                  title: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Change device', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  trailing: const Icon(Icons.expand_less, color: Colors.white),
                  children: otherDevices.map((device) {
                    return _MenuItem(
                      title: device.name,
                      onTap: () async {
                        await deviceProvider.persistActiveDevice(device);
                        // Optional: close menu after selection
                      },
                    );
                  }).toList(),
                ),
              ),
              _MenuItem(
                title: 'Manage all devices',
                onTap: () {
                  Navigator.of(context).pushNamed('/device_list');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo({required this.userName, required this.deviceName});
  final String userName;
  final String deviceName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.person, size: 28, color: Colors.white),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              deviceName,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        )
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}