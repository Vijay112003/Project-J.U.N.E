import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pc_connect/Controller/manual_bloc/manual_event.dart';
import 'package:pc_connect/Controller/manual_bloc/manual_state.dart';
import 'package:pc_connect/Services/mqtt_service.dart';

class ManualBloc extends Bloc<ManualEvent, ManualState> {
  ManualBloc() : super(ManualInitial()) {
    on<SetBrightness>(_onSetBrightness);
    on<SetVolume>(_onSetVolume);
  }

  void _onSetBrightness(SetBrightness event, Emitter<ManualState> emit) {
    print('Brightness: ${event.brightness}');
    MQTTHelper.publishMessage('SENDER', '{"type": "manual", "module": "brightness", "action": "set", "value": "${event.brightness}"}');
  }

  void _onSetVolume(SetVolume event, Emitter<ManualState> emit) {
    emit(ManualVolumeChanged(event.volume));
  }
}