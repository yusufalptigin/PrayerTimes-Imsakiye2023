import 'dart:async';
import 'dart:convert';
import 'package:imsakiye_namaz_vakitleri/Utils/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:imsakiye_namaz_vakitleri/Utils/constant_values.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/screen_resolutions.dart';
import 'package:imsakiye_namaz_vakitleri/Views/Home/home_view.dart';
import '../../Utils/notifications.dart';
import '../../Utils/one_signal.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with AutomaticKeepAliveClientMixin {

  late Timer timer;
  late int remainingSeconds;
  late int remainingSecondsUntilMidnight = 0;
  bool isEat = false;
  bool flag = true;
  String city = "Şehir Seçiniz";
  String remainingTime = "Hesaplanıyor...";
  List<String> timesNamesFirstRow = ["İmsak", "Güneş", "Öğle"];
  List<String> timesNamesSecondRow = ["İkindi", "Akşam", "Yatsı"];
  List<String> timesListFirstRow = ["-", "-", "-"];
  List<String> timesListSecondRow = ["-", "-", "-"];
  List<Map<String, dynamic>> foundTurkeyCities = [];


  @override
  void initState() {
    foundTurkeyCities = turkeyCities;
    configureLocalTimeZone();
    sendFirstRequest();
    LocalNotificationService().initializeNotificationService();
    setupLocalNotificationsOnStartUp(context, mounted);
    setupOneSignal();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return HomeView(
      isEat: isEat, city: city, remainingTime: remainingTime, callback: () => showBottomSheet(),
      timesNamesFirstRow: timesNamesFirstRow, timesNamesSecondRow: timesNamesSecondRow,
      timesListFirstRow: timesListFirstRow, timesListSecondRow: timesListSecondRow);
  }

  void sendFirstRequest() async {
    String userCityChoice = await getUserCityChoice();
    if(userCityChoice == 'Şehir Seçiniz') {
      Future.delayed(const Duration(seconds: 0)).then((_) {
        showBottomSheet();
      });
    } else {
      getPrayersData(userCityChoice, false);
    }
  }

  Future<void> getPrayersData(String chosenCity, bool isModalSheet) async {
    String lowercaseCity = chosenCity.toLowerCase();
    Uri requestUrl = Uri.parse(
        'https://prayer-times-api.happydigital.com.tr/aladhan-proxy/v1/calendarByCity?country=turkey&method=13&city=$lowercaseCity&tune=0,0,-7,5,4,0,7,-1,0');
    var response = await http.get(requestUrl, headers: requestHeaders);
    if (response.statusCode == 200) {
      if (city != chosenCity && city != "Şehir Seçiniz" && isModalSheet) {
        await setAllNotificationSettingsToDefault();
        final notificationService = LocalNotificationService();
        notificationService.clearAllScheduledNotifications();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Şehir değiştirmenin bildirim ayarlarını sıfırladığını unutmayın!')));
      }
      city = chosenCity;
      setUserCityChoice(chosenCity);
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> responsesList = jsonResponse["data"];
      for(int i = 0; i < responsesList.length; i++) {
        Map<String, dynamic> todayJson = responsesList[i];
        Map<String, dynamic> tomorrowJson = responsesList[i + 1];
        String responseDateString = todayJson["date"]["gregorian"]["date"];
        String tomorrowDateString = tomorrowJson["date"]["gregorian"]["date"];
        final tempDate = DateFormat("dd-MM-yyyy").parse(responseDateString);
        final tomorrowDate = DateFormat("dd-MM-yyyy").parse(tomorrowDateString);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        if(tempDate == today) {
          Map<String, dynamic> prayerTimesResponse = todayJson["timings"];
          timesListFirstRow[0] = prayerTimesResponse["Fajr"];
          timesListFirstRow[1] = prayerTimesResponse["Sunrise"];
          timesListFirstRow[2] = prayerTimesResponse["Dhuhr"];
          timesListSecondRow[0] = prayerTimesResponse["Asr"];
          timesListSecondRow[1] = prayerTimesResponse["Sunset"];
          timesListSecondRow[2] = prayerTimesResponse["Isha"];
          for(int i = 0; i < timesListFirstRow.length; i++) {
            setState(() {
              timesListFirstRow[i] = timesListFirstRow[i].substring(0, 5);
              timesListSecondRow[i] = timesListSecondRow[i].substring(0, 5);
            });
          }
          final prayerDate = DateTime(now.year, now.month, now.day, int.parse(timesListSecondRow[1].substring(0, 2)), int.parse(timesListSecondRow[1].substring(3, 5)));
          final todayEatDate = DateTime(now.year, now.month, now.day, int.parse(timesListFirstRow[0].substring(0, 2)), int.parse(timesListFirstRow[0].substring(3, 5)));
          String tomorrowEatTime = tomorrowJson["timings"]["Fajr"];
          final tomorrowEatDate = DateTime(tomorrowDate.year, tomorrowDate.month, tomorrowDate.day, int.parse(tomorrowEatTime.substring(0, 2)), int.parse(tomorrowEatTime.substring(3, 5)));
          Duration timeDifference;
          if(now.isBefore(todayEatDate)) {
            setState(() { isEat = true; });
            timeDifference = todayEatDate.difference(now);
          } else if(now.isAfter(todayEatDate) && prayerDate.isAfter(now)){
            timeDifference = prayerDate.difference(now);
            setState(() { isEat = false; });
          } else {
            timeDifference = tomorrowEatDate.difference(now);
            setState(() { isEat = true; });
          }
          remainingSeconds = timeDifference.inSeconds;
          remainingSecondsUntilMidnight = tomorrowDate.difference(now).inSeconds;
          calculateRemainingTime(remainingSeconds);
          if(flag) { startTimer(); }
          break;
        }
      }
      if (!mounted) return;
      if(isModalSheet) { Navigator.pop(context); }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veri isteği gönderilemedi. İnternetinizi kontrol ederek tekrar deneyin.")));
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if(remainingSeconds > 0) {
        if(mounted) {
          remainingSeconds = remainingSeconds - 1;
          calculateRemainingTime(remainingSeconds);
          if(remainingSecondsUntilMidnight > 0) {
            remainingSecondsUntilMidnight = remainingSecondsUntilMidnight - 1;
          } else {
            getPrayersData(city, false);
          }
          //print(remainingSecondsUntilMidnight);
          //print(remainingSeconds);
        }
      } else {
        getPrayersData(city, false);
      }
    });
    flag = false;
  }

  void calculateRemainingTime(int remainingSeconds) {
    int remainingHours = remainingSeconds ~/ 3600;
    int remainingMinutes = ((remainingSeconds % 3600) ~/ 60) + 1;
    if(remainingMinutes == 60){
      remainingHours = remainingHours + 1;
      remainingMinutes = 0;
    }
    setState(() {
      if(remainingHours != 0 && remainingMinutes != 0) {
        remainingTime = "$remainingHours saat $remainingMinutes dakika";
      } else if (remainingHours != 0 && remainingMinutes == 0){
        remainingTime = "$remainingHours saat";
      } else {
        remainingTime = "$remainingMinutes dakika";
      }
    });
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return FractionallySizedBox(
                  heightFactor: 0.88,
                  child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      appBar: AppBar(
                          title: const Text("Şehir Seçiniz"), elevation: 0, backgroundColor: appThemeColor,
                          leading: Navigator.canPop(context) ? IconButton(
                              splashColor: Colors.transparent, highlightColor: Colors.transparent,
                              icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()) : null
                      ),
                      body: Column(
                        children: [
                          SizedBox(
                            width: context.screenWidth * 0.9,
                            child: TextField(
                              onChanged: (enteredKeyword) {
                                List<Map<String, dynamic>> results = [];
                                if(enteredKeyword.isEmpty) {
                                  results = turkeyCities;
                                } else {
                                  results = turkeyCities.where((city) => city["name"].toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
                                }
                                setModalState(() {
                                  foundTurkeyCities = results;
                                });
                              },
                              cursorColor: appThemeColor,
                              decoration: InputDecoration(
                                iconColor: appThemeColor, suffixIconColor: appThemeColor, labelStyle: TextStyle(color: appThemeColor),
                                labelText: "Ara", suffixIcon: const Icon(Icons.search),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: appThemeColor)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: appThemeColor)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(context.screenWidth * 0.05, 0, context.screenWidth * 0.05, 0),
                              itemCount: foundTurkeyCities.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  splashColor: Colors.grey.shade400, highlightColor: Colors.grey.shade400,
                                  onTap: () => getPrayersData(foundTurkeyCities[index]["name"], true),
                                  child: Column(
                                    children: [
                                      SizedBox(height: context.screenHeight * 0.01),
                                      Row(
                                        children: [
                                          SizedBox(width: context.screenWidth * 0.04),
                                          Text(foundTurkeyCities[index]["name"], style: const TextStyle(fontWeight: FontWeight.w500)),
                                          const Spacer(),
                                          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                                          SizedBox(width: context.screenWidth * 0.04),
                                        ],
                                      ),
                                      SizedBox(height: context.screenHeight * 0.01),
                                      Container(width: context.screenWidth * 0.9, height: context.screenHeight * 0.001,color: Colors.grey)
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: context.screenHeight * 0.03)
                        ],
                      )
                  )
              );
            }
        );
      },
    ).whenComplete(() => {foundTurkeyCities = turkeyCities});
  }

  @override
  bool get wantKeepAlive => true;    /// Overriding the value to preserve the state

}
