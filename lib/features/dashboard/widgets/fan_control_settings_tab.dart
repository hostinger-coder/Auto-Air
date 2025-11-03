import 'package:flutter/material.dart';
import 'package:AutoAir/features/dashboard/screens/dashboard_screen.dart';

class FanControlSettingsTab extends StatefulWidget {
  const FanControlSettingsTab({Key? key}) : super(key: key);

  @override
  State<FanControlSettingsTab> createState() => _FanControlSettingsTabState();
}

class _FanControlSettingsTabState extends State<FanControlSettingsTab> {
  bool _isManualMode = false;
  bool _isFanOnInAuto = false;
  int _turnOffTemp = 24;
  int _turnOnTemp = 28;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DashboardCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Fan Control Settings',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mode:', style: TextStyle(fontSize: 16)),
                _CustomModeToggle(
                  labelOn: 'Manual',
                  labelOff: 'Auto',
                  isActive: _isManualMode,
                  onToggle: (value) {
                    setState(() {
                      _isManualMode = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 32),
            SizedBox(
              height: 180,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _isManualMode ? _buildManualMode(theme) : _buildAutoMode(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoMode(ThemeData theme) {
    return Column(
      key: const ValueKey('auto_mode'),
      children: [
        Text(
          'Auto Mode',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Fan State:', style: TextStyle(fontSize: 16)),
            _CustomModeToggle(
              labelOn: 'On',
              labelOff: 'Off',
              isActive: _isFanOnInAuto,
              onToggle: (value) {
                setState(() {
                  _isFanOnInAuto = value;
                });
              },
            ),
          ],
        )
      ],
    );
  }

  Widget _buildManualMode(ThemeData theme) {
    return Column(
      key: const ValueKey('manual_mode'),
      children: [
        Text(
          'Manual Mode',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _TemperatureControl(
          label: 'Turn off below Temp (°C):',
          value: _turnOffTemp,
          onChanged: (val) => setState(() => _turnOffTemp = val),
        ),
        const SizedBox(height: 16),
        _TemperatureControl(
          label: 'Turn on above Temp (°C):',
          value: _turnOnTemp,
          onChanged: (val) => setState(() => _turnOnTemp = val),
        ),
      ],
    );
  }
}

class _CustomModeToggle extends StatelessWidget {
  const _CustomModeToggle({
    required this.labelOn,
    required this.labelOff,
    required this.isActive,
    required this.onToggle,
  });

  final String labelOn;
  final String labelOff;
  final bool isActive;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onToggle(!isActive),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 105,
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
              curve: Curves.easeOut,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: isActive ? Alignment.centerLeft : Alignment.centerRight,
              curve: Curves.easeOut,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  isActive ? labelOn : labelOff,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemperatureControl extends StatelessWidget {
  const _TemperatureControl({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => onChanged(value - 1),
              iconSize: 20,
            ),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onChanged(value + 1),
              iconSize: 20,
            ),
          ],
        )
      ],
    );
  }
}