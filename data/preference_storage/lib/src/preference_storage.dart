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

  /// device id key
  static const _prefDeviceId = '__pref_device_id__';

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
  int getUserId() => _plugin.getInt(_prefUserId) ?? -1;

  /// set user id
  Future<void> setUserId(int value) =>
      _plugin.setInt(_prefUserId, value);

  /// get device_id
  String getDeviceId() => _plugin.getString(_prefDeviceId) ?? '';

  /// set device_id
  Future<void> setDeviceId(String deviceId) =>
      _plugin.setString(_prefDeviceId, deviceId);
}
