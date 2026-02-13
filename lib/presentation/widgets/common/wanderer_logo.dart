import 'package:flutter/material.dart';

/// Wanderer app logo - uses the wanderer-logo.png asset
class WandererLogo extends StatelessWidget {
  final double size;
  final Color?
      color; // Kept for backward compatibility, but not used with image

  const WandererLogo({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/wanderer-logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
