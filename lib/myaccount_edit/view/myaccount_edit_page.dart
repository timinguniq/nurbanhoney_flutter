import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/myaccount_edit/view/widgets/widgets.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:share_service/share_service.dart';

/// 프로필 수정(풀스크린 폼). 닉네임(8자)·소개(100자)·닉네임 옆에 보이는 휘장(최대 2개)을 고친다.
/// 저장이 성공하면 프로필 Provider 를 무효화하고 직전 화면으로 돌아간다.
class MyaccountEditPage extends ConsumerStatefulWidget {
  const MyaccountEditPage({super.key});

  static const nicknameMaxLength = 8;
  static const introMaxLength = 100;
  static const maxShownInsignia = 2;

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MyaccountEditPage(),
    );
  }

  @override
  ConsumerState<MyaccountEditPage> createState() => _MyaccountEditPageState();
}

class _MyaccountEditPageState extends ConsumerState<MyaccountEditPage> {
  static const _emptyToken = '__empty__';
  static const _updated = 'profile_updated';

  final _nickname = TextEditingController();
  final _intro = TextEditingController();

  /// 닉네임 옆에 보이는 휘장 URL(순서 유지). 서버 값으로 한 번 채운다.
  final _shown = <String>[];
  var _filled = false;
  var _showNicknameError = false;
  var _saving = false;

  @override
  void dispose() {
    _nickname.dispose();
    _intro.dispose();
    super.dispose();
  }

  void _fillOnce(String nickname, String description, List<String> shown) {
    if (_filled) return;
    _filled = true;
    _nickname.text = nickname;
    _intro.text = description == 'null' ? '' : description;
    // 예전 화면은 개수를 제한하지 않아 3개 이상 저장된 계정이 있을 수 있다. 중복을 빼고 앞 2개만 쓴다.
    _shown.addAll(
      shown.where((url) => url.isNotEmpty).toSet().take(MyaccountEditPage.maxShownInsignia),
    );
  }

  bool get _full => _shown.length >= MyaccountEditPage.maxShownInsignia;

  void _toggle(String url) {
    setState(() {
      if (_shown.contains(url)) {
        _shown.remove(url);
      } else if (!_full) {
        _shown.add(url);
      }
      // 2개가 차 있으면 보유 휘장 탭을 무시한다(안내 문구가 이미 보인다).
    });
  }

