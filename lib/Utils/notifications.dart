import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/shared_preferences.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/constant_values.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

class LocalNotificationService {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future initializeNotificationService() async {
    var androidInitialize = const AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);
    var initializationSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
    }
  }

  notificationDetails(bool cannonSound) {
    AndroidNotificationDetails androidNotificationDetailsWithCannonSound = const AndroidNotificationDetails(
        'channelId', 'Namaz Vakitleri - İmsakiye', playSound: true,
        sound: RawResourceAndroidNotificationSound('cannon'),
        importance: Importance.max, priority: Priority.max
    );
    AndroidNotificationDetails androidNotificationDetailsWithoutCannonSound = const AndroidNotificationDetails(
        'channelId', 'Namaz Vakitleri - İmsakiye', playSound: true,
        importance: Importance.max, priority: Priority.max
    );

    const DarwinNotificationDetails darwinNotificationDetailsWithCannonSound = DarwinNotificationDetails(sound: 'cannon.aiff');
    const DarwinNotificationDetails darwinNotificationDetailsWithoutCannonSound = DarwinNotificationDetails();

    NotificationDetails notificationDetailsWithCannonSound =
        NotificationDetails(android: androidNotificationDetailsWithCannonSound, iOS: darwinNotificationDetailsWithCannonSound);
    NotificationDetails notificationDetailsWithoutCannonSound =
        NotificationDetails(android: androidNotificationDetailsWithoutCannonSound, iOS: darwinNotificationDetailsWithoutCannonSound);

    return cannonSound ? notificationDetailsWithCannonSound : notificationDetailsWithoutCannonSound;
  }

  Future<void> clearAllScheduledNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> clearNotificationsByIndex(int i) async {
    for(int j = i * 10; j < (i + 1) * 10; j++) {
      print('Silinen bildirimin id\'si: $j');
      await flutterLocalNotificationsPlugin.cancel(j);
    }
  }

  Future<void> printAllPendingNotificationRequests() async {
    var pendingNotificationRequests = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for(int i = 0; i < pendingNotificationRequests.length; i++) {
      final notification = pendingNotificationRequests[i];
      print('Id: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');

    }
  }

  Future<void> schedulePrayerTimeNotification(int notificationId, String prayerTimeName, int offsetMinutes, DateTime notificationDate, bool cannonSound) async {
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, notificationDate.year, notificationDate.month, notificationDate.day, notificationDate.hour, notificationDate.minute, 0);
    tz.TZDateTime scheduledDateWithOffset = scheduledDate.subtract(Duration(minutes: offsetMinutes));
    print('Yeni bildirimin zamanı: $scheduledDateWithOffset');
    await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId, offsetMinutes == 0 ? '$prayerTimeName Vakti!' : '$prayerTimeName Vaktine $offsetMinutes Dakika Kaldı!',
        '$scheduledDateWithOffset',
        scheduledDateWithOffset,
        notificationDetails(cannonSound), androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> showNotificationForAndroidAndIOS(bool cannonSound) async {
    await flutterLocalNotificationsPlugin.show(13, 'başlık', 'içerik', notificationDetails(cannonSound));
  }

}

void setupLocalNotificationsOnStartUp (BuildContext context, bool mounted) async {
  int counter = 0;
  String chosenCity = await getUserCityChoice();
  if (chosenCity == 'Şehir Seçiniz') {
    return;
  }
  final localNotificationService = LocalNotificationService();
  localNotificationService.clearAllScheduledNotifications();
  String lowercaseCity = chosenCity.toLowerCase();
  Uri requestUrl = Uri.parse(
      'https://prayer-times-api.happydigital.com.tr/aladhan-proxy/v1/calendarByCity?country=turkey&method=13&city=$lowercaseCity&tune=0,0,-7,5,4,0,7,-1,0');
  var response = await http.get(requestUrl, headers: requestHeaders);
  if (response.statusCode == 200) {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);
    Uri nextMonthRequestUrl = Uri.parse('https://prayer-times-api.happydigital.com.tr/aladhan-proxy/v1/calendarByCity?country=turkey&method=13&city=$lowercaseCity'
        '&tune=0,0,-7,5,4,0,7,-1,0&year=${nextMonth.year}&month=${nextMonth.month}');
    var responseInside = await http.get(nextMonthRequestUrl, headers: requestHeaders);
    if (responseInside.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      Map<String, dynamic> jsonResponseInside = jsonDecode(responseInside.body);
      List<dynamic> responsesList = jsonResponse["data"];
      List<dynamic> responsesListInside = jsonResponseInside["data"];
      responsesList = responsesList + responsesListInside;
      for(int i = 0; i < responsesList.length; i++) {
        Map<String, dynamic> todayJson = responsesList[i];
        String responseDateString = todayJson["date"]["gregorian"]["date"];
        final now = DateTime.now();
        final todayDate = DateTime(now.year, now.month, now.day);
        final responseDate = DateFormat("dd-MM-yyyy").parse(responseDateString);
        if(responseDate == todayDate || (responseDate.isAfter(todayDate) && responseDate.isBefore(todayDate.add(const Duration(days: 10))))) {
          for (int j = 0; j < prayerTimeNames.length; j++) {
            bool isNotificationEnabledForPrayerTime = await isPrayerNotificationOpen(prayerTimeNames[j]);
            if (isNotificationEnabledForPrayerTime) {
              int offsetMinutesForPrayerTime = await getPrayerNotificationReminderOffset(prayerTimeNames[j]);
              Map<String, dynamic> prayerTimesResponse = todayJson["timings"];
              String givenPrayerTimeHourAndMinute = prayerTimesResponse[apiPrayerTimeNames[j]];
              final notificationDate = DateTime(
                  responseDate.year, responseDate.month, responseDate.day,
                  int.parse(givenPrayerTimeHourAndMinute.substring(0, 2)), int.parse(givenPrayerTimeHourAndMinute.substring(3, 5))
              );
              localNotificationService.schedulePrayerTimeNotification(
                  10 * j + counter, prayerTimeNames[j], offsetMinutesForPrayerTime, notificationDate, j == 4 ? true : false);
            }
          }
          counter = counter + 1;
        }
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veri isteği gönderilemedi. İnternetinizi kontrol ederek tekrar deneyin.")));
    }
  } else {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veri isteği gönderilemedi. İnternetinizi kontrol ederek tekrar deneyin.")));
  }



}

