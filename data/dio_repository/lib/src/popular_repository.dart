class PopularRepository {
  /// constructor
  PopularRepository._privateConstructor();
  static final PopularRepository _instance = PopularRepository._privateConstructor();

  factory PopularRepository(){
    return _instance;
  }
}