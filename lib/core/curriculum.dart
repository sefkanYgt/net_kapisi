/// YKS ve KPSS ders / konu listesi. İstediğiniz kadar genişletebilirsiniz.
class Curriculum {
  static const String yks = 'YKS';
  static const String kpss = 'KPSS';
  static const List<String> fields = [yks, kpss];

  static const Map<String, Map<String, List<String>>> _data = {
    'YKS': {
      'Matematik': [
        'Temel Kavramlar', 'Sayılar ve Bölünebilme', 'Rasyonel ve Üslü Sayılar',
        'Denklemler ve Eşitsizlikler', 'Fonksiyonlar', 'Polinomlar',
        'Trigonometri', 'Logaritma', 'Limit ve Türev', 'İntegral',
        'Olasılık', 'Üçgenler',
      ],
      'Türkçe': [
        'Sözcükte Anlam', 'Cümlede Anlam', 'Paragraf', 'Ses Bilgisi',
        'Yazım Kuralları', 'Noktalama İşaretleri', 'Sözcük Türleri',
        'Cümle Bilgisi', 'Anlatım Bozuklukları',
      ],
      'Fizik': [
        'Kuvvet ve Hareket', 'İş, Güç ve Enerji', 'Isı ve Sıcaklık',
        'Elektrostatik', 'Elektrik Akımı', 'Manyetizma', 'Dalgalar',
        'Optik', 'Basınç ve Kaldırma Kuvveti',
      ],
      'Kimya': [
        'Atom ve Periyodik Sistem', 'Kimyasal Türler Arası Etkileşimler',
        'Maddenin Halleri', 'Asitler, Bazlar ve Tuzlar',
        'Kimyasal Hesaplamalar', 'Karışımlar', 'Tepkime Hızı ve Denge',
        'Organik Kimya',
      ],
      'Biyoloji': [
        'Canlıların Ortak Özellikleri', 'Hücre', 'Hücre Bölünmeleri',
        'Kalıtım', 'Ekosistem', 'Sindirim ve Dolaşım Sistemleri',
        'Sinir ve Endokrin Sistem', 'Bitki Biyolojisi', 'Protein Sentezi',
      ],
      'Tarih': [
        'İlk Türk Devletleri', 'Osmanlı Kuruluş ve Yükselme',
        'Osmanlı Duraklama ve Dağılma', 'Kurtuluş Savaşı',
        'Atatürk İlke ve İnkılapları', 'Çağdaş Türk ve Dünya Tarihi',
      ],
      'Coğrafya': [
        'Doğa ve İnsan', 'Dünya\'nın Şekli ve Hareketleri', 'Harita Bilgisi',
        'İklim Bilgisi', 'İç ve Dış Kuvvetler', 'Nüfus ve Yerleşme',
        'Türkiye\'nin Ekonomisi', 'Doğal Afetler',
      ],
      'Edebiyat': [
        'Şiir Bilgisi', 'Edebi Sanatlar', 'Halk Edebiyatı', 'Divan Edebiyatı',
        'Tanzimat Edebiyatı', 'Servet-i Fünun ve Fecr-i Ati',
        'Milli Edebiyat', 'Cumhuriyet Dönemi Edebiyatı',
      ],
    },
    'KPSS': {
      'Türkçe': [
        'Sözcükte Anlam', 'Cümlede Anlam', 'Paragraf', 'Ses Bilgisi',
        'Yazım ve Noktalama', 'Sözcük Türleri', 'Cümle Bilgisi',
        'Anlatım Bozuklukları',
      ],
      'Matematik': [
        'Temel Kavramlar', 'Sayı Basamakları', 'Bölme ve Bölünebilme',
        'EBOB - EKOK', 'Rasyonel Sayılar', 'Oran Orantı',
        'Yüzde, Kâr ve Zarar', 'Problemler',
        'Permütasyon, Kombinasyon ve Olasılık', 'Geometri',
      ],
      'Tarih': [
        'İslamiyet Öncesi Türk Tarihi', 'İlk Türk-İslam Devletleri',
        'Osmanlı Kuruluş ve Yükselme', 'Osmanlı Yenileşme Hareketleri',
        'Kurtuluş Savaşı', 'Atatürk İlke ve İnkılapları',
        'Çağdaş Türk ve Dünya Tarihi',
      ],
      'Coğrafya': [
        'Türkiye\'nin Coğrafi Konumu', 'Yeryüzü Şekilleri',
        'İklim ve Bitki Örtüsü', 'Nüfus ve Yerleşme',
        'Tarım ve Hayvancılık', 'Madenler ve Enerji', 'Ulaşım ve Ticaret',
      ],
      'Vatandaşlık': [
        'Hukuka Giriş', 'Anayasa Hukuku Temel Kavramlar',
        '1982 Anayasası Temel İlkeleri', 'Yasama', 'Yürütme', 'Yargı',
        'İdare Hukuku', 'Temel Hak ve Hürriyetler',
      ],
      'Güncel Bilgiler': [
        'Türkiye\'de Güncel Gelişmeler', 'Dünyada Güncel Gelişmeler',
        'Kültür ve Sanat', 'Bilim ve Teknoloji',
      ],
    },
  };

  static List<String> lessons(String field) =>
      _data[field]?.keys.toList() ?? const [];

  static List<String> topics(String field, String lesson) =>
      _data[field]?[lesson] ?? const [];

  static int totalTopics(String field) {
    final lessons = _data[field];
    if (lessons == null) return 0;
    return lessons.values.fold<int>(0, (sum, t) => sum + t.length);
  }

  /// [ders, konu] çiftleri
  static List<List<String>> allTopicKeys(String field) {
    final out = <List<String>>[];
    final lessons = _data[field];
    if (lessons == null) return out;
    lessons.forEach((lesson, topics) {
      for (final t in topics) {
        out.add([lesson, t]);
      }
    });
    return out;
  }
}
