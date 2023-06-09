class NoticeRepository {
  /// constructor
  NoticeRepository._privateConstructor();
  static final NoticeRepository _instance = NoticeRepository._privateConstructor();

  factory NoticeRepository(){
    return _instance;
  }
}