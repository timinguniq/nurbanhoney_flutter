import 'package:flutter/material.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 화면 하단 고정 댓글 입력 바: surface 필 입력(최대 60자, 오른쪽 `0/60`) + honey 필 [등록](44).
/// [onSubmit] 이 true 를 돌려주면 입력을 비운다. Scaffold.bottomNavigationBar 는 키보드를 피하지 않으므로
/// 키보드 높이(viewInsets.bottom)만큼 아래 여백을 두어 같이 올라온다.
class CommentInputBar extends StatefulWidget {
  const CommentInputBar({required this.onSubmit, super.key});

  final Future<bool> Function(String content) onSubmit;

  static const maxLength = 60;

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  final _controller = TextEditingController();
  var _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final done = await widget.onSubmit(_controller.text);
      if (done && mounted) {
        _controller.clear();
        FocusScope.of(context).unfocus();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      decoration: const BoxDecoration(
        color: NbkColors.bg,
        border: Border(top: BorderSide(color: NbkColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NbkSpacing.screen,
            vertical: NbkSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: NbkSize.commentInput,
                  padding: const EdgeInsets.only(left: NbkSpacing.lg, right: NbkSpacing.md),
                  decoration: BoxDecoration(
                    color: NbkColors.surface,
                    borderRadius: BorderRadius.circular(NbkRadius.pill),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLength: CommentInputBar.maxLength,
                          style: NbkTypography.inputText,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(
                            hintText: Strings.commentHint,
                            counterText: '',
                            filled: false,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: NbkSpacing.sm),
                      ValueListenableBuilder(
                        valueListenable: _controller,
                        builder: (_, value, __) => Text(
                          '${value.text.characters.length}/${CommentInputBar.maxLength}',
                          style: NbkTypography.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: NbkSpacing.sm + NbkSpacing.xxs),
              SizedBox(
                height: NbkSize.commentInput,
                child: NbkButton(
                  label: Strings.register,
                  size: NbkButtonSize.medium,
                  expand: false,
                  pill: true,
                  loading: _submitting,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
