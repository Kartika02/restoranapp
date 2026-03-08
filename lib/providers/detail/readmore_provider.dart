import 'package:flutter/material.dart';

class ReadMoreProvider extends ChangeNotifier {
  bool _expanded = false;

  bool get expanded => _expanded;

  void toggleExpanded() {
    _expanded = !_expanded;
    notifyListeners();
  }
}