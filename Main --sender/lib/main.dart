import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pc_connect/Controller/macro_bloc/macro_bloc.dart';
import 'package:pc_connect/Controller/manual_bloc/manual_bloc.dart';
import 'package:pc_connect/Controller/terminal_bloc/terminal_bloc.dart';
import 'package:pc_connect/Controller/websocket_bloc/websocket_bloc.dart';
import 'package:pc_connect/Controller/websocket_bloc/websocket_event.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Components/bottom_nav_bar.dart';
import 'Services/app_bloc_observer.dart';

Future<void> requestMicrophonePermission() async {
  var status = await Permission.microphone.request();
  if (status.isGranted) {
    print("Microphone permission granted");
  } else {
    print("Microphone permission denied");
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  requestMicrophonePermission();
  Bloc.observer = AppBlocObserver();  // Ensure this observer is set
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (_) => WebSocketBloc()..add(WebSocketConnect())),
    BlocProvider(create: (_) => ManualBloc()),
    BlocProvider(create: (_) => MacroBloc()),
    BlocProvider(create: (_) => TerminalBloc()),
  ], child: MyApp()));
}

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorObservers: [routeObserver],
        debugShowCheckedModeBanner: false,
        title: 'Power Button App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BottomNavBar());
  }
}
