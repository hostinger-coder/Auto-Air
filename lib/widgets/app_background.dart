import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.intensity = 1.0,
  });

  final Widget child;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final t = intensity.clamp(0.0, 1.0);

    final baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [
        Color(0xFF0B0713),
        Color(0xFF140A26),
        Color(0xFF1A0C2E),
        Color(0xFF2B1055),
      ].map((c) => _lerpColor(c, Colors.black, 0.15 * t)).toList(),
      stops: const [0.0, 0.35, 0.62, 1.0],
    );

    final brGlow = RadialGradient(
      center: const Alignment(0.75, 0.65),
      radius: 0.85,
      colors: [
        const Color(0xFF6A2BC2).withOpacity(0.35 * (1.0 - 0.4 * t)),
        const Color(0xFF42177F).withOpacity(0.22 * (1.0 - 0.3 * t)),
        Colors.transparent,
      ],
      stops: const [0.0, 0.35, 1.0],
    );

    final tlGlow = RadialGradient(
      center: const Alignment(-0.9, -0.9),
      radius: 1.1,
      colors: [
        const Color(0xFF2A1F5E).withOpacity(0.28 * (1.0 - 0.4 * t)),
        const Color(0xFF1A1240).withOpacity(0.18 * (1.0 - 0.3 * t)),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    );

    final vignette = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.40 + 0.25 * t),
      ],
      stops: const [0.70, 1.0],
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: baseGradient),
        ),
        DecoratedBox(
          decoration: BoxDecoration(gradient: tlGlow),
        ),
        DecoratedBox(
          decoration: BoxDecoration(gradient: brGlow),
        ),
        DecoratedBox(
          decoration: BoxDecoration(gradient: vignette),
        ),
        child,
      ],
    );
  }

  Color _lerpColor(Color a, Color b, double t) => Color.lerp(a, b, t) ?? a;
}
