import 'package:flutter/material.dart';

class SessionProvider with ChangeNotifier {
  String? _currentRole;

  String? get currentRole => _currentRole;

  void setRole(String? role) {
    _currentRole = role;
    notifyListeners();
  }
}
