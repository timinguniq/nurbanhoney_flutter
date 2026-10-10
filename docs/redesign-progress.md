# 리디자인 진행 기록 (재개용)

마지막 갱신: 2026-10-10. 명세 원문은 `docs/redesign-spec.md`, 시안은 `design/*.png`.
이 문서는 다음 세션이 **처음부터 다시 탐색하지 않고** 이어서 작업하기 위한 기록이다. 읽는 순서: 1 현재 상태 → 2 결정 사항 → 3 남은 작업 → 4 검증 절차 → 5 참고.

## 1. 현재 상태

### 커밋 (main)

| 커밋 | 내용 | 검증 |
|---|---|---|
| `c77ced4` | [Add] 개발 하네스·에이전트 지침 추가 | 하네스 테스트 |
| `b9d7843` | [Add] 리디자인 시안(design/) 추가 | — |
| `933608b` | [Add] 디자인 토큰(lib/theme)과 손실액·날짜 유틸 추가 — **1단계** | verifier PASS, code-reviewer FAIL→(2단계에서 반영) , mutation FAIL→(2단계에서 테스트 보강) |
| `edb1b16` | [Update] Gradle 8.14·AGP 8.11.1로 변경 | verifier/code-reviewer PASS |
| `52310f7` | [Add] 공통 컴포넌트(lib/widgets)와 문구·오류 코드 유틸 추가 — **2단계** | verifier PASS, code-reviewer PASS(낮음 1건 반영), mutation FAIL→생존 3건 테스트 보강(작업 트리에 있음, 미커밋) |

| `f8ee1b9` | [Refactor] 하단 탭 3개 셸로 내비게이션 교체하고 내 계정 탭 구현 — **3단계 + 4단계 5번(내 계정 탭)** | verifier PASS(stage3b), code-reviewer FAIL→FAIL→FAIL→PASS(stage3d). 보고서 `.harness/reports/*-stage3{b,c,d}-snapshot.md` |

| `8bbb51c` | [Refactor] 홈 화면 — **4단계 1번** | verifier PASS, code-reviewer 4회 반복 후 PASS, mutation 9/10(DashedBox 픽셀 테스트는 5ce771a 에 포함) |
| `723fb20` | [Refactor] 로그인 화면 — **4단계 2번** | verifier PASS, code-reviewer 5회 반복 후 PASS, mutation 7/10(보강 테스트는 5ce771a 에 포함) |
| `5ce771a` | [Refactor] 글 상세 — **4단계 3번** | verifier·code-reviewer 2회 후 PASS, mutation 8/10(보강은 e69fcf2 에 포함) |
| `e69fcf2` | [Refactor] 글 작성 — **4단계 4번** | verifier·code-reviewer 3회 후 PASS, mutation 8/10(보강은 e38a8be 에 포함) |
| `e38a8be` | [Refactor] 내 정보(설정) — **4단계 6번** | verifier PASS, code-reviewer 3회 후 PASS, mutation 실행 중이었음(결과 미확인 — 다음 세션에서 `git diff e38a8be~1 e38a8be` 로 다시 돌릴 것) |

### 작업 트리

- **남은 화면 초안**(저장소 밖 작업물이라 `.harness/wip/` 에 복사해 둠, gitignore 대상): `wip-ranking/`(랭킹 탭 + 테스트, 문구는 `strings-ranking.txt`), `wip-splash/`(Android Theme.SplashScreen + 벡터 심볼 + MainActivity, iOS LaunchImage 생성기 `test/_gen_launch_symbol_test.dart` — 실행 후 삭제), `wip-edit/`(프로필 수정 초안 백업), `stage5-checklist.md`(5단계 체크리스트). 초안을 트리에 넣을 때는 해당 `strings-*.txt` 의 문구를 `Strings` 에 먼저 추가한다.

#### 3단계 커밋에 내 계정 탭을 같이 넣은 이유
3단계 검증 FAIL 지적 2건(프로필 저장 후 갱신, 로그아웃 후 계정 탭 갱신)이 모두 내 계정 탭의 일이라, 임시 래퍼를 고치는 대신 4단계 5번(내 계정 탭)을 먼저 구현해 함께 커밋했다.
리뷰에서 추가로 잡힌 것: PagedSliverList 중간 페이지 실패가 조용히 빠지는 문제(페이지를 순서대로 잇다가 값 없는 페이지에서 멈추고 그 상태를 footer 로), 짧은 내용에서 당겨서 새로고침(`AlwaysScrollableScrollPhysics`), 프로필 저장 중 화면을 닫으면 `ref` 사용 예외(`context.mounted` 확인). 각각 테스트 추가.

### 이전 작업 트리 기록 (3단계, 커밋 전 상태)

**3단계(내비게이션) 구현 전부**: 40개 파일.

