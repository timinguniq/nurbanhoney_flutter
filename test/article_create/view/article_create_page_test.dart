import 'dart:async';
import 'dart:io';

import 'package:dio_repository/dio_repository.dart';
import 'package:dio_service/dio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurbanhoney/article_create/article_create.dart';
import 'package:nurbanhoney/l10n/strings.dart';
import 'package:nurbanhoney/theme/theme.dart';
import 'package:nurbanhoney/widgets/widgets.dart';
import 'package:preference_storage/preference_storage.dart';
import 'package:preference_storage_service/preference_storage_service.dart';

/// 이미지 업로드·삭제·글 등록만 흉내 내는 주식 저장소
class _FakeNurbanRepository implements NurbanRepository {
  _FakeNurbanRepository({
    this.uploadResult = 'https://example.com/a.jpg',
    this.createResult = 'nurbanboard_posted',
    this.uploadGate,
    this.createGate,
  });

  final String uploadResult;
  final String createResult;

  /// 있으면 업로드·등록 응답을 이 Completer 가 끝날 때까지 미룬다(진행 중 상태를 보기 위해)
  final Completer<void>? uploadGate;
  final Completer<void>? createGate;
  final calls = <String>[];
  Map<String, Object?>? created;

  @override
  Future<String> nurbanImageUpload({required String uuid, required String token, required File image}) async {
    calls.add('upload:$uuid');
    await uploadGate?.future;
    // 업로드마다 다른 URL 을 돌려줘 교체한 사진으로 등록되는지 가릴 수 있게 한다.
    final uploads = calls.where((c) => c.startsWith('upload:')).length;
    return uploads == 1 ? uploadResult : '$uploadResult?v=$uploads';
  }

  @override
  Future<String> nurbanImageDelete({required String uuid, required String token}) async {
    calls.add('delete:$uuid');
    return 'deleted';
  }

