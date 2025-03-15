import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pc_connect/Controller/manual_bloc/manual_bloc.dart';
import 'package:pc_connect/Controller/manual_bloc/manual_event.dart';
import 'package:pc_connect/Controller/mqtt_bloc/mqtt_bloc.dart';
import 'package:pc_connect/Controller/mqtt_bloc/mqtt_event.dart';
import 'package:pc_connect/Controller/mqtt_bloc/mqtt_state.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late stt.SpeechToText _speech;
  String _text = "Press the mic and start speaking...";
  bool _isListening = false;

  final List<Map<String, dynamic>> icons = [
    {
      'icon': FontAwesomeIcons.powerOff,
      'name': 'Power On',
      'color': Colors.green
    },
    {'icon': Icons.lock, 'name': 'Lock', 'color': Colors.green},
    // {'icon': Icons.camera, 'name': 'Camera', 'color': Colors.green},
    {'icon': Icons.bluetooth, 'name': 'Bluetooth', 'color': Colors.green},
    {'icon': Icons.wifi, 'name': 'Wi-Fi', 'color': Colors.green},
    {'icon': Icons.volume_up, 'name': 'Volume', 'color': Colors.green},
    {'icon': Icons.mic_off, 'name': 'Mute', 'color': Colors.green},
    // {'icon': Icons.light_mode, 'name': 'Light Mode', 'color': Colors.green},
    // {'icon': Icons.dark_mode, 'name': 'Dark Mode', 'color': Colors.green},
    {'icon': Icons.brightness_6, 'name': 'Brightness', 'color': Colors.green},
    {'icon': Icons.apps, 'name': 'Apps', 'color': Colors.green},
    {'icon': Icons.mouse_outlined, 'name': 'Touch Pad', 'color': Colors.green},
    {'icon': Icons.keyboard, 'name': 'Keyboard', 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MQTTBloc>(context).add(MQTTConnect());
    _speech = stt.SpeechToText();
  }

  void _showSpeechBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.95, // Ensuring it covers 95% of the width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isListening ? "Listening..." : "Tap mic to speak",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _text,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _isListening ? Colors.red : Colors.black,
                            width: 2),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_off,
                          size: 40,
                          color: _isListening ? Colors.red : Colors.black,
                        ),
                        onPressed: () {
                          if (_isListening) {
                            _stopListening(setModalState);
                          } else {
                            _startListening(setModalState);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        _stopListening(setModalState);
                        Navigator.pop(context);
                      },
                      child: Text("Close"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startListening(Function setModalState) async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done") {
          setModalState(() => _isListening = false);
        }
      },
      onError: (error) => print("Speech error: $error"),
    );

    if (available) {
      setModalState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setModalState(() {
            _text = result.recognizedWords;
          });
        },
      );
    } else {
      print("Speech not recognized.");
    }
  }

  void _stopListening(Function setModalState) {
    _speech.stop();
    setModalState(() => _isListening = false);
  }

  double _volume = 50;
  double _brightness = 50; // Initial volume level

  void _showVolumeBottomSheet() {
    double _tempVolume =
        _volume; // Temporary variable to update within bottom sheet

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // StatefulBuilder to update UI in bottom sheet
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
                      setModalState(() {
                        // Updates the slider in the bottom sheet
                        _tempVolume = value;
                      });
                    },
                    onChangeEnd: (value) {
                      // Save value when slider is released
                      setState(() {
                        _volume = value;
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

  void _showBrightnessBottomSheet() {
    double _tempBrightness =
        _brightness; // Temporary variable to update within bottom sheet

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // StatefulBuilder to update UI in bottom sheet
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
                      print("IN CALLER $value");
                      BlocProvider.of<ManualBloc>(context).add(SetBrightness(value.toInt()));
                      setModalState(() {
                        // Updates the slider in the bottom sheet
                        _tempBrightness = value;
                      });
                    },
                    onChangeEnd: (value) {
                      // Save value when slider is released
                      setState(() {
                        _brightness = value;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: const [
          Row(
            children: [
              Icon(FontAwesomeIcons.batteryFull, color: Colors.green),
              // Battery Icon
              SizedBox(width: 5),
              // Spacing
              Text("85%", style: TextStyle(fontSize: 16)),
              // Dummy battery percentage
              SizedBox(width: 10),
              // Right padding
            ],
          ),
        ],
      ),
      body: BlocListener<MQTTBloc, MQTTState>(
          listener: (context, state) {
            if (state is MQTTConnected) {
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
                  content: Text("Message: ${state.message}"),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 3
                        : 5,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (icons[index]['name'] == 'Volume') {
                      _showVolumeBottomSheet();
                    } else if (icons[index]['name'] == 'Brightness') {
                      _showBrightnessBottomSheet();
                    }
                  },
                  child: SizedBox(
                    // Ensures it doesn't overflow
                    width: 90, // Adjust width as per your UI
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // Prevents extra space issues
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              icons[index]['icon'] as IconData,
                              size: 40,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          icons[index]['name'] as String,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          textAlign: TextAlign.center,
                          maxLines: 2, // Allows wrapping if needed
                          overflow: TextOverflow
                              .visible, // Ensures text is always shown
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            onPressed: _showSpeechBottomSheet,
            backgroundColor: Colors.blue,
            child: const Icon(
              Icons.mic,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
