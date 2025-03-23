import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../Controller/manual_bloc/manual_bloc.dart';
import '../Controller/manual_bloc/manual_event.dart';

class RoundedButton extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;
  final GestureTapCallback onTap;

  const RoundedButton({super.key, required this.icon, required this.name, required this.color, required this.onTap});

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
                child: Icon(
                    icon,
                    size: 40,
                    color: color
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(fontSize: 14, color: Colors.black),
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

  const BatteryWidget({Key? key, required this.batteryLevel}) : super(key: key);

  IconData _getBatteryIcon() {
    if (batteryLevel >= 90) {
      return FontAwesomeIcons.batteryFull;
    } else if (batteryLevel >= 75) {
      return FontAwesomeIcons.batteryThreeQuarters;
    } else if (batteryLevel >= 50) {
      return FontAwesomeIcons.batteryHalf;
    } else if (batteryLevel >= 25) {
      return FontAwesomeIcons.batteryQuarter;
    } else {
      return FontAwesomeIcons.batteryEmpty;
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
        Text(
          "$batteryLevel%",
          style: const TextStyle(fontSize: 16),
        ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: isSynced ? Colors.blue : Colors.red),
          onPressed: isSyncing ? null : onPressed,  // Disable button while syncing
          child: isSyncing
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.5,
            ),
          )
              : Text(
              isSynced ? "sync" : "not synced",
              style: TextStyle(color: Colors.white)
          ),
        ),
      ],
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
  late stt.SpeechToText _speech;
  String _text = "Press the mic and start speaking...";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showSpeechBottomSheet(context),
      backgroundColor: Colors.blue,
      child: const Icon(
        Icons.mic,
        size: 30,
        color: Colors.white,
      ),
    );
  }

  void _showSpeechBottomSheet(BuildContext context) {
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
                      _isListening ? "Listening..." : "Tap mic to speak",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isListening ? Colors.red : Colors.black,
                          width: 2,
                        ),
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
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        _stopListening(setModalState);
                        Navigator.pop(context);
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
    );
  }

  void _startListening(Function setModalState) async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech Status: $status");
        if (status == "done" || status == "notListening") {
          setModalState(() {
            _isListening = false;
          });
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

    if (available) {
      setModalState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setModalState(() {
              _text = result.recognizedWords;
            });
            widget.onVoiceCommand(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 10), // Extend listening duration
        pauseFor: const Duration(seconds: 2),
        cancelOnError: false,
        partialResults: true, // Enable partial results
      );
    } else {
      setModalState(() {
        _text = "Speech recognition not available.";
        _isListening = false;
      });
    }
  }

  void _stopListening(Function setModalState) {
    _speech.stop();
    setModalState(() => _isListening = false);
  }
}