import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pc_connect/Services/mqtt_service.dart';

import 'terminal_event.dart';
import 'terminal_state.dart';

class TerminalBloc extends Bloc<TerminalEvent, TerminalState> {
  TerminalBloc() : super(TerminalInitialState()) {
    on<TerminalSendCommandEvent>(_onTerminalSendCommand);
  }

  Future<void> _onTerminalSendCommand(
      TerminalSendCommandEvent event, Emitter<TerminalState> emit) async {
    final command = event.command;
    MQTTHelper.publishMessage('SENDER', '{"type":"terminal", "text": "$command"}');
  }
}