- 새 파일: `lib/home/view/widgets/home_tab_view.dart`(로고 상단바 + 세그먼트 탭 + LazyIndexedStack[StockTabPage, CoinTabPage]), `lib/home/view/widgets/losscut_fab.dart`(확장 FAB, 비로그인→로그인, 등록 후 onCreated), `lib/widgets/lazy_indexed_stack.dart`, `lib/ranking/`(RankingTabPage: 임시로 기존 `RankView` 래핑), `lib/account/`(AccountTabPage: 임시로 기존 `MyaccountBodyView` 래핑).
- 수정: `lib/home/view/home_page_refactor.dart`(→ `HomeShell`: `homeBottomNavigationProvider` 로 탭 전환 + `NbkBottomTabBar`), `stock_tab_page.dart`/`coin_tab_page.dart`(bottomSheet → `floatingActionButton: LossCutFab(board: 1|2)`), `article_create_page.dart`(`board` 파라미터, ConsumerStatefulWidget, post-frame 에 게시판 기본값 select), `myaccount_setting_logout_widget.dart`·`myaccount_edit_title_widget.dart`(`pushAndRemoveUntil(Home)` → `pop()`), `app.dart`(`navigatorKey: nbkNavigatorKey`, unused import 제거), `lib/l10n/strings.dart`(lossCutCta, thisWeek, rankingTitle), 배럴들.
- 삭제: drawer_* 3개, appbar_bottom*, board_all_view, popular_view, nurban_view, free_view, nurban_rank_tab_*, honey_rank_body_view, stock/coin bottom sheet view, `lib/format/format_page.dart`.
- 2단계 mutation 보강 테스트 3개(`error_code_utils_test`, `reaction_button_test`, `nbk_segment_tabs_test`)도 이 stage 에 섞여 있다.
- 상태: `flutter analyze` error 0 / warning 115(모두 기존 코드, 아래 §5), `flutter test` 75개 통과, `flutter build apk --debug` 성공.

**3단계 교차 검증 결과: verifier FAIL, code-reviewer FAIL** (보고서 `.harness/reports/*-stage3-snapshot.md`). 지적 3건, 아직 반영하지 않음:

1. [중간] `myaccount_edit_title_widget.dart:97` 프로필 저장 후 `pop()` 만 하므로 내 계정 탭이 `getProfileProvider(token)` 캐시를 그대로 보여준다. → 저장 성공 시 `ref.invalidate(getProfileProvider)` (+ 내 글/댓글 provider) 하고 테스트.
2. [중간] `myaccount_setting_logout_widget.dart:58` 로그아웃 후 `pop()` 으로 돌아온 계정 탭이 인증 상태를 구독하지 않아 이전 사용자 정보가 남는다. → 4단계 내 계정 탭 재작성 시 `authenticationServiceProvider` 를 watch 해 비로그인 카드로 전환하고, 로그아웃 시 `getProfileProvider` 를 invalidate.
3. [중간] `stock_tab_page.dart`/`coin_tab_page.dart` 가 레거시 `BaseView` 를 유지한다. → **사용자 결정(§2)으로 유지**. 재검증 시 추가 지시에 이 결정을 적어 주면 된다.

→ 재개 시 1·2 를 고친 뒤(4단계 내 계정 탭과 함께 고치는 것이 자연스럽다) verifier·code-reviewer 를 다시 돌리고 PASS 면 3단계를 커밋한다. 커밋 메시지 초안: `[Refactor] 하단 탭 3개 셸로 내비게이션 교체(드로어·게시판 링크 제거, 손절 인증 FAB)`.

### 문서 (미커밋)
`docs/redesign-spec.md`, `docs/redesign-progress.md` — untracked. 게이트 검사 경로가 아니라 커밋을 막지 않는다. 다음 커밋에 함께 넣는다.

## 2. 결정 사항 (사용자 승인)

| 주제 | 결정 |
|---|---|
| 시안 | `design/` 21장 사용. 시안과 명세가 다르면 시안 우선 |
| 토큰 위치 | `lib/theme/nbk_*.dart` 신규. 기존 `data/nurbanhoney_ui_data`·`application/nurbanhoney_ui_service` 는 **5단계에서 참조 0 확인 후 삭제** + `docs/architecture.md` 갱신 |
| 상태 관리 | 홈 목록의 레거시 `BaseView`+`ChangeNotifier` ViewModel(`StockTabViewModel`/`CoinTabViewModel`) **유지**. `StockTabViewModel.fetch` 에 `CoinTabViewModel` 과 같은 try/catch 한 블록만 추가(ErrorState 표시용, 아직 안 함 → 4단계 홈) |
| Gradle | 8.14 / AGP 8.11.1 로 올림(`edb1b16`). Flutter 3.47.5 최소 요구. `android/gradle.properties` 의 builtInKotlin·newDsl=false 는 Flutter 마이그레이터가 넣은 값 |
| 글 작성 [완료] 버튼 | **시안**을 따른다: 아무것도 입력하지 않았거나 사진 업로드 중일 때만 비활성, 그 외엔 활성이고 누르면 누락 항목 인라인 오류 + 토스트 '아직 입력하지 않은 항목이 N개 있어요.' |
| warning 범위 | `lib/` 뿐 아니라 **패키지 warning 도 정리**(동작 불변 범위: `return await`, 빈 테스트 unused import, pubspec `publish_to: none`). 5단계 별도 커밋 |
| 하네스 | 미커밋이던 하네스를 먼저 커밋(`c77ced4`). `.claude/settings.local.json` 은 gitignore |

