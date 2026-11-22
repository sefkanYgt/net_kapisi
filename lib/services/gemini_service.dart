import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../models/question.dart';

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);
  @override
  String toString() => message;
}

class _Retry implements Exception {
  final String message;
  final int? status;
  _Retry(this.message, {this.status});
}

/// Gemini API ile soru üretir. Sağlayıcıyı değiştirmek isterseniz sadece
/// bu sınıfı değiştirmeniz yeterli.
class GeminiService {
  static const String _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// [counts] örn: {'kolay': 1, 'orta': 2, 'zor': 2}
  Future<List<Question>> generate({
    required String field,
    required String lesson,
    required String topic,
    required Map<String, int> counts,
  }) async {
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final prompt = _prompt(field, lesson, topic, counts, total);

    GeminiException? last;
    var saw404 = false;
    var sawBusy = false;
    var sawQuota = false;
    final tried = <String>{};

    Future<List<Question>?> attempt(String model) async {
      tried.add(model);
      for (var i = 0; i < 2; i++) {
        try {
          return await _call(model, prompt, total);
        } on _Retry catch (e) {
          last = GeminiException(e.message);
          if (e.status == 404) saw404 = true;
          if (e.status == 429) sawQuota = true;
          if (e.status != null && e.status! >= 500) sawBusy = true;
          // Sadece geçici hatalarda (5xx, bozuk yanıt) aynı modeli bir kez daha dene.
          final temporary = e.status == null || e.status! >= 500;
          if (!temporary) break;
          if (i == 0) await Future.delayed(const Duration(seconds: 4));
        } on TimeoutException {
          last = GeminiException('Yanıt zaman aşımına uğradı. Tekrar dene.');
          break;
        }
      }
      return null;
    }

    // 1) config.dart'taki modelleri sırayla dene
    for (final m in AppConfig.geminiModels) {
      final r = await attempt(m);
      if (r != null) return r;
    }

    // 2) Bir model bulunamadıysa, anahtarın erişebildiği modelleri listele ve onları dene
    if (saw404) {
      final found = await _discoverModels();
      for (final m in found) {
        if (tried.contains(m)) continue;
        final r = await attempt(m);
        if (r != null) return r;
        if (tried.length >= 12) break;
      }
    }

    if (sawBusy) {
      throw GeminiException(
          'Yapay zeka modelleri şu an çok yoğun. 1-2 dakika sonra tekrar dene.');
    }
    if (sawQuota) {
      throw GeminiException(
          'Ücretsiz kullanım limiti doldu. Biraz bekleyip tekrar dene.');
    }
    throw last ?? GeminiException('Soru üretilemedi.');
  }

  /// Anahtarın kullanabildiği, generateContent destekleyen flash modelleri listeler.
  Future<List<String>> _discoverModels() async {
    try {
      final res = await http.get(
        Uri.parse('$_base?pageSize=200'),
        headers: {'x-goog-api-key': AppConfig.geminiApiKey},
      ).timeout(const Duration(seconds: 20));
      final body = utf8.decode(res.bodyBytes);
      if (res.statusCode != 200) {
        debugPrint('MODEL LISTESI HATASI (${res.statusCode}): $body');
        return [];
      }
      final data = jsonDecode(body);
      final names = <String>[];
      for (final m in ((data['models'] as List?) ?? [])) {
        final name = (m['name'] ?? '').toString().replaceFirst('models/', '');
        final methods = ((m['supportedGenerationMethods'] as List?) ?? [])
            .map((e) => e.toString())
            .toList();
        if (!methods.contains('generateContent')) continue;
        final n = name.toLowerCase();
        if (!n.contains('flash')) continue;
        const skip = [
          'omni', 'image', 'tts', 'live', 'audio', 'embed', 'vision',
          'robotics', 'computer'
        ];
        if (skip.any((k) => n.contains(k))) continue;
        names.add(name);
      }
      // Yüksek sürüm önce, "latest" takma adları en sonda
      names.sort((a, b) {
        final al = a.contains('latest');
        final bl = b.contains('latest');
        if (al != bl) return al ? 1 : -1;
        return b.compareTo(a);
      });
      debugPrint('KULLANILABILIR MODELLER: $names');
      return names;
    } catch (e) {
      debugPrint('MODEL LISTESI ALINAMADI: $e');
      return [];
    }
  }

