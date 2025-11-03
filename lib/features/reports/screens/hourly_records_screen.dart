import 'package:flutter/material.dart';
import 'package:AutoAir/widgets/app_background.dart';

class HourlyRecordsScreen extends StatefulWidget {
  const HourlyRecordsScreen({Key? key}) : super(key: key);

  @override
  State<HourlyRecordsScreen> createState() => _HourlyRecordsScreenState();
}

class _HourlyRecordsScreenState extends State<HourlyRecordsScreen> {
  final List<Map<String, String>> _records = List.generate(
    20,
        (index) => {
      'timestamp': '2025-08-06\n${(3 + index).toString().padLeft(2, '0')}:47:54',
      'value': (0.123 + (index * 0.001)).toStringAsFixed(3),
    },
  );

  String _selectedCurrent = 'Current 1 (kWh)';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Detailed Hourly Records'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Line Chart Placeholder',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Download as Excel (CSV)'),
              ),
              const SizedBox(height: 24),
              _buildDataTable(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildHeaderRow(theme),
          const Divider(color: Colors.white24, height: 1),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _records.length,
            itemBuilder: (context, index) {
              final record = _records[index];
              return _buildDataRow(record['timestamp']!, record['value']!);
            },
            separatorBuilder: (context, index) => const Divider(color: Colors.white24, height: 1, indent: 16, endIndent: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Timestamp',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCurrent,
                isDense: true,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                dropdownColor: Colors.grey.shade800,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCurrent = newValue;
                    });
                  }
                },
                items: <String>[
                  'Current 1 (kWh)',
                  'Current 2 (kWh)',
                  'Current 3 (kWh)',
                  'Current 4 (kWh)'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String timestamp, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Text(timestamp, style: const TextStyle(color: Colors.white70))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}