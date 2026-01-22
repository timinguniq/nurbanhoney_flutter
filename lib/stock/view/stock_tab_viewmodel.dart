part of 'stock_tab_page.dart';

class StockTabViewModel extends BaseViewModel {
  StockTabViewModel(
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
  
  int _currentStockArticleId = 0;

  bool _hasNextPage = false;

  bool get hasNextPage => _hasNextPage;

  int scrollThresholdCount = 10;

  // followerList --------------------//

  List<BoardAllType> _stockList = [];

  List<BoardAllType> get stockList => _stockList;

  // fetch
  Future<void> fetch({required bool isRefresh}) async {
    if (isRefresh) {
      _currentStockArticleId = 0;
      _updateFetchState(DataRefetching());
    } else {
      _updateFetchState(DataFetchingMore());
    }

    final nextPage = isRefresh ? firstArticleId : _currentStockArticleId;

    log('articleId : $nextPage');

    final preferenceStorage = ref.watch(preferenceStorageProvider);
    final storage = preferenceStorage.asData?.value;
    final token = storage?.getToken();
    log('token: $token');

    //final nurbanAll = ref.watch(getNurbanAllProvider((0, nextPage, 10)));
    final nurbanRepository = ref.read(nurbanRepositoryProvider);
    final nurbanList = await nurbanRepository.getNurbanAll(flag: 0, articleId: nextPage, limit: 10, token: token);

    if(nurbanList.isNotEmpty){
      _stockList = isRefresh
          ? nurbanList
          : _stockList + nurbanList;

      _currentStockArticleId = nurbanList.last.id;
      _hasNextPage = nurbanList.length >= scrollThresholdCount;
      log('StockTabViewModel _currentStockArticleId: $_currentStockArticleId');
      log('StockTabViewModel _hasNextPage: $_hasNextPage');
    }

    _updateFetchState(DataFetchSuccess());
  }

}
