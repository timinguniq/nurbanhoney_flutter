/// Status to manage login status with token
enum AuthenticationStatus{
  /// initial status(splash)
  unknown,

  /// token exist
  authenticated,

  /// no have token
  unauthenticated,
}