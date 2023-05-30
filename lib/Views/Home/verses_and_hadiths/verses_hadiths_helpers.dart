import '../../../Data/hadiths.dart';
import '../../../Data/quran_verses.dart';

List getHadithLists() {
  final dailyHadithList = [];
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final marchStart = DateTime(2023, 3, 1);
  final dayDifference = todayStart.difference(marchStart).inDays;
  final hadithDayDifference = dayDifference % (hadiths.length ~/ 10);
  for(int i = 0; i < 10; i++) {
    dailyHadithList.add(hadiths[hadithDayDifference * 10 + i]);
  }
  return dailyHadithList;
}

List getVersesList() {
  final dailyVerseList = [];
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final marchStart = DateTime(2023, 3, 1);
  final dayDifference = todayStart.difference(marchStart).inDays;
  final versesDayDifference = dayDifference % (quranVerses.length ~/ 10);
  for(int i = 0; i < 10; i++) {
    dailyVerseList.add(quranVerses[versesDayDifference * 10 + i]);
  }
  return dailyVerseList;
}