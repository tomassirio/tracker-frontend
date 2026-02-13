import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tracker_frontend/data/client/websocket_client.dart';
import 'package:tracker_frontend/data/models/websocket/websocket_event.dart';
import 'package:tracker_frontend/core/constants/api_endpoints.dart';

/// Singleton service for managing WebSocket connections and subscriptions
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketService._internal();

  WebSocketClient? _client;
  StreamSubscription? _messageSubscription;
  StreamSubscription<WebSocketConnectionState>? _connectionStateSubscription;

  final _eventController = StreamController<WebSocketEvent>.broadcast();
  final _tripEventControllers = <String, StreamController<WebSocketEvent>>{};
  final Set<String> _subscribedTrips = {};

  bool _isInitialized = false;

  /// Stream of all WebSocket events
  Stream<WebSocketEvent> get events => _eventController.stream;

  /// Connection state stream
  Stream<WebSocketConnectionState> get connectionState =>
      _client?.connectionState ?? const Stream.empty();

  /// Whether the service is connected
  bool get isConnected => _client?.isConnected ?? false;

  /// Initialize the WebSocket service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _client = WebSocketClient();

    _messageSubscription = _client!.messages.listen(_handleMessage);

    // Listen for connection state changes to resubscribe when reconnected
    _connectionStateSubscription =
        _client!.connectionState.listen(_handleConnectionStateChange);

    _isInitialized = true;
    debugPrint('WebSocketService: Initialized');
  }

  void _handleConnectionStateChange(WebSocketConnectionState state) {
    debugPrint('WebSocketService: Connection state changed to $state');
    if (state == WebSocketConnectionState.connected) {
      // Subscribe to all pending trips when connection is established
      _subscribeToAllPendingTrips();
    }
  }

  void _subscribeToAllPendingTrips() {
    for (final tripId in _subscribedTrips) {
      _client?.subscribe(ApiEndpoints.wsTripTopic(tripId));
      debugPrint('WebSocketService: Subscribed to trip $tripId');
    }
  }

  /// Connect to the WebSocket server
  Future<void> connect() async {
    if (!_isInitialized) {
      await initialize();
    }

    await _client?.connect();
    // Note: Subscriptions are handled by _handleConnectionStateChange
    // when the connection is established
  }

  /// Disconnect from the WebSocket server
  Future<void> disconnect() async {
    await _client?.disconnect();
  }

  /// Subscribe to events for a specific trip
  Stream<WebSocketEvent> subscribeToTrip(String tripId) {
    if (!_tripEventControllers.containsKey(tripId)) {
      _tripEventControllers[tripId] =
          StreamController<WebSocketEvent>.broadcast();
    }

    if (!_subscribedTrips.contains(tripId)) {
      _subscribedTrips.add(tripId);
      if (isConnected) {
        _client?.subscribe(ApiEndpoints.wsTripTopic(tripId));
        debugPrint('WebSocketService: Subscribed to trip $tripId');
      }
    }

    return _tripEventControllers[tripId]!.stream;
  }

  /// Unsubscribe from events for a specific trip
  void unsubscribeFromTrip(String tripId) {
    if (_subscribedTrips.contains(tripId)) {
      _subscribedTrips.remove(tripId);
      if (isConnected) {
        _client?.unsubscribe(ApiEndpoints.wsTripTopic(tripId));
        debugPrint('WebSocketService: Unsubscribed from trip $tripId');
      }
    }

    // Close and remove the controller
    _tripEventControllers[tripId]?.close();
    _tripEventControllers.remove(tripId);
  }

  /// Subscribe to multiple trips at once
  void subscribeToTrips(List<String> tripIds) {
    for (final tripId in tripIds) {
      subscribeToTrip(tripId);
    }
  }

  /// Unsubscribe from all trips
  void unsubscribeFromAllTrips() {
    final tripIds = List<String>.from(_subscribedTrips);
    for (final tripId in tripIds) {
      unsubscribeFromTrip(tripId);
    }
  }

  void _handleMessage(Map<String, dynamic> data) {
    try {
      final event = _parseEvent(data);

      // Emit to global stream
      _eventController.add(event);

      // Emit to trip-specific stream if applicable
      if (event.tripId != null &&
          _tripEventControllers.containsKey(event.tripId)) {
        _tripEventControllers[event.tripId]!.add(event);
      }

      debugPrint(
          'WebSocketService: Processed event ${event.type} for trip ${event.tripId}');
    } catch (e) {
      debugPrint('WebSocketService: Error handling message: $e');
    }
  }

  WebSocketEvent _parseEvent(Map<String, dynamic> data) {
    final typeStr = data['type'] as String?;
    final type = WebSocketEvent.parseEventType(typeStr);

    switch (type) {
      case WebSocketEventType.tripStatusChanged:
        return TripStatusChangedEvent.fromJson(data);
      case WebSocketEventType.tripUpdated:
        return TripUpdatedEvent.fromJson(data);
      case WebSocketEventType.commentAdded:
        return CommentAddedEvent.fromJson(data);
      case WebSocketEventType.commentReactionAdded:
        return CommentReactionEvent.fromJson(data, isRemoval: false);
      case WebSocketEventType.commentReactionRemoved:
        return CommentReactionEvent.fromJson(data, isRemoval: true);
      default:
        return WebSocketEvent.fromJson(data);
    }
  }

  /// Dispose of the service
  void dispose() {
    _messageSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _client?.dispose();
    _eventController.close();

    for (final controller in _tripEventControllers.values) {
      controller.close();
    }
    _tripEventControllers.clear();
    _subscribedTrips.clear();

    _isInitialized = false;
    debugPrint('WebSocketService: Disposed');
  }
}
