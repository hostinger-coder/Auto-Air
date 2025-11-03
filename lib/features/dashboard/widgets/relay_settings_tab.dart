import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:AutoAir/features/dashboard/models/relay_model.dart';
import 'package:AutoAir/providers/dashboard_provider.dart';
import 'package:AutoAir/themes/custom_colors.dart';

class RelaySettingsTab extends StatelessWidget {
  const RelaySettingsTab({
    Key? key,
    required this.provider,
  }) : super(key: key);

  final DashboardProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          key: const ValueKey('relay_settings'),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                  padding: EdgeInsets.all(24.0),
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
            ],
          ),
        ),
      ),
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
              Switch(
                value: isOn,
                onChanged: widget.onToggle,
                thumbColor: MaterialStateProperty.resolveWith(
                      (_) => isOn ? Colors.white : Colors.white70,
                ),
                trackColor: MaterialStateProperty.resolveWith(
                      (_) => isOn ? custom.successTrack! : Colors.white10,
                ),
                overlayColor: MaterialStateProperty.resolveWith(
                      (_) => isOn
                      ? custom.success!.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
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
            label: 'Manual',
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          _PrimaryButton(
            label: 'Configure Schedule',
            onPressed: () {},
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
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
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
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}