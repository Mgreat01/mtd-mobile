import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:moto_taxi_digital_mobile/utils/appConfig.dart';

class RealtimeNotificationService {
  final _notifications = StreamController<Map<String, dynamic>>.broadcast();
  WebSocket? _socket;
  Timer? _reconnectTimer;
  bool _disposed = false;
  bool _connecting = false;
  bool _manuallyDisconnected = false;
  int _reconnectAttempt = 0;
  String? _socketId;
  final Set<String> _channels = <String>{};
  final Set<String> _subscribedChannels = <String>{};
  final Set<String> _processedEventIds = <String>{};

  Stream<Map<String, dynamic>> get notifications => _notifications.stream;

  Future<void> connect() async {
    if (_disposed || _connecting || _socket != null) return;
    _manuallyDisconnected = false;
    if (!AppConfig.isRealtimeConfigured) {
      debugPrint(
        'Temps réel désactivé : REALTIME_WS_URL ou REVERB_APP_KEY absent.',
      );
      return;
    }
    final userId = _currentUserId();
    final token = GetStorage().read<String>('token');
    if (userId == null || token == null || token.isEmpty) {
      debugPrint('Temps réel non connecté : utilisateur ou jeton absent.');
      return;
    }

    _connecting = true;
    try {
      await _loadBootstrap(token);
      final base = Uri.parse(AppConfig.realtimeWsUrl);
      final path =
          '${base.path.replaceFirst(RegExp(r'/+$'), '')}'
          '/app/${AppConfig.reverbAppKey}';
      final uri = base.replace(
        path: path,
        queryParameters: const {
          'protocol': '7',
          'client': 'moto-digital-flutter',
          'version': '1.0',
          'flash': 'false',
        },
      );

      _socket = await WebSocket.connect(uri.toString());
      _reconnectAttempt = 0;
      _subscribedChannels.clear();
      debugPrint('WebSocket notifications connecté à $uri');
      _socket!.listen(
        (raw) async {
          try {
            await _handleMessage(raw.toString(), token);
          } catch (error) {
            debugPrint('Message Reverb invalide: $error');
          }
        },
        onError: (error) {
          debugPrint('Erreur WebSocket notifications: $error');
          _scheduleReconnect();
        },
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (error) {
      debugPrint('Connexion Reverb impossible: $error');
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  Future<void> _handleMessage(String raw, String token) async {
    final envelope = jsonDecode(raw) as Map<String, dynamic>;
    final event = _normalizeEventName(envelope['event']?.toString());

    if (event == 'pusher:connection_established') {
      final connectionData = _decodeData(envelope['data']);
      final socketId = connectionData['socket_id']?.toString();
      if (socketId != null) {
        _socketId = socketId;
        await _subscribeChannels(token, socketId);
      }
      return;
    }

    if (event == 'pusher:ping') {
      _socket?.add(jsonEncode({'event': 'pusher:pong', 'data': {}}));
      return;
    }

    if (event == 'notification.created' ||
        event == 'race.accepted' ||
        event == 'race.confirmed' ||
        event == 'race.state.updated' ||
        event == 'biker.location.updated') {
      final payload = _decodeData(envelope['data']);
      final eventId = payload['event_id']?.toString();
      if (eventId != null && !_rememberEvent(eventId)) return;
      if (event == 'race.accepted' || event == 'race.confirmed') {
        await _subscribeToRaceChannel(payload, token);
      }
      debugPrint('Événement temps réel reçu ($event): ${envelope['data']}');
      _notifications.add({..._decodeData(envelope['data']), '_event': event});
    }
  }

  String? _normalizeEventName(String? event) {
    if (event == null || event.isEmpty) return event;
    if (event == 'race.accepted' ||
        event == 'race.confirmed' ||
        event == 'notification.created' ||
        event == 'race.state.updated' ||
        event == 'biker.location.updated') {
      return event;
    }

    // Laravel peut envoyer le nom public, le nom de classe complet ou le nom
    // d'alias configure dans broadcastAs().
    final shortName = event.split('\\').last.split('.').last;
    switch (shortName) {
      case 'BikerAcceptedRace':
      case 'race.accepted':
        return 'race.accepted';
      case 'PassengerConfirmedRace':
      case 'race.confirmed':
        return 'race.confirmed';
      case 'NotificationCreated':
      case 'notification.created':
        return 'notification.created';
      case 'RaceStateUpdated':
        return 'race.state.updated';
      case 'BikerLocationUpdated':
        return 'biker.location.updated';
      default:
        return event;
    }
  }

  Future<void> _subscribe(
    int userId,
    String token,
    String socketId, {
    String? channelName,
  }) async {
    final role = _currentUserRole();
    final channel =
        channelName ??
        (role == 'passenger'
            ? 'private-user.$userId'
            : 'private-biker.$userId');
    debugPrint('Authentification Reverb du rôle $role sur $channel');
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/api/broadcasting/auth'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: {'socket_id': socketId, 'channel_name': channel},
    );
    if (response.statusCode != 200) {
      throw HttpException(
        'Authentification Reverb refusée (${response.statusCode})',
      );
    }

    final auth = jsonDecode(response.body) as Map<String, dynamic>;
    _socket?.add(
      jsonEncode({
        'event': 'pusher:subscribe',
        'data': {'channel': channel, 'auth': auth['auth']},
      }),
    );
    debugPrint('Abonnement Reverb actif: $channel');
  }

  Future<void> _loadBootstrap(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/api/realtime/bootstrap'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) {
        throw HttpException(
          'Bootstrap temps reel refuse (${response.statusCode})',
        );
      }
      final body = jsonDecode(response.body);
      final data = body is Map ? body['data'] : null;
      if (data is! Map)
        throw const FormatException('Bootstrap temps reel invalide');

      final channels = data['channels'];
      if (channels is List) {
        _channels
          ..clear()
          ..addAll(
            channels.whereType<Map>().map((item) {
              final name = item['subscription_name']?.toString();
              if (name == null || name.isEmpty) {
                throw const FormatException('Canal temps reel invalide');
              }
              return name;
            }),
          );
      }
      _notifications.add({
        ...Map<String, dynamic>.from(data),
        '_event': 'realtime.bootstrap',
      });
    } catch (error) {
      debugPrint('Bootstrap temps reel indisponible: $error');
      _setFallbackChannel();
    }
  }

  Future<void> _subscribeChannels(String token, String socketId) async {
    if (_channels.isEmpty) _setFallbackChannel();
    final userId = _currentUserId();
    if (userId == null) return;
    for (final channel in _channels) {
      if (_subscribedChannels.contains(channel)) continue;
      await _subscribe(userId, token, socketId, channelName: channel);
      _subscribedChannels.add(channel);
    }
  }

  Future<void> _subscribeToRaceChannel(
    Map<String, dynamic> payload,
    String token,
  ) async {
    final race = payload['race'];
    final raceId = race is Map
        ? race['id']?.toString()
        : payload['race_id']?.toString();
    if (raceId == null || int.tryParse(raceId) == null) return;

    _channels.add('private-race.$raceId');
    final socketId = _socketId;
    if (socketId != null) await _subscribeChannels(token, socketId);
  }

  void _setFallbackChannel() {
    final userId = _currentUserId();
    if (userId == null) return;
    final role = _currentUserRole();
    _channels
      ..clear()
      ..add(
        role == 'passenger' ? 'private-user.$userId' : 'private-biker.$userId',
      );
  }

  bool _rememberEvent(String eventId) {
    if (!_processedEventIds.add(eventId)) return false;
    if (_processedEventIds.length > 100) {
      _processedEventIds.remove(_processedEventIds.first);
    }
    return true;
  }

  Map<String, dynamic> _decodeData(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    }
    return <String, dynamic>{};
  }

