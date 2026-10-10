import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nurbanhoney/theme/theme.dart';

/// 토스트를 올릴 Overlay 를 찾기 위한 키. `MaterialApp.navigatorKey` 에 넣는다.
final nbkNavigatorKey = GlobalKey<NavigatorState>();

enum NbkToastType { success, info, error }

/// 토스트. 배경은 항상 text1, 왼쪽 아이콘 색만 상태를 말한다. 새 토스트가 오면 이전 것을 바로 치운다.
abstract class NbkToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static const _duration = Duration(seconds: 2);

  static void show(
    String message, {
    NbkToastType type = NbkToastType.info,
  }) {
    final overlay = nbkNavigatorKey.currentState?.overlay;
    if (overlay == null) return;
    hide();
    final entry = OverlayEntry(
      builder: (_) => _NbkToastView(message: message, type: type),
    );
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(_duration, hide);
  }

  static void success(String message) => show(message, type: NbkToastType.success);

  static void info(String message) => show(message, type: NbkToastType.info);

  static void error(String message) => show(message, type: NbkToastType.error);

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _NbkToastView extends StatefulWidget {
  const _NbkToastView({required this.message, required this.type});

  final String message;
  final NbkToastType type;

  @override
  State<_NbkToastView> createState() => _NbkToastViewState();
}

class _NbkToastViewState extends State<_NbkToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final (icon, iconColor) = switch (widget.type) {
      NbkToastType.success => (Icons.check, NbkColors.toastSuccess),
      NbkToastType.info => (Icons.error_outline, NbkColors.toastInfo),
      NbkToastType.error => (Icons.error_outline, NbkColors.toastError),
    };

    return Positioned(
      left: NbkSpacing.screen,
      right: NbkSpacing.screen,
      bottom: media.viewInsets.bottom + media.padding.bottom + NbkSpacing.xxl,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _controller,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(minHeight: NbkSize.toast),
                padding: const EdgeInsets.symmetric(
                  horizontal: NbkSpacing.lg,
                  vertical: NbkSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: NbkColors.text1,
                  borderRadius: BorderRadius.circular(NbkRadius.toast),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: NbkSize.reactionIcon, color: iconColor),
                    const SizedBox(width: NbkSpacing.md),
                    Expanded(
                      child: Text(widget.message, style: NbkTypography.toast),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
