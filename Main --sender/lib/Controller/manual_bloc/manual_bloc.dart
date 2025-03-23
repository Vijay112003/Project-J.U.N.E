import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pc_connect/Controller/manual_bloc/manual_event.dart';
import 'package:pc_connect/Controller/manual_bloc/manual_state.dart';
import 'package:pc_connect/Services/mqtt_service.dart';

class ManualBloc extends Bloc<ManualEvent, ManualState> {
  ManualBloc() : super(ManualInitial()) {
    on<SyncButtonPressed>(_onSendSyncMessage);
    on<SetBrightness>(_onSetBrightness);
    on<SetVolume>(_onSetVolume);
    on<TogglePower>(_onTogglePower);
    on<ToggleLock>(_onToggleLock);
    on<ToggleWifi>(_onToggleWifi);
    on<ToggleBluetooth>(_onToggleBluetooth);
  }

  void _onSendSyncMessage(SyncButtonPressed event, Emitter<ManualState> emit) {
    MQTTHelper.publishMessage('SENDER', 'STATUS');
  }

  void _onSetBrightness(SetBrightness event, Emitter<ManualState> emit) {
    MQTTHelper.publishMessage('SENDER', '{"type": "manual", "module": "brightness", "action": "set", "value": "${event.brightness}"}');
  }

  void _onSetVolume(SetVolume event, Emitter<ManualState> emit) {
    MQTTHelper.publishMessage('SENDER', '{"type": "manual", "module": "volume", "action": "set", "value": "${event.volume}"}');
  }

  void _onTogglePower(TogglePower event, Emitter<ManualState> emit) {
    MQTTHelper.publishMessage('SENDER', '{"type": "manual", "module": "power", "action": "toggle"}');
  }

  void _onToggleLock(ToggleLock event, Emitter<ManualState> emit) {
    MQTTHelper.publishMessage('SENDER', '{"type": "manual", "module": "lock", "action": "toggle"}');
  }

  void _onToggleWifi(ToggleWifi event, Emitter<ManualState> emit) {
    MQTTHelper.publishMessage('SENDER', '{"type": "manual", "module": "wifi", "action": "toggle"}');
  }

  void _onToggleBluetooth(ToggleBluetooth event, Emitter<ManualState> emit) {
    MQTTHelper.publishMessage('SENDER', '{"type": "manual", "module": "bluetooth", "action": "toggle"}');
  }
}