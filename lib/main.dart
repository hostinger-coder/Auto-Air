// ===== lib/main.dart =====

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/authentication/screens/signup_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/authentication/screens/forgot_password_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/devices/screens/add_device_screen.dart';
import 'features/devices/screens/device_list_screen.dart';
import 'features/setup/screens/system_time_screen.dart';
import 'features/setup/screens/wifi_onboarding_screen.dart';
import 'features/setup/screens/wifi_scan_screen.dart';
import 'features/setup/screens/wifi_password_screen.dart';
import 'features/dashboard/screens/relay_schedule_screen.dart';
import 'features/dashboard/screens/hourly_records_screen.dart';
import 'features/dashboard/screens/firmware_update_screen.dart';
import 'features/dashboard/screens/configuration_screen.dart';
import 'providers/dashboard_provider.dart';
import 'providers/device_provider.dart';
import 'themes.dart';
import 'auth_gate.dart';
import 'navigation_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProxyProvider<DeviceProvider, DashboardProvider>(
          create: (context) => DashboardProvider(
            Provider.of<DeviceProvider>(context, listen: false),
          ),
          update: (context, deviceProvider, dashboardProvider) =>
              DashboardProvider(deviceProvider),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.dark,
      navigatorKey: navigatorKey,
      initialRoute: '/auth_gate',
      routes: {
        '/auth_gate': (context) => const AuthGate(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/device_list': (context) => const DeviceListScreen(),
        '/add_device': (context) => const AddDeviceScreen(),
        '/system_time': (context) => const SystemTimeScreen(),
        '/wifi_onboarding': (context) => const WifiOnboardingScreen(),
        '/wifi_scan': (context) => const WifiScanScreen(),
        '/wifi_password': (context) => const WifiPasswordScreen(),
        '/relay_schedule': (context) => const RelayScheduleScreen(),
        '/hourly_records': (context) => const HourlyRecordsScreen(),
        '/firmware_update': (context) => const FirmwareUpdateScreen(),
        '/configuration': (context) => const ConfigurationScreen(),
      },
    );
  }
}