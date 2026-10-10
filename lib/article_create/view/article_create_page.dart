import 'dart:developer';
import 'dart:io';

import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurbanhoney/article_create/view/widgets/widgets.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/utils/utils.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage_service/preference_storage_service.dart';
import 'package:uuid/uuid.dart';

/// 글 작성(풀스크린 폼). [board] 는 진입한 홈 탭의 게시판(1 주식, 2 코인)으로 기본 선택된다.
/// [완료] 는 아무것도 입력하지 않았거나 사진을 올리는 중이면 비활성이고, 누르면 빠진 항목을 인라인으로 표시한다.
/// 등록에 성공하면 `true` 를 돌려주며 닫힌다. [pickImage] 는 테스트에서 갤러리 대신 끼워 넣는다.
class ArticleCreatePage extends ConsumerStatefulWidget {
  const ArticleCreatePage({
    this.board = 1,
    this.pickImage = pickAndCompressImage,
    super.key,
  });

  final int board;
  final Future<File?> Function() pickImage;

  static const titleMaxLength = 40;

  static Route<bool> route({int board = 1}) {
    return MaterialPageRoute<bool>(
      builder: (_) => ArticleCreatePage(board: board),
    );
  }

  @override
  ConsumerState<ArticleCreatePage> createState() => _ArticleCreatePageState();
}

class _ArticleCreatePageState extends ConsumerState<ArticleCreatePage> {
  static const _emptyToken = '__empty__';
  static const _posted = {'nurbanboard_posted', 'freeboard_posted'};

  late int _board = widget.board;
  final _title = TextEditingController();
  final _loss = TextEditingController();
  final _content = TextEditingController();

  /// 업로드된 사진 URL·uuid 와 올린 게시판(삭제할 때 같은 게시판 API 를 쓴다)
  var _thumbnail = '';
  var _uuid = '';
  var _uploadBoard = 1;

  /// 갤러리에서 고르고 압축하는 중(이 동안 [완료] 를 막는다 — 바꾸기 중에 이전 사진으로 등록되지 않게)
  var _pickingPhoto = false;
  var _uploading = false;
  var _submitting = false;
  var _showErrors = false;

  @override
  void dispose() {
    _title.dispose();
    _loss.dispose();
    _content.dispose();
    super.dispose();
  }

  String get _token =>
      ref.read(preferenceStorageProvider).valueOrNull?.getToken() ?? _emptyToken;

  int get _lossAmount => parseLossAmount(_loss.text);

  bool get _titleMissing => _title.text.trim().isEmpty;
  bool get _lossMissing => _lossAmount <= 0;
  bool get _photoMissing => _thumbnail.isEmpty;
  bool get _contentMissing => _content.text.trim().isEmpty;

  bool get _hasAnyInput =>
      !_titleMissing || _loss.text.isNotEmpty || !_contentMissing || !_photoMissing || _uploading;

  int get _missingCount =>
      [_titleMissing, _lossMissing, _photoMissing, _contentMissing].where((m) => m).length;

  bool get _canSubmit => _hasAnyInput && !_pickingPhoto && !_uploading && !_submitting;

  Future<void> _close() async {
    // 등록 응답을 기다리는 동안은 닫지 않는다(확인창이 열리면 성공 pop 이 확인창을 닫아 버린다).
    if (_submitting) return;
    if (!_hasAnyInput) {
      Navigator.of(context).pop(false);
      return;
    }
    final leave = await showConfirmDialog(
      context,
      title: Strings.cancelComposeTitle,
      message: Strings.cancelComposeMessage,
      confirmLabel: Strings.leave,
      cancelLabel: Strings.keepWriting,
    );
    if (leave && mounted) Navigator.of(context).pop(false);
  }

