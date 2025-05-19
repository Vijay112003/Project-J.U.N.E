import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobizync/Components/bottom_nav_bar.dart';
import 'package:mobizync/Components/custom_text_field.dart';
import 'package:mobizync/Config/text_theme.dart';
import 'package:mobizync/Controller/login_bloc/login_bloc.dart';
import 'package:mobizync/Controller/login_bloc/login_event.dart';
import 'package:mobizync/Controller/login_bloc/login_state.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF8349FF),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Color(0xFFFC9150),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: BlocConsumer<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginSuccess) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => BottomNavBar()),
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          "Welcome Back!",
                          style: MyTextTheme.headline.copyWith(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Text("Username", style: MyTextTheme.normal.copyWith(color: Colors.white)),
                      const SizedBox(height: 6),
                      CustomTextField(
                        label: "Enter your username",
                        controller: usernameController,
                      ),

                      const SizedBox(height: 16),
                      Text("Password", style: MyTextTheme.normal.copyWith(color: Colors.white)),
                      const SizedBox(height: 6),
                      CustomTextField(
                        label: "Enter your password",
                        controller: passwordController,
                      ),

                      const SizedBox(height: 30),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: MyTextTheme.normal.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          BlocProvider.of<LoginBloc>(context).add(
                            UserLoginEvent(
                              username: usernameController.text.trim(),
                              password: passwordController.text.trim(),
                            ),
                          );
                        },
                        child: Text("Login", style: MyTextTheme.headline.copyWith(color: Colors.white)),
                      ),

                      if (state is LoginLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
