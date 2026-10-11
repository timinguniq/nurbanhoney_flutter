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

    try {
      final freeRepository = ref.read(freeRepositoryProvider);
      final coinList = await freeRepository.getFreeAll(flag: 0, articleId: nextPage, limit: 10);

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
      // 오류는 ErrorState 의 오류 코드(errorCodeOf)·오프라인 배너(isNetworkError)를 만드는 데만 쓴다.
      _updateFetchState(DataFetchError(e));
    }
  }

}
