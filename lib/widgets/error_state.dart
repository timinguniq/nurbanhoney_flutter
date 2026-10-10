import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/nbk_button.dart';

/// 오류 상태: 아이콘 타일 + 제목 + 설명 + [다시 시도] + 작은 오류 코드 캡션.
/// 개발자용 오류 문자열은 받지 않는다. [errorCode] 는 `errorCodeOf` 로 만든 짧은 코드만 넣는다.
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.onRetry,
    this.title = Strings.errorLoadTitle,
    this.message = Strings.errorNetworkMessage,
    this.errorCode,
    this.occurredAt,
    super.key,
  });

  final VoidCallback onRetry;
  final String title;
  final String message;
  final String? errorCode;

  /// 캡션에 찍을 시각. 없으면 지금.
  final DateTime? occurredAt;

  static const _timeFormat = 'M.d HH:mm';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NbkSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: NbkSize.emptyTile,
              height: NbkSize.emptyTile,
              decoration: BoxDecoration(
                color: NbkColors.surface,
                borderRadius: BorderRadius.circular(NbkRadius.emptyTile),
              ),
              child: const Icon(
                Icons.report_gmailerrorred,
                size: NbkSize.stateIcon,
                color: NbkColors.text2,
              ),
            ),
            const SizedBox(height: NbkSpacing.xl),
            Text(title, style: NbkTypography.heading, textAlign: TextAlign.center),
            const SizedBox(height: NbkSpacing.sm),
            Text(
              message,
              style: NbkTypography.body.copyWith(color: NbkColors.text3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NbkSpacing.xxl),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: NbkSize.retryButtonMinWidth),
              child: NbkButton(
                label: Strings.retry,
                icon: Icons.refresh,
                variant: NbkButtonVariant.dark,
                expand: false,
                onPressed: onRetry,
              ),
            ),
            if (errorCode != null) ...[
              const SizedBox(height: NbkSpacing.md),
              Text(
                Strings.errorCode(
                  errorCode!,
                  DateFormat(_timeFormat).format(occurredAt ?? DateTime.now()),
                ),
                style: NbkTypography.caption.copyWith(color: NbkColors.hint),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
