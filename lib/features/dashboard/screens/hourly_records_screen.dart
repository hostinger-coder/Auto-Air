import 'dart:math';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:AutoAir/features/dashboard/models/hourly_record_model.dart';
import 'package:AutoAir/widgets/app_background.dart';

class HourlyRecordsScreen extends StatelessWidget {
  const HourlyRecordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Detailed Hourly Records',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const _HourlyRecordsBody(),
      ),
    );
  }
}

class _HourlyRecordsBody extends StatefulWidget {
  const _HourlyRecordsBody();

  @override
  State<_HourlyRecordsBody> createState() => _HourlyRecordsBodyState();
}

class _HourlyRecordsBodyState extends State<_HourlyRecordsBody> {
  late List<HourlyRecord> _records;
  bool _isBreakdown = true;
  int _selectedTableCurrent = 0;

  final List<Color> _lineColors = const [
    Color(0xFFFF5A5F),
    Color(0xFF22D3EE),
    Color(0xFF86EFAC),
    Color(0xFFF59E0B),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final random = Random();
    _records = List.generate(
      24,
          (index) => HourlyRecord(
        timestamp: now.subtract(Duration(hours: 24 - index)),
        current1: 1500 + random.nextDouble() * 500,
        current2: 1200 + random.nextDouble() * 600,
        current3: 1800 + random.nextDouble() * 400,
        current4: 1000 + random.nextDouble() * 700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartHeight = min(320.0, MediaQuery.of(context).size.height * 0.34);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _GlassContainer(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              children: [
                _GraphSwitch(
                  isBreakdown: _isBreakdown,
                  onToggle: (val) => setState(() => _isBreakdown = val),
                ),
                const SizedBox(height: 16),
                RepaintBoundary(
                  child: SizedBox(
                    height: chartHeight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _buildChart(theme),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isBreakdown
                      ? _ChartLegend(colors: _lineColors)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export to CSV coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Download as Excel (CSV)'),
          ),
        ),
        const SizedBox(height: 24),
        _buildDataTable(context),
      ],
    );
  }

  Widget _buildChart(ThemeData theme) {
    if (_records.isEmpty) {
      return const Center(
        child: Text('No data', style: TextStyle(color: Colors.white70)),
      );
    }

    final lines = _isBreakdown
        ? [
      _buildLine(_records.map((r) => r.current1).toList(), _lineColors[0]),
      _buildLine(_records.map((r) => r.current2).toList(), _lineColors[1]),
      _buildLine(_records.map((r) => r.current3).toList(), _lineColors[2]),
      _buildLine(_records.map((r) => r.current4).toList(), _lineColors[3]),
    ]
        : [
      _buildLine(_records.map((r) => r.total).toList(), theme.colorScheme.primary),
    ];

    final allY = lines.expand((l) => l.spots.map((s) => s.y)).toList();
    final bounds = _niceBounds(allY);

    return LineChart(
      LineChartData(
        minY: bounds.$1,
        maxY: bounds.$2,
        lineBarsData: lines,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (bounds.$2 - bounds.$1) / 4,
          getDrawingHorizontalLine: (_) => const FlLine(color: Colors.white10, strokeWidth: 1),
          getDrawingVerticalLine: (_) => const FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        titlesData: _chartTitles(bounds),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24)),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 12,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spots) => spots.map((ts) {
              final i = ts.x.toInt().clamp(0, _records.length - 1);
              return LineTooltipItem(
                  '${(ts.y / 1000).toStringAsFixed(2)}k kWh\n',
                  TextStyle(
                    color: ts.bar.color ?? Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: DateFormat('yyyy-MM-dd HH:mm').format(_records[i].timestamp),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ]
              );
            }).toList(),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 350),
    );
  }

  LineChartBarData _buildLine(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      curveSmoothness: 0.15,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
        ),
      ),
    );
  }

  FlTitlesData _chartTitles((double, double) yBounds) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        axisNameSize: 22,
        axisNameWidget: const Text('Current (kWh)', style: TextStyle(color: Colors.white70, fontSize: 12)),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          interval: (yBounds.$2 - yBounds.$1) / 4,
          getTitlesWidget: (value, meta) {
            if (value > meta.max || value < meta.min) return const SizedBox.shrink();
            return Text(_kWh(value), style: const TextStyle(color: Colors.white70, fontSize: 10));
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        axisNameSize: 22,
        axisNameWidget: const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text('Timestamp', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: max(1, (_records.length / 6).floorToDouble()),
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= _records.length) return const SizedBox.shrink();
            return Text(DateFormat('HH:mm').format(_records[i].timestamp),
                style: const TextStyle(color: Colors.white70, fontSize: 10));
          },
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final theme = Theme.of(context);
    final headers = ['Current 1', 'Current 2', 'Current 3', 'Current 4'];

    return _GlassContainer(
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                _buildHeaderCell('Timestamp', theme),
                const VerticalDivider(width: 1, color: Colors.white12),
                _buildHeaderCell(
                  '${headers[_selectedTableCurrent]} (kWh)',
                  theme,
                  onTap: () => _showCurrentPicker(context, headers),
                  hasDropdown: true,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          ..._records.map((record) {
            final value = record.getValue(_selectedTableCurrent);
            return IntrinsicHeight(
              child: Row(
                children: [
                  _buildDataCell(DateFormat('yyyy-MM-dd\nHH:mm:ss').format(record.timestamp), theme),
                  const VerticalDivider(width: 1, color: Colors.white12),
                  _buildDataCell(value.toStringAsFixed(3), theme),
                ],
              ),
            );
          }).expand((w) => [w, const Divider(height: 1, color: Colors.white12)]).toList()
            ..removeLast(),
        ],
      ),
    );
  }

  void _showCurrentPicker(BuildContext context, List<String> headers) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: const Color(0xFF1C1C1E).withOpacity(0.85),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: headers.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedTableCurrent;
                return ListTile(
                  title: Text(
                    '${headers[index]} (kWh)',
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.white70) : null,
                  tileColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.18) : Colors.transparent,
                  onTap: () {
                    setState(() => _selectedTableCurrent = index);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, ThemeData theme, {VoidCallback? onTap, bool hasDropdown = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasDropdown) ...[
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, ThemeData theme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  (double, double) _niceBounds(List<double> values) {
    if (values.isEmpty) return (0, 1);
    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    if (minV == maxV) return (minV * 0.9, maxV * 1.1);

    final range = maxV - minV;
    final mag = pow(10, (log(range) / ln10).floor());
    double niceRange = (range / mag).ceil() * mag.toDouble();
    if (niceRange == 0) niceRange = range;

    final minY = (minV / mag).floor() * mag.toDouble();
    final maxY = minY + niceRange;
    return (minY, maxY);
  }

  String _kWh(double v) => '${(v / 1000).toStringAsFixed(1)}k';
}

class _GraphSwitch extends StatelessWidget {
  const _GraphSwitch({required this.isBreakdown, required this.onToggle});
  final bool isBreakdown;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chip(context, 'Breakdown', isBreakdown, () => onToggle(true)),
        const SizedBox(width: 8),
        _chip(context, 'Total', !isBreakdown, () => onToggle(false)),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary.withOpacity(0.85) : Colors.black26,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : Colors.white54,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.colors});
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white.withOpacity(0.9);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(colors.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: colors[index])),
            const SizedBox(width: 6),
            Text('Current ${index + 1}', style: TextStyle(color: textColor, fontSize: 12)),
          ],
        );
      }),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  const _GlassContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          child: child,
        ),
      ),
    );
  }
}