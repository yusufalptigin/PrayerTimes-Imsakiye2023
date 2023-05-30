import 'package:imsakiye_namaz_vakitleri/Utils/constant_values.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

Future<bool> isPrayerNotificationOpen(String prayerTimeName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('${prayerTimeName}NotificationOpen') ?? false;
}

Future<void> setPrayerNotificationSwitch(String prayerTimeName, bool isPrayerNotificationOpen) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('${prayerTimeName}NotificationOpen', isPrayerNotificationOpen);
  if(!isPrayerNotificationOpen) { prefs.setInt('${prayerTimeName}ReminderOffset', 0); }
}

Future<int> getPrayerNotificationReminderOffset(String prayerTimeName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('${prayerTimeName}ReminderOffset') ?? 0;
}

Future<void> setPrayerNotificationReminderOffset(String prayerTimeName, double prayerNotificationReminderOffset) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('${prayerTimeName}ReminderOffset', prayerNotificationReminderOffset.toInt());
}

Future<String> getUserCityChoice() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userCityChoice') ?? 'Şehir Seçiniz';
}

Future<void> setUserCityChoice(String userCityChoice) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('userCityChoice', userCityChoice);
}

Future<void> setAllNotificationSettingsToDefault() async {
  for (int i = 0; i < prayerTimeNames.length; i++) {
    setPrayerNotificationSwitch(prayerTimeNames[i], false);
    setPrayerNotificationReminderOffset(prayerTimeNames[i], 0);
  }
}

Future<void> configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}