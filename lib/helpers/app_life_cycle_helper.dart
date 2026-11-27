import 'package:flutter/widgets.dart';

class AppLifecycleHelper {
  AppLifecycleHelper({required this.onBackground, required this.onForeground}) {
    _listener = AppLifecycleListener(onHide: _handleHide, onShow: _handleShow);
  }

  final VoidCallback onBackground;

  final void Function(Duration timeAway) onForeground;

  late final AppLifecycleListener _listener;
  DateTime? _hiddenAt;

  void _handleHide() {
    if (_hiddenAt != null) return;
    _hiddenAt = DateTime.now();
    onBackground();
  }

  void _handleShow() {
    final hiddenAt = _hiddenAt;
    if (hiddenAt == null) return;
    _hiddenAt = null;
    onForeground(DateTime.now().difference(hiddenAt));
  }

  void dispose() => _listener.dispose();
}
