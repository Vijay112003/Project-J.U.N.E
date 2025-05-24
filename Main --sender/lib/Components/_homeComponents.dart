import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:mobizync/Config/text_theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../Controller/manual_bloc/manual_bloc.dart';
import '../Controller/manual_bloc/manual_event.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class RoundedButton extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;
  final GestureTapCallback onTap;

  const RoundedButton(
      {super.key,
      required this.icon,
      required this.name,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(icon, size: 30, color: color),
              ),
            ),
            SizedBox(height: 8),
            Text(
              name,
              style: MyTextTheme.normal.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}

class BatteryWidget extends StatelessWidget {
  final int batteryLevel;
  final bool isCharging;

  const BatteryWidget(
      {Key? key, required this.batteryLevel, required this.isCharging})
      : super(key: key);

  IconData _getBatteryIcon() {
    if (isCharging) {
      return HugeIcons.strokeRoundedBatteryCharging02;
    }
    if (batteryLevel >= 90) {
      return HugeIcons.strokeRoundedBatteryFull;
    } else if (batteryLevel >= 75) {
      return HugeIcons.strokeRoundedBatteryMedium02;
    } else if (batteryLevel >= 50) {
      return HugeIcons.strokeRoundedBatteryMedium01;
    } else if (batteryLevel >= 25) {
      return HugeIcons.strokeRoundedBatteryLow;
    } else {
      return HugeIcons.strokeRoundedBatteryEmpty;
    }
  }

  Color _getBatteryColor() {
    if (batteryLevel >= 50) {
      return Colors.green;
    } else if (batteryLevel >= 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getBatteryIcon(),
          color: _getBatteryColor(),
        ),
        const SizedBox(width: 5),
        Text("$batteryLevel%", style: MyTextTheme.normal),
      ],
    );
  }
}

class SyncButton extends StatelessWidget {
  final bool isSyncing;
  final bool isSynced;
  final VoidCallback? onPressed;

  const SyncButton({
    Key? key,
    required this.isSyncing,
    required this.isSynced,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: isSynced ? Colors.green : Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      icon: isSyncing
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 2.5,
              ),
            )
          : Icon(
              isSynced ? Icons.sync : Icons.sync_disabled,
              color: Colors.white,
            ),
      onPressed: isSyncing ? null : onPressed,
      tooltip: isSynced ? "Sync" : "Not Synced", // optional tooltip for clarity
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text("Confirm"),
        ),
      ],
    );
  }
}

class VoiceButton extends StatefulWidget {
  final Function(String) onVoiceCommand;

  const VoiceButton({Key? key, required this.onVoiceCommand}) : super(key: key);

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _text = "";
  bool isCaptured = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _text = "Press the mic and start speaking...";
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: CircleBorder(),
      onPressed: () => _showSpeechBottomSheet(context),
      backgroundColor: Colors.blue,
      child: const Icon(Icons.mic, size: 30, color: Colors.white),
    );
  }

  void _showSpeechBottomSheet(BuildContext context) {
    List<Color> colors = [
      Colors.lightBlueAccent,
      Colors.purpleAccent,
      Colors.blueAccent,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
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
                widthFactor: 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isCaptured ? "You Said" : _isListening ? "Listening..." : "Tap mic to speak",
                      style: MyTextTheme.headline,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _text,
                      textAlign: TextAlign.center,
                      style: MyTextTheme.normal.copyWith(
                        fontSize: 16,
                        color: _isListening ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        if (_isListening) {
                          _stopListening(setModalState);
                        } else {
                          _startListening(setModalState);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCaptured ? Colors.green : _isListening ? Colors.red : Colors.black,
                            width: 2,
                          ),
                        ),
                        child: isCaptured
                            ? IconButton(
                          onPressed: () {
                            widget.onVoiceCommand(_text);
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            HugeIcons.strokeRoundedTick03,
                            size: 40,
                            color: Colors.green,
                          ),
                        )
                            : _isListening
                            ? SpinKitThreeInOut(
                          itemBuilder: (_, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors[index % colors.length],
                              ),
                            );
                          },
                        )
                            : Icon(
                          _isListening ? HugeIcons.strokeRoundedMic01 : HugeIcons.strokeRoundedMicOff01,
                          size: 40,
                          color: _isListening ? Colors.red : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        _stopListening(setModalState);
                        Navigator.pop(context); // <-- Close bottom sheet
                      },
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Reset state after bottom sheet is dismissed
      setState(() {
        _text = "Press the mic and start speaking...";
        _isListening = false;
        isCaptured = false;
      });
    });
  }

  void _startListening(Function setModalState) async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech Status: $status");
        if (status == "done" || status == "notListening") {
          setModalState(() => _isListening = false);
        }
      },
      onError: (error) {
        print("Speech Error: ${error.errorMsg}");
        setModalState(() {
          _text = "Couldn't recognize speech. Please try again!";
          _isListening = false;
        });
      },
    );

    if (available && !_isListening) {
      setModalState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setModalState(() {
            _text = result.recognizedWords;
          });

          if (result.finalResult) {
            setModalState(() {
              _isListening = false;
              isCaptured = true;
              _text = result.recognizedWords;
            });
            _stopListening(setModalState); // auto-stop after result
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 5),
      );
    } else {
      setModalState(() {
        _text = "Speech recognition not available or permission denied.";
        _isListening = false;
      });
    }
  }

  void _stopListening(Function setModalState) {
    _speech.stop();
    setModalState(() => _isListening = false);
  }
}

class TrackPadWidget extends StatefulWidget {
  const TrackPadWidget({super.key});

