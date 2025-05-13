
abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class AlreadyLoggedIn extends LoginState {
  const AlreadyLoggedIn();
}

class NotLoggedIn extends LoginState {
  const NotLoggedIn();
}

class LoginSuccess extends LoginState {
  final String message;

  const LoginSuccess({required this.message});
}

class LoginError extends LoginState {
  final String message;

  const LoginError({required this.message});
}