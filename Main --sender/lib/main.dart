import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pc_connect/Controller/manual_bloc/manual_bloc.dart';
import 'package:pc_connect/Controller/mqtt_bloc/mqtt_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Components/bottom_nav_bar.dart';

Future<void> requestMicrophonePermission() async {
  var status = await Permission.microphone.request();
  if (status.isGranted) {
    print("Microphone permission granted");
  } else {
    print("Microphone permission denied");
  }
}

void main() {
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (_) => MQTTBloc()),
    BlocProvider(create: (_) => ManualBloc())
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Power Button App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BottomNavBar());
  }
}
