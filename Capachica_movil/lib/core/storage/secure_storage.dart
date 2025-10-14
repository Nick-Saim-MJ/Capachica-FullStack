import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AppSecureStorage {
static const _tokenKey = 'auth_token';
static const _rolesKey = 'roles';
static const _emailVerifiedKey = 'email_verified';
static const _twoFAEnabledKey = 'two_factor_enabled';
final _storage = const FlutterSecureStorage();


Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
Future<String?> getToken() => _storage.read(key: _tokenKey);
Future<void> clearToken() => _storage.delete(key: _tokenKey);


Future<void> saveRoles(List<String> roles) =>
_storage.write(key: _rolesKey, value: roles.join(','));
Future<List<String>> getRoles() async =>
(await _storage.read(key: _rolesKey))?.split(',').where((e) => e.isNotEmpty).toList() ?? [];


Future<void> setEmailVerified(bool v) =>
_storage.write(key: _emailVerifiedKey, value: v ? '1' : '0');
Future<bool> isEmailVerified() async => (await _storage.read(key: _emailVerifiedKey)) == '1';

Future<void> setTwoFAEnabled(bool v) =>
    _storage.write(key: _twoFAEnabledKey, value: v ? '1' : '0');

Future<bool> isTwoFAEnabled() async =>
    (await _storage.read(key: _twoFAEnabledKey)) == '1';

Future<void> clearAll() async {
await _storage.delete(key: _tokenKey);
await _storage.delete(key: _rolesKey);
await _storage.delete(key: _emailVerifiedKey);
}
}