  Future<void> _pickPhoto() async {
    if (_submitting || _pickingPhoto || _uploading) return;
    setState(() => _pickingPhoto = true);
    File? file;
    try {
      file = await widget.pickImage();
    } catch (e) {
      log('image pick error: $e');
      NbkToast.error(Strings.toastPhotoPickFailed);
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
    if (file == null || !mounted || _submitting) return;
    final board = _board;
    final uuid = const Uuid().v4();
    setState(() => _uploading = true);
    String url;
    try {
      url = board == 2
          ? await ref.read(freeRepositoryProvider).freeImageUpload(uuid: uuid, token: _token, image: file)
          : await ref.read(nurbanRepositoryProvider).nurbanImageUpload(uuid: uuid, token: _token, image: file);
    } catch (e) {
      log('image upload error: $e');
      url = '';
    }
    if (!mounted) return;
    // 저장소는 실패하면 서버 오류 문자열을 돌려주므로 URL 모양인지 확인한다.
    final ok = url.startsWith('http');
    if (!ok) NbkToast.error(Strings.toastPhotoUploadFailed);
    setState(() {
      _uploading = false;
      if (ok) {
        _thumbnail = url;
        _uuid = uuid;
        _uploadBoard = board;
      }
    });
  }

  Future<void> _removePhoto() async {
    if (_submitting) return;
    final uuid = _uuid;
    final board = _uploadBoard;
    setState(() {
      _thumbnail = '';
      _uuid = '';
    });
    // 서버의 임시 이미지는 지워 두되, 실패해도 작성에는 영향이 없으므로 조용히 넘어간다.
    try {
      if (board == 2) {
        await ref.read(freeRepositoryProvider).freeImageDelete(uuid: uuid, token: _token);
      } else {
        await ref.read(nurbanRepositoryProvider).nurbanImageDelete(uuid: uuid, token: _token);
      }
    } catch (e) {
      log('image delete error: $e');
    }
  }

  Future<void> _submit() async {
    final missing = _missingCount;
    if (missing > 0) {
      setState(() => _showErrors = true);
      NbkToast.error(Strings.toastMissingFields(missing));
      return;
    }
    setState(() => _submitting = true);
    String result;
    try {
      result = _board == 2
          ? await ref.read(freeRepositoryProvider).freeArticleCreate(
                token: _token,
                title: _title.text.trim(),
                uuid: _uuid,
                lossCut: _lossAmount,
                thumbnail: _thumbnail,
                content: _content.text.trim(),
              )
          : await ref.read(nurbanRepositoryProvider).nurbanArticleCreate(
                token: _token,
                title: _title.text.trim(),
                uuid: _uuid,
                lossCut: _lossAmount,
                thumbnail: _thumbnail,
                content: _content.text.trim(),
              );
    } catch (e) {
      log('article create error: $e');
      result = '';
    }
    if (!mounted) return;
    if (!_posted.contains(result)) {
      setState(() => _submitting = false);
      NbkToast.error(Strings.toastPostCreateFailed);
      return;
    }
    NbkToast.success(Strings.toastPostCreated);
    // 등록 중에는 _close·폼이 막혀 있어 위에 다른 route 가 없으므로 작성 화면을 바로 닫는다.
    Navigator.of(context).pop(true);
  }

  InputDecoration _decoration(String hint, {required bool error}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(NbkRadius.input),
      borderSide: BorderSide(
        color: error ? NbkColors.danger : NbkColors.line,
        width: NbkSize.inputBorder,
      ),
    );
    return InputDecoration(
      hintText: hint,
      counterText: '',
      fillColor: error ? NbkColors.dangerTint : NbkColors.bg,
      enabledBorder: border,
      focusedBorder: error ? border : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleError = _showErrors && _titleMissing;
    final lossError = _showErrors && _lossMissing;
    final photoError = _showErrors && _photoMissing;
    final contentError = _showErrors && _contentMissing;

    return PopScope(
      canPop: !_hasAnyInput && !_submitting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: NbkAppBar(
          leading: NbkAppBarLeading.close,
          title: Strings.composeTitle,
          onLeadingTap: _close,
          actions: [
            NbkPillButton(label: Strings.done, onPressed: _canSubmit ? _submit : null),
          ],
        ),
        // 등록 중에는 폼을 건드리지 못하게 한다(등록에 쓴 사진을 지우는 경합 방지).
        body: IgnorePointer(
          ignoring: _submitting,
          child: ListView(
          padding: const EdgeInsets.fromLTRB(
            NbkSpacing.screen,
            NbkSpacing.lg,
            NbkSpacing.screen,
            NbkSpacing.xxxl,
          ),
          children: [
            const NbkFieldLabel(label: Strings.boardLabel),
            const SizedBox(height: NbkSpacing.sm),
            BoardSegment(board: _board, onChanged: (value) => setState(() => _board = value)),
            const SizedBox(height: NbkSpacing.formGap),
            ValueListenableBuilder(
              valueListenable: _title,
              builder: (_, value, __) => NbkFieldLabel(
                label: Strings.titleLabel,
                required: true,
                counter: '${value.text.characters.length}/${ArticleCreatePage.titleMaxLength}',
                error: titleError,
              ),
            ),
            const SizedBox(height: NbkSpacing.sm),
            TextField(
              controller: _title,
              maxLength: ArticleCreatePage.titleMaxLength,
              style: NbkTypography.inputText,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
              decoration: _decoration(Strings.titleHint, error: titleError),
            ),
            if (titleError) const FieldError(message: Strings.errorTitleRequired),
            const SizedBox(height: NbkSpacing.formGap),
            NbkFieldLabel(label: Strings.lossLabel, required: true, error: lossError),
            const SizedBox(height: NbkSpacing.sm),
            LossAmountField(
              controller: _loss,
              error: lossError,
              onChanged: (_) => setState(() {}),
            ),
            if (lossError) const FieldError(message: Strings.errorLossRequired),
            const SizedBox(height: NbkSpacing.formGap),
            NbkFieldLabel(label: Strings.photoLabel, required: true, error: photoError),
            const SizedBox(height: NbkSpacing.sm),
            PhotoField(
              imageUrl: _thumbnail,
              uploading: _uploading,
              error: photoError,
              onPick: _pickPhoto,
              onRemove: _removePhoto,
            ),
            if (photoError) const FieldError(message: Strings.errorPhotoRequired),
            const SizedBox(height: NbkSpacing.formGap),
            NbkFieldLabel(label: Strings.contentLabel, required: true, error: contentError),
            const SizedBox(height: NbkSpacing.sm),
            TextField(
              controller: _content,
              minLines: 6,
              maxLines: 12,
              style: NbkTypography.inputText,
              keyboardType: TextInputType.multiline,
              onChanged: (_) => setState(() {}),
              decoration: _decoration(Strings.contentHint, error: contentError),
            ),
            if (contentError) const FieldError(message: Strings.errorContentRequired),
          ],
          ),
        ),
      ),
    );
  }
}
