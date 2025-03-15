import 'package:equatable/equatable.dart';

abstract class MQTTEvent extends Equatable {
  const MQTTEvent();
}

class MQTTConnect extends MQTTEvent {
  @override
  List<Object> get props => [];
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

