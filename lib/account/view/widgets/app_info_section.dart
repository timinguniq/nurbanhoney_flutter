import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/account/view/widgets/account_menu_row.dart';
import 'package:nurbanhoney/common/common.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 설치된 앱의 버전 문자열(`pubspec.yaml` 의 version 앞부분)
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

/// '앱 정보' 섹션: 이용약관 / 개인정보 처리방침 / 앱 버전. 내 계정(비로그인)과 내 정보 화면이 같이 쓴다.
class AppInfoSection extends ConsumerWidget {
  const AppInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).valueOrNull ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NbkSpacing.screen),
          child: Text(
            Strings.appInfo,
            style: NbkTypography.itemTitle.copyWith(color: NbkColors.text3),
          ),
        ),
        const SizedBox(height: NbkSpacing.sm),
        AccountMenuRow(
          title: Strings.terms,
          onTap: () => showPolicyDialog(
            context,
            title: Strings.terms,
            provider: getTermsProvider,
          ),
        ),
        const Divider(),
        AccountMenuRow(
          title: Strings.privacy,
          onTap: () => showPolicyDialog(
            context,
            title: Strings.privacy,
            provider: getPrivacyProvider,
          ),
        ),
        const Divider(),
        AccountMenuRow(
          title: Strings.appVersion,
          trailing: Text(
            version,
            style: NbkTypography.body.copyWith(color: NbkColors.text3),
          ),
        ),
      ],
    );
  }
}
