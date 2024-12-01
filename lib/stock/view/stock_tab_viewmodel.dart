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

  final firstPage = -1;
  
  int _currentStockPage = 0;

  bool _hasNextPage = false;

  bool get hasNextPage => _hasNextPage;

  int scrollThresholdCount = 20;

  // followerList --------------------//

  List<BoardAllType> _stockList = [];

  List<BoardAllType> get stockList => _stockList;

  // fetch
  Future<void> fetch({required bool isRefresh}) async {
    if (isRefresh) {
      _currentStockPage = 0;
      _updateFetchState(DataRefetching());
    } else {
      _updateFetchState(DataFetchingMore());
    }

    final nextPage = isRefresh ? firstPage : _currentStockPage + 1;

    log('articleId : $nextPage');
    //final nurbanAll = ref.watch(getNurbanAllProvider((0, nextPage, 10)));
    final nurbanRepository = ref.read(nurbanRepositoryProvider);
    final nurbanList = await nurbanRepository.getNurbanAll(flag: 0, articleId: nextPage, limit: 10);

    //final getNurbanAll = ref.read(getNurbanAllProvider((0, nextPage, 10)));
    //final list = getNurbanAll.asData?.valueOrNull ?? [];
/*
    nurbanAll.when(
      data: (data) {
        log('StockTabViewModel data: $data');
        //_updateStockList(data, nextPage, isRefresh);
        _stockList = isRefresh
            ? data
            : _stockList + data;
        _currentStockPage = nextPage;
        _hasNextPage = data.length >= scrollThresholdCount;
        _updateFetchState(DataFetchSuccess());
      },
      loading: () {
        log('StockTabViewModel loading');
        _updateFetchState(DataRefetching());
      },
      error: (error, stackTrace) {
        log('StockTabViewModel error: $error');
        _updateFetchState(DataFetchError('error'));
      },
    );
 */
    if(nurbanList.isNotEmpty){
      _stockList = isRefresh
          ? nurbanList
          : _stockList + nurbanList;
      _currentStockPage = nextPage;
      _hasNextPage = nurbanList.length >= scrollThresholdCount;
      _updateFetchState(DataFetchSuccess());
    }else{
      _updateFetchState(DataFetchError('error'));
    }
  }

}