### 시안을 따르기로 한 명세 차이 (기본값, 사용자에게 보고함)
- ErrorState [다시 시도] 는 text1(검정) 채움 + 흰 글자(`NbkButtonVariant.dark`).
- 홈 빈 상태·에러 상태 시안에는 FAB 가 없다 → 그 두 상태에서는 FAB 숨김(빈 상태는 [첫 글 쓰기] CTA 가 대신).
- 로그인 진행 중: 누른 버튼의 라벨이 사라지고 스피너만(`NbkButton.loading`), 나머지 버튼·X opacity 0.4.
- 내 댓글 날짜 `MM.dd`(`shortDateFormat`), 내 글 `yyyy.MM.dd`(`dotDateFormat`), 상세 `yyyy.MM.dd HH:mm`(`dotDateTimeFormat`).
- AdMob 자리의 점선 박스·'AdMob 배너 320×50' 글자는 목업 표시로 보고 실제로는 높이 50 만 비워 둔다.
- 시상대 손실액은 만원 단위, 끝자리 버림(`formatLossAmount(compact: true)` → `-1,248만원`, 1억 이상 `-1.2억원`).
- 홈 세그먼트 탭 글자 크기는 명세에 없어 16(`NbkTypography.segment`).
- 오프라인 배너는 `connectivity_plus` 없이 `isNetworkError`(타임아웃·연결 오류)로 판단.
- 탭바 아이콘은 기존 PNG 대신 Material Icons(home / emoji_events / person).
- 랭킹 순위는 응답 `id` 대신 정렬 순서(index+1).
- '이번 주' 기간은 클라이언트에서 월~일 계산(`formatWeekRange`). 서버 집계 기준은 남은 질문.
- 탈퇴 성공 후에만 루트(홈)로 이동, 로그아웃·프로필 저장·글 작성은 `pop`.
- 심볼은 PNG 대신 `NbkSymbol`(CustomPainter: 둥근 육각형 + 물방울)로 그린다. 기존 `nurban_symbol.png` 는 화살표가 있어 시안과 다르다.

### API 한계 (서버 변경 없이는 못 하는 것)
- 내 정보의 '닉네임 · 2026.07.02 가입' — 프로필 API(`ProfileType`)에 가입일이 없다 → 닉네임만 표시.
- 랭킹 `/rank`, `/rank/popup` 응답에 기간 정보가 없다.
- 포인트 적립·사용 규칙 — 바텀시트 내용은 자리표시 문구.

## 3. 남은 작업

### 3단계 마무리
위 §1 의 지적 1·2 반영 → verifier·code-reviewer 재실행 → PASS 면 커밋 → mutation-verifier(테스트가 추가됐으므로) 실행 → FAIL 이면 테스트 보강 후 다음 단계 커밋에 포함.

### 4단계 — 화면별 구현 (화면마다 커밋 1개, 각 커밋 전 교차 검증)
공통: 화면 안의 `ref.read(colorXXXX)`·`ref.read(xxxStyle)`(`nurbanhoney_ui_service`)와 `Fluttertoast` 를 모두 토큰·`NbkToast` 로 바꾼다. 문구는 `Strings` 에 추가해 쓴다. 각 화면에 로딩 스켈레톤·빈 상태·에러 상태.

1. **홈** — **완료(커밋 아래 참조)**. `BoardTabView`(공용 UI, ViewModel 상태를 받음) + `PostListItem` + `Top3Section`(+`Top3Card`) + `DashedBox`(lib/widgets) + `startLossCutCreate`. `StockTabPage`/`CoinTabPage` 는 `ConsumerStatefulWidget` 이 ViewModel 을 한 번 만들고 `ListenableBuilder` 로 그린다(BaseView 미사용). ViewModel.fetch 는 try/catch 로 `DataFetchError(e.toString())`. 좋아요 로컬 상태는 BoardTabView 의 `_likeOverrides`(새로고침 세대 기록, 새로고침 중 끝난 좋아요는 유지) — 리뷰 4회 반복으로 잡은 경쟁 조건. `BoardPost` 레코드 typedef 로 data 레이어 import 회피. 삭제: stock/coin_list_item, rank_page, rank_card. 테스트 `test/home/view/widgets/*`(23개). 원래 계획:
   (원래 계획) **홈** (`lib/stock`, `lib/coin`, `lib/home/view/widgets/home_tab_view.dart`)
   - `StockTabPage`/`CoinTabPage` 의 UI 를 하나의 `BoardTabView`(가칭)로 공유하고 ViewModel 2개는 그대로. `StockListItem`/`CoinListItem`(99% 중복) → `PostListItem` 하나로. `AuthorInfo.small` + `formatRelativeTime(createdAt)` + `LossAmount(list)` + `listTitle` 1줄 + `listBody` 2줄 + `NbkThumbnail`(있을 때만) + `ReactionButton.like(selected: myRating == 'like')` + `CommentCount`.
   - Top3: `RankPage`(carousel) → 가로 스크롤 카드(폭 236, 간격 10) `Top3Section`. 헤더 '이번 주 손실 Top 3'(`Icons.emoji_events_outlined` honeyDeep) + '전체보기 ›' → `ref.read(homeBottomNavigationProvider.notifier).select(HomeBottomStatus.rank)`. 버그 수정: `totalLikeCount` 에 `totalLossCut` 이 들어가던 것(`rank_page.dart:107`), 콤마. 비면 점선 박스 안내.
   - 상태: `DataFetching`/`DataRefetching` → `Shimmer(Top3CardSkeleton×2 + PostItemSkeleton×2)`; 빈 목록 → `EmptyState('아직 {주식|코인} 손절 인증이 없어요', cta '첫 글 쓰기')`, 이때 FAB 숨김; `DataFetchError` → `ErrorState(errorCode: errorCodeOf(e))` + `isNetworkError` 면 상단 `OfflineBanner`, FAB 숨김. `StockTabViewModel.fetch` 에 try/catch 추가(승인됨).
   - `BaseView` 의 `LoadingIndicator`(가운데 스피너)는 스켈레톤과 겹치므로 `loadingIndicatorHeight` 등으로 숨기거나 `BaseView` 를 거치지 않는 방식 검토(ViewModel 로직은 유지).
