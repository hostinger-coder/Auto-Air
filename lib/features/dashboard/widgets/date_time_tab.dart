// ===== lib/features/dashboard/widgets/date_time_tab.dart =====

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:AutoAir/api/api_service.dart';
import 'package:AutoAir/providers/device_provider.dart';

class DateTimeTab extends StatefulWidget {
  const DateTimeTab({Key? key}) : super(key: key);

  @override
  State<DateTimeTab> createState() => _DateTimeTabState();
}

class _DateTimeTabState extends State<DateTimeTab> {
  // State variables for dropdowns
  String _selectedMonth = 'January';
  String _selectedDay = '01';
  String _selectedYear = '2019';
  String _selectedHour = '01';
  String _selectedMinute = '00';
  String _selectedAmPm = 'AM';
  bool _isLoading = false;

  Future<void> _setManualTime() async {
    if (!mounted || _isLoading) return;
    setState(() => _isLoading = true);

    final provider = Provider.of<DeviceProvider>(context, listen: false);
    final device = provider.selectedDevice;

    if (device == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No device selected.'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final month = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'].indexOf(_selectedMonth) + 1;
      final day = int.parse(_selectedDay);
      final year = int.parse(_selectedYear);
      int hour = int.parse(_selectedHour);
      if (_selectedAmPm == 'PM' && hour != 12) hour += 12;
      if (_selectedAmPm == 'AM' && hour == 12) hour = 0;
      final minute = int.parse(_selectedMinute);

      final selectedDateTime = DateTime(year, month, day, hour, minute);

      final iso = selectedDateTime.toUtc().toIso8601String();
      final String timezone = (await FlutterTimezone.getLocalTimezone()) as String;

      await ApiService().updateDeviceTimeConfig(
        deviceSerialNumber: device.serialNumber,
        isoTime: iso,
        timezone: timezone,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('System time configured successfully.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending time: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateRow(),
          const SizedBox(height: 24),
          _buildTimeRow(),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _isLoading ? null : _setManualTime,
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Set Time Manually'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              DefaultTabController.of(context).animateTo(0);
            },
            child: const Text('Auto-sync with Internet Time'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        const Text('Date:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: _buildDropdown(
            value: _selectedMonth,
            items: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
            onChanged: (val) => setState(() => _selectedMonth = val!),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: _buildDropdown(
            value: _selectedDay,
            items: List.generate(31, (i) => (i + 1).toString().padLeft(2, '0')),
            onChanged: (val) => setState(() => _selectedDay = val!),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: _buildDropdown(
            value: _selectedYear,
            items: List.generate(10, (i) => (2019 + i).toString()),
            onChanged: (val) => setState(() => _selectedYear = val!),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        const Text('Time:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDropdown(
            value: _selectedHour,
            items: List.generate(12, (i) => (i + 1).toString().padLeft(2, '0')),
            onChanged: (val) => setState(() => _selectedHour = val!),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(':', style: TextStyle(fontSize: 16, color: Colors.white70)),
        ),
        Expanded(
          child: _buildDropdown(
            value: _selectedMinute,
            items: List.generate(60, (i) => i.toString().padLeft(2, '0')),
            onChanged: (val) => setState(() => _selectedMinute = val!),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown(
            value: _selectedAmPm,
            items: ['AM', 'PM'],
            onChanged: (val) => setState(() => _selectedAmPm = val!),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          dropdownColor: const Color(0xFF1C1C1E),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}