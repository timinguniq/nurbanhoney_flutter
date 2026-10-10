import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// 이용약관·개인정보 처리방침 다이얼로그. 본문은 [provider](`getTermsProvider`/`getPrivacyProvider`)로 받아온다.
/// 받는 동안 스피너, 실패하면 [다시 시도].
Future<void> showPolicyDialog(
  BuildContext context, {
  required String title,
  required AutoDisposeFutureProvider<String> provider,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _PolicyDialog(title: title, provider: provider),
  );
}

class _PolicyDialog extends ConsumerWidget {
  const _PolicyDialog({required this.title, required this.provider});

  final String title;
  final AutoDisposeFutureProvider<String> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(provider);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: NbkSpacing.lg,
        vertical: NbkSpacing.xxxl + NbkSpacing.xxl,
      ),
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: content.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(NbkSpacing.xxl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Strings.errorPolicyLoad,
                style: NbkTypography.body.copyWith(color: NbkColors.text3),
              ),
              const SizedBox(height: NbkSpacing.lg),
              NbkButton(
                label: Strings.retry,
                icon: Icons.refresh,
                variant: NbkButtonVariant.dark,
                expand: false,
                onPressed: () => ref.invalidate(provider),
              ),
            ],
          ),
          data: (text) => SingleChildScrollView(
            child: Text(text, style: NbkTypography.body),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(Strings.confirm),
        ),
      ],
    );
  }
}
