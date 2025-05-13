import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pc_connect/Components/bottom_nav_bar.dart';
import 'package:pc_connect/Config/text_theme.dart';
import 'package:pc_connect/Controller/login_bloc/login_bloc.dart';
import 'package:pc_connect/Controller/login_bloc/login_state.dart';
import 'package:pc_connect/Controller/login_bloc/login_event.dart';
import 'package:pc_connect/Views/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      BlocProvider.of<LoginBloc>(context).add(LoginInitialEvent());
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is AlreadyLoggedIn) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => BottomNavBar()), // Replace with actual homepage
            );
          } else if (state is NotLoggedIn) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/ld_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpinKitCircle(
                    color: Colors.blue,
                    size: 20.0,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: MyTextTheme.body.copyWith(fontSize: 12),
                      children: [
                        TextSpan(
                          text: 'Powered by ',
                          style: MyTextTheme.body.copyWith(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/ld_logo.png",
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lightning Developers',
                        style: MyTextTheme.body.copyWith(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
