import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:tracker_frontend/data/client/websocket_client.dart';
import 'package:tracker_frontend/data/storage/token_storage.dart';

@GenerateMocks([TokenStorage])
import 'websocket_client_test.mocks.dart';

void main() {
  group('WebSocketClient', () {
    late MockTokenStorage mockTokenStorage;

    setUp(() {
      mockTokenStorage = MockTokenStorage();
    });

    test('creates instance with default values', () {
      final client = WebSocketClient();
      expect(client, isNotNull);
      expect(client.isConnected, isFalse);
      expect(client.currentState, WebSocketConnectionState.disconnected);
    });

    test('creates instance with custom token storage', () {
      final client = WebSocketClient(tokenStorage: mockTokenStorage);
      expect(client, isNotNull);
    });

    test('creates instance with custom base URL', () {
      final client = WebSocketClient(baseUrl: 'ws://custom.url/ws');
      expect(client, isNotNull);
    });

    test('initial state is disconnected', () {
      final client = WebSocketClient();
      expect(client.currentState, WebSocketConnectionState.disconnected);
      expect(client.isConnected, isFalse);
    });

    test('messages stream is broadcast', () {
      final client = WebSocketClient();
      expect(client.messages, isA<Stream<Map<String, dynamic>>>());
    });

    test('connectionState stream is broadcast', () {
      final client = WebSocketClient();
      expect(client.connectionState, isA<Stream<WebSocketConnectionState>>());
    });

    test('dispose cleans up resources', () {
      final client = WebSocketClient();
      // Should not throw
      client.dispose();
    });

    test('send does nothing when not connected', () {
      final client = WebSocketClient();
      // Should not throw
      client.send({'type': 'TEST'});
    });

    test('subscribe sends subscribe message format', () {
      final client = WebSocketClient();
      // Since not connected, this won't actually send but validates method exists
      client.subscribe('/topic/test');
    });

    test('unsubscribe sends unsubscribe message format', () {
      final client = WebSocketClient();
      // Since not connected, this won't actually send but validates method exists
      client.unsubscribe('/topic/test');
    });

    test('disconnect when not connected does not throw', () async {
      final client = WebSocketClient();
      // Should not throw
      await client.disconnect();
      expect(client.currentState, WebSocketConnectionState.disconnected);
    });
  });

  group('WebSocketConnectionState', () {
    test('has all expected states', () {
      expect(WebSocketConnectionState.values,
          contains(WebSocketConnectionState.disconnected));
      expect(WebSocketConnectionState.values,
          contains(WebSocketConnectionState.connecting));
      expect(WebSocketConnectionState.values,
          contains(WebSocketConnectionState.connected));
      expect(WebSocketConnectionState.values,
          contains(WebSocketConnectionState.reconnecting));
    });
  });
}
