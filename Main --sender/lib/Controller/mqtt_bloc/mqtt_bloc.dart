import 'package:bloc/bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:pc_connect/Services/mqtt_service.dart';
import 'mqtt_event.dart';
import 'mqtt_state.dart';

class MQTTBloc extends Bloc<MQTTEvent, MQTTState> {
  MQTTBloc() : super(MQTTInitial()) {
    on<MQTTConnect>(_onConnect);
  }

  void _onConnect(MQTTConnect event, Emitter<MQTTState> emit) async {
    bool connected = await MQTTHelper.connect();
    if (connected) {
      MQTTHelper.subscribe('RECIEVER');
      MQTTHelper.subscribe('STATUS');
      emit(MQTTConnected());

      MQTTHelper.getMessagesStream()?.listen((messages) {
        final message = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
        emit(MQTTMessageReceived(payload));
      });
    }
  }
}