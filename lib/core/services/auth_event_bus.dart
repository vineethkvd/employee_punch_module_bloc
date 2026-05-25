import 'dart:async';

enum AuthEvent { sessionExpired }

class AuthEventBus {
  final _authEventController = StreamController<AuthEvent>.broadcast();
  Stream<AuthEvent> get authStream => _authEventController.stream;

  void emitSessionExpired() {
    _authEventController.add(AuthEvent.sessionExpired);
  }

  void dispose() {
    _authEventController.close();
  }
}
