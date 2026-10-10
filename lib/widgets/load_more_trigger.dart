import 'package:flutter/material.dart';

/// 목록 끝에 두면 처음 그려질 때 [onVisible] 을 한 번 부른다. 지연 생성되는 목록(SliverList 등)에서
/// 스크롤이 끝에 닿았을 때 다음 페이지를 받는 용도다. [child] 는 보통 다음 페이지 스켈레톤이다.
class LoadMoreTrigger extends StatefulWidget {
  const LoadMoreTrigger({required this.onVisible, required this.child, super.key});

  final VoidCallback onVisible;
  final Widget child;

  @override
  State<LoadMoreTrigger> createState() => _LoadMoreTriggerState();
}

class _LoadMoreTriggerState extends State<LoadMoreTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onVisible();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