2. **로그인** — **완료(커밋 아래 참조)**. `LoginPage`(ConsumerStatefulWidget, SDK 호출은 `kakaoKey`/`googleKey` 파라미터로 주입) + `LoginView`(순수 UI) + `SocialLoginButton`·`LoginFailureCard`·`LoginNotice`. 서버 로그인은 `_requestServerLogin` 이 `getLoginProvider` 를 invalidate 한 뒤 `listenManual(fireImmediately)` 로 한 번만 처리(isLoading 건너뜀). 토큰·userId 저장을 await 한 뒤 인증 상태 변경·pop(위에 뜬 다이얼로그는 popUntil 로 먼저 닫음); 저장 실패면 토큰 되돌리고 실패 카드; userId 가 숫자가 아니면 서버 실패로 처리. `loginTypeService`/`keyService`/`passwordService` Provider 는 더 쓰지 않는다(5단계 삭제 대상). 리뷰 5회 반복. 테스트 `test/login/**`(21개). 원래 계획:
   (원래 계획) **로그인** (`lib/login`) — `NbkLogo.vertical` + 제목 2줄 + 설명. 소셜 버튼 3개(높이 52, 아이콘 왼쪽 18 고정 + 텍스트 중앙; 색 `NbkColors.kakao/naver/google*`). 진행 중·실패 상태(dangerTint 인라인 카드 + '카카오로 다시 로그인'). 네이버 → `NbkToast.info('네이버 로그인은 준비 중이에요.')`. 약관 링크 → 기존 `_policyPopup` 을 토큰으로. 로그인 성공 시 기존처럼 `pop`. `lib/` 가 `preference_storage`(data)를 직접 import 하는 것은 기존 상태(architecture.md 참고).
3. **글 상세** — **완료(커밋 아래 참조)**. 리뷰 2회(키보드 inset, 광고 dispose, 404 pop(false)). `ArticleDetailPage` + `ArticleBody`·`ReactionBar`(기존 LikeDislikeBoard 로직)·`CommentSection`·`CommentItem`·`CommentInputBar`(bottomNavigationBar 고정)·`ArticleDetailSkeleton`. AdMob 은 initState 에서 한 번 로드, 실패는 삼킴. `route()` 는 `Route<bool>`(삭제 시 true). 레거시 상세 위젯·user_info 삭제. `AuthorInfo.comment` 세로 배치. 테스트 `test/article_detail/**`(12개; AdMob 채널은 성공 봉투 `[0,0]` mock, route 전환은 `pump(500ms)`). 원래 계획:
   (원래 계획) **글 상세** (`lib/article_detail`) — `NbkAppBar(back, titleWidget: NbkPill.neutral('주식'|'코인'))`, 내 글이면 ⋮ → `showConfirmSheet` 후 삭제. 본문: 제목 `title` → `AuthorInfo.medium(subtitle: '${formatDate(updatedAt, dotDateTimeFormat)} · 조회 N', trailing: 내 글이면 NbkPill.honey('내 글'))` → 손실액 카드(lossTint, '손실액' labelStrong loss + `LossAmount(detail)`) → `NbkThumbnail(height: null)`(원본 비율, 최대 폭 500) → `body` → AdMob 자리(높이 50 확보) → `ReactionButton.like/dislike(pill: true, selected)`. `SectionBand` → 댓글 헤더 '댓글 N'(N honeyDeep) → `AuthorInfo.comment` + `commentText`, 내 댓글 삭제 → `showConfirmSheet`. 빈 댓글 → `EmptyState(showTile: false, icon: Icons.chat_bubble_outline, '아직 댓글이 없어요', '첫 위로를 남겨 보세요.')`. 댓글 입력 바를 `Scaffold.bottomNavigationBar`(또는 body 하단 고정 + `resizeToAvoidBottomInset`)로 고정: surface 필 입력 + `0/60` + honey 필 [등록](44). 로딩: 앱바 유지 + 본문 스켈레톤. 404(`httpStatusOf(e) == 404`) → `NbkToast.error('글이 존재하지 않습니다.')` 후 pop. 그 외 `ErrorState`. 기존 좋아요/싫어요 로직(`LikeDislikeBoard`, `getFreeArticleProvider` 로 myRating)은 유지하고 UI 만 교체. 상단바 '너반꿀' 표기는 '주식'으로.
