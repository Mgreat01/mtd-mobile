import 'dart:convert';

import 'package:get_storage/get_storage.dart';

/// Stockage JSON local, expirant et séparé par compte connecté.
///
/// Il sert uniquement de secours et d'affichage rapide. Les données réseau et
/// les événements temps réel restent la source de vérité.
class AppCacheStore {
  AppCacheStore({GetStorage? storage}) : _storage = storage ?? GetStorage();

  static const _prefix = 'mtd_cache_v1';
  final GetStorage _storage;

  Future<void> writeJson(
    String key,
    Object? value, {
    required Duration ttl,
  }) async {
    final payload = <String, Object?>{
      'expires_at': DateTime.now().toUtc().add(ttl).millisecondsSinceEpoch,
      'value': value,
    };
    await _storage.write(_cacheKey(key), jsonEncode(payload));
  }

  dynamic readJson(String key, {bool allowExpired = false}) {
    final raw = _storage.read(_cacheKey(key));
    if (raw is! String) return null;

    try {
      final payload = jsonDecode(raw);
      if (payload is! Map) return null;
      final expiresAt = payload['expires_at'];
      final expiry = expiresAt is num ? expiresAt.toInt() : null;
      final expired =
          expiry == null ||
          DateTime.now().toUtc().millisecondsSinceEpoch > expiry;
      if (expired && !allowExpired) {
        _storage.remove(_cacheKey(key));
        return null;
      }
      return payload['value'];
    } catch (_) {
      _storage.remove(_cacheKey(key));
      return null;
    }
  }

  Future<void> remove(String key) => _storage.remove(_cacheKey(key));

  Future<void> clearCurrentUser() async {
    final scope = _scope();
    // `getKeys()` n'a pas le même type de retour sur toutes les versions de
    // GetStorage. Une boucle typée évite une erreur runtime pendant logout.
    final matchingKeys = <String>[
      for (final key in _storage.getKeys())
        if (key is String && key.startsWith('$_prefix:$scope:')) key,
    ];
    for (final key in matchingKeys) {
      await _storage.remove(key);
    }
  }

  String _cacheKey(String key) => '$_prefix:${_scope()}:$key';

  String _scope() {
    dynamic user = _storage.read('user');
    if (user is String) {
      try {
        user = jsonDecode(user);
      } catch (_) {
        user = null;
      }
    }
    if (user is Map && user['id'] != null) {
      return 'user_${user['id']}';
    }
    return 'anonymous';
  }
}
