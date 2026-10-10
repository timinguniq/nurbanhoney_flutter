part of 'coin_tab_page.dart';

class CoinTabViewModel extends BaseViewModel {
  CoinTabViewModel(
      this.ref,
      ): _fetchState = DataFetching(){
    unawaited(fetch(isRefresh: true));
  }

  WidgetRef ref;

  // fetchState --------------------//

  DataFetchStatus _fetchState;

  DataFetchStatus get fetchState => _fetchState;

  void _updateFetchState(DataFetchStatus value) {
    isBusy = value is DataFetching || value is DataFetchingMore || value is DataRefetching;
    _fetchState = value;
    log('_updateFetchState isBusy: $isBusy');
    notifyListeners();
  }

  // state --------------------//

  final firstArticleId = -1;

  int _currentCoinArticleId = 0;

  bool _hasNextPage = false;

  bool get hasNextPage => _hasNextPage;

  int scrollThresholdCount = 10;

  // followerList --------------------//

  List<BoardAllType> _coinList = [];

  List<BoardAllType> get coinList => _coinList;

  // fetch
  Future<void> fetch({required bool isRefresh}) async {
    if (isRefresh) {
      _currentCoinArticleId = 0;
      _updateFetchState(DataRefetching());
    } else {
      _updateFetchState(DataFetchingMore());
    }

    final nextPage = isRefresh ? firstArticleId : _currentCoinArticleId;

    log('articleId : $nextPage');

    final preferenceStorage = ref.watch(preferenceStorageProvider);
    final storage = preferenceStorage.asData?.value;
    final token = storage?.getToken();
    log('token: $token');

    try {
      final freeRepository = ref.read(freeRepositoryProvider);
      final coinList = await freeRepository.getFreeAll(flag: 0, articleId: nextPage, limit: 10, token: token);

      if (coinList.isEmpty) {
        if (isRefresh) _coinList = [];
        _hasNextPage = false;
        _updateFetchState(DataFetchSuccess());
        return;
      }
      _coinList = isRefresh
          ? coinList
          : _coinList + coinList;

      _currentCoinArticleId = coinList.last.id;
      _hasNextPage = coinList.length >= scrollThresholdCount;
      log('CoinTabViewModel _currentCoinArticleId: $_currentCoinArticleId');
      log('CoinTabViewModel _hasNextPage: $_hasNextPage');

      _updateFetchState(DataFetchSuccess());
    } catch (e) {
      log('error: $e');
      // 오류 문자열은 ErrorState 의 오류 코드(errorCodeOf)를 만드는 데만 쓰고 화면에 그대로 보이지 않는다.
      _updateFetchState(DataFetchError(e.toString()));
    }
  }

}
