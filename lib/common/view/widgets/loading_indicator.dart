import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.height,
    required this.isLoading,
    required this.child,
  });

  final double? height;
  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        /// CircularIndicator
        IgnorePointer(
          ignoring: !isLoading,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isLoading ? 1 : 0,
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
