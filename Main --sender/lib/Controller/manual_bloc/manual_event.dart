import 'package:equatable/equatable.dart';

abstract class ManualEvent extends Equatable {
  const ManualEvent();
}

class SyncButtonPressed extends ManualEvent {
  @override
  List<Object> get props => [];
}

class SetBrightness extends ManualEvent {
  final int brightness;

  SetBrightness(this.brightness);

  @override
  List<Object> get props => [brightness];
}

class SetVolume extends ManualEvent {
  final int volume;

  SetVolume(this.volume);

  @override
  List<Object> get props => [volume];
}

class TogglePower extends ManualEvent {
  @override
  List<Object> get props => [];
}

class ToggleLock extends ManualEvent {
  @override
  List<Object> get props => [];
}

class ToggleWifi extends ManualEvent {
  @override
  List<Object> get props => [];
}

class ToggleBluetooth extends ManualEvent {
  @override
  List<Object> get props => [];
}