4. **글 작성** — **완료(커밋 아래 참조)**. 리뷰 3회(등록 중 폼 잠금·X 무시·성공 시 popUntil, picker 예외, 사진 고르는 중 완료 비활성). `ArticleCreatePage`(로컬 상태; navigation_service 의 articleCreate* Provider 미사용 → 5단계 삭제) + `BoardSegment`·`LossAmountField`·`PhotoField`·`FieldError`·`pickAndCompressImage`(기존 압축 로직). 업로드 응답이 `http` 로 시작하지 않으면 실패 처리, [삭제] 는 기존 ImageDelete API 를 best-effort 호출. 진행률은 불확정 바(질문 5). 테스트 `test/article_create/**`(10개). 원래 계획:
   (원래 계획) **글 작성** (`lib/article_create`) — `NbkAppBar(close, '손절 인증', actions: [NbkPillButton('완료')])`. 게시판 세그먼트 2버튼(선택: honeyTint + honey 테두리 + 체크) — 내부 값은 기존 `'너반꿀'`/`'코인'` 문자열 유지(표시만 주식/코인). 제목(`NbkFieldLabel('제목', required, counter '0/40')` + TextField maxLength 40) → 손실액(높이 64 박스: '-' + 오른쪽 정렬 `lossInput` + '원', `keyboardType: number`, `inputFormatters: [ThousandsInputFormatter()]`, 아래 `toKoreanWon(parseLossAmount(text))` 보조 표기; Provider 에는 숫자만 `select`) → 사진(점선 박스 96 / 미리보기 160 + [바꾸기][삭제] / 업로드 중 `NbkColors.overlay` + 스피너 + 진행 바. 진행률은 `Dio` 의 `onSendProgress` 가 저장소에 없으므로 불확정 진행 바로 표시하거나 저장소에 콜백 파라미터를 추가할지 사용자에게 질문) → 내용(textarea). [완료] 규칙은 §2. 인라인 오류: 테두리 danger + dangerText 메시지. X → 입력값 있으면 `showConfirmDialog('작성을 취소할까요?', '입력한 내용이 사라져요.', confirm '나가기', cancel '계속 쓰기')`. 성공 `NbkToast.success('글이 등록되었습니다.')` + `pop(true)`, 실패 `NbkToast.error(...)`. `flutter_material_pickers`(라디오 피커)·`article_create_appbar.dart` 의 전역 `selectedUsState` 제거. 게시판 변경 시 업로드 이미지 유지.
5. **내 계정 탭** (`lib/account`) — **완료(3단계 커밋에 포함)**. 구현 내용: `AccountTabPage`(ConsumerWidget) 가 `authenticationServiceProvider` 와 `preferenceStorageProvider` 를 watch → 비로그인 `AccountLoggedOutView`(honeyTint 카드 + `AppInfoSection`), 로그인 `AccountProfileView`(key=token; `AuthorInfo.profile` + `ActivitySummaryCard` + `NbkSegmentTabs` + `PagedSliverList`(offset 10개씩, `LoadMoreTrigger`) + `RefreshIndicator`). 댓글 삭제는 `showConfirmSheet` → `nurbanCommentDelete` → 토스트 + provider invalidate. 앱 버전은 `package_info_plus`(`appVersionProvider`, `lib/account/view/widgets/app_info_section.dart`). 약관·개인정보 다이얼로그는 `lib/common/view/widgets/policy_dialog.dart` 의 `showPolicyDialog`(로그인·내 정보 화면도 쓴다). 테스트 `test/account/**`(18개). 원래 계획: `authenticationServiceProvider` watch → 비로그인이면 honeyTint 카드(`NbkSymbol` 타일 + 제목 + 체크 3줄 + [3초 만에 로그인] → LoginPage push) + '앱 정보' 섹션(이용약관/개인정보 처리방침 → 기존 `getTermsProvider`/`getPrivacyProvider` 다이얼로그, 앱 버전 → `package_info_plus` 추가 필요). 로그인이면 `getProfileProvider(token)`: 프로필 블록(`NbkBadge(64, radius 16)` + `profileName` + `InsigniaImage.small`×2 + 소개 1줄 text3 + [수정] `NbkPillButton.outline` → MyaccountEditPage) → 3칸 카드(게시글/댓글/포인트 `statValue`, 포인트 honeyDeep + `?` → 바텀시트 자리표시) → `NbkSegmentTabs(['내 글','내 댓글'], counts: [myArticleCount, myCommentCount])` → 목록(`getProfileArticleProvider`/`getProfileCommentProvider`, 현재 offset 0·limit 10 고정 → 무한 스크롤은 offset 증가로 가능하면 적용, 아니면 '최근 10개' 캡션). 내 글 아이템: `NbkPill.neutral(게시판)` + `itemTitle` / `LossAmount(caption)`(ProfileArticleType 에 lossCut 이 **없음** → 표시 불가, 날짜·조회만. 사용자에게 보고) · `dotDateFormat` · 조회 / `CommentCount`. 내 댓글 아이템: `commentBody` → 게시판 필 + 원문 제목 › · `shortDateFormat`; 탭 → `ArticleDetailPage.route(board, articleId)`; 휴지통 → `showConfirmSheet` → `nurbanCommentDelete`. 상단바 `NbkAppBar.root('내 계정', actions: [NbkIconButton(Icons.settings_outlined) → MyaccountSettingPage])`. 로그아웃·프로필 저장 후 갱신(§1 지적 1·2): `ref.invalidate(getProfileProvider)` 등. 기존 `MyaccountBodyView`/`MyaccountView`/`myaccount_*` 위젯·`MyaccountTabStatus`·`myaccountNavigationProvider` 는 대체 후 삭제.
6. **내 정보(설정)** — **완료(커밋 아래 참조)**. 리뷰 3회(세션 정리를 mounted 와 무관하게, 요청 중 뒤로 가기·본문 잠금). `MyaccountSettingPage`(ConsumerStatefulWidget) + `LoginMethodRow`(kakao/google 아이콘 타일 + 닉네임 캡션 + [로그아웃]) + `AccountMenuRow`('프로필 수정') + `AppInfoSection` + '탈퇴하기'(showConfirmDialog 체크박스 → myaccountWithdrawal → 성공 시만 홈으로). 레거시 setting 위젯 3개 삭제. 테스트 `test/myaccount_setting/**`(6개). 원래 계획:
   (원래 계획) **내 정보(설정)** (`lib/myaccount_setting`) — `NbkAppBar(back, '내 정보')`. '계정' 섹션: 로그인 수단 행(아이콘 타일 36: kakao → 말풍선/kakao 색, google → G; '카카오 계정'|'Google 계정' `itemTitle` + 닉네임 캡션(가입일 없음) + [로그아웃] outline 필 → `setEmptyToken` + `set(unauthenticated)` + `NbkToast.success('로그아웃 되었습니다.')` + pop). '프로필 수정 ›' 행. '앱 정보' 섹션(이용약관/개인정보/앱 버전). 하단 '탈퇴하기' 밑줄 text3 → `showConfirmDialog(icon: warning, checkboxLabel: '위 내용을 확인했어요', confirm '탈퇴')` → `myaccountWithdrawal` → 성공 `NbkToast.success('탈퇴가 완료되었습니다.')` + 루트로, 실패 `NbkToast.error`. 메시지의 글 N·댓글 N·포인트 N 은 프로필 값.
