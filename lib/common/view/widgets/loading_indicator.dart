import 'dart:developer';

import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.height,
    required this.isBusy,
    required this.child,
  });

  final double? height;
  final bool isBusy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    log('LoadingIndicator: isBusy: $isBusy');
    return Stack(
      children: [
        child,

        /// CircularIndicator
        IgnorePointer(
          ignoring: !isBusy,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isBusy ? 1 : 0,
            curve: Curves.easeOutCubic,
            child: Container(
              height: height,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}
