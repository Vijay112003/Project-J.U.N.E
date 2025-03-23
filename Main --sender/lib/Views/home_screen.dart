import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pc_connect/Components/_homeComponents.dart';
import 'package:pc_connect/Controller/manual_bloc/manual_bloc.dart';
import 'package:pc_connect/Controller/manual_bloc/manual_event.dart';
import 'package:pc_connect/Controller/mqtt_bloc/mqtt_bloc.dart';
import 'package:pc_connect/Controller/mqtt_bloc/mqtt_event.dart';
import 'package:pc_connect/Controller/mqtt_bloc/mqtt_state.dart';
import 'package:pc_connect/Services/mqtt_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Models/status_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late stt.SpeechToText _speech;
  String _text = "Press the mic and start speaking...";
  bool _isListening = false;
  bool _isSyncing = false;

  StatusInfo? _statusInfo;

  int brightness = 50;
  int volume = 50;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Row(
            children: [
              if (_statusInfo?.power == "Charging")
                Icon(FontAwesomeIcons.bolt, color: Colors.green),
              SizedBox(width: 10),
              BatteryWidget(batteryLevel: _statusInfo?.battery ?? 50),
              SizedBox(width: 10),
            ],
          ),
          // SyncButton to initiate the sync process
          SyncButton(
            isSyncing: _isSyncing,
            isSynced: _statusInfo != null,
            onPressed: () {
              setState(() {
                _isSyncing = true; // Set syncing status
              });
              BlocProvider.of<ManualBloc>(context)
                  .add(SyncButtonPressed()); // Trigger sync action
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: BlocListener<MQTTBloc, MQTTState>(
          listener: (context, state) {
            if (state is MQTTConnected) {
              BlocProvider.of<MQTTBloc>(context).add(MQTTStartListening());
              BlocProvider.of<ManualBloc>(context).add(SyncButtonPressed());
              setState(() {
                _isSyncing = true; // Set syncing status
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Connected to MQTT"),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            if (state is MQTTMessageReceived) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Message received: ${state.message}"),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            if (state is MQTTStatusReceived) {
              setState(() {
                _isSyncing = false;
              });
              print("Status received: ${state.statusInfo}");
              setState(() {
                _statusInfo = state.statusInfo;
                brightness = _statusInfo?.brightness ?? 50;
                volume = _statusInfo?.volume ?? 50;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                    child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                  ),
                  children: [
                    RoundedButton(
                      icon: FontAwesomeIcons.powerOff,
                      name: "Power",
                      color: Colors.red,
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmationDialog(
                                  title: "Power",
                                  content:
                                      "Are you sure you want to power off?",
                                  onConfirm: () {
                                    BlocProvider.of<ManualBloc>(context)
                                        .add(TogglePower());
                                  });
                            });
                      },
                    ),

                    RoundedButton(
                      icon: Icons.lock,
                      name: "Lock",
                      color: Colors.grey,
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmationDialog(
                                  title: "Lock",
                                  content:
                                      "Are you sure you want to lock the device?",
                                  onConfirm: () {
                                    BlocProvider.of<ManualBloc>(context)
                                        .add(ToggleLock());
                                  });
                            });
                      },
                    ),

                    RoundedButton(
                      icon: Icons.bluetooth,
                      name: "Bluetooth",
                      color: (_statusInfo?.bluetooth ?? false)
                          ? Colors.green
                          : Colors.grey,
                      onTap: () {
                        BlocProvider.of<ManualBloc>(context)
                            .add(ToggleBluetooth());
                      },
                    ),

                    RoundedButton(
                      icon: Icons.wifi,
                      name: "Wi-Fi",
                      color: (_statusInfo?.wifi ?? false)
                          ? Colors.green
                          : Colors.grey,
                      onTap: () {
                        BlocProvider.of<ManualBloc>(context).add(ToggleWifi());
                      },
                    ),

                    RoundedButton(
                      icon: Icons.volume_up,
                      name: "Volume",
                      color: Colors.blue,
                      onTap: () {
                        _showVolumeBottomSheet(volume);
                      },
                    ),

                    // RoundedButton(
                    //   icon: Icons.mic_off,
                    //   name: "Mute",
                    //   color: Colors.grey,
                    //   onTap: () {
                    //     // Implement mute functionality
                    //   },
                    // ),

                    RoundedButton(
                      icon: Icons.brightness_6,
                      name: "Brightness",
                      color: Colors.orangeAccent,
                      onTap: () {
                        _showBrightnessBottomSheet(brightness);
                      },
                    ),

                    // RoundedButton(
                    //   icon: Icons.apps,
                    //   name: "Apps",
                    //   color: Colors.grey,
                    //   onTap: () {
                    //     // Implement apps functionality
                    //   },
                    // ),

                    // RoundedButton(
                    //   icon: Icons.mouse_outlined,
                    //   name: "Touch Pad",
                    //   color: Colors.grey,
                    //   onTap: () {
                    //     // Implement touchpad functionality
                    //   },
                    // ),
                    //
                    // RoundedButton(
                    //   icon: Icons.keyboard,
                    //   name: "Keyboard",
                    //   color: Colors.grey,
                    //   onTap: () {
                    //     // Implement keyboard functionality
                    //   },
                    // ),
                  ],
                )),
              ],
            ),
          )),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: VoiceButton(
          onVoiceCommand: (text) {
            print("Sending voice command: $text");
            MQTTHelper.publishMessage(
                'SENDER', '{"type": "voice", "text": "$text"}');
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showVolumeBottomSheet(int _volume) {
    double _tempVolume = double.parse(_volume.toString());

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Volume",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Icon(Icons.volume_up, size: 40, color: Colors.blue),
                  Slider(
                    value: _tempVolume,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: "${_tempVolume.toInt()}%",
                    onChanged: (value) {
                      BlocProvider.of<ManualBloc>(context)
                          .add(SetVolume(value.toInt()));
                      setModalState(() {
                        _tempVolume = value;
                      });
                    },
                    onChangeEnd: (value) {
                      setState(() {
                        volume = value.toInt();
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBrightnessBottomSheet(int _brightness) {
    double _tempBrightness = double.parse(_brightness.toString());

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Brightness",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Icon(
                    Icons.brightness_6,
                    size: 40,
                    color: _brightness > 50 ? Colors.yellow : Colors.blue,
                  ),
                  Slider(
                    value: _tempBrightness,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: "${_tempBrightness.toInt()}%",
                    onChanged: (value) {
                      BlocProvider.of<ManualBloc>(context)
                          .add(SetBrightness(value.toInt()));
                      setModalState(() {
                        _tempBrightness = value;
                      });
                    },
                    onChangeEnd: (value) {
                      setState(() {
                        brightness = value.toInt();
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
