import 'dart:convert';
import 'dart:typed_data';
import 'package:mobizync/Models/message_model.dart';
import 'package:mobizync/Services/sharedpreference_helper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketHelper {
  static WebSocketChannel? _channel;
  static const String wsUrl = 'wss://june-backend-fckl.onrender.com';

  static void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    print('✅ WebSocket connected to $wsUrl');

    // Use shared preferences to get the token
    SharedPreferenceHelper.getAccessToken().then((token) {
      if (token != null) {
        // Register once token is available
        final registerPayload = jsonEncode({
          "type": "register",
          "token": token,
          "role": "mobile",
        });

        _channel?.sink.add(registerPayload);
        print('🔐 Register payload sent with token: $token');
      } else {
        print('❌ No token found in SharedPreferences');
      }
    }).catchError((error) {
      print('❌ Error retrieving token: $error');
    });
  }

  static void sendMessage(SendMessageModel msg) {
    final message = jsonEncode(msg.toJson());
    _channel?.sink.add(message);
    print('📤 Message sent: $message');
  }

  static void listen(void Function(String) onMessage) {
    _channel?.stream.listen((data) {
        try {
          String message;

          if (data is String) {
            message = data;
          } else if (data is Uint8List) {
            message = utf8.decode(data);
          } else {
            print("⚠️ Unsupported data type received: ${data.runtimeType}");
            return;
          }

          print("📥 Decoded Message: $message");
          onMessage(message);
        } catch (e) {
          print("❌ Error decoding WebSocket message: $e");
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
