import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../storage/token_storage.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/config/api_endpoints_stub.dart'
    if (dart.library.js_interop) '../../core/config/api_endpoints_web.dart'
    as config;

/// Connection state for the WebSocket client
enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// WebSocket client for real-time communication
class WebSocketClient {
  final TokenStorage _tokenStorage;
  final String _baseUrl;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController =
      StreamController<WebSocketConnectionState>.broadcast();

  WebSocketConnectionState _connectionState =
      WebSocketConnectionState.disconnected;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _pingInterval = Duration(seconds: 30);

  bool _shouldReconnect = true;

  WebSocketClient({
    TokenStorage? tokenStorage,
    String? baseUrl,
  })  : _tokenStorage = tokenStorage ?? TokenStorage(),
        _baseUrl = baseUrl ?? ApiEndpoints.wsBaseUrl;

  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  /// Stream of connection state changes
  Stream<WebSocketConnectionState> get connectionState =>
      _connectionStateController.stream;

  /// Current connection state
  WebSocketConnectionState get currentState => _connectionState;

  /// Whether the client is connected
  bool get isConnected =>
      _connectionState == WebSocketConnectionState.connected;

  /// Connect to the WebSocket server
  Future<void> connect() async {
    if (_connectionState == WebSocketConnectionState.connected ||
        _connectionState == WebSocketConnectionState.connecting) {
      return;
    }

    _shouldReconnect = true;
    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    _updateConnectionState(WebSocketConnectionState.connecting);

    try {
      final token = await _tokenStorage.getAccessToken();
      final wsUrl = _buildWebSocketUrl(token);

      // Skip connection if URL appears to be pointing to Flutter dev server
      // (typically localhost with high port numbers used by Flutter)
      final uri = Uri.tryParse(wsUrl);
      if (uri != null && uri.host == 'localhost' && uri.port > 50000) {
        debugPrint(
            'WebSocket: Skipping connection - dev server detected ($wsUrl)');
        debugPrint(
            'WebSocket: Configure WS_BASE_URL or wsBaseUrl for real WebSocket connection');
        _updateConnectionState(WebSocketConnectionState.disconnected);
        _shouldReconnect = false;
        return;
      }

      debugPrint('WebSocket: Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Wait for the connection to be established
      await _channel!.ready;

      _updateConnectionState(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );

      _startPingTimer();

      debugPrint('WebSocket: Connected successfully');
    } catch (e) {
      debugPrint('WebSocket: Connection error: $e');
      _updateConnectionState(WebSocketConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  String _buildWebSocketUrl(String? token) {
    // Determine if we need ws:// or wss://
    String wsUrl = _baseUrl;

    // If baseUrl is a relative path, we need to construct the full URL
    if (wsUrl.startsWith('/')) {
      // Use the config helper to get the proper WebSocket URL
      wsUrl = config.getWebSocketUrl(wsUrl);
    }

    // Convert http(s) to ws(s) if needed
    if (wsUrl.startsWith('http://')) {
      wsUrl = wsUrl.replaceFirst('http://', 'ws://');
    } else if (wsUrl.startsWith('https://')) {
      wsUrl = wsUrl.replaceFirst('https://', 'wss://');
    }

    // Add token as query parameter if available
    if (token != null && token.isNotEmpty) {
      final separator = wsUrl.contains('?') ? '&' : '?';
      wsUrl = '$wsUrl${separator}token=$token';
    }

    return wsUrl;
  }

  void _handleMessage(dynamic message) {
    try {
      final String messageStr =
          message is String ? message : message.toString();

      // Handle ping/pong
      if (messageStr == 'PONG' || messageStr == 'pong') {
        debugPrint('WebSocket: Received pong');
        return;
      }

      // Detect if we received HTML instead of JSON (wrong routing - frontend served instead of backend)
      if (messageStr.trimLeft().startsWith('<!DOCTYPE') ||
          messageStr.trimLeft().startsWith('<html')) {
        debugPrint(
            'WebSocket: ERROR - Received HTML instead of JSON. The /ws endpoint is being served by the frontend nginx instead of the backend WebSocket server. Check your ingress/proxy configuration.');
        _handleError('WebSocket endpoint misconfigured - receiving HTML');
        return;
      }

      final Map<String, dynamic> data = jsonDecode(messageStr);
      debugPrint('WebSocket: Received message: ${data['type']}');
      _messageController.add(data);
    } catch (e) {
      debugPrint('WebSocket: Error parsing message: $e');
    }
  }

  void _handleError(dynamic error) {
    debugPrint('WebSocket: Error: $error');
    _updateConnectionState(WebSocketConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _handleDone() {
    debugPrint('WebSocket: Connection closed');
    _updateConnectionState(WebSocketConnectionState.disconnected);
    _stopPingTimer();
    _scheduleReconnect();
  }

  void _updateConnectionState(WebSocketConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      _connectionStateController.add(state);
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('WebSocket: Max reconnection attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    final delay = _reconnectDelay * _reconnectAttempts;
    debugPrint(
        'WebSocket: Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)');

    _updateConnectionState(WebSocketConnectionState.reconnecting);

    _reconnectTimer = Timer(delay, () {
      if (_shouldReconnect) {
        _establishConnection();
      }
    });
  }

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      if (isConnected) {
        send({'type': 'PING'});
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Send a message to the server
  void send(Map<String, dynamic> message) {
    if (!isConnected || _channel == null) {
      debugPrint('WebSocket: Cannot send message - not connected');
      return;
    }

    try {
      final jsonStr = jsonEncode(message);
      _channel!.sink.add(jsonStr);
      debugPrint('WebSocket: Sent message: ${message['type']}');
    } catch (e) {
      debugPrint('WebSocket: Error sending message: $e');
    }
  }

  /// Subscribe to a topic
  void subscribe(String topic) {
    send({
      'type': 'SUBSCRIBE',
      'destination': topic,
    });
  }

  /// Unsubscribe from a topic
  void unsubscribe(String topic) {
    send({
      'type': 'UNSUBSCRIBE',
      'destination': topic,
    });
  }

  /// Disconnect from the WebSocket server
  Future<void> disconnect() async {
    debugPrint('WebSocket: Disconnecting');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _stopPingTimer();

    await _subscription?.cancel();
    await _channel?.sink.close();

    _channel = null;
    _subscription = null;

    _updateConnectionState(WebSocketConnectionState.disconnected);
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionStateController.close();
  }
}
