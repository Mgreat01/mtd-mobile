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
  int _reconnectAttempt = 0;

  Stream<Map<String, dynamic>> get notifications => _notifications.stream;

  Future<void> connect() async {
    if (_disposed || _connecting || !AppConfig.isRealtimeConfigured) return;
    final userId = _currentUserId();
    final token = GetStorage().read<String>('token');
    if (userId == null || token == null || token.isEmpty) return;

    _connecting = true;
    try {
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
      debugPrint('WebSocket notifications connecté à $uri');
      _socket!.listen(
        (raw) async {
          try {
            await _handleMessage(raw.toString(), userId, token);
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

  Future<void> _handleMessage(String raw, int userId, String token) async {
    final envelope = jsonDecode(raw) as Map<String, dynamic>;
    final event = _normalizeEventName(envelope['event']?.toString());

    if (event == 'pusher:connection_established') {
      final connectionData = _decodeData(envelope['data']);
      final socketId = connectionData['socket_id']?.toString();
      if (socketId != null) {
        await _subscribe(userId, token, socketId);
      }
      return;
    }

    if (event == 'pusher:ping') {
      _socket?.add(jsonEncode({'event': 'pusher:pong', 'data': {}}));
      return;
    }

    if (event == 'notification.created' ||
        event == 'race.accepted' ||
        event == 'race.confirmed') {
      debugPrint('Événement temps réel reçu ($event): ${envelope['data']}');
      _notifications.add({..._decodeData(envelope['data']), '_event': event});
    }
  }

  String? _normalizeEventName(String? event) {
    if (event == null || event.isEmpty) return event;
    if (event == 'race.accepted' ||
        event == 'race.confirmed' ||
        event == 'notification.created') {
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
      default:
        return event;
    }
  }

  Future<void> _subscribe(int userId, String token, String socketId) async {
    final channel = _currentUserRole() == 'passenger'
        ? 'private-user.$userId'
        : 'private-biker.$userId';
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/broadcasting/auth'),
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
    if (_disposed || _reconnectTimer?.isActive == true) return;
    _socket = null;
    _reconnectAttempt++;
    final seconds = (_reconnectAttempt * 2).clamp(2, 30).toInt();
    _reconnectTimer = Timer(Duration(seconds: seconds), connect);
  }

  Future<void> dispose() async {
    _disposed = true;
    _reconnectTimer?.cancel();
    await _socket?.close();
    await _notifications.close();
  }
}
