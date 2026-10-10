import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/account/view/widgets/widgets.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney/myaccount_setting/myaccount_setting.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 내 계정 탭. 인증 상태([authenticationServiceProvider])를 구독해 비로그인이면 [AccountLoggedOutView],
/// 로그인이면 저장된 토큰으로 [AccountProfileView] 를 보여준다. 로그아웃·로그인 뒤 돌아오면 그에 맞게 바뀐다.
class AccountTabPage extends ConsumerWidget {
  const AccountTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated =
        ref.watch(authenticationServiceProvider) == AuthenticationStatus.authenticated;
    final storage = ref.watch(preferenceStorageProvider).valueOrNull;

    final Widget body;
    if (!authenticated) {
      body = AccountLoggedOutView(
        onLogin: () => Navigator.of(context).push(LoginPage.route()),
      );
    } else if (storage == null) {
      body = const AccountProfileSkeleton();
    } else {
      final token = storage.getToken();
      // 토큰이 바뀌면(다른 계정으로 로그인) 목록 페이지 상태도 처음부터 다시 쌓는다.
      body = AccountProfileView(key: ValueKey(token), token: token);
    }

    return Scaffold(
      appBar: NbkAppBar.root(
        title: Strings.tabAccount,
        actions: [
          if (authenticated)
            NbkIconButton(
              icon: Icons.settings_outlined,
              tooltip: Strings.settingsTitle,
              onTap: () => Navigator.of(context).push(MyaccountSettingPage.route()),
            ),
        ],
      ),
      body: body,
    );
  }
}
