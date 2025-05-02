
abstract class TerminalEvent {}

class TerminalSendCommandEvent extends TerminalEvent {
  final String command;

  TerminalSendCommandEvent(this.command);
}