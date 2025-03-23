import 'package:equatable/equatable.dart';

import '../../Models/status_model.dart';

abstract class MQTTState extends Equatable {
  const MQTTState();
}

class MQTTInitial extends MQTTState {
  @override
  List<Object> get props => [];
}

class MQTTConnected extends MQTTState {
  @override
  List<Object> get props => [];
}

class MQTTDisconnected extends MQTTState {
  @override
  List<Object> get props => [];
}

class MQTTError extends MQTTState {
  final String error;

  MQTTError(this.error);

  @override
  List<Object> get props => [error];
}

class MQTTMessageReceived extends MQTTState {
  final String message;

  MQTTMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class MQTTStatusReceived extends MQTTState {
  final StatusInfo statusInfo;

  MQTTStatusReceived(this.statusInfo);

  @override
  List<Object> get props => [statusInfo];
}