7. **프로필 수정** — **완료(커밋 아래 참조)**. 리뷰 2회(서버가 3개 이상 주면 앞 2개만, 저장 후 재조회 단언). `MyaccountEditPage`(로컬 상태; navigation_service 의 myaccountEdit* Provider 미사용 → 5단계 삭제) + `InsigniaTile`/`InsigniaCheck`/`InsigniaRemove`. 보이는 휘장 2개 제한 버그 수정(2개 차면 탭 무시 + 안내). insignia 는 기존처럼 `Set.toString()` 형식(`{url1, url2}`)으로 전송. 테스트 `test/myaccount_edit/**`(7개). 원래 계획:
   (원래 계획) **프로필 수정** (`lib/myaccount_edit`) — `NbkAppBar(close, '프로필 수정', actions: [NbkPillButton('저장')])`. 배지 88(radius 24) + 캡션. 닉네임(`NbkFieldLabel` + `2/8`, maxLength 8, 아래 상태줄: 비어 있으면 dangerText, 아니면 success 체크 + '사용할 수 있는 닉네임이에요') / 소개(`24/100`). 보이는 휘장 `N/2`: 선택 타일 84×64(honeyTint + honey 테두리 + `InsigniaImage.tile` + 검정 원형 X 24). **2개 제한 버그 수정**: 2개 차면 보유 휘장 탭 무시 + 안내 문구. 보유 휘장 3열 그리드(높이 64, radius 16, 선택은 honeyTint + honey 테두리 + 검정 체크 18). 기존 전역 변수 `insigniaShowList`/`isFirst`(`myaccount_edit_page.dart`) 는 State 로 옮긴다. 저장 성공 → `NbkToast.success('프로필이 저장되었습니다.')` + `ref.invalidate(getProfileProvider)` + pop. `insignia` 는 기존처럼 `insigniaShowList.toString()` 형식으로 전송.
8. **랭킹 탭** — 초안 `.harness/wip/wip-ranking/`(미적용). 적용 시 `lib/home/view/widgets/rank_view.dart`·`appbar_divider.dart`·`lib/board/**` 삭제. 원래 계획:
   (원래 계획) **랭킹 탭** (`lib/ranking`) — `NbkAppBar.root('손실 랭킹', actions: [기간 필(surface, calendar 아이콘, Strings.thisWeek(formatWeekRange(now)))])`. `getRankProvider`(전체 한 번에). 시상대 3열(2위/1위/3위, 아래 정렬): 1위 honeyTint + honeyLine + 왕관(`Icons.workspace_premium` 또는 그린 아이콘) + `NbkBadge(60)`, 2·3위 surface + `NbkBadge(48)`; 순위 뱃지(1위 honey/onHoney, 나머지 text2/흰); 닉네임 + 휘장 1개(`convertToInsignia(insignia.toString())` 첫 번째) + `LossAmount(podiumFirst|podium, compact: true)` + '추천 N'. `SectionBand` → 4위 이하 행 60: `rankNumber`(폭 28) + `NbkBadge(36)` + 닉네임·휘장 + 오른쪽 `LossAmount(rank)` / '추천 N'. 하단 고정 '내 순위' 바(honeyTint, radius 14): `prefStorage.getUserId()` 로 내 행 찾기 → [내 순위] 필 + '27위' `statValue` + 닉네임 + `LossAmount(top3)` + ›, 탭 → `select(HomeBottomStatus.myaccount)`; 비로그인 '로그인하고 내 순위 확인하기', 순위 밖 '아직 이번 주 기록이 없어요'. 로딩 `PodiumSkeleton` + `RankRowSkeleton`×5 + 내 순위 바 스켈레톤. 빈 상태 `EmptyState('아직 이번 주 랭킹이 없어요', '첫 손절 인증이 1위가 됩니다.')`. 기존 `RankView`·`RankCard`·`RankPage`·`UserInfo`·`rank_board_badge` 등은 대체 후 삭제.
