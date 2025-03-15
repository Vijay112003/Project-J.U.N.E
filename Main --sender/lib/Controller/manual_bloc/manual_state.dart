import 'package:equatable/equatable.dart';

abstract class ManualState extends Equatable {
  const ManualState();
}

class ManualInitial extends ManualState {
  @override
  List<Object> get props => [];
}

class ManualBrightnessChanged extends ManualState {
  final int brightness;

  ManualBrightnessChanged(this.brightness);

  @override
  List<Object> get props => [brightness];
}

class ManualVolumeChanged extends ManualState {
  final int volume;

  ManualVolumeChanged(this.volume);

  @override
  List<Object> get props => [volume];
}