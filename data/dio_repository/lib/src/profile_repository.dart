class ProfileRepository {
  /// constructor
  ProfileRepository._privateConstructor();
  static final ProfileRepository _instance = ProfileRepository._privateConstructor();

  factory ProfileRepository(){
    return _instance;
  }
}