import 'package:equatable/equatable.dart';

abstract class MacroEvent extends Equatable {
  const MacroEvent();
}

class RequestMacros extends MacroEvent {
  @override
  List<Object> get props => [];
}

class RunMacro extends MacroEvent {
  final String jsonPath;

  const RunMacro(this.jsonPath);

  @override
  List<Object> get props => [jsonPath];
}