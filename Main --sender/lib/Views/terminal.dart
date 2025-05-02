import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:pc_connect/Config/text_theme.dart';
import 'package:pc_connect/Controller/mqtt_bloc/mqtt_bloc.dart';
import 'package:pc_connect/Controller/mqtt_bloc/mqtt_state.dart';
import 'package:pc_connect/Controller/terminal_bloc/terminal_bloc.dart';
import 'package:pc_connect/Controller/terminal_bloc/terminal_event.dart';
import 'package:pc_connect/Controller/terminal_bloc/terminal_state.dart';

class Terminal extends StatefulWidget {
  const Terminal({super.key});

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _terminalLines = [];
  bool _cursorVisible = true;
  late Timer _cursorTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Blinking cursor
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _cursorVisible = !_cursorVisible;
      });
    });

    // Autofocus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _cursorTimer.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _executeCommand(String command) {
    if (command.trim().isEmpty) return;

    BlocProvider.of<TerminalBloc>(context)
        .add(TerminalSendCommandEvent(command));

    setState(() {
      _terminalLines.add("> $command"); // Command prompt
    });

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "> ",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Courier',
              fontSize: 14,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Courier',
                fontSize: 14,
              ),
              cursorColor: Colors.greenAccent,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: _cursorVisible ? "_" : " ",
                hintStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier',
                ),
              ),
              onSubmitted: _executeCommand,
              autofocus: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Terminal >",
          style: MyTextTheme.headline.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () {
                setState(() {
                  _terminalLines.clear();
                });
                _controller.clear();
                FocusScope.of(context).requestFocus(_focusNode);
              },
              child: Text(
                "CLEAR",
                style: MyTextTheme.normal.copyWith(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_focusNode),
        child: SafeArea(
          child: BlocListener<MQTTBloc, MQTTState>(
            listener: (context, state) {
              if (state is MQTTTerminalReceived) {
                setState(() {
                  _terminalLines.add(state.terminalOutput); // Output
                  _terminalLines.add(""); // Blank line for spacing
                });
                _scrollToBottom();
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: _terminalLines.length + 1, // For live prompt
                    itemBuilder: (context, index) {
                      if (index < _terminalLines.length) {
                        return Text(
                          _terminalLines[index],
                          style: MyTextTheme.normal.copyWith(
                            color: Colors.white,
                            fontFamily: 'Courier',
                          ),
                        );
                      } else {
                        return _buildInputArea(); // Current prompt
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
