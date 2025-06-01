// Bu dosya, astrolojik hesaplamalar ve yardımcı fonksiyonlar için kullanılacaktır.

String getSunSign(DateTime date) {
  final day = date.day;
  final month = date.month;
  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return "Koç"; // Koç için 19 Nisan son gün
  if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return "Boğa"; // Boğa için 20 Nisan başlangıç, 20 Mayıs son
  if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return "İkizler"; // İkizler için 21 Mayıs başlangıç, 20 Haziran son
  if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return "Yengeç"; // Yengeç için 21 Haziran başlangıç, 22 Temmuz son
  if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "Aslan"; // Aslan için 23 Temmuz başlangıç, 22 Ağustos son
  if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return "Başak"; // Başak için 23 Ağustos başlangıç, 22 Eylül son
  if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return "Terazi"; // Terazi için 23 Eylül başlangıç, 22 Ekim son
  if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return "Akrep"; // Akrep için 23 Ekim başlangıç, 21 Kasım son
  if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return "Yay"; // Yay için 22 Kasım başlangıç, 21 Aralık son
  if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return "Oğlak"; // Oğlak için 22 Aralık başlangıç, 19 Ocak son
  if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return "Kova"; // Kova için 20 Ocak başlangıç, 18 Şubat son
  if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return "Balık"; // Balık için 19 Şubat başlangıç, 20 Mart son
  return "Bilinmiyor";
}
