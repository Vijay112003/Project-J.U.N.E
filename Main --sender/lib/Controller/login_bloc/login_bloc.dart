import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pc_connect/Services/sharedpreference_helper.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginInitialEvent>(_onLoginInitial);
    on<UserLoginEvent>(_onUserLogin);
  }

  final String baseUrl = 'https://june-backend-fckl.onrender.com/api';

  Future<void> _onLoginInitial(LoginInitialEvent event, Emitter<LoginState> emit) async {
    if (await SharedPreferenceHelper.hasAccessToken()) {
      emit(AlreadyLoggedIn());
    } else {
      emit(NotLoggedIn());
    }
  }

  Future<void> _onUserLogin(UserLoginEvent event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    final url = Uri.parse(baseUrl+'/login'); // Replace with actual base URL

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": event.username,
          "password": event.password,
        }),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      print('Response ${response.body}');

      if (response.statusCode == 200 && jsonResponse.containsKey('token')) {
        final token = jsonResponse['token'];
        await SharedPreferenceHelper.setAccessToken(token);
        emit(LoginSuccess(message: jsonResponse["message"] ?? "Login successful"));
      } else if (response.statusCode == 400) {
        // Multiple validation errors
        if (jsonResponse.containsKey('errors')) {
          final errors = (jsonResponse['errors'] as List)
              .map((e) => e['msg'])
              .join('\n');
          emit(LoginError(message: errors));
        } else {
          // Single error case like invalid credentials
          emit(LoginError(message: jsonResponse['error'] ?? "Login failed"));
        }
      } else {
        emit(LoginError(message: "Unexpected error: ${response.statusCode}"));
      }
    } catch (e) {
      emit(LoginError(message: "An error occurred: $e"));
    }
  }
}