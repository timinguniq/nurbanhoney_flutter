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

    final getNurbanAll = ref.read(getNurbanAllProvider((0, nextPage, 10)));

    final list = getNurbanAll.asData?.valueOrNull ?? [];

    if(list.isNotEmpty){
      _stockList = isRefresh
          ? list
          : _stockList + list;
      _currentStockPage = nextPage;
      _hasNextPage = list.length >= scrollThresholdCount;
      _updateFetchState(DataFetchSuccess());
    }else{
      _updateFetchState(DataFetchError('error'));
    }

  }

}
