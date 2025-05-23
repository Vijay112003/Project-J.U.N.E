import 'package:equatable/equatable.dart';
import 'package:mobizync/Models/macro_models.dart';
import 'package:mobizync/Views/macros.dart';

import '../../Models/status_model.dart';

abstract class WebSocketState extends Equatable {
  const WebSocketState();
}

class WebSocketInitial extends WebSocketState {
  @override
  List<Object> get props => [];
}

class WebSocketConnected extends WebSocketState {
  @override
  List<Object> get props => [];
}

class WebSocketDisconnected extends WebSocketState {
  @override
  List<Object> get props => [];
}

class WebSocketError extends WebSocketState {
  final String error;

  WebSocketError(this.error);

  @override
  List<Object> get props => [error];
}

class WebSocketScreenFrameReceived extends WebSocketState {
  final String screenFrame;

  WebSocketScreenFrameReceived(this.screenFrame);

  @override
  List<Object> get props => [screenFrame];
}

class WebSocketMacrosReceived extends WebSocketState {
  final List<MacroModel> macros;

  WebSocketMacrosReceived(this.macros);

  @override
  List<Object> get props => [macros];
}

class WebSocketMacrosEnded extends WebSocketState {
  final String macroName;

  WebSocketMacrosEnded(this.macroName);

  @override
  List<Object> get props => [macroName];
}

class WebSocketTerminalReceived extends WebSocketState {
  final String terminalOutput;

  WebSocketTerminalReceived(this.terminalOutput);

  @override
  List<Object> get props => [terminalOutput];
}

class WebSocketMessageReceived extends WebSocketState {
  final String message;

  WebSocketMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class WebSocketStatusReceived extends WebSocketState {
  final StatusInfo statusInfo;

  WebSocketStatusReceived(this.statusInfo);

  @override
  List<Object> get props => [statusInfo];
}

