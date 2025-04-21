import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pc_connect/Config/text_theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../Controller/manual_bloc/manual_bloc.dart';
import '../Controller/manual_bloc/manual_event.dart';

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
  final void Function(Map<String, dynamic> data)? onGesture;

  const TrackPadWidget({super.key, this.onGesture});

  @override
  State<TrackPadWidget> createState() => _TrackPadWidgetState();
}

class _TrackPadWidgetState extends State<TrackPadWidget> {
  Offset? previousPosition;
  DateTime? lastTime;

  void _onPanStart(DragStartDetails details) {
    previousPosition = details.localPosition;
    lastTime = DateTime.now();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final currentPosition = details.localPosition;
    final currentTime = DateTime.now();

    final dx = currentPosition.dx - (previousPosition?.dx ?? 0);
    final dy = currentPosition.dy - (previousPosition?.dy ?? 0);
    final duration =
        currentTime.difference(lastTime ?? currentTime).inMilliseconds;
    final distance = sqrt(dx * dx + dy * dy);
    final speed = duration > 0 ? distance / duration : 0;

    previousPosition = currentPosition;
    lastTime = currentTime;

    final data = {
      'dx': dx,
      'dy': dy,
      'speed': speed,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    if (widget.onGesture != null) {
      widget.onGesture!(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Square shape
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text('TrackPad',
                textAlign: TextAlign.center,
                style: MyTextTheme.normal.copyWith(
                  fontSize: 14,
                  color: Colors.black54,
                )),
          ),
        ),
      ),
    );
  }
}
