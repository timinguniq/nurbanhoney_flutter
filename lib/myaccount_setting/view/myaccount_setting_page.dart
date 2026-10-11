import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio_domain/dio_domain.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nurbanhoney/account/account.dart';
import 'package:nurbanhoney/home/home.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/myaccount_edit/myaccount_edit.dart';
import 'package:nurbanhoney/myaccount_setting/view/widgets/widgets.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 내 정보(설정): '계정'(로그인 수단 + 로그아웃, 프로필 수정) / '앱 정보' / 맨 아래 '탈퇴하기'.
/// 로그아웃은 직전 화면(내 계정 탭)으로 돌아가고, 탈퇴는 성공했을 때만 홈으로 돌아간다.
class MyaccountSettingPage extends ConsumerStatefulWidget {
  const MyaccountSettingPage({super.key});

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MyaccountSettingPage(),
    );
  }

  @override
  ConsumerState<MyaccountSettingPage> createState() => _MyaccountSettingPageState();
}

class _MyaccountSettingPageState extends ConsumerState<MyaccountSettingPage> {
  static final _comma = NumberFormat('#,###');

  /// 로그아웃·탈퇴 요청 중. 이 동안은 뒤로 가기를 막는다(세션 정리가 끝나기 전에 화면을 떠나지 않게).
  var _busy = false;

  Future<void> _logout() async {
    if (_busy) return;
    setState(() => _busy = true);
    // 화면이 사라져도 세션 정리는 끝나야 하므로 ref 로 얻을 것은 await 전에 잡아 둔다.
    final auth = ref.read(authenticationServiceProvider.notifier);
    final storageFuture = ref.read(preferenceStorageProvider.future);
    try {
      final storage = await storageFuture;
      await storage.setEmptyToken();
      auth.set(AuthenticationStatus.unauthenticated);
      if (!mounted) return;
      NbkToast.success(Strings.toastLoggedOut);
      // 요청 중에는 본문이 잠겨 위에 다른 route 가 없지만, 혹시 있어도 설정 화면 자체를 닫는다.
      final route = ModalRoute.of(context);
      final navigator = Navigator.of(context);
      if (route != null) navigator.popUntil((r) => r == route);
      navigator.pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _withdraw({
    required int userId,
    required int articles,
    required int comments,
    required int points,
  }) async {
    final confirmed = await showConfirmDialog(
      context,
      title: Strings.withdrawConfirmTitle,
      message: Strings.withdrawConfirmMessage(
        _comma.format(articles),
        _comma.format(comments),
        _comma.format(points),
      ),
      confirmLabel: Strings.withdrawAction,
      icon: Icons.warning_amber_rounded,
      checkboxLabel: Strings.withdrawCheckbox,
    );
    if (!confirmed || !mounted || _busy) return;
    setState(() => _busy = true);
    // 요청 중 화면이 사라져도(강제 종료 등) 서버에서 탈퇴됐으면 토큰·인증 상태는 정리해야 한다.
    final auth = ref.read(authenticationServiceProvider.notifier);
    final repository = ref.read(profileRepositoryProvider);
    final storageFuture = ref.read(preferenceStorageProvider.future);
    try {
      final storage = await storageFuture;
      try {
        await repository.myaccountWithdrawal(userId: userId);
      } on ApiFailure {
        if (mounted) NbkToast.error(Strings.toastWithdrawFailed);
        return;
      }
      await storage.setEmptyToken();
      auth.set(AuthenticationStatus.unauthenticated);
      if (!mounted) return;
      NbkToast.success(Strings.toastWithdrawn);
      Navigator.of(context).pushAndRemoveUntil(HomePageRefactor.route(), (_) => false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(getProfileProvider);

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
      appBar: const NbkAppBar(leading: NbkAppBarLeading.back, title: Strings.settingsTitle),
      // 요청 중에는 본문(프로필 수정·약관·탈퇴 등)을 건드리지 못하게 한다.
      body: IgnorePointer(
        ignoring: _busy,
        child: profile.when(
        loading: () => const _SettingsSkeleton(),
        error: (error, _) => ErrorState(
          errorCode: errorCodeOf(error),
          onRetry: () => ref.invalidate(getProfileProvider),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.symmetric(vertical: NbkSpacing.lg),
          children: [
            const _SectionTitle(Strings.accountSection),
            LoginMethodRow(
              loginType: data.loginType,
              nickname: data.nickname,
              createdAt: data.createdAt,
              onLogout: _logout,
            ),
            const Divider(),
            AccountMenuRow(
              title: Strings.profileEdit,
              onTap: () => Navigator.of(context).push(MyaccountEditPage.route()),
            ),
            const Divider(),
            const SizedBox(height: NbkSpacing.xxl),
            const AppInfoSection(),
            const SizedBox(height: NbkSpacing.xxxl),
            Center(
              child: TextButton(
                onPressed: () => _withdraw(
                  userId: data.id,
                  articles: data.myArticleCount,
                  comments: data.myCommentCount,
                  points: data.point,
                ),
                child: Text(
                  Strings.withdraw,
                  style: NbkTypography.caption.copyWith(
                    color: NbkColors.text3,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(NbkSpacing.screen, 0, NbkSpacing.screen, NbkSpacing.sm),
      child: Text(title, style: NbkTypography.itemTitle.copyWith(color: NbkColors.text3)),
    );
  }
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Padding(
        padding: EdgeInsets.all(NbkSpacing.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 40),
            SizedBox(height: NbkSpacing.lg),
            Row(
              children: [
                SkeletonBox(width: NbkSize.avatarMd, height: NbkSize.avatarMd, radius: NbkRadius.avatarMd),
                SizedBox(width: NbkSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 90, height: NbkSize.iconSm),
                    SizedBox(height: NbkSpacing.xs),
                    SkeletonBox(width: 60),
                  ],
                ),
              ],
            ),
            SizedBox(height: NbkSpacing.xl),
            SkeletonBox(width: 120, height: NbkSize.iconSm),
            SizedBox(height: NbkSpacing.xxl),
            SkeletonBox(width: 50),
            SizedBox(height: NbkSpacing.lg),
            SkeletonBox(width: 80, height: NbkSize.iconSm),
            SizedBox(height: NbkSpacing.lg),
            SkeletonBox(width: 140, height: NbkSize.iconSm),
          ],
        ),
      ),
    );
  }
}