  @override
  State<TrackPadWidget> createState() => _TrackPadWidgetState();
}

class _TrackPadWidgetState extends State<TrackPadWidget> {
  Offset? previousPosition;
  DateTime? lastTime;

  void _handlePointerMove(PointerMoveEvent event) {
    final currentPosition = event.localPosition;
    final currentTime = DateTime.now();

    final dx = currentPosition.dx - (previousPosition?.dx ?? currentPosition.dx);
    final dy = currentPosition.dy - (previousPosition?.dy ?? currentPosition.dy);
    final duration = currentTime.difference(lastTime ?? currentTime).inMilliseconds;

    final distance = sqrt(dx * dx + dy * dy);
    final speed = duration > 0 ? distance / duration : 0;

    previousPosition = currentPosition;
    lastTime = currentTime;

    const multiplier = 4.0;
    int dxInt = (dx * multiplier).toInt();
    int dyInt = (dy * multiplier).toInt();
    int speedInt = speed.toInt();

    BlocProvider.of<ManualBloc>(context).add(MoveMouse(dxInt, dyInt, speedInt));
  }

  void _handlePointerDown(PointerDownEvent event) {
    previousPosition = event.localPosition;
    lastTime = DateTime.now();
  }

  void _onTap() {
    BlocProvider.of<ManualBloc>(context).add(MouseClick('left_click'));
  }

  void _onSecondaryTap() {
    BlocProvider.of<ManualBloc>(context).add(MouseClick('right_click'));
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Listener(
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        child: GestureDetector(
          onTap: _onTap,
          onSecondaryTap: _onSecondaryTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                'TrackPad',
                textAlign: TextAlign.center,
                style: MyTextTheme.normal.copyWith(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCircularSlider extends StatelessWidget {
  final double min;
  final double max;
  final double initialValue;
  final ValueChanged<double>? onChange;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final bool isSpinner;
  final Widget Function(double)? innerWidget;

  const CustomCircularSlider({
    Key? key,
    this.min = 0,
    this.max = 100,
    this.initialValue = 50,
    this.onChange,
    this.onChangeStart,
    this.onChangeEnd,
    this.isSpinner = false,
    this.innerWidget,
  })  : assert(min <= max),
        assert(initialValue >= min && initialValue <= max),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SleekCircularSlider(
      min: min,
      max: max,
      initialValue: initialValue,
      onChange: onChange,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      innerWidget: innerWidget,
      appearance: CircularSliderAppearance(
        size: 200,
        spinnerMode: isSpinner,
        animationEnabled: false,
        angleRange: 270,
        startAngle: 135,
        customWidths: CustomSliderWidths(
          progressBarWidth: 8,
          trackWidth: 2,
          shadowWidth: 10,
          handlerSize: 15,
        ),
        customColors: CustomSliderColors(
          progressBarColors: [Colors.orangeAccent, Colors.yellow , Colors.grey, Colors.black],
          trackColor: Colors.grey.withOpacity(0.3),
          dotColor: Colors.grey,
          shadowColor: Colors.black,
          shadowMaxOpacity: 0.1,
        ),
        infoProperties: InfoProperties(
          mainLabelStyle: MyTextTheme.normal.copyWith(color: Colors.transparent),
          modifier: (double value) {
            return '${value.toStringAsFixed(0)}';
          },
        ),
      ),
    );
  }
}

class LiquidBatteryIndicator extends StatelessWidget {
  final double batteryLevel; // Value between 0.0 and 1.0

  const LiquidBatteryIndicator({Key? key, required this.batteryLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fillColor = _getBatteryColor(batteryLevel);

    return Container(
      height: 50,
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Fluid battery container
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: SizedBox(
              width: 300,
              child: LiquidLinearProgressIndicator(
                value: batteryLevel,
                valueColor: AlwaysStoppedAnimation(fillColor),
                backgroundColor: Colors.grey[300],
                borderColor: Colors.black,
                borderWidth: 2.0,
                borderRadius: 16.0,
                direction: Axis.horizontal,
                center: Text(
                  '${(batteryLevel * 100).toInt()}%',
                  style: MyTextTheme.headline
                ),
              ),
            ),
          ),
          // Battery terminal
          Positioned(
            right: -6,
            top: 10,
            child: Container(
              width: 12,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(double level) {
    if (level < 0.2) return Colors.redAccent;
    if (level < 0.5) return Colors.orangeAccent;
    return Colors.lightGreenAccent.shade700;
  }
}

class MasterVolumeSlider extends StatefulWidget {
  final int volume;
  const MasterVolumeSlider({super.key, required this.volume});

  @override
  State<MasterVolumeSlider> createState() => _MasterVolumeSliderState();
}

class _MasterVolumeSliderState extends State<MasterVolumeSlider> {
  late double _volume;

  @override
  void initState() {
    super.initState();
    _volume = widget.volume.toDouble();
  }

  Color _getThumbColor(double value) {
    if (value < 40) return Colors.green;
    if (value < 75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Track background with gradient
          Container(
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.orange, Colors.red],
              ),
            ),
          ),
          // Slider lever
          Positioned.fill(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackShape: const RectangularSliderTrackShape(),
                trackHeight: 20,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.transparent,
                thumbShape: SliderComponentShape.noThumb,
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: _volume,
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                  });
                  BlocProvider.of<ManualBloc>(context).add(SetVolume(value.toInt()));
                },
              ),
            ),
          ),
          // Lever thumb as a custom widget
          Positioned(
            left: _volume * 2.5,
            top: 17,
            child: Container(
              width: 12,
              height: 60,
              decoration: BoxDecoration(
                color:Colors.black,
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    offset: Offset(1, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