9. **스플래시** — 초안 `.harness/wip/wip-splash/`(미적용). 적용 시 `android/app/build.gradle` 에 `dependencies { implementation 'androidx.core:core-splashscreen:1.0.1' }` 추가, `lib/splash` 삭제, `app.dart` 의 `onGenerateRoute` 제거, iOS `LaunchScreen.storyboard` 의 image 크기(168×185 → 96×96) 수정. 원래 계획:
   (원래 계획) **스플래시** — Flutter `lib/splash` 삭제 + `app.dart` 의 `onGenerateRoute: SplashPage.route()` 제거. Android: `androidx.core:core-splashscreen` 의존성 + `Theme.SplashScreen` 스타일(`windowSplashScreenBackground` 흰색, `windowSplashScreenAnimatedIcon` 심볼) + `MainActivity` 에서 `installSplashScreen()`(Kotlin) + 12 미만은 `launch_background.xml` 에 bitmap. iOS: `LaunchScreen.storyboard` 의 LaunchImage 를 심볼 PNG 로 교체. **심볼 PNG 가 없다**: `NbkSymbol` 과 같은 모양의 래스터/벡터 자원을 만들어야 한다(옵션: Android 는 VectorDrawable XML 로 육각형+물방울 path 작성, iOS 는 PDF/PNG 1x/2x/3x. 사용자에게 고해상도 심볼 파일이 있는지 질문).

### 5단계 — 문구·피드백 통일·정리 (별도 커밋 여러 개 가능)
- 남은 문자열 리터럴을 `Strings` 로 이동, 토스트 표(`docs/redesign-spec.md` 5단계) 적용. `Fluttertoast` 사용처 0 → `fluttertoast` 의존성 제거.
- 레거시 제거: `lib/common/view/{base_view,rank_page}.dart` 는 ViewModel 유지 결정 때문에 `base_view`·`loading_indicator`·`base_viewmodel` 은 남길 수 있음(검토). `rank_card`, `user_info`, `lib/board/`(nurban/free board item·badge), `lib/home/view/widgets/myaccount_*`, `rank_view`, `appbar_divider`(→ `Divider`), `lib/myaccount_*` 레거시 위젯, `assets/images/*` 중 미사용 PNG(탭 아이콘, drawer 아이콘 등) + `lib/gen/assets.gen.dart` 재생성(`dart run build_runner build`), `carousel_slider`·`flutter_material_pickers` 의존성 제거, `data/nurbanhoney_ui_data`·`application/nurbanhoney_ui_service` 패키지 삭제(루트 pubspec 의 path 의존성 제거, `pubspec.lock` 갱신) → `docs/architecture.md` 패키지 표·테마 설명 갱신, `tool/dep_guard.py` 는 pubspec name 으로 자동 수집하므로 수정 불필요.
- `HomeAppbarStatus`/`homeAppbarNavigationProvider`(application/navigation_service): 글 작성 앱바가 쓰던 것. 글 작성 재작성 후 참조 0 이면 삭제(생성 파일 `*.g.dart` 재생성 필요: `(cd application/navigation_service && dart run build_runner build --delete-conflicting-outputs)`).
- 패키지 warning 정리(사용자 승인): `data/dio_repository` 의 `return futureValue` → `return await futureValue`(동작 동일), `rank_repository.dart` unused import, 각 패키지 빈 테스트의 unused import, `application/share_service/pubspec.yaml`·`data/dio_repository/pubspec.yaml` 에 `publish_to: none`.
- 최종 확인: `grep -rn "Color(0x\|fontSize:" lib --include='*.dart' | grep -v "lib/theme/"` 결과 0, `flutter analyze` warning 0(전체), 디버그 빌드, 바뀐 화면 목록·남은 질문 보고.

### 사용자에게 남은 질문 (최종 보고에 포함)
1. 랭킹 집계 기준(주간? 월~일?) — API 에 기간이 없어 클라이언트에서 '이번 주' 를 계산함.
2. 포인트 적립·사용 규칙 — 바텀시트 내용.
3. 프로필 API 에 가입일 추가 여부(내 정보 '가입일' 표시용).
4. 내 글 목록(`/profile/myarticle`)에 `lossCut` 이 없어 시안의 `-430,000원` 을 표시할 수 없음 — API 추가 여부.
5. 이미지 업로드 진행률 — 저장소에 `onSendProgress` 콜백을 추가해도 되는지(규칙 3 과 충돌).
6. 네이티브 스플래시용 고해상도 심볼 파일 유무.

### 이번 세션에서 추가로 배운 것
- 다음 화면 초안은 `git stash` 대신 scratch/`.harness/wip/` 에 두었다가 커밋 뒤 복사한다(stash 에 스테이징이 섞이면 add/add 충돌).
- route 를 push 하는 위젯 테스트는 `pump(500ms)` ×2 로 전환 애니메이션을 끝내야 오른쪽 위젯이 화면 안에 들어온다. ListView 폼은 `tester.view.physicalSize = Size(1200, 3000)` 로 전부 만든다. `toImage` 는 `tester.runAsync` 안에서만 끝난다. macOS 에는 `timeout` 명령이 없다.
- Codex 리뷰는 화면마다 2~5회 반복됐고 주로 경쟁 조건(요청 중 화면 이탈·중복 탭·다이얼로그 위 pop)을 잡았다. 요청 중에는 PopScope + IgnorePointer 로 잠그고, 세션 정리는 await 전에 notifier 를 잡아 mounted 와 무관하게 끝내는 패턴으로 수렴했다.
- 홈 화면 관찰: 코인 게시판의 좋아요·댓글도 nurban API 를 쓴다(기존 동작 유지, 남은 질문에 추가). 댓글 목록은 최근 10개만(기존), 댓글 등록 결과 문자열은 확인하지 않음(기존). 글 작성의 [삭제] 는 기존 ImageDelete API 를 새로 호출한다.

