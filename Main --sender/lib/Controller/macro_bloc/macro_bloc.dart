import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobizync/Models/message_model.dart';
import 'package:mobizync/Services/websocket_service.dart';

import 'macro_event.dart';
import 'macro_state.dart';

class MacroBloc extends Bloc<MacroEvent, MacroState> {
  MacroBloc() : super(MacroInitial()) {
    on<RequestMacros>(_onRequestMacros);
    on<RunMacro>(_onRunMacro);
  }

  Future<void> _onRequestMacros(
      RequestMacros event, Emitter<MacroState> emit) async {
    final SendMessageModel message = SendMessageModel(
      type: 'macro',
      action: 'get_macro',
    );
    WebSocketHelper.sendMessage(message);
  }

  Future<void> _onRunMacro(RunMacro event, Emitter<MacroState> emit) async {
    final jsonPath = event.jsonPath;
    final SendMessageModel message = SendMessageModel(
      type: 'macro',
      filepath: jsonPath,
      action: 'run_macro',
    );
    WebSocketHelper.sendMessage(message);
  }
}