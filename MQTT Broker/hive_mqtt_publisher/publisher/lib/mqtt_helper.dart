import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTHelper {
  static MqttServerClient? client;
  static const String broker = '117b05b4f6e74fc18152fad7ddcc76a9.s1.eu.hivemq.cloud';
  static const int port = 8883;
  static const String username = 'admin@gmail.com';
  static const String password = 'Admin@123';

  static Future<bool> connect() async {
    client = MqttServerClient.withPort(broker, 'flutter_client', port);
    client!.secure = true;
    client!.keepAlivePeriod = 60;
    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .authenticateAs(username, password)
        .withClientIdentifier('flutter_client')
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
      return true;
    } catch (e) {
      print('Exception: $e');
      client!.disconnect();
      return false;
    }
  }

  static void subscribe(String topic) {
    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      client!.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  static void publishMessage(String topic, String message) {
    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }
  }

  static void onConnected() {
    print('Connected to MQTT Broker');
  }

  static void onDisconnected() {
    print('Disconnected from MQTT Broker');
  }

  static void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  static Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
    return client?.updates;
  }

  static void disconnect() {
    client?.disconnect();
  }
}