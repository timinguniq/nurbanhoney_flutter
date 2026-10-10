import 'package:flutter/material.dart';

/// 한 번이라도 보인 자식만 만들어 두고 상태를 유지하는 [IndexedStack]. 탭 전환용.
/// 처음부터 모든 탭을 만들면 보이지 않는 탭까지 데이터를 받아오므로 첫 방문 때 만든다.
class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    required this.index,
    required this.children,
    super.key,
  });

  final int index;
  final List<Widget> children;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  final _built = <int>{};

  @override
  Widget build(BuildContext context) {
    _built.add(widget.index);
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _built.contains(i) ? widget.children[i] : const SizedBox.shrink(),
      ],
    );
  }
}
