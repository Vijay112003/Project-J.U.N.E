import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketHelper {
  static WebSocketChannel? _channel;
  static const String wsUrl = 'wss://june-backend-fckl.onrender.com';

  static void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    print('✅ WebSocket connected to $wsUrl');

    // Register once connected
    final registerPayload = jsonEncode({
      "type": "register",
      "token":
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MTcyYTY5OGE3Yzg3ZTY2NjIxNjAzZCIsImVtYWlsIjoidGhlamVzaGJoYWdhdmFudGhAZ21haWwuY29tIiwiaWF0IjoxNzQ2MzQ5MjgyLCJleHAiOjE3NDY5NTQwODJ9.bAxsJ3krmvqXBh5UdpGhM4LzKLHMa7npukfNfHR6kpI",
      "role": "mobile",
    });
    _channel?.sink.add(registerPayload);
    print('🔐 Register payload sent');
  }

  static void sendMessage(String type, dynamic payload) {
    final message = jsonEncode({
      "type": type,
      "payload": payload,
    });
    _channel?.sink.add(message);
    print('📤 Message sent: $message');
  }

  static void listen(void Function(String) onMessage) {
    _channel?.stream.listen(
          (data) {
        if (data is String) {
          onMessage(data);
        } else {
          print("⚠️ Received non-string data");
        }
      },
      onDone: () => print("❌ WebSocket closed"),
      onError: (e) => print("⚠️ WebSocket error: $e"),
    );
  }

  static void disconnect() {
    _channel?.sink.close();
    print('🚪 WebSocket disconnected');
  }

  static Stream<String>? get messages =>
      _channel?.stream.cast<String>();
}
