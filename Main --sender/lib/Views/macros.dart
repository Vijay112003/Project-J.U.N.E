import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobizync/Config/text_theme.dart';
import 'package:mobizync/Controller/macro_bloc/macro_bloc.dart';
import 'package:mobizync/Controller/macro_bloc/macro_event.dart';
import 'package:mobizync/Controller/websocket_bloc/websocket_bloc.dart';
import 'package:mobizync/Controller/websocket_bloc/websocket_state.dart';
import 'package:mobizync/Models/macro_models.dart';
import 'package:mobizync/main.dart';

class Macros extends StatefulWidget {
  const Macros({super.key});

  @override
  State<Macros> createState() => _MacrosState();
}

class _MacrosState extends State<Macros> with RouteAware {
  List<MacroModel> _macros = [];
  String? _runningMacroName;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<MacroBloc>(context).add(RequestMacros());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this page
    BlocProvider.of<MacroBloc>(context).add(RequestMacros());
  }

  void _handleStart(String macroName, String jsonPath) {
    if (_runningMacroName != null && _runningMacroName != macroName) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Another macro "${_runningMacroName!}" is already running. Stop it first.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    BlocProvider.of<MacroBloc>(context).add(RunMacro(jsonPath));

    setState(() {
      _runningMacroName = macroName;
    });
  }

  void _handleStop() {
    setState(() {
      _runningMacroName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Macros', style: MyTextTheme.headline),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocConsumer<WebSocketBloc, WebSocketState>(
          listener: (context, state) {
            if (state is WebSocketMacrosReceived) {
              setState(() {
                _macros = state.macros;
              });
            } else if (state is WebSocketMacrosEnded) {
              print("Macro ended: ${state.macroName}");
              setState(() {
                _runningMacroName = null;
              });
            }
          },
          builder: (context, state) {
            if (state is WebSocketMacrosReceived && _macros.isNotEmpty) {
              return ListView.builder(
                itemCount: _macros.length,
                itemBuilder: (context, index) {
                  final macro = _macros[index];
                  final isRunning = _runningMacroName == macro.macroName;

                  return MacroCard(
                    macroName: macro.macroName,
                    description: macro.description,
                    isRunning: isRunning,
                    onStart: () => _handleStart(macro.macroName, macro.macroPath),
                    onStop: _handleStop,
                  );
                },
              );
            } else if (state is WebSocketError) {
              return Center(child: Text("Error: ${state.error}"));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class MacroCard extends StatefulWidget {
  final String macroName;
  final String description;
  final bool isRunning;
  final VoidCallback? onStart;
  final VoidCallback? onStop;

  const MacroCard({
    Key? key,
    required this.macroName,
    required this.description,
    required this.isRunning,
    this.onStart,
    this.onStop,
  }) : super(key: key);

  @override
  State<MacroCard> createState() => _MacroCardState();
}

class _MacroCardState extends State<MacroCard> {
  double startX = 0;
  double swipeDistance = 0;
  bool isAnimating = false;

  void handleToggle() {
    if (widget.isRunning) {
      widget.onStop?.call();
    } else {
      widget.onStart?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        startX = details.globalPosition.dx;
      },
      onHorizontalDragUpdate: (details) {
        final currentX = details.globalPosition.dx;
        final distance = currentX - startX;
        if (distance > 0 && distance < 200) {
          setState(() {
            swipeDistance = distance;
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (swipeDistance > 100) {
          handleToggle();
        }

        setState(() {
          isAnimating = true;
          swipeDistance = 0;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            isAnimating = false;
          });
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(swipeDistance, 0, 0),
        curve: Curves.easeOut,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.macroName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Swipe to ${widget.isRunning ? 'stop' : 'start'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
