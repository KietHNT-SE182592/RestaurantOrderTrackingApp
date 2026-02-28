import 'package:flutter/material.dart';

/// Shell của Kitchen (Chef) — full screen, không có bottom nav.
/// Chef chỉ có 1 màn hình chính là KDS.
class KitchenShellPage extends StatelessWidget {
  final Widget child;

  const KitchenShellPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
