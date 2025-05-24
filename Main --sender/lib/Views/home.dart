import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobizync/Components/_homeComponents.dart';
import 'package:mobizync/Config/text_theme.dart';
import 'package:mobizync/Controller/manual_bloc/manual_bloc.dart';
import 'package:mobizync/Controller/manual_bloc/manual_event.dart';
import 'package:mobizync/Controller/websocket_bloc/websocket_bloc.dart';
import 'package:mobizync/Controller/websocket_bloc/websocket_event.dart';
import 'package:mobizync/Controller/websocket_bloc/websocket_state.dart';
import 'package:mobizync/Models/home_models.dart';
import 'package:mobizync/Services/websocket_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Models/status_model.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late stt.SpeechToText _speech;
  String _text = "Press the mic and start speaking...";
  bool _isListening = false;
  bool _isSyncing = false;

  StatusInfo? _statusInfo;

  int brightness = 50;
  int volume = 50;

  List<AppWidgetModel> apps = [
    AppWidgetModel(
        name: "Google Chrome",
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSBFJYG6Wdb7DawiV0gfkfaCW4tinaEh0VCVg&s",
        command: "chrome"),
    AppWidgetModel(
        name: "Microsoft Edge",
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-Qzo1NiAsyBBGSyF7nZvKPBuPX_EaXTAFdg&s",
        command: "edge"),
    AppWidgetModel(
        name: "Microsoft Word",
        image:
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzw4zM8bYkbqu4rxIuBXcIq1vIZKSC6LIyAg&s",
        command: "word"),
    AppWidgetModel(
        name: "Microsoft Excel",
        image:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Microsoft_Office_Excel_%282019%E2%80%93present%29.svg/1200px-Microsoft_Office_Excel_%282019%E2%80%93present%29.svg.png",
        command: "excel"),
  ];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ManualBloc>(context).add(SyncButtonPressed());
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MY PC', style: MyTextTheme.headline),
        actions: [
          // Wifi Section
          if (_statusInfo?.wifi ?? false)
            Icon(HugeIcons.strokeRoundedWifi01, color: Colors.green),
          if (_statusInfo?.wifi == false)
            Icon(HugeIcons.strokeRoundedWifiOff01, color: Colors.red),
          SizedBox(width: 10),

          // Bluetooth Section
          if (_statusInfo?.bluetooth ?? false)
            Icon(HugeIcons.strokeRoundedBluetooth, color: Colors.green),
          if (_statusInfo?.bluetooth == false)
            Icon(HugeIcons.strokeRoundedBluetoothNotConnected,
                color: Colors.red),
          SizedBox(width: 10),

          // Battery Section
          if (_statusInfo?.battery != null)
            BatteryWidget(
                batteryLevel: _statusInfo?.battery ?? 50,
                isCharging: _statusInfo?.power == "Charging"),
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
      body: BlocListener<WebSocketBloc, WebSocketState>(
        listener: (context, state) {
          if (state is WebSocketConnected) {
            BlocProvider.of<WebSocketBloc>(context)
                .add(WebSocketStartListening());
            BlocProvider.of<ManualBloc>(context).add(SyncButtonPressed());
            setState(() {
              _isSyncing = true; // Set syncing status
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Connected to WebSocket"),
                duration: Duration(seconds: 2),
              ),
            );
          }
          if (state is WebSocketMessageReceived) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Message received: ${state.message}"),
                duration: Duration(seconds: 2),
              ),
            );
          }
          if (state is WebSocketStatusReceived) {
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // _buildTopButtons(),
                SizedBox(height: 5),
                _buildPowerandLock(),
                SizedBox(height: 5),
                _buildBrightnessSlider(),
                SizedBox(height: 5),
                _buildVolumeSlider(),
                SizedBox(height: 5),
                _buildAppCarousel(apps),
                // _buildMouseArea()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPowerandLock() {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            content: "Are you sure you want to power off?",
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
            ],
          ),
          SizedBox(height: 5),
          Text("Power Options", style: MyTextTheme.normal)
        ],
      ),
    );
  }

  Widget _buildBrightnessSlider() {
    IconData icon(int value) {
      if (value < 20) {
        return Icons.lightbulb_outline;
      } else if (value < 50) {
        return Icons.lightbulb;
      } else {
        return Icons.lightbulb;
      }
    }

    Color glowColor(int value) {
      if (value < 20) return Colors.grey;
      if (value < 50) return Colors.yellow.withOpacity(0.5);
      return Colors.yellowAccent;
    }

    double glowOpacity(int value) => (value / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Glowing Bulb Icon
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: glowColor(brightness),
                          blurRadius:
                              30 * glowOpacity(brightness), // Intensity of glow
                          spreadRadius: 5 * glowOpacity(brightness),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon(brightness),
                      size: 50,
                      color:
                          brightness < 20 ? Colors.grey : Colors.orangeAccent,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "${brightness.toInt()}%",
                    style: MyTextTheme.subheading,
                  ),
                ],
              ),

              // Circular Slider
              CustomCircularSlider(
                min: 0,
                max: 100,
                initialValue: brightness.toDouble(),
                onChangeEnd: (value) {
                  setState(() {
                    brightness = value.toInt();
                  });
                  BlocProvider.of<ManualBloc>(context)
                      .add(SetBrightness(value.toInt()));
                },
              ),
            ],
          ),
          SizedBox(height: 5),
          Text("Brightness Options", style: MyTextTheme.normal),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(HugeIcons.strokeRoundedVolumeMinus),
              SizedBox(width: 5),
              Expanded(
                child: MasterVolumeSlider(volume: volume),
              ),
              SizedBox(width: 5),
              Icon(HugeIcons.strokeRoundedVolumeUp)
            ],
          ),
          SizedBox(height: 5),
          Text(
            "Volume Options",
            style: MyTextTheme.normal,
          ),
        ],
      ),
    );
  }

  Widget _buildAppCarousel(List<AppWidgetModel> appsData) {
    return CarouselSlider(
      items: appsData.map((app) => _buildAppButton(app)).toList(),
      options: CarouselOptions(
        height: 120, // slightly increased to avoid clipping
        autoPlay: false,
        viewportFraction: 0.35,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        aspectRatio: 1.5,
        initialPage: (appsData.length / 2).toInt(),
      ),
    );
  }

  Widget _buildAppButton(AppWidgetModel app) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          BlocProvider.of<ManualBloc>(context)
              .add(ApplicationLaunch(app.command));
        },
        child: Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Image.network(
                  app.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, size: 50),
                ),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: Text(
                  app.name,
                  style: MyTextTheme.normal,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMouseArea() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          TrackPadWidget(),
          SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    maximumSize: Size(100, 50),
                    minimumSize: Size(100, 50),
                  ),
                  onPressed: () {
                    // BlocProvider.of<ManualBloc>(context)
                    //     .add(ClickMouse());
                  },
                  child: Text("left",
                      style:
                          MyTextTheme.subheading.copyWith(color: Colors.white)),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    maximumSize: Size(100, 50),
                    minimumSize: Size(100, 50),
                  ),
                  onPressed: () {
                    // BlocProvider.of<ManualBloc>(context)
                    //     .add(ClickMouse());
                  },
                  child: Text("right",
                      style:
                          MyTextTheme.subheading.copyWith(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
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