  int? _currentUserId() {
    dynamic storedUser = GetStorage().read('user');
    if (storedUser is String) storedUser = jsonDecode(storedUser);
    if (storedUser is! Map) return null;
    return int.tryParse(storedUser['id']?.toString() ?? '');
  }

  String? _currentUserRole() {
    dynamic storedUser = GetStorage().read('user');
    if (storedUser is String) storedUser = jsonDecode(storedUser);
    if (storedUser is! Map) return null;
    return storedUser['role']?.toString();
  }

  void _scheduleReconnect() {
    if (_disposed ||
        _manuallyDisconnected ||
        _reconnectTimer?.isActive == true) {
      return;
    }
    _socket = null;
    _socketId = null;
    _subscribedChannels.clear();
    _reconnectAttempt++;
    final seconds = (_reconnectAttempt * 2).clamp(2, 30).toInt();
    _reconnectTimer = Timer(Duration(seconds: seconds), connect);
  }

  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
    await _notifications.close();
  }

  Future<void> disconnect() async {
    _manuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _socketId = null;
    _subscribedChannels.clear();
    _channels.clear();
    _processedEventIds.clear();

    final socket = _socket;
    _socket = null;
    // La fermeture WebSocket peut attendre le réseau indéfiniment. La session
    // applicative est déjà invalidée ci-dessus, donc elle ne doit jamais
    // empêcher une déconnexion hors ligne.
    if (socket != null) unawaited(socket.close());
  }
}
