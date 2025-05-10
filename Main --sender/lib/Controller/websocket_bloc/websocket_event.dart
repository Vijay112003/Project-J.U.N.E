import 'package:equatable/equatable.dart';

abstract class WebSocketEvent extends Equatable {
  const WebSocketEvent();
}

class WebSocketConnect extends WebSocketEvent {
  @override
  List<Object> get props => [];
}

class WebSocketStartListening extends WebSocketEvent {
  @override
  List<Object> get props => [];
}

class WebSocketNewMessage extends WebSocketEvent {
  final String payload;

  WebSocketNewMessage(this.payload);

  @override
  List<Object> get props => [payload];
}

class WebSocketDisconnect extends WebSocketEvent {
  @override
  List<Object> get props => [];
}

class WebSocketSendMessage extends WebSocketEvent {
  final String message;

  WebSocketSendMessage(this.message);

  @override
  List<Object> get props => [message];
}

