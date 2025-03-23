import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:pc_connect/Services/mqtt_service.dart';
import '../../Models/status_model.dart';
import 'mqtt_event.dart';
import 'mqtt_state.dart';

class MQTTBloc extends Bloc<MQTTEvent, MQTTState> {
  late final StreamController<String> _messageController;

  MQTTBloc() : super(MQTTInitial()) {
    _messageController = StreamController<String>.broadcast();

    on<MQTTConnect>(_onConnect);
    on<MQTTStartListening>(_onStartListening);
    on<MQTTNewMessage>(_onNewMessage);

    // Listen to the message stream and add new events dynamically
    _messageController.stream.listen((message) {
      add(MQTTNewMessage(message));
    });
  }

  @override
  Future<void> close() {
    _messageController.close();
    return super.close();
  }

  Future<void> _onConnect(MQTTConnect event, Emitter<MQTTState> emit) async {
    bool connected = await MQTTHelper.connect();
    if (connected) {
      MQTTHelper.subscribe('RECIEVER');
      MQTTHelper.subscribe('STATUS');
      emit(MQTTConnected());
    } else {
      emit(MQTTError("Failed to connect to MQTT broker"));
    }
  }

  void _onStartListening(MQTTStartListening event, Emitter<MQTTState> emit) {
    MQTTHelper.getMessagesStream()?.listen((messages) {
      final message = messages[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);

      // Instead of calling emit(), add the message to the StreamController
      _messageController.add(payload);
    });
  }

  Future<void> _onNewMessage(MQTTNewMessage event, Emitter<MQTTState> emit) async {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(event.payload);

      if (jsonData.containsKey("status") && jsonData["status"] is Map<String, dynamic>) {
        final statusInfo = StatusInfo.fromJson(jsonData["status"]);
        print("Status: \${statusInfo.battery}");
        emit(MQTTStatusReceived(statusInfo));
      } else if (jsonData.containsKey("message") && jsonData["message"] is String) {
        emit(MQTTMessageReceived(jsonData["message"]));
      } else if (jsonData.containsKey("error") && jsonData["error"] is String) {
        emit(MQTTError(jsonData["error"]));
      } else {
        emit(MQTTError("Invalid message format"));
      }
    } catch (e) {
      print("Error parsing MQTT message: $e");
      emit(MQTTError("Error parsing MQTT message: $e"));
    }
  }
}
