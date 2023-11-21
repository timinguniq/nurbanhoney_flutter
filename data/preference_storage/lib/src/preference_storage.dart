import 'package:shared_preferences/shared_preferences.dart';

/// {@template preference_storage}
/// Storage to access user token data in Preference.
/// {@endtemplate}
class PreferenceStorage {
  /// {@macro preference_storage}
  const PreferenceStorage({
    required SharedPreferences plugin,
  }) : _plugin = plugin;

  final SharedPreferences _plugin;

  /// storage token key
  static const _prefAuthToken = '__pref_auth_token__';

  /// preference empty string
  static const _prefEmptyStr = '__empty__';

  /// user id key
  static const _prefUserId = '__pref_user_id__';

  /// get user token
  String getToken() => _plugin.getString(_prefAuthToken) ?? _prefEmptyStr;

  /// set user token
  Future<void> setToken(String value) =>
      _plugin.setString(_prefAuthToken, value);

  /// set empty token
  Future<void> setEmptyToken() =>
      _plugin.setString(_prefAuthToken, _prefEmptyStr);

  /// has token
  bool hasToken() => getToken() != _prefEmptyStr;

  /// get user id
  String getUserId() => _plugin.getString(_prefUserId) ?? _prefEmptyStr;

  /// set user id
  Future<void> setUserId(String value) =>
      _plugin.setString(_prefUserId, value);

}
