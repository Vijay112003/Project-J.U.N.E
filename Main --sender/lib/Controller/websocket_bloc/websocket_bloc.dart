import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:pc_connect/Models/macro_models.dart';
import 'package:pc_connect/Services/websocket_service.dart';
import '../../Models/status_model.dart';
import 'websocket_event.dart';
import 'websocket_state.dart';

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  late final StreamController<String> _messageController;

  WebSocketBloc() : super(WebSocketInitial()) {
    _messageController = StreamController<String>.broadcast();

    on<WebSocketConnect>(_onConnect);
    on<WebSocketStartListening>(_onStartListening);
    on<WebSocketNewMessage>(_onNewMessage);

    _messageController.stream.listen((message) {
      add(WebSocketNewMessage(message));
    });
  }

  @override
  Future<void> close() {
    _messageController.close();
    WebSocketHelper.disconnect();
    return super.close();
  }

  Future<void> _onConnect(WebSocketConnect event, Emitter<WebSocketState> emit) async {
    try {
      WebSocketHelper.connect();
      emit(WebSocketConnected());
    } catch (e) {
      emit(WebSocketError("Failed to connect to WebSocket: $e"));
    }
  }

  void _onStartListening(WebSocketStartListening event, Emitter<WebSocketState> emit) {
    WebSocketHelper.listen((message) {
      try {
        _messageController.add(message);
      } catch (e) {
        emit(WebSocketError("Error receiving WebSocket message: $e"));
      }
    });
  }

  Future<void> _onNewMessage(WebSocketNewMessage event, Emitter<WebSocketState> emit) async {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(event.payload);

      if (jsonData.containsKey("status") && jsonData["status"] is Map<String, dynamic>) {
        final statusInfo = StatusInfo.fromJson(jsonData["status"]);
        emit(WebSocketStatusReceived(statusInfo));
      } else if (jsonData.containsKey("message") && jsonData["message"] is String) {
        emit(WebSocketMessageReceived(jsonData["message"]));
      } else if (jsonData.containsKey("error") && jsonData["error"] is String) {
        emit(WebSocketError(jsonData["error"]));
      } else if (jsonData.containsKey("macros") && jsonData["macros"] is List) {
        final List<MacroModel> macros = (jsonData["macros"] as List)
            .map((e) => MacroModel.fromJson(e))
            .toList();
        emit(WebSocketMacrosReceived(macros));
      } else if (jsonData.containsKey("macro_end") && jsonData["macro_end"] is String) {
        emit(WebSocketMacrosEnded(jsonData["macro_end"]));
      } else if (jsonData.containsKey("terminal") && jsonData["terminal"] is String) {
        emit(WebSocketTerminalReceived(jsonData["terminal"]));
      } else if (jsonData.containsKey("type") && jsonData["type"] == "command") {
        emit(WebSocketMessageReceived(jsonData["command"]));
      } else {
        emit(WebSocketError("Invalid message format"));
      }
    } catch (e) {
      emit(WebSocketError("Error parsing WebSocket message: $e"));
    }
  }
}