  String _prompt(String field, String lesson, String topic,
      Map<String, int> counts, int total) {
    final dist = counts.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.value} ${e.key}')
        .join(', ');
    return '''
Sen deneyimli bir $field soru yazarısın.
"$lesson" dersinin "$topic" konusundan toplam $total adet $field sınav formatında, 5 şıklı (A, B, C, D, E) çoktan seçmeli Türkçe soru üret.

Kurallar:
- Zorluk dağılımı: $dist. Her sorunun "difficulty" alanı kolay, orta veya zor olsun. Soruları kolaydan zora doğru sırala.
- Her sorunun tam olarak 5 şıkkı ve yalnızca bir doğru cevabı olsun.
- "options" içinde yalnızca şık metni olsun; "A)" gibi harf öneki yazma.
- "correctIndex" doğru şıkkın 0-4 arası sırasıdır.
- "explanation" alanında doğru cevabın neden doğru olduğunu 1-3 cümleyle açıkla.
- Sorular birbirinden farklı olsun ve sadece bu konuyu kapsasın.
- Matematiksel ifadeleri düz metinle yaz (LaTeX kullanma).
''';
  }

  Map<String, dynamic> get _schema => {
    'type': 'OBJECT',
    'properties': {
      'questions': {
        'type': 'ARRAY',
        'items': {
          'type': 'OBJECT',
          'properties': {
            'text': {'type': 'STRING'},
            'options': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
            },
            'correctIndex': {'type': 'INTEGER'},
            'explanation': {'type': 'STRING'},
            'difficulty': {'type': 'STRING'},
          },
          'required': [
            'text',
            'options',
            'correctIndex',
            'explanation',
            'difficulty'
          ],
        },
      },
    },
    'required': ['questions'],
  };

  Future<List<Question>> _call(String model, String prompt, int total) async {
    final res = await http
        .post(
      Uri.parse('$_base/$model:generateContent'),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': AppConfig.geminiApiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'responseSchema': _schema,
          'temperature': 0.8,
        },
      }),
    )
        .timeout(const Duration(seconds: 90));

    final status = res.statusCode;
    final body = utf8.decode(res.bodyBytes);

    if (status == 200) return _parse(body, total);

    debugPrint('GEMINI HATA $status (model: $model): '
        '${body.length > 400 ? body.substring(0, 400) : body}');

    if (status == 404 || status == 429 || status >= 500) {
      throw _Retry(
        status == 429
            ? 'İstek limiti doldu (ücretsiz katman). Biraz bekleyip tekrar dene.'
            : 'Model şu an kullanılamıyor ($status).',
        status: status,
      );
    }
    throw GeminiException(
        'API anahtarı veya istek hatası ($status): ${_errorMessage(body)}');
  }

  String _errorMessage(String body) {
    try {
      final m = jsonDecode(body);
      return (m['error']?['message'] ?? body).toString();
    } catch (_) {
      return body;
    }
  }

  List<Question> _parse(String body, int total) {
    try {
      final data = jsonDecode(body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      final map = jsonDecode(text) as Map<String, dynamic>;
      final list = map['questions'] as List;
      final out = <Question>[];
      final prefix = RegExp(r'^\s*[A-Ea-e][\)\.\:]\s*');
      for (final raw in list) {
        try {
          final q = Question.fromJson(Map<String, dynamic>.from(raw as Map));
          final opts = q.options.map((o) => o.replaceFirst(prefix, '')).toList();
          if (opts.length < 2 ||
              q.correctIndex < 0 ||
              q.correctIndex >= opts.length ||
              q.text.trim().isEmpty) {
            continue;
          }
          out.add(Question(
            text: q.text.trim(),
            options: opts,
            correctIndex: q.correctIndex,
            explanation: q.explanation.trim(),
            difficulty: q.difficulty.trim().toLowerCase(),
          ));
        } catch (_) {
          continue;
        }
      }
      if (out.isEmpty) throw _Retry('Geçerli soru üretilemedi.');
      return out.length > total ? out.sublist(0, total) : out;
    } on _Retry {
      rethrow;
    } catch (_) {
      throw _Retry('Model yanıtı okunamadı.');
    }
  }
}