## 4. 검증 절차 (이번에 배운 것)

- `tool/cross_verify.sh` 는 복제본에서 **`git diff --cached`(커밋되지 않은 변경)** 만 본다. 따라서 **커밋 전에** 변경을 `git add` 한 뒤 검증하고, PASS 후 커밋한다. 1단계는 커밋 후에 돌려서 아무것도 검토되지 않았고(gradle.properties 만 봄), 추가 지시로 커밋 해시를 지정해 다시 돌렸다.
- 검증이 도는 동안 원본 작업 트리를 바꾸면 결과가 무효가 된다. 그래서 **고정 스냅샷**에서 돌렸다:
  ```bash
  S=<scratch>/xv/<이름> && bash tool/verify_copy.sh --stub-secrets "$S/repo" && cd "$S/repo" \
    && bash tool/cross_verify.sh codex <verifier|code-reviewer|mutation-verifier> "<추가 지시>"
  cp "$S"/repo/.harness/reports/*.md <원본>/.harness/reports/<이름>-stageN-snapshot.md
  ```
  verify_copy 는 `git diff HEAD` 로 변경을 옮기므로 **untracked 파일은 `git add` 해야** 스냅샷에 들어간다. 스냅샷에서 돌리면 본 트리에서 다음 단계를 계속 작업할 수 있다. 보고서의 '원본' 경로는 스냅샷 경로로 찍힌다.
- 커밋 시점에 다음 단계 WIP 가 섞여 있으면 게이트(staged ↔ 작업 트리 일치)가 막는다. `git stash push --keep-index --include-untracked -m wip` → 커밋 → `git stash pop`. WIP 는 staged 파일을 건드리지 않아야 pop 충돌이 없다.
- mutation-verifier 는 verifier·code-reviewer 가 끝난 뒤 **단독** 실행. 이미 커밋된 범위를 검증하려면 추가 지시에 `git diff <hash>~1 <hash>` 를 보라고 적는다.
- FAIL 이면 지적을 반영하고 **같은 역할을 다시** 돌린다. 생존 변이는 제안된 경계 테스트를 추가한다.
- 보고서: `.harness/reports/` (gitignore). 이번 세션 파일명은 `*-stage{1,2,2b,3}-snapshot.md`.
- Codex 가 가끔 복제본에서 `flutter test` 의존성을 못 찾아 "테스트 미실행" 으로 적는다(stage3 code-reviewer). 판정에는 영향 없었지만 보고서의 "실행하지 못한 검사" 를 확인한다.

## 5. 참고·주의

- **analyze warning 세는 법**: `flutter analyze --no-pub 2>&1 | grep -cE '^warning •'`. `warning •` 줄은 들여쓰기가 없고 `   info •`·`  error •` 는 들여쓰기가 있다. 앞 공백을 요구하는 패턴을 쓰면 0 으로 잘못 센다(이번에 1·2단계 보고에서 그랬다). 현재 warning 115: `lib/` 66(4단계에서 다시 쓰는 레거시 파일) + 패키지 49. 새로 만든 파일의 warning 은 0.
- **디버그 빌드**: `flutter build apk --debug` (Gradle 8.14 로 올린 뒤 우회 플래그 불필요). 에뮬레이터·기기 없음 → 실행 확인은 빌드로 대체.
- **Pretendard**: `nurbanhoney_ui_data` 의 TextStyle 이 `package: 'nurbanhoney_ui'`(실제 이름 `nurbanhoney_ui_data`)를 써서 한 번도 로드된 적이 없었다. 지금은 루트 `fonts/`(400·500·600·700)와 `pubspec.yaml` `fonts:` 로 고쳤고 빌드 산출물 `FontManifest.json` 에 `Pretendard` 가 등록된다. 기존 패키지 pubspec 의 font 선언은 뺐다.
- **토큰 규칙**: `Color(0x…)` 는 `lib/theme/nbk_colors.dart` 에만, `fontSize:` 는 `nbk_typography.dart` 에만. 크기·간격은 `NbkSize`/`NbkSpacing`/`NbkRadius`. 화면에서 필요한 새 크기는 토큰 파일에 추가한다(컴포넌트 안의 수치 상수는 허용).
- **토스트**: `NbkToast.success/info/error(msg)` 는 context 없이 쓴다(`nbkNavigatorKey` 가 `MaterialApp.navigatorKey`). 기존 `Fluttertoast` 호출은 모두 이걸로 바꾼다.
- **ArticleCreate 게시판 값**: Provider 문자열은 `'너반꿀'`(주식)/`'코인'`. 표시만 주식/코인. `ArticleCreatePage.route(board: 1|2)`.
- **HomePageRefactor**: 이름은 그대로 두고(`AppView` 가 쓰는 진입점, AGENTS.md 의 "확인 없이 고치지 않는다" 영역) 내용만 `HomeShell` 로 바꿨다. `SplashPage` 는 4단계 스플래시에서 삭제.
- **LazyIndexedStack**: 처음 방문한 탭만 만든다. `MyaccountBodyView`(임시 내 계정 탭)는 비로그인에서 LoginPage 를 자동으로 push 하는 기존 동작이 있어 lazy 가 필수다(4단계에서 교체).
- Codex/Claude 교차 검증 CLI 는 `codex exec` 를 쓰며 한 역할에 5~10분 걸린다. 세 역할 모두 돌리면 20~30분.
