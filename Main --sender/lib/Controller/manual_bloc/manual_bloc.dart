import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobizync/Controller/manual_bloc/manual_event.dart';
import 'package:mobizync/Controller/manual_bloc/manual_state.dart';
import 'package:mobizync/Models/message_model.dart';
import 'package:mobizync/Services/websocket_service.dart';

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
    final model = SendMessageModel(type: 'status');
    WebSocketHelper.sendMessage(model);
  }

  void _onSetBrightness(SetBrightness event, Emitter<ManualState> emit) {
    final model = SendMessageModel(
      type: 'manual',
      module: 'brightness',
      action: 'set',
      value: event.brightness.toString(),
    );
    WebSocketHelper.sendMessage(model);
  }

  void _onSetVolume(SetVolume event, Emitter<ManualState> emit) {
    final model = SendMessageModel(
      type: 'manual',
      module: 'volume',
      action: 'set',
      value: event.volume.toString(),
    );
    WebSocketHelper.sendMessage(model);
  }

  void _onTogglePower(TogglePower event, Emitter<ManualState> emit) {
    final model = SendMessageModel(
      type: 'manual',
      module: 'power',
      action: 'toggle',
    );
    WebSocketHelper.sendMessage(model);
  }

  void _onToggleLock(ToggleLock event, Emitter<ManualState> emit) {
    final model = SendMessageModel(
      type: 'manual',
      module: 'lock',
      action: 'toggle',
    );
    WebSocketHelper.sendMessage(model);
  }

  void _onToggleWifi(ToggleWifi event, Emitter<ManualState> emit) {
    final model = SendMessageModel(
      type: 'manual',
      module: 'wifi',
      action: 'toggle',
    );
    WebSocketHelper.sendMessage(model);
  }

  void _onToggleBluetooth(ToggleBluetooth event, Emitter<ManualState> emit) {
    final model = SendMessageModel(
      type: 'manual',
      module: 'bluetooth',
      action: 'toggle',
    );
    WebSocketHelper.sendMessage(model);
  }
}
