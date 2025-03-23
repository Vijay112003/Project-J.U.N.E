import 'package:equatable/equatable.dart';

abstract class MQTTEvent extends Equatable {
  const MQTTEvent();
}

class MQTTConnect extends MQTTEvent {
  @override
  List<Object> get props => [];
}

class MQTTStartListening extends MQTTEvent {
  @override
  List<Object> get props => [];
}

class MQTTNewMessage extends MQTTEvent {
  final String payload;

  MQTTNewMessage(this.payload);

  @override
  List<Object> get props => [payload];
}

class MQTTDisconnect extends MQTTEvent {
  @override
  List<Object> get props => [];
}

class MQTTSendMessage extends MQTTEvent {
  final String message;

  MQTTSendMessage(this.message);

  @override
  List<Object> get props => [message];
}

