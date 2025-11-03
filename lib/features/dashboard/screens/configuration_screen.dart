import 'package:flutter/material.dart';
import 'package:AutoAir/widgets/app_background.dart';
import 'package:AutoAir/features/dashboard/widgets/date_time_tab.dart';
import 'package:AutoAir/features/dashboard/widgets/wifi_setup_tab.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: DefaultTabController(
        length: 2,
        initialIndex: 1,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text('Configuration'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: TabBar(
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'Wi-Fi Setup'),
                Tab(text: 'Date & Time'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              WifiSetupTab(),
              DateTimeTab(),
            ],
          ),
        ),
      ),
    );
  }
}