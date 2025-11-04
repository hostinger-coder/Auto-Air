// ===== lib/features/dashboard/widgets/side_menu.dart =====

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:AutoAir/api/api_service.dart';
import 'package:AutoAir/providers/device_provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await ApiService().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final selectedDevice = deviceProvider.selectedDevice;
    final otherDevices = deviceProvider.devices.where((d) => d != selectedDevice).toList();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: const Color(0xFF1C1C1E).withOpacity(0.85),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UserInfo(),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  _MenuItem(
                    icon: Icons.person_outline,
                    title: 'Visit Profile',
                    onTap: () => Navigator.of(context).pushNamed('/profile'),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: Icons.devices_other_outlined,
                    title: 'Manage All Devices',
                    onTap: () => Navigator.of(context).pushNamed('/device_list'),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      'Change Device',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (otherDevices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text('No other devices available.', style: TextStyle(color: Colors.white54)),
                    )
                  else
                    ...otherDevices.map((device) {
                      return _DeviceItem(
                        title: device.name,
                        onTap: () async {
                          await deviceProvider.persistActiveDevice(device);
                        },
                      );
                    }).toList(),
                  const Spacer(),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    final selectedDeviceName = deviceProvider.selectedDevice?.name ?? 'No Device Selected';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User 1',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Device: $selectedDeviceName',
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    );
  }
}

class _DeviceItem extends StatelessWidget {
  const _DeviceItem({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.developer_board, color: Colors.white54, size: 20),
      title: Text(title, style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9))),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.only(left: 24, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    );
  }
}