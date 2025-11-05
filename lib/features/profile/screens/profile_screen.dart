// ===== lib/features/profile/screens/profile_screen.dart =====

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:AutoAir/widgets/app_background.dart';
import 'package:AutoAir/api/api_service.dart';
import 'package:AutoAir/providers/device_provider.dart';
import 'package:AutoAir/providers/profile_provider.dart';
import 'package:AutoAir/features/devices/models/device_model.dart';
import 'package:AutoAir/features/profile/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final Device? selected = deviceProvider.selectedDevice;
    final others = deviceProvider.devices.where((d) => d != selected).toList();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'Profile',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline, color: isDark ? Colors.white70 : Colors.black54),
              onPressed: _showHelp,
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: SafeArea(
          child: Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              if (profileProvider.isLoading && profileProvider.user == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (profileProvider.error != null && profileProvider.user == null) {
                return Center(child: Text('Error: ${profileProvider.error}'));
              }
              if (profileProvider.user == null) {
                return const Center(child: Text('No user data found.'));
              }

              final user = profileProvider.user!;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(
                      name: user.fullName,
                      email: user.email,
                    ),
                    const SizedBox(height: 16),
                    _GlassSection(
                      title: 'Account',
                      child: Column(
                        children: [
                          _Tile(
                            icon: Icons.person_outline,
                            title: 'Edit profile',
                            subtitle: 'Name, username, contact',
                            onTap: () => Navigator.of(context).pushNamed('/edit_profile', arguments: user),
                          ),
                          const Divider(height: 1, color: Colors.white24),
                          _Tile(
                            icon: Icons.lock_outline,
                            title: 'Change password',
                            subtitle: 'Update your password',
                            onTap: () => Navigator.of(context).pushNamed('/change_password'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GlassSection(
                      title: 'Device',
                      trailing: TextButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed('/device_list'),
                        icon: const Icon(Icons.devices_other, size: 18),
                        label: const Text('Manage'),
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                      ),
                      child: Column(
                        children: [
                          if (selected != null) ...[
                            _DeviceRow(device: selected, selected: true),
                            if (others.isNotEmpty) const SizedBox(height: 8),
                          ],
                          if (others.isNotEmpty)
                            ...others.take(3).map((d) => Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: _DeviceRow(device: d),
                            )),
                          if (selected == null && others.isEmpty)
                            const _MutedText('No device selected. Tap Manage to add one.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GlassSection(
                      title: 'Preferences',
                      child: Column(
                        children: [
                          _SwitchRow(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark mode',
                            value: _darkMode,
                            onChanged: (v) => setState(() => _darkMode = v),
                          ),
                          const Divider(height: 1, color: Colors.white24),
                          _SwitchRow(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            value: _notificationsEnabled,
                            onChanged: (v) => setState(() => _notificationsEnabled = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GlassSection(
                      title: 'About',
                      child: Column(
                        children: const [
                          _KeyValueRow(label: 'App', value: 'AutoAir'),
                          SizedBox(height: 8),
                          _KeyValueRow(label: 'Version', value: '1.0.0'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DangerZone(onLogout: () => _confirmLogout(context)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Profile'),
        content: const Text(
          'Manage your account, devices and preferences here.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out from this device?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService().logout();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(0.38),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(0.38),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white24),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.device, this.selected = false});

  final Device device;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final status = device.status;

    Color statusColor;
    String statusText;
    switch (status) {
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

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? Colors.white30 : Colors.white12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.memory, color: selected ? Colors.white : Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Selected', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.circle, color: statusColor, size: 10),
                    const SizedBox(width: 6),
                    Text(statusText, style: TextStyle(color: statusColor)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'SN: ${device.serialNumber}',
                        style: const TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.white70))),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Danger Zone', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Log out of this device'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade300,
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}