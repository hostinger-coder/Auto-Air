// ===== lib/features/dashboard/screens/dashboard_screen.dart =====

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:AutoAir/features/dashboard/models/relay_model.dart';
import 'package:AutoAir/providers/dashboard_provider.dart';
import 'package:AutoAir/themes/custom_colors.dart';
import 'package:AutoAir/widgets/app_background.dart';
import 'package:AutoAir/features/dashboard/widgets/fan_control_settings_tab.dart';
import 'package:AutoAir/features/dashboard/widgets/side_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedActionIndex = 0;
  late PageController _pageController;
  int _currentPage = 0;
  bool _isSideMenuOpen = false;

  void _toggleSideMenu() {
    setState(() {
      _isSideMenuOpen = !_isSideMenuOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuWidth = MediaQuery.of(context).size.width * 0.75;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildCustomAppBar(context),
        body: Stack(
          children: [
            SafeArea(
              bottom: true,
              child: Consumer<DashboardProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return _buildDashboardContent(context, provider);
                },
              ),
            ),
            if (_isSideMenuOpen)
              GestureDetector(
                onTap: _toggleSideMenu,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: _isSideMenuOpen ? 0 : -menuWidth,
              width: menuWidth,
              child: const SideMenu(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const _StatusHeader(),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: _toggleSideMenu,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context, DashboardProvider provider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            DashboardCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      provider.selectedDevice?.name ?? 'Power Monitor',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSlidableGauges(provider),
                    const SizedBox(height: 32),
                    _buildStatusInfo(provider),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildContentSection(provider),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSlidableGauges(DashboardProvider provider) {
    final List<Map<String, dynamic>> gauges = [
      {
        'label': 'Temperature',
        'metric': _Metric.temperature,
        'color': const Color(0xFF22D3EE),
        'unit': '°',
      },
      {
        'label': 'Humidity',
        'metric': _Metric.humidity,
        'color': const Color(0xFF22C55E),
        'unit': '%',
      },
      {
        'label': 'Heat Index',
        'metric': _Metric.heatIndex,
        'color': const Color(0xFFFB923C),
        'unit': '°',
      },
    ];

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: gauges.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final gauge = gauges[index];
              return _MonitorGauge(
                size: 250,
                label: gauge['label'],
                metric: gauge['metric'],
                color: gauge['color'],
                unit: gauge['unit'],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildDotIndicator(gauges.length, _currentPage),
      ],
    );
  }

  Widget _buildDotIndicator(int pageCount, int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: 8.0,
          decoration: BoxDecoration(
            color: currentPage == index ? Colors.white : Colors.grey.shade700,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildStatusInfo(DashboardProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _InfoChip(icon: Icons.sync, label: 'Mode: ${provider.mode}'),
        ),
        Expanded(
          child: _InfoChip(
            icon: Icons.ssid_chart,
            label: 'Total kWh: ${provider.totalKwh.toStringAsFixed(0)} kWh',
          ),
        ),
        Expanded(
          child: _InfoChip(
            icon: Icons.close,
            label: 'Status: ${provider.isPowerOn ? "On" : "Off"}',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(icon: FontAwesomeIcons.clock, index: 0),
        _buildActionButton(icon: FontAwesomeIcons.fan, index: 1),
        _buildActionButton(icon: FontAwesomeIcons.boltLightning, index: 2),
        _buildActionButton(icon: FontAwesomeIcons.sliders, index: 3),
        _buildActionButton(icon: FontAwesomeIcons.gear, index: 4),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required int index}) {
    final isSelected = _selectedActionIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (index == 2) {
          Navigator.pushNamed(context, '/hourly_records');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/firmware_update');
        } else if (index == 4) {
          Navigator.pushNamed(context, '/configuration');
        } else {
          setState(() => _selectedActionIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: FaIcon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(DashboardProvider provider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _getSelectedSection(provider),
    );
  }

  Widget _getSelectedSection(DashboardProvider provider) {
    switch (_selectedActionIndex) {
      case 0:
        return _buildRelaySettings(provider);
      case 1:
        return const FanControlSettingsTab();
      default:
        return Container(
          key: const ValueKey('empty'),
        );
    }
  }

  Widget _buildRelaySettings(DashboardProvider provider) {
    final theme = Theme.of(context);
    return DashboardCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Relay Settings',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 16),
            if (provider.relays.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 24, 0, 40),
                child: Center(child: Text('No relays found for this device.')),
              )
            else
              ...provider.relays.map((relay) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: _RelayCard(
                    relay: relay,
                    onToggle: (value) => provider.toggleRelay(relay.id, value),
                  ),
                );
              }).toList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141416).withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StatusHeader extends StatefulWidget {
  const _StatusHeader();

  @override
  State<_StatusHeader> createState() => _StatusHeaderState();
}

class _StatusHeaderState extends State<_StatusHeader> {
  late Timer _clock;
  DateTime _now = DateTime.now();

  final _conn = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  int _signalBars = 0;
  bool _onWifi = false;

  static const double _tilt = -pi / 10;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _connSub = _conn.onConnectivityChanged.listen((_) => _refreshSignal());
    _refreshSignal();
  }

  Future<void> _refreshSignal() async {
    try {
      final result = await _conn.checkConnectivity();
      _onWifi = result.contains(ConnectivityResult.wifi);
      int bars = 0;
      if (_onWifi) {
        final int? rssi = await WiFiForIoTPlugin.getCurrentSignalStrength();
        if (rssi != null) {
          final int v = (rssi > 0) ? -rssi : rssi;
          if (v >= -55) {
            bars = 4;
          } else if (v >= -67) {
            bars = 3;
          } else if (v >= -75) {
            bars = 2;
          } else if (v >= -90) {
            bars = 1;
          } else {
            bars = 1;
          }
        } else {
          bars = 2;
        }
      } else {
        bars = 0;
      }
      if (mounted) setState(() => _signalBars = bars);
    } catch (_) {
      if (mounted) setState(() => _signalBars = _onWifi ? 2 : 0);
    }
  }

  @override
  void dispose() {
    _clock.cancel();
    _connSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTime(_now);
    final dateStr = _formatDate(_now);

    return Row(
      children: [
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(-1.0, 1.0),
          child: Transform.rotate(
            angle: _tilt,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _WifiRssIcon(
                size: 24,
                color: Colors.white70,
                strokeWidth: 5.5,
                gap: 2.0,
                signalBars: _signalBars,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeStr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(height: 1.0, color: Colors.white),
              ),
              Text(
                dateStr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.0, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final mon = months[dt.month - 1];
    final day = dt.day.toString().padLeft(2, '0');
    return '$mon $day, ${dt.year}';
  }
}

class _WifiRssIcon extends StatelessWidget {
  const _WifiRssIcon({
    Key? key,
    this.size = 48,
    this.color = Colors.white70,
    this.strokeWidth = 7.0,
    this.gap = 3.0,
    this.signalBars = 0,
  }) : super(key: key);

  final double size;
  final Color color;
  final double strokeWidth;
  final double gap;
  final int signalBars;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _WifiRssPainter(
        color: color,
        strokeWidth: strokeWidth,
        gap: gap,
        signalBars: signalBars.clamp(0, 4),
      ),
    );
  }
}

class _WifiRssPainter extends CustomPainter {
  _WifiRssPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.signalBars,
  });

  final Color color;
  final double strokeWidth;
  final double gap;
  final int signalBars;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = min(size.width, size.height);
    final Offset base = Offset(s * 0.18, s * 0.78);
    final double dotR = s * 0.11;

    final activePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..isAntiAlias = true;

    final inactivePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.3)
      ..isAntiAlias = true;

    final double r1 = s * 0.34;
    final double r2 = r1 + gap + strokeWidth;
    final double r3 = r2 + gap + strokeWidth;

    void band(double rOuter, Paint paint) {
      final double rInner = max(0, rOuter - strokeWidth);
      final Rect outer = Rect.fromCircle(center: base, radius: rOuter);
      final Rect inner = Rect.fromCircle(center: base, radius: rInner);
      final Path p = Path()
        ..arcTo(outer, -pi / 2, pi / 2, false)
        ..arcTo(inner, 0, -pi / 2, false)
        ..close();
      canvas.drawPath(p, paint);
    }

    canvas.drawCircle(base, dotR, signalBars >= 1 ? activePaint : inactivePaint);
    band(r1, signalBars >= 2 ? activePaint : inactivePaint);
    band(r2, signalBars >= 3 ? activePaint : inactivePaint);
    band(r3, signalBars >= 4 ? activePaint : inactivePaint);
  }

  @override
  bool shouldRepaint(covariant _WifiRssPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.signalBars != signalBars;
  }
}

enum _Metric { temperature, humidity, heatIndex }

class _MonitorGauge extends StatefulWidget {
  const _MonitorGauge({
    required this.label,
    required this.color,
    required this.metric,
    required this.size,
    required this.unit,
  });

  final String label;
  final Color color;
  final _Metric metric;
  final double size;
  final String unit;

  @override
  State<_MonitorGauge> createState() => _MonitorGaugeState();
}

class _MonitorGaugeState extends State<_MonitorGauge> {
  String _formatMetric(DashboardProvider p) {
    switch (widget.metric) {
      case _Metric.temperature:
        final v = p.temperature;
        return v == null ? '—' : v.toStringAsFixed(0);
      case _Metric.humidity:
        final v = p.humidity;
        return v == null ? '—' : v.toStringAsFixed(0);
      case _Metric.heatIndex:
        final v = p.heatIndex;
        return v == null ? '—' : v.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _AnimatedDottedCirclePainter(
            color: widget.color,
            rotationAngle: 0.0,
          ),
          child: Center(
            child: Consumer<DashboardProvider>(
              builder: (_, p, __) {
                final valueStyle = TextStyle(
                  fontSize: widget.size * 0.20,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                  height: 1.0,
                );
                final unitStyle = TextStyle(
                  fontSize: widget.size * 0.12,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                  fontFeatures: const [FontFeature.superscripts()],
                );
                final labelStyle = TextStyle(
                  fontSize: widget.size * 0.07,
                  fontWeight: FontWeight.w400,
                  color: widget.color.withOpacity(0.8),
                  height: 1.5,
                );

                return RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                        text: _formatMetric(p),
                        style: valueStyle,
                      ),
                      TextSpan(
                        text: widget.unit,
                        style: unitStyle,
                      ),
                      TextSpan(
                        text: '\n${widget.label}',
                        style: labelStyle,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedDottedCirclePainter extends CustomPainter {
  _AnimatedDottedCirclePainter({
    required this.color,
    required this.rotationAngle,
  });

  final Color color;
  final double rotationAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final paint = Paint()..isAntiAlias = true;
    const brightestAngle = -pi / 2.5;

    final rings = [
      {'radiusFactor': 0.60, 'dotSizeFactor': 0.012, 'dotCount': 40, 'baseOpacity': 1.0},
      {'radiusFactor': 0.72, 'dotSizeFactor': 0.013, 'dotCount': 45, 'baseOpacity': 0.7},
      {'radiusFactor': 0.84, 'dotSizeFactor': 0.014, 'dotCount': 50, 'baseOpacity': 0.5},
      {'radiusFactor': 0.96, 'dotSizeFactor': 0.015, 'dotCount': 55, 'baseOpacity': 0.3},
    ];

    for (final ring in rings) {
      final ringRadius = radius * (ring['radiusFactor'] as double);
      final dotRadius = size.width * (ring['dotSizeFactor'] as double);
      final numberOfDots = ring['dotCount'] as int;
      final baseOpacity = ring['baseOpacity'] as double;

      for (int i = 0; i < numberOfDots; i++) {
        final double theta = (i / numberOfDots) * 2 * pi + rotationAngle;

        final double cosDiff = cos(theta - brightestAngle);
        const double minAngularOpacity = 0.8;
        const double maxAngularOpacity = 1.0;
        final double normalized = (cosDiff + 1) / 2;
        final double angularOpacity = minAngularOpacity + normalized * (maxAngularOpacity - minAngularOpacity);

        final finalOpacity = baseOpacity * angularOpacity;
        paint.color = color.withOpacity(finalOpacity);

        final p = Offset(
          center.dx + ringRadius * cos(theta),
          center.dy + ringRadius * sin(theta),
        );
        canvas.drawCircle(p, dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedDottedCirclePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.rotationAngle != rotationAngle;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: Colors.white.withOpacity(0.9),
          child: Icon(icon, size: 14, color: Colors.black87),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _RelayCard extends StatefulWidget {
  const _RelayCard({
    required this.relay,
    required this.onToggle,
  });

  final Relay relay;
  final ValueChanged<bool> onToggle;

  @override
  State<_RelayCard> createState() => _RelayCardState();
}

class _RelayCardState extends State<_RelayCard> {
  bool _isAutoMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final custom = theme.extension<CustomColors>()!;
    final bool isOn = widget.relay.isOn;
    final double currentA = widget.relay.amperage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOn ? custom.successBorder! : Colors.white.withOpacity(0.06),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                widget.relay.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_isAutoMode)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOn ? custom.success : Colors.grey.shade800,
                  ),
                )
              else
                Switch(
                  value: isOn,
                  onChanged: widget.onToggle,
                  thumbColor: MaterialStateProperty.resolveWith((_) => isOn ? Colors.white : Colors.white70),
                  trackColor: MaterialStateProperty.resolveWith((_) => isOn ? custom.successTrack! : Colors.white10),
                  overlayColor: MaterialStateProperty.resolveWith(
                        (_) => isOn ? custom.success!.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF151517),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: _SegmentDisplayText(
              text: '${currentA.toStringAsFixed(2)}  A',
            ),
          ),
          const SizedBox(height: 10),
          _DimButton(
            label: _isAutoMode ? 'Auto' : 'Manual',
            onPressed: () {
              setState(() {
                _isAutoMode = !_isAutoMode;
              });
            },
          ),
          const SizedBox(height: 8),
          _PrimaryButton(
            label: 'Configure Schedule',
            onPressed: () {
              Navigator.pushNamed(context, '/relay_schedule', arguments: widget.relay);
            },
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _SegmentDisplayText extends StatelessWidget {
  const _SegmentDisplayText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'DigitalNumbers',
          fontFeatures: [ui.FontFeature.tabularFigures()],
          fontSize: 34,
          letterSpacing: 2.0,
          color: Colors.white,
          height: 1.0,
        ),
      ),
    );
  }
}

class _DimButton extends StatelessWidget {
  const _DimButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF232325);
    return SizedBox(
      height: 40,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.color,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}