  @override
  Future<String> nurbanArticleCreate({
    required String token,
    required String title,
    required String uuid,
    required int lossCut,
    required String thumbnail,
    required String content,
  }) async {
    calls.add('create');
    created = {'title': title, 'uuid': uuid, 'lossCut': lossCut, 'thumbnail': thumbnail, 'content': content};
    await createGate?.future;
    return createResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 코인 저장소
class _FakeFreeRepository implements FreeRepository {
  final calls = <String>[];

  @override
  Future<String> freeImageUpload({required String uuid, required String token, required File image}) async {
    calls.add('upload');
    return 'https://example.com/coin.jpg';
  }

  @override
  Future<String> freeArticleCreate({
    required String token,
    required String title,
    required String uuid,
    required int lossCut,
    required String thumbnail,
    required String content,
  }) async {
    calls.add('create');
    return 'freeboard_posted';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

File _tempImage() => File('${Directory.systemTemp.path}/nbk_test_${DateTime.now().microsecondsSinceEpoch}.jpg')
  ..writeAsBytesSync([0]);

Widget _app({
  int board = 1,
  _FakeNurbanRepository? nurban,
  _FakeFreeRepository? free,
  Future<File?> Function()? pickImage,
  List<bool?>? popped,
}) {
  return ProviderScope(
    overrides: [
      preferenceStorageProvider.overrideWith(
        (ref) async => PreferenceStorage(plugin: await SharedPreferences.getInstance()),
      ),
      nurbanRepositoryProvider.overrideWithValue(nurban ?? _FakeNurbanRepository()),
      freeRepositoryProvider.overrideWithValue(free ?? _FakeFreeRepository()),
    ],
    child: MaterialApp(
      navigatorKey: nbkNavigatorKey,
      theme: NbkTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (_) => ArticleCreatePage(
                    board: board,
                    pickImage: pickImage ?? () async => _tempImage(),
                  ),
                ),
              );
              popped?.add(result);
            },
            child: const Text('열기'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('열기'));
  await tester.pumpAndSettle();
}

Future<void> _pumpFrames(WidgetTester tester, [int frames = 4]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump();
  }
}

NbkButton _doneButton(WidgetTester tester) =>
    tester.widget<NbkButton>(find.widgetWithText(NbkButton, Strings.done));

Future<void> _fillAll(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextField, Strings.titleHint), '삼전 물타기 실패했습니다');
  await tester.enterText(find.byType(TextField).at(1), '1250000');
  await tester.enterText(find.widgetWithText(TextField, Strings.contentHint), '결국 손절했습니다.');
  await tester.tap(find.text(Strings.photoAdd));
  await _pumpFrames(tester, 6);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'__pref_auth_token__': 'token-1'}));
  tearDown(NbkToast.hide);

  /// 폼 전체가 한 화면에 들어오게 세로로 긴 화면을 쓴다(ListView 는 보이는 항목만 만든다).
  Future<void> pumpTall(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app);
  }

  group('ArticleCreatePage', () {
    testWidgets('처음엔 진입 탭의 게시판이 선택되고 완료는 비활성이다', (tester) async {
      await pumpTall(tester, _app(board: 2));
      await _open(tester);

      expect(_doneButton(tester).onPressed, isNull);
      expect(find.byIcon(Icons.check), findsOneWidget);
      final coin = find.ancestor(of: find.text(Strings.boardCoin), matching: find.byType(Material)).first;
      expect((tester.widget<Material>(coin)).color, NbkColors.honeyTint);
      expect(find.text('0/${ArticleCreatePage.titleMaxLength}'), findsOneWidget);
      expect(find.text(Strings.lossHelper), findsOneWidget);
    });

    testWidgets('일부만 입력하고 완료를 누르면 빠진 항목마다 인라인 오류와 개수 토스트를 보여준다', (tester) async {
      final nurban = _FakeNurbanRepository();
      await pumpTall(tester, _app(nurban: nurban));
      await _open(tester);

      await tester.enterText(find.widgetWithText(TextField, Strings.titleHint), '제목만');
      await tester.pump();
      expect(_doneButton(tester).onPressed, isNotNull);

      await tester.tap(find.text(Strings.done));
      await _pumpFrames(tester);

      expect(find.text(Strings.errorLossRequired), findsOneWidget);
      expect(find.text(Strings.errorPhotoRequired), findsOneWidget);
      expect(find.text(Strings.errorContentRequired), findsOneWidget);
      expect(find.text(Strings.errorTitleRequired), findsNothing);
      expect(find.text(Strings.toastMissingFields(3)), findsOneWidget);
      expect(nurban.calls, isEmpty);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('손실액은 콤마가 자동으로 붙고 한글 금액이 보조 표기된다', (tester) async {
      await pumpTall(tester, _app());
      await _open(tester);

      await tester.enterText(find.byType(TextField).at(1), '1250000');
      await tester.pump();

      expect(find.text('1,250,000'), findsOneWidget);
      expect(find.text('백이십오만 원'), findsOneWidget);
    });

    testWidgets('사진을 고르면 올리는 동안 완료가 비활성이고, 끝나면 미리보기와 바꾸기·삭제가 보인다', (tester) async {
      final gate = Completer<void>();
      final nurban = _FakeNurbanRepository(uploadGate: gate);
      await pumpTall(tester, _app(nurban: nurban));
      await _open(tester);

      await tester.tap(find.text(Strings.photoAdd));
      await _pumpFrames(tester);
      expect(find.text(Strings.photoUploading), findsOneWidget);
      expect(_doneButton(tester).onPressed, isNull);

      gate.complete();
      await _pumpFrames(tester, 6);
      expect(find.text(Strings.photoUploading), findsNothing);
      expect(find.byType(NbkThumbnail), findsOneWidget);
      expect(nurban.calls.single, startsWith('upload:'));

      await tester.tap(find.byTooltip(Strings.delete));
      await _pumpFrames(tester);
      expect(find.text(Strings.photoAdd), findsOneWidget);
      expect(nurban.calls.last, startsWith('delete:'));
    });

    testWidgets('업로드가 실패하면 오류 토스트를 띄우고 사진 추가 상자로 돌아간다', (tester) async {
      await pumpTall(tester, _app(nurban: _FakeNurbanRepository(uploadResult: 'server error')));
      await _open(tester);

      await tester.tap(find.text(Strings.photoAdd));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.toastPhotoUploadFailed), findsOneWidget);
      expect(find.text(Strings.photoAdd), findsOneWidget);
      expect(find.byType(NbkThumbnail), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('모두 입력하고 완료를 누르면 주식 저장소로 등록하고 성공 토스트 뒤 true 로 닫힌다', (tester) async {
      final nurban = _FakeNurbanRepository();
      final popped = <bool?>[];
      await pumpTall(tester, _app(nurban: nurban, popped: popped));
      await _open(tester);
      await _fillAll(tester);

      await tester.tap(find.text(Strings.done));
      await tester.pumpAndSettle();

      expect(nurban.created, isNotNull);
      expect(nurban.created!['title'], '삼전 물타기 실패했습니다');
      expect(nurban.created!['lossCut'], 1250000);
      expect(nurban.created!['thumbnail'], 'https://example.com/a.jpg');
      expect(nurban.created!['content'], '결국 손절했습니다.');
      expect(nurban.created!['uuid'], isNotEmpty);
      expect(popped, [true]);
      expect(find.text(Strings.toastPostCreated), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('코인을 고르면 코인 저장소로 올리고 등록한다', (tester) async {
      final free = _FakeFreeRepository();
      final nurban = _FakeNurbanRepository();
      await pumpTall(tester, _app(board: 2, free: free, nurban: nurban));
      await _open(tester);
      await _fillAll(tester);

      await tester.tap(find.text(Strings.done));
      await tester.pumpAndSettle();

      expect(free.calls, ['upload', 'create']);
      expect(nurban.calls, isEmpty);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('등록에 실패하면 오류 토스트를 띄우고 폼은 그대로다', (tester) async {
      await pumpTall(tester, _app(nurban: _FakeNurbanRepository(createResult: 'error')));
      await _open(tester);
      await _fillAll(tester);

      await tester.tap(find.text(Strings.done));
      await _pumpFrames(tester, 6);

      expect(find.text(Strings.toastPostCreateFailed), findsOneWidget);
      expect(find.byType(ArticleCreatePage), findsOneWidget);
      expect(find.text('삼전 물타기 실패했습니다'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('등록 응답을 기다리는 동안에는 사진 삭제·X 가 동작하지 않고, 성공하면 true 로 닫힌다', (tester) async {
      final gate = Completer<void>();
      final nurban = _FakeNurbanRepository(createGate: gate);
      final popped = <bool?>[];
      await pumpTall(tester, _app(nurban: nurban, popped: popped));
      await _open(tester);
      await _fillAll(tester);

      await tester.tap(find.text(Strings.done));
      await _pumpFrames(tester);
      expect(nurban.calls.last, 'create');

      await tester.tap(find.byTooltip(Strings.delete), warnIfMissed: false);
      await tester.tap(find.byIcon(Icons.close).first, warnIfMissed: false);
      await _pumpFrames(tester);
      expect(nurban.calls.where((c) => c.startsWith('delete:')), isEmpty);
      expect(find.text(Strings.cancelComposeTitle), findsNothing);
      expect(find.byType(NbkThumbnail), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
      expect(popped, [true]);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('사진을 고르고 압축하는 동안에는 완료가 비활성이고, 끝나면 새 사진으로 다시 활성이다', (tester) async {
      final picking = Completer<File?>();
      var picks = 0;
      final nurban = _FakeNurbanRepository();
      await pumpTall(tester, _app(
        nurban: nurban,
        pickImage: () => ++picks == 1 ? Future.value(_tempImage()) : picking.future,
      ));
      await _open(tester);
      await _fillAll(tester);
      expect(_doneButton(tester).onPressed, isNotNull);

      // [바꾸기] → 고르는 중(응답 대기)
      await tester.tap(find.byTooltip(Strings.change));
      await _pumpFrames(tester);
      expect(_doneButton(tester).onPressed, isNull);
      expect(nurban.calls.where((c) => c == 'create'), isEmpty);

      picking.complete(_tempImage());
      await _pumpFrames(tester, 8);
      expect(_doneButton(tester).onPressed, isNotNull);
      final uploads = nurban.calls.where((c) => c.startsWith('upload:')).toList();
      expect(uploads, hasLength(2));

      // 교체한(두 번째) 사진의 URL·uuid 로 등록된다.
      await tester.tap(find.text(Strings.done));
      await tester.pumpAndSettle();
      expect(nurban.created!['thumbnail'], 'https://example.com/a.jpg?v=2');
      expect(nurban.created!['uuid'], uploads.last.substring('upload:'.length));
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('사진 선택을 취소하면 완료가 다시 활성이다', (tester) async {
      var picks = 0;
      await pumpTall(tester, _app(
        pickImage: () async => ++picks == 1 ? _tempImage() : null,
      ));
      await _open(tester);
      await _fillAll(tester);

      await tester.tap(find.byTooltip(Strings.change));
      await _pumpFrames(tester, 6);

      expect(_doneButton(tester).onPressed, isNotNull);
      expect(find.byType(NbkThumbnail), findsOneWidget);
    });

    testWidgets('사진 선택·압축이 예외를 던지면 오류 토스트를 띄우고 올리지 않는다', (tester) async {
      final nurban = _FakeNurbanRepository();
      await pumpTall(tester, _app(nurban: nurban, pickImage: () async => throw Exception('gallery')));
      await _open(tester);

      await tester.tap(find.text(Strings.photoAdd));
      await _pumpFrames(tester);

      expect(find.text(Strings.toastPhotoPickFailed), findsOneWidget);
      expect(nurban.calls, isEmpty);
      expect(find.text(Strings.photoAdd), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('입력값이 있을 때 X 를 누르면 확인 다이얼로그를 거친다', (tester) async {
      final popped = <bool?>[];
      await pumpTall(tester, _app(popped: popped));
      await _open(tester);
      await tester.enterText(find.widgetWithText(TextField, Strings.titleHint), '쓰던 글');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text(Strings.cancelComposeTitle), findsOneWidget);

      await tester.tap(find.text(Strings.keepWriting));
      await tester.pumpAndSettle();
      expect(find.byType(ArticleCreatePage), findsOneWidget);
      expect(popped, isEmpty);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.leave));
      await tester.pumpAndSettle();
      expect(find.byType(ArticleCreatePage), findsNothing);
      expect(popped, [false]);
    });

    testWidgets('아무것도 입력하지 않았으면 X 로 바로 닫힌다', (tester) async {
      final popped = <bool?>[];
      await pumpTall(tester, _app(popped: popped));
      await _open(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(ArticleCreatePage), findsNothing);
      expect(popped, [false]);
    });
  });
}
