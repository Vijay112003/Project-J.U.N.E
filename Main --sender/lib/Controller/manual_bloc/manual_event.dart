import 'package:equatable/equatable.dart';

abstract class ManualEvent extends Equatable {
  const ManualEvent();
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