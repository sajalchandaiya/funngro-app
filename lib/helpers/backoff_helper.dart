import 'dart:math';

class BackoffHelper {
  int attempt = 0;
  int _seconds = 1;

  Duration next() {
    final delay = Duration(seconds: _seconds);
    _seconds = min(_seconds * 2, 30);
    attempt++;
    return delay;
  }

  void reset() {
    attempt = 0;
    _seconds = 1;
  }
}
