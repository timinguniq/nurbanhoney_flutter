import 'package:authentication_domain/authentication_domain.dart';
import 'package:authentication_service/authentication_service.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_domain/navigation_domain.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney/ranking/view/widgets/widgets.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:share_service/share_service.dart';

/// 랭킹 탭: 기간 필 상단바 → 시상대(1~3위) → 띠 → 4위 이하 행 → 하단 고정 '내 순위' 바.
/// [getRankProvider] 가 전체를 한 번에 주므로 페이지네이션은 없다. 순위는 응답 순서(index + 1)다.
/// 집계 기준은 월 단위라 기간 필은 클라이언트에서 그 달 1일~말일로 계산한다.
class RankingTabPage extends ConsumerWidget {
  const RankingTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranks = ref.watch(getRankProvider);
    final loggedIn =
        ref.watch(authenticationServiceProvider) == AuthenticationStatus.authenticated;
    final myUserId = ref.watch(preferenceStorageProvider).valueOrNull?.getUserId();
    final toInsignia = ref.read(convertToInsignia);

    void goToAccount() =>
        ref.read(homeBottomNavigationProvider.notifier).select(HomeBottomStatus.myaccount);

    Future<void> refresh() async {
      ref.invalidate(getRankProvider);
      try {
        await ref.read(getRankProvider.future);
      } catch (_) {
        // 오류는 ErrorState 가 보여준다.
      }
    }

    /// 빈 상태·오류 상태도 당겨서 새로고침할 수 있게 스크롤 안에 둔다.
    Widget refreshable(Widget child) => RefreshIndicator(
          onRefresh: refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
          ),
        );

    return Scaffold(
      appBar: NbkAppBar.root(
        title: Strings.rankingTitle,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: NbkSpacing.md),
            child: Center(
              child: NbkPill(
                label: Strings.thisMonth(formatMonthRange(DateTime.now())),
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ),
        ],
      ),
      body: ranks.when(
        // 작은 화면에서는 스켈레톤이 본문보다 길 수 있어 스크롤되게 둔다.
        loading: () => const SingleChildScrollView(
          child: Shimmer(
            child: Column(
              children: [
                PodiumSkeleton(),
                SectionBand(),
                RankRowSkeleton(),
                RankRowSkeleton(),
                RankRowSkeleton(),
                RankRowSkeleton(),
                RankRowSkeleton(),
              ],
            ),
          ),
        ),
        error: (error, _) => refreshable(ErrorState(
          errorCode: errorCodeOf(error),
          onRetry: refresh,
        )),
        data: (data) {
          if (data.isEmpty) {
            return refreshable(const EmptyState(
              title: Strings.rankingEmptyTitle,
              message: Strings.rankingEmptyMessage,
              icon: Icons.emoji_events_outlined,
            ));
          }
          final entries = [
            for (var i = 0; i < data.length; i++)
              (
                rank: i + 1,
                badgeUrl: data[i].badge,
                nickname: data[i].nickname,
                insigniaUrls: toInsignia(data[i].insignia) as List<String>,
                lossAmount: data[i].totalLossCut,
                likeCount: data[i].totalLikeCount,
              ),
          ];
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: NbkSpacing.lg),
              children: [
                Podium(entries: entries.take(3).toList()),
                if (entries.length > 3) const SectionBand(),
                for (final entry in entries.skip(3)) ...[
                  RankRow(
                    rank: entry.rank,
                    badgeUrl: entry.badgeUrl,
                    nickname: entry.nickname,
                    insigniaUrls: entry.insigniaUrls,
                    lossAmount: entry.lossAmount,
                    likeCount: entry.likeCount,
                  ),
                  const Divider(),
                ],
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ranks.when(
          loading: () => MyRankBar(loggedIn: loggedIn, loading: true, onTap: () {}),
          error: (_, __) => const SizedBox.shrink(),
          data: (data) {
            final index = data.indexWhere((rank) => rank.userId == myUserId);
            final mine = loggedIn && index >= 0 ? data[index] : null;
            return MyRankBar(
              loggedIn: loggedIn,
              rank: mine == null ? null : index + 1,
              nickname: mine?.nickname,
              lossAmount: mine?.totalLossCut,
              onTap: loggedIn
                  ? goToAccount
                  : () => Navigator.of(context).push(LoginPage.route()),
            );
          },
        ),
      ),
    );
  }
}
