import 'package:flutter/material.dart';
import 'package:AutoAir/utils/app_assets.dart';
import 'package:AutoAir/widgets/app_background.dart';

class WifiOnboardingScreen extends StatelessWidget {
  const WifiOnboardingScreen({Key? key}) : super(key: key);

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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    Text(
                      'Wi-Fi Setup',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To sync your device time automatically, it needs to connect to the internet. Please select your Wi-Fi network and enter the password.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.wifi_find, size: 64, color: isDark ? Colors.white70 : Colors.black87),
                          const SizedBox(height: 16),
                          Text(
                            'Device Provisioning',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The app will now scan for the device. Make sure your device is powered on and in pairing mode.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () => Navigator.pushNamed(context, '/wifi_scan'),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Begin Scan'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
