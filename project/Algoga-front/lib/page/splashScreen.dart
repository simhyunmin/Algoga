import 'package:algoga/page/mainpage.dart';

import 'formpage.dart';
import 'splashOverlay.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [const FormPage(), if (_showSplash) const SplashOverlay()],
    );
  }
}
