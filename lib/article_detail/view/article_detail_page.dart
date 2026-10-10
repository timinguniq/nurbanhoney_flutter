import 'dart:async';
import 'dart:developer';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nurbanhoney/article_detail/view/widgets/widgets.dart';
import 'package:nurbanhoney/config/config.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/login/login.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:share_service/share_service.dart';

/// 글 상세. 본문·반응·댓글을 보여주고 댓글 입력 바를 화면 하단에 고정한다.
/// 글을 삭제하면 `true` 를 돌려주며 닫힌다. 없는 글(404)이면 토스트 뒤 바로 닫힌다.
class ArticleDetailPage extends ConsumerStatefulWidget {
  const ArticleDetailPage({
    required this.board,
    required this.articleId,
    super.key,
  });

  /// 1 주식, 2 코인
  final int board;
  final int articleId;

  static Route<bool> route({required int articleId, required int board}) {
    return MaterialPageRoute<bool>(
      builder: (_) => ArticleDetailPage(articleId: articleId, board: board),
    );
  }

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  static const _emptyToken = '__empty__';
  static const _articleDeleted = 'nurbanboard_deleted';
  static const _commentDeleted = 'nurbancomment_deleted';

  BannerAd? _bannerAd;
  var _bannerLoaded = false;
  var _notFoundHandled = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: banner1key,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _bannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          log('$BannerAd failedToLoad: $error');
          unawaited(ad.dispose().catchError((Object e) => log('$BannerAd dispose error: $e')));
        },
      ),
      request: const AdRequest(),
    );
    // 광고는 없어도 화면은 떠야 하므로 로드 실패(플러그인 없음 포함)는 삼킨다.
    unawaited(_bannerAd!.load().catchError((Object e) => log('$BannerAd load error: $e')));
  }

  @override
  void dispose() {
    unawaited(_bannerAd?.dispose().catchError((Object e) => log('$BannerAd dispose error: $e')));
    super.dispose();
  }

  String get _token =>
      ref.read(preferenceStorageProvider).valueOrNull?.getToken() ?? _emptyToken;

  void _invalidateComments() {
    ref.invalidate(getNurbanCommentsProvider(widget.articleId));
    ref.invalidate(getNurbanArticleProvider(widget.articleId));
  }

  Future<void> _deleteArticle(String uuid) async {
    final confirmed = await showConfirmSheet(
      context,
      title: Strings.deleteArticleTitle,
      message: Strings.deleteArticleMessage,
      confirmLabel: Strings.delete,
    );
    if (!confirmed || !mounted) return;
    String result;
    try {
      result = await ref.read(nurbanRepositoryProvider).nurbanArticleDelete(
            token: _token,
            articleId: widget.articleId,
            uuid: uuid,
          );
    } catch (_) {
      result = '';
    }
    if (!mounted) return;
    if (result != _articleDeleted) {
      NbkToast.error(Strings.toastArticleDeleteFailed);
      return;
    }
    NbkToast.success(Strings.toastArticleDeleted);
    Navigator.of(context).pop(true);
  }

  Future<void> _deleteComment(int commentId) async {
    final confirmed = await showConfirmSheet(
      context,
      title: Strings.deleteCommentTitle,
      message: Strings.deleteCommentMessage,
      confirmLabel: Strings.delete,
    );
    if (!confirmed || !mounted) return;
    String result;
    try {
      result = await ref.read(nurbanRepositoryProvider).nurbanCommentDelete(
            token: _token,
            commentId: commentId,
            articleId: widget.articleId,
          );
    } catch (_) {
      result = '';
    }
    if (!mounted) return;
    if (result != _commentDeleted) {
      NbkToast.error(Strings.toastCommentDeleteFailed);
      return;
    }
    NbkToast.success(Strings.toastCommentDeleted);
    _invalidateComments();
  }

  /// 댓글 등록. 비로그인이면 로그인 화면으로, 등록되면 true(입력 바가 비운다).
  Future<bool> _createComment(String content) async {
    final token = _token;
    if (token == _emptyToken) {
      await Navigator.of(context).push(LoginPage.route());
      return false;
    }
    if (content.trim().isEmpty) {
      NbkToast.info(Strings.toastCommentEmpty);
      return false;
    }
    try {
      await ref.read(nurbanRepositoryProvider).nurbanCommentCreate(
            token: token,
            articleId: widget.articleId,
            content: content,
          );
    } catch (_) {
      NbkToast.error(Strings.toastCommentCreateFailed);
      return false;
    }
    if (!mounted) return false;
    _invalidateComments();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(preferenceStorageProvider).valueOrNull;
    final myUserId = storage?.getUserId();
    final article = ref.watch(getNurbanArticleProvider(widget.articleId));
    ref.listen(getNurbanArticleProvider(widget.articleId), (_, next) {
      if (_notFoundHandled || !next.hasError || httpStatusOf(next.error) != 404) return;
      _notFoundHandled = true;
      NbkToast.error(Strings.toastArticleNotFound);
      Navigator.of(context).pop(false);
    });

    final data = article.valueOrNull;
    final mine = data != null && myUserId != null && data.userId == myUserId;

    return Scaffold(
      appBar: NbkAppBar(
        leading: NbkAppBarLeading.back,
        titleWidget: NbkPill(label: Strings.boardName(widget.board)),
        actions: [
          if (mine)
            NbkIconButton(
              icon: Icons.more_vert,
              tooltip: Strings.delete,
              onTap: () => _deleteArticle(data.uuid),
            ),
        ],
      ),
      body: article.when(
        loading: () => const ArticleDetailSkeleton(),
        error: (error, _) => httpStatusOf(error) == 404
            ? const SizedBox.shrink()
            : ErrorState(
                errorCode: errorCodeOf(error),
                onRetry: () => ref.invalidate(getNurbanArticleProvider(widget.articleId)),
              ),
        data: (data) => ListView(
          padding: const EdgeInsets.only(bottom: NbkSpacing.xxl),
          children: [
            ArticleBody(
              title: data.title,
              badgeUrl: data.badge,
              nickname: data.nickname,
              insigniaUrls: ref.read(convertToInsignia)(data.insignia),
              meta: '${formatDate(data.updatedAt, dotDateTimeFormat)} · '
                  '${Strings.views(data.count.toString())}',
              mine: mine,
              lossAmount: parseLossAmount(data.lossCut),
              thumbnailUrl: data.thumbnail,
              content: data.content,
            ),
            // AdMob 자리. 광고가 오기 전에도 높이를 비워 둔다.
            SizedBox(
              height: NbkSize.adBanner.height,
              child: _bannerLoaded && _bannerAd != null
                  ? Center(
                      child: SizedBox(
                        width: NbkSize.adBanner.width,
                        height: NbkSize.adBanner.height,
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: NbkSpacing.lg),
            ReactionBar(articleId: widget.articleId),
            const SizedBox(height: NbkSpacing.xl),
            const SectionBand(),
            CommentSection(
              articleId: widget.articleId,
              commentCount: data.commentCount,
              myUserId: myUserId,
              onDelete: _deleteComment,
              onRetry: () => ref.invalidate(getNurbanCommentsProvider(widget.articleId)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CommentInputBar(onSubmit: _createComment),
    );
  }
}