  Future<void> _save(String token) async {
    final nickname = _nickname.text.trim();
    if (nickname.isEmpty) {
      setState(() => _showNicknameError = true);
      NbkToast.error(Strings.nicknameRequired);
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);
    String result;
    try {
      result = await ref.read(profileRepositoryProvider).profileEdit(
            token: token,
            nickname: nickname,
            description: _intro.text.trim(),
            // 서버는 기존처럼 Set.toString() 형식('{url1, url2}')을 받는다.
            insignia: _shown.toSet().toString(),
          );
    } catch (_) {
      result = '';
    }
    if (!mounted) return;
    if (result != _updated) {
      setState(() => _saving = false);
      NbkToast.error(Strings.toastProfileSaveFailed);
      return;
    }
    NbkToast.success(Strings.toastProfileSaved);
    ref.invalidate(getProfileProvider);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(preferenceStorageProvider).valueOrNull?.getToken() ?? _emptyToken;
    final profile = ref.watch(getProfileProvider(token));
    final toInsignia = ref.read(convertToInsignia);

    return Scaffold(
      appBar: NbkAppBar(
        leading: NbkAppBarLeading.close,
        title: Strings.profileEditTitle,
        actions: [
          NbkPillButton(
            label: Strings.save,
            onPressed: profile.hasValue && !_saving ? () => _save(token) : null,
          ),
        ],
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          errorCode: errorCodeOf(error),
          onRetry: () => ref.invalidate(getProfileProvider),
        ),
        data: (data) {
          final List<String> owned = toInsignia(data.insigniaOwn);
          _fillOnce(data.nickname, data.description, toInsignia(data.insigniaShow));
          final nicknameEmpty = _nickname.text.trim().isEmpty;
          final nicknameError = _showNicknameError && nicknameEmpty;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              NbkSpacing.screen,
              NbkSpacing.xl,
              NbkSpacing.screen,
              NbkSpacing.xxxl,
            ),
            children: [
              Center(
                child: NbkBadge(url: data.badge, size: NbkSize.avatarEdit, radius: NbkRadius.avatarXl),
              ),
              const SizedBox(height: NbkSpacing.md),
              const Text(Strings.badgeAutoNote, style: NbkTypography.caption, textAlign: TextAlign.center),
              const SizedBox(height: NbkSpacing.formGap),
              ValueListenableBuilder(
                valueListenable: _nickname,
                builder: (_, value, __) => NbkFieldLabel(
                  label: Strings.nicknameLabel,
                  counter: '${value.text.characters.length}/${MyaccountEditPage.nicknameMaxLength}',
                  error: nicknameError,
                ),
              ),
              const SizedBox(height: NbkSpacing.sm),
              TextField(
                controller: _nickname,
                maxLength: MyaccountEditPage.nicknameMaxLength,
                style: NbkTypography.inputText,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: Strings.nicknameHint, counterText: ''),
              ),
              const SizedBox(height: NbkSpacing.sm),
              if (nicknameEmpty)
                Text(
                  Strings.nicknameRequired,
                  style: NbkTypography.caption.copyWith(color: NbkColors.dangerText),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.check, size: NbkSize.iconXs, color: NbkColors.success),
                    const SizedBox(width: NbkSpacing.xs),
                    Text(
                      Strings.nicknameAvailable,
                      style: NbkTypography.caption.copyWith(color: NbkColors.success),
                    ),
                  ],
                ),
              const SizedBox(height: NbkSpacing.formGap),
              ValueListenableBuilder(
                valueListenable: _intro,
                builder: (_, value, __) => NbkFieldLabel(
                  label: Strings.introLabel,
                  counter: '${value.text.characters.length}/${MyaccountEditPage.introMaxLength}',
                ),
              ),
              const SizedBox(height: NbkSpacing.sm),
              TextField(
                controller: _intro,
                maxLength: MyaccountEditPage.introMaxLength,
                minLines: 1,
                maxLines: 3,
                style: NbkTypography.inputText,
                decoration: const InputDecoration(hintText: Strings.introHint, counterText: ''),
              ),
              const SizedBox(height: NbkSpacing.formGap),
              Row(
                children: [
                  const Text(Strings.shownInsigniaLabel, style: NbkTypography.labelStrong),
                  const Spacer(),
                  Text(
                    '${_shown.length}/${MyaccountEditPage.maxShownInsignia}',
                    style: NbkTypography.labelStrong.copyWith(
                      color: _full ? NbkColors.honeyDeep : NbkColors.text3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NbkSpacing.sm),
              if (_shown.isNotEmpty)
                Row(
                  children: [
                    for (final url in _shown) ...[
                      InsigniaTile(
                        url: url,
                        selected: true,
                        width: NbkSize.insigniaTile.width,
                        onTap: () => _toggle(url),
                        badge: InsigniaRemove(onTap: () => _toggle(url)),
                      ),
                      const SizedBox(width: NbkSpacing.xl),
                    ],
                  ],
                ),
              if (_full) ...[
                const SizedBox(height: NbkSpacing.sm),
                const Text(Strings.shownInsigniaFull, style: NbkTypography.caption),
              ],
              const SizedBox(height: NbkSpacing.formGap),
              Text(Strings.ownedInsigniaLabel(owned.length), style: NbkTypography.labelStrong),
              const SizedBox(height: NbkSpacing.sm),
              // 3열 그리드. 칸 높이가 타일 높이(64)와 같도록 칸 폭에서 비율을 계산한다.
              LayoutBuilder(
                builder: (context, constraints) {
                  const columns = 3;
                  const spacing = NbkSpacing.md;
                  final cellWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
                  return GridView.count(
                    crossAxisCount: columns,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: cellWidth / NbkSize.insigniaGridTileHeight,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final url in owned)
                        InsigniaTile(
                          url: url,
                          selected: _shown.contains(url),
                          onTap: () => _toggle(url),
                          badge: _shown.contains(url) ? const InsigniaCheck() : null,
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
