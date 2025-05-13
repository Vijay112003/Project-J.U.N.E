import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pc_connect/Components/bottom_nav_bar.dart';
import 'package:pc_connect/Components/custom_text_field.dart';
import 'package:pc_connect/Config/text_theme.dart';
import 'package:pc_connect/Controller/login_bloc/login_bloc.dart';
import 'package:pc_connect/Controller/login_bloc/login_event.dart';
import 'package:pc_connect/Controller/login_bloc/login_state.dart';
import 'package:pc_connect/Views/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              if(state is LoginSuccess) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => BottomNavBar()));
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("UserName"),
                  CustomTextField(
                      label: "Enter your username",
                      controller: usernameController
                  ),
                  SizedBox(height: 10),
                  Text("Password"),
                  CustomTextField(
                      label: "Enter your password",
                      controller: passwordController
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<LoginBloc>(context).add(
                            UserLoginEvent(
                              username: usernameController.text,
                              password: passwordController.text,
                            ),
                          );
                        },
                        child: Text("Login", style: MyTextTheme.normal)
                    ),
                  )
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}
