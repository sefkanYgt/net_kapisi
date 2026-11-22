# Soru Üretim Merkezi

## Problem
YKS ve KPSS'ye hazırlanan öğrenciler, konu bazlı seviyelerini takip edemiyor ve 
kendi eksik olduğu konulara özel soru bulmakta zorlanıyor. Hazır soru bankaları 
herkese aynı zorlukta soru sunuyor, öğrencinin gerçek seviyesine göre 
kişiselleştirme yapmıyor.

## Çözüm
Soru Üretim Merkezi, öğrencinin seçtiği ders ve konuya göre yapay zeka (Gemini API) 
ile seviyesine uygun soru üretiyor. Öğrenci önce bir "seviye belirleme" testiyle 
konu bazlı seviyesini (kolay/orta/zor) belirliyor, sonrasında bu seviyeye uygun 
20 soruluk testler çözebiliyor, PDF olarak indirebiliyor ve ilerlemesini 
(doğru/yanlış/boş, konu tamamlama yüzdesi) takip edebiliyor.

## Hedef Kitle
YKS veya KPSS'ye hazırlanan öğrenciler.

## Teknolojiler
- Flutter (MVVM mimarisi)
- Gemini API (soru üretimi)
- Firebase (planlanıyor — kullanıcı verisi ve ilerleme takibi için)
