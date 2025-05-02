import 'package:equatable/equatable.dart';
import 'package:pc_connect/Models/macro_models.dart';
import 'package:pc_connect/Views/macros.dart';

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

class MQTTMacrosReceived extends MQTTState {
  final List<MacroModel> macros;

  MQTTMacrosReceived(this.macros);

  @override
  List<Object> get props => [macros];
}

class MQTTMacrosEnded extends MQTTState {
  final String macroName;

  MQTTMacrosEnded(this.macroName);

  @override
  List<Object> get props => [macroName];
}

class MQTTTerminalReceived extends MQTTState {
  final String terminalOutput;

  MQTTTerminalReceived(this.terminalOutput);

  @override
  List<Object> get props => [terminalOutput];
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

