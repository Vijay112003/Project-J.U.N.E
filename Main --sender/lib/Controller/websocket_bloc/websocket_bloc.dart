import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:mobizync/Models/macro_models.dart';
import 'package:mobizync/Services/websocket_service.dart';
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
      print("🧩 Received raw message: ${event.payload}");
      final Map<String, dynamic> jsonData = jsonDecode(event.payload);

      final type = jsonData["type"];
      final data = jsonData["data"];
      final message = jsonData["message"];

      switch (type) {
        case "screen_frame":
          if (data is Map && data["frame"] is String) {
            emit(WebSocketScreenFrameReceived(data["frame"]));
          } else {
            emit(WebSocketError("Invalid screen frame data format"));
          }
          break;

        case "status":
          if (data is Map<String, dynamic>) {
            final statusInfo = StatusInfo.fromJson(data);
            emit(WebSocketStatusReceived(statusInfo));
          } else {
            emit(WebSocketError("Invalid status data format"));
          }
          break;

        case "manual":
          if (data is Map && data["message"] is String) {
            emit(WebSocketMessageReceived(data["message"]));
          } else {
            emit(WebSocketError("Invalid manual message format"));
          }
          break;

        case "macro":
          if (data is Map && data["macros"] is List) {
            final macros = (data["macros"] as List)
                .map((e) => MacroModel.fromJson(e))
                .toList();
            emit(WebSocketMacrosReceived(macros));
          } else {
            emit(WebSocketError("Invalid macro data format"));
          }
          break;

        case "terminal":
          if (data is Map && data["output"] is String) {
            emit(WebSocketTerminalReceived(data["output"]));
          } else {
            emit(WebSocketError("Invalid terminal output format"));
          }
          break;

        case "command":
          if (jsonData["command"] is String) {
            emit(WebSocketMessageReceived(jsonData["command"]));
          } else {
            emit(WebSocketError("Invalid command format"));
          }
          break;

        case "error":
          emit(WebSocketError(message ?? "Unknown error occurred"));
          break;

        default:
          emit(WebSocketError("Unknown message type: $type"));
      }
    } catch (e) {
      emit(WebSocketError("Error parsing WebSocket message: $e"));
    }
  }
}
