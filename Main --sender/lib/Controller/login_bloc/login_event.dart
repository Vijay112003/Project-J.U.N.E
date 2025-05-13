
abstract class LoginEvent {}

class LoginInitialEvent extends LoginEvent {}

class UserLoginEvent extends LoginEvent {
  final String username;
  final String password;

  UserLoginEvent({required this.username, required this.password});
}