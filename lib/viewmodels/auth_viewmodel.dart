import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

/// Şimdilik basit giriş: kullanıcı adı + şifre boş olmamalı.
/// TODO: E-posta ile giriş (ör. Firebase Auth) daha sonra buraya eklenecek.
class AuthViewModel extends ChangeNotifier {
  final StorageService _s;
  AuthViewModel(this._s);

  bool get isLoggedIn => _s.loggedIn;

  /// Hata varsa mesaj döner, başarılıysa null.
  Future<String?> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      return 'Kullanıcı adı ve şifre boş olamaz.';
    }
    if (_s.name.isEmpty) await _s.setName(username.trim());
    await _s.setLoggedIn(true);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await _s.setLoggedIn(false);
    notifyListeners();
  }
}
