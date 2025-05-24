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

class MoveMouse extends ManualEvent {
  final int dx;
  final int dy;
  final int speed;

  MoveMouse(this.dx, this.dy, this.speed);

  @override
  List<Object> get props => [dx, dy, speed];
}

class MouseClick extends ManualEvent {
  final String button;

  MouseClick(this.button);

  @override
  List<Object> get props => [button];
}

class ApplicationLaunch extends ManualEvent {
  final String appName;

  ApplicationLaunch(this.appName);

  @override
  List<Object> get props => [appName];
}
