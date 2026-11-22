import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final StorageService _s;
  ProfileViewModel(this._s);

  String get name => _s.name;
  String? get field => _s.field;

  Future<void> setName(String v) async {
    await _s.setName(v.trim());
    notifyListeners();
  }

  Future<void> setField(String v) async {
    await _s.setField(v);
    notifyListeners();
  }
}
