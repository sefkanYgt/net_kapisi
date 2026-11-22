/// Uygulama ayarları. API anahtarı ŞİMDİLİK burada duruyor.
/// Uygulama hazır olunca anahtarı sunucuya (ör. Firebase Cloud Functions) taşıyın.
class AppConfig {
  static const String geminiApiKey =
      // apı key gir.


  /// Sırayla denenir. Yoğun (503), kotası olmayan (429) veya bulunamayan (404)
  /// model atlanıp sıradakine geçilir.
  static const List<String> geminiModels = [
    'gemini-3.8-flash',
    'gemini-3.7-flash',
    'gemini-3.6-flash',
    'gemini-3.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
  ];

  static const String footerText = 'Yiğit Yazılım';
}