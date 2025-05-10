import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pc_connect/Services/websocket_service.dart';

import 'macro_event.dart';
import 'macro_state.dart';

class MacroBloc extends Bloc<MacroEvent, MacroState> {
  MacroBloc() : super(MacroInitial()) {
    on<RequestMacros>(_onRequestMacros);
    on<RunMacro>(_onRunMacro);
  }

  Future<void> _onRequestMacros(
      RequestMacros event, Emitter<MacroState> emit) async {
    WebSocketHelper.sendMessage('SENDER', '{"action":"get_macro"}');
  }

  Future<void> _onRunMacro(RunMacro event, Emitter<MacroState> emit) async {
    final jsonPath = event.jsonPath;
    WebSocketHelper.sendMessage('SENDER', '{"type": "macro", "filepath": "$jsonPath"}');
  }
}