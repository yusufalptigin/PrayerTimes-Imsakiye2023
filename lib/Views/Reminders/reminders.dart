import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Utils/notifications.dart';
import '../../Utils/shared_preferences.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/constant_values.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/screen_resolutions.dart';

class Reminders extends StatefulWidget {
  const Reminders({Key? key}) : super(key: key);

  @override
  State<Reminders> createState() => _RemindersState();
}

class _RemindersState extends State<Reminders> {

  Future <List<dynamic>> fetchNotificationSettings(String prayerTimeName) async {
    final isPrayerNotificationOpenSetting = await isPrayerNotificationOpen(prayerTimeName);
    final prayerNotificationReminderOffset = await getPrayerNotificationReminderOffset(prayerTimeName);
    List<dynamic> results = [isPrayerNotificationOpenSetting, prayerNotificationReminderOffset];
    return results;
  }

  Future<void> schedulePrayerTimeNotifications(String chosenCity, String prayerTimeName, int offsetMinutes, bool cannonSound, int n) async {
    int counter = 0;
    final localNotificationService = LocalNotificationService();
    localNotificationService.clearNotificationsByIndex(n);
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
            Map<String, dynamic> prayerTimesResponse = todayJson["timings"];
            String givenPrayerTimeHourAndMinute = prayerTimesResponse[prayerTimeName];
            final notificationDate = DateTime(
                responseDate.year, responseDate.month, responseDate.day,
                int.parse(givenPrayerTimeHourAndMinute.substring(0, 2)), int.parse(givenPrayerTimeHourAndMinute.substring(3, 5))
            );
            localNotificationService.schedulePrayerTimeNotification(10 * n + counter, prayerTimeNames[n], offsetMinutes, notificationDate, cannonSound);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'Bildirimler'),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: context.screenWidth * 0.92, height: context.screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for(int i = 0; i < prayerTimeNames.length; i++)
                  FutureBuilder(
                    future: fetchNotificationSettings(prayerTimeNames[i]),
                    builder: (BuildContext context, AsyncSnapshot<List<dynamic>> notificationSettingsSnapshot) {
                      if(notificationSettingsSnapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: context.screenHeight * 0.01),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${prayerTimeNames[i]} Vaktini Hatırlat', style: TextStyle(fontSize: context.screenHeight * 0.02)),
                                CupertinoSwitch(
                                  activeColor: appThemeColor, value: notificationSettingsSnapshot.data![0],
                                  onChanged: (bool value) async {
                                    setState(() {
                                      setPrayerNotificationSwitch(prayerTimeNames[i], value);
                                    });
                                    if (value) {
                                      String chosenCity = await getUserCityChoice();
                                      int offsetMinutes = await getPrayerNotificationReminderOffset(prayerTimeNames[i]);
                                      schedulePrayerTimeNotifications(chosenCity, apiPrayerTimeNames[i], offsetMinutes, i == 4 ? true : false, i);
                                    } else {
                                      final localNotificationService = LocalNotificationService();
                                      localNotificationService.clearNotificationsByIndex(i);
                                    }
                                  }
                                )
                              ],
                            ),
                            SizedBox(height: context.screenHeight * 0.01),
                            Text('${notificationSettingsSnapshot.data![1]} dakika kala hatırlat', style: TextStyle(fontSize: context.screenHeight * 0.0175)),
                            SizedBox(height: context.screenHeight * 0.005),
                            SizedBox(
                              width: context.screenWidth * 0.92,
                              child: CupertinoSlider(
                                  value: notificationSettingsSnapshot.data![0] ? notificationSettingsSnapshot.data![1].toDouble() : 0,
                                  divisions: 12, max: 60, activeColor: appThemeColor, thumbColor: appThemeColorDark,
                                  onChanged: (double value) {
                                    if(notificationSettingsSnapshot.data![0]) {
                                      setState(() { setPrayerNotificationReminderOffset(prayerTimeNames[i], value); });
                                    }
                                  },
                                  onChangeEnd: (double value) async {
                                    if(notificationSettingsSnapshot.data![0]) {
                                      final localNotificationService = LocalNotificationService();
                                      localNotificationService.clearNotificationsByIndex(i);
                                      String chosenCity = await getUserCityChoice();
                                      int offsetMinutes = await getPrayerNotificationReminderOffset(prayerTimeNames[i]);
                                      schedulePrayerTimeNotifications(chosenCity, apiPrayerTimeNames[i], offsetMinutes, i == 4 ? true : false, i);
                                    }
                                  },
                              ),
                            )
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            SizedBox(height: context.screenHeight * 0.05),
                            Center(child: CircularProgressIndicator(color: appThemeColor)),
                            SizedBox(height: context.screenHeight * 0.05)
                          ],
                        );
                      }
                    }
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
