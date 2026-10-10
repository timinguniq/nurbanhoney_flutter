import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';

/// offset 단위로 받은 페이지들을 하나의 sliver 목록으로 보여준다.
/// 첫 페이지 로딩은 [skeleton] 3행, 첫 페이지 오류는 [ErrorState], 빈 목록은 [empty].
/// 뒤 페이지가 로딩 중이면 끝에 [skeleton] 1행, 실패했으면 그 페이지를 다시 받는 [다시 시도] 를 둔다.
/// 모든 페이지를 받았고 마지막 페이지가 [pageSize] 만큼 차 있으면 [LoadMoreTrigger] 가 [onLoadMore] 를 부른다.
class PagedSliverList<T> extends StatelessWidget {
  const PagedSliverList({
    required this.pages,
    required this.pageSize,
    required this.itemBuilder,
    required this.empty,
    required this.skeleton,
    required this.onLoadMore,
    required this.onRetry,
    super.key,
  }) : assert(pages.length > 0, '첫 페이지는 항상 있어야 한다');

  /// offset 순서대로 watch 한 페이지들
  final List<AsyncValue<List<T>>> pages;
  final int pageSize;
  final Widget Function(T item) itemBuilder;
  final Widget empty;
  final Widget skeleton;
  final VoidCallback onLoadMore;

  /// 그 페이지를 다시 받는다
  final void Function(int pageIndex) onRetry;

  @override
  Widget build(BuildContext context) {
    final first = pages.first;
    if (!first.hasValue) {
      if (first.hasError) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(
            errorCode: errorCodeOf(first.error),
            onRetry: () => onRetry(0),
          ),
        );
      }
      return SliverToBoxAdapter(
        child: Shimmer(child: Column(children: [for (var i = 0; i < 3; i++) skeleton])),
      );
    }

    // 페이지를 offset 순서대로 이어 붙인다. 값이 없는 페이지(로딩·오류)를 만나면 거기서 멈추고
    // 그 상태를 footer 로 보여준다. 탭을 오가며 autoDispose 된 뒤 다시 받을 때 중간 페이지만 실패해도
    // 조용히 빠지지 않고 그 페이지를 다시 시도할 수 있다.
    final items = <T>[];
    Widget? footer;
    var allLoaded = true;
    for (var i = 0; i < pages.length; i++) {
      final page = pages[i];
      if (page.hasValue) {
        items.addAll(page.value!);
        continue;
      }
      allLoaded = false;
      footer = page.hasError ? _retryRow(i) : Shimmer(child: skeleton);
      break;
    }
    if (items.isEmpty && footer == null) {
      return SliverFillRemaining(hasScrollBody: false, child: empty);
    }
    if (allLoaded) {
      final last = pages.last;
      if (!last.isLoading && (last.valueOrNull?.length ?? 0) >= pageSize) {
        footer = LoadMoreTrigger(onVisible: onLoadMore, child: Shimmer(child: skeleton));
      }
    }

    // 아이템 사이에 Divider 를 끼우고, footer 가 있으면 맨 뒤에 둔다.
    final bodyCount = items.isEmpty ? 0 : items.length * 2 - 1;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == bodyCount) return footer;
          if (index.isOdd) return const Divider();
          return itemBuilder(items[index ~/ 2]);
        },
        childCount: bodyCount + (footer == null ? 0 : 1),
      ),
    );
  }

  Widget _retryRow(int pageIndex) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NbkSpacing.lg),
        child: NbkButton(
          label: Strings.retry,
          icon: Icons.refresh,
          variant: NbkButtonVariant.outline,
          expand: false,
          onPressed: () => onRetry(pageIndex),
        ),
      ),
    );
  }
}
