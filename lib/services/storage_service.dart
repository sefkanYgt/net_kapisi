import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/test_record.dart';

class StorageService {
  final SharedPreferences _p;
  StorageService(this._p);

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  bool get loggedIn => _p.getBool('loggedIn') ?? false;
  Future<void> setLoggedIn(bool v) => _p.setBool('loggedIn', v);

  String get name => _p.getString('name') ?? '';
  Future<void> setName(String v) => _p.setString('name', v);

  String? get field => _p.getString('field');
  Future<void> setField(String v) => _p.setString('field', v);

  /// anahtar: "alan|ders|konu" -> seviye
  Map<String, String> get levels {
    final raw = _p.getString('levels');
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  Future<void> saveLevels(Map<String, String> v) =>
      _p.setString('levels', jsonEncode(v));

  List<TestRecord> get records {
    final raw = _p.getString('records');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => TestRecord.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecords(List<TestRecord> v) =>
      _p.setString('records', jsonEncode(v.map((e) => e.toJson()).toList()));
}
