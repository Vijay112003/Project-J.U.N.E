
import 'package:equatable/equatable.dart';

abstract class MacroState extends Equatable {
  const MacroState();
}

class MacroInitial extends MacroState {
  @override
  List<Object> get props => [];
}

class MacroInitiated extends MacroState {
  @override
  List<Object> get props => [];
}
