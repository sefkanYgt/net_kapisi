Soru Üretim Merkezi

YKS veya KPSS'ye hazırlanan öğrenciler, konu bazlı seviyelerini takip edemiyor ve kendi
eksik olduğu konulara özel soru bulmakta zorlanıyor. Hazır soru bankaları herkese aynı
zorlukta soru sunuyor, öğrencinin gerçek seviyesine göre kişiselleştirme yapmıyor.

**Soru Üretim Merkezi**, öğrencinin seçtiği ders ve konuya göre yapay zeka (Gemini API)
ile seviyesine uygun soru üreten bir Flutter uygulamasıdır. Öğrenci önce bir "seviye
belirleme" testiyle konu bazlı seviyesini (kolay/orta/zor) belirler, sonrasında bu
seviyeye uygun testler çözebilir ve ilerlemesini takip edebilir.

**Kimin için?** YKS veya KPSS'ye hazırlanan, konu bazlı eksiklerini görmek isteyen öğrenciler.

## Proje panosu

Pano: https://github.com/users/sefkanYgt/projects/3


Çalıştırma

Gereksinim: Flutter SDK, bir Gemini API anahtarı (Google AI Studio'dan ücretsiz alınır)

```bash
git clone https://github.com/sefkanYgt/soru-uretim-merkezi.git
cd soru-uretim-merkezi
flutter pub get
flutter run --dart-define=GEMINI_API_KEY=KENDI_ANAHTARIN
```


 Özellikleri deneme

 -> Giriş ve boş alan kontrolü
1. Uygulamayı açın, logo splash ekranı ~2 saniye gösterilir.
2. Login ekranında kullanıcı adı/şifre alanlarını boş bırakıp giriş yapmayı deneyin.
3. **Beklenen:** "Kullanıcı adı ve şifre boş olamaz." hatası görünür; dolu bilgiyle giriş yapınca ana sayfaya geçilir.

-> 2. Seviye belirleme
1. Ana sayfada "Seviye" sekmesine girin, bir ders ve konu seçin, "Belirle" butonuna basın.
2. **Beklenen:** Gemini API'den 1 kolay + 2 orta + 2 zor olmak üzere 5 soru gelir, sorular sırayla gösterilir.
3. Soruları cevaplayın.
4. **Beklenen:** Doğru sayınıza göre seviyeniz (kolay/orta/zor) hesaplanıp ekranda gösterilir.
