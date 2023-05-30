import 'package:flutter/material.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/constant_values.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/notifications.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/screen_resolutions.dart';
import 'package:imsakiye_namaz_vakitleri/Views/Home/verses_and_hadiths/verses_and_hadiths.dart';
import 'package:imsakiye_namaz_vakitleri/Views/Home/verses_and_hadiths/verses_hadiths_helpers.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key, required this.isEat, required this.city, required this.remainingTime, required this.callback,
    required this.timesNamesFirstRow, required this.timesNamesSecondRow, required this.timesListFirstRow,
    required this.timesListSecondRow}) : super(key: key);

  final bool isEat;
  final String city;
  final String remainingTime;
  final VoidCallback callback;
  final List<String> timesNamesFirstRow;
  final List<String> timesNamesSecondRow;
  final List<String> timesListFirstRow;
  final List<String> timesListSecondRow;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: "Ramazan İmsakiyesi"),
      body: Center(
        child: SizedBox(
          width: context.screenWidth * 0.94,
          child: CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ElevatedButton(onPressed: () async {
                      print("----");
                      final service = LocalNotificationService();
                      service.showNotificationForAndroidAndIOS(true);
                      print("----");
                    }, child: Text("show notif")),
                    ElevatedButton(onPressed: () async {
                      print("----");
                      final service = LocalNotificationService();
                      service.printAllPendingNotificationRequests();
                      print("----");
                    }, child: Text("print pending notifs")),
                    ElevatedButton(onPressed: () async {
                      print("----");
                      final service = LocalNotificationService();
                      service.clearAllScheduledNotifications();
                      print("----");
                    }, child: Text("clear pending notifs")),
                    SizedBox(height: context.screenHeight * 0.04),
                    Container(
                        height: context.screenHeight * 0.04,
                        decoration: BoxDecoration(color: appThemeColor, borderRadius: const BorderRadius.all(Radius.circular(20))),
                        child: ElevatedButton(
                          onPressed: widget.callback,
                          style: ElevatedButton.styleFrom(foregroundColor: appThemeColor, backgroundColor: appThemeColor, elevation: 0),
                          child: Row(
                              children: [
                                Text("dd", style: TextStyle(color: appThemeColor)),
                                const Spacer(),
                                Text(widget.city, style: const TextStyle(color: Colors.white)),
                                const Spacer(),
                                const Icon(Icons.keyboard_arrow_down_outlined, color: Colors.white),
                              ]
                          ),
                        )
                    ),
                    SizedBox(height: context.screenHeight * 0.05),
                    Text(widget.isEat ? "Sahur Vaktine Kalan" : "İftar Vaktine Kalan", style: TextStyle(fontSize: context.screenHeight * 0.02)),
                    SizedBox(height: context.screenHeight * 0.03),
                    Container(
                      height: context.screenHeight * 0.08, width: context.screenWidth * 0.94,
                      decoration: BoxDecoration(color: appThemeColor, borderRadius: const BorderRadius.all(Radius.circular(20))),
                      child: Center(child: Text(widget.remainingTime, style: TextStyle(color: Colors.white, fontSize: context.screenHeight * 0.035))),
                    ),
                    SizedBox(height: context.screenHeight * 0.04),
                    for(int i = 0; i < 2; i++)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              for(int j = 0; j < 3; j++)
                                Column(
                                  children: [
                                    TextBox(text: i == 0 ? widget.timesNamesFirstRow[j] : widget.timesNamesSecondRow[j]),
                                    SizedBox(height: context.screenHeight * 0.02),
                                     Text(i == 0 ? widget.timesListFirstRow[j] : widget.timesListSecondRow[j],
                                         style: TextStyle(color: appThemeColorDark, fontWeight: FontWeight.bold))
                                  ],
                                )
                            ],
                          ),
                          SizedBox(height: context.screenHeight * 0.05),
                        ],
                      ),
                    SizedBox(height: context.screenHeight * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent, highlightColor: Colors.transparent,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => VerseAndHadith(listOfQuotes: getVersesList(), isVerse: true)));
                          },
                          child: const TextBox(text: 'Günün Ayetleri'),
                        ),
                        InkWell(
                          splashColor: Colors.transparent, highlightColor: Colors.transparent,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => VerseAndHadith(listOfQuotes: getHadithLists(), isVerse: false)));
                          },
                          child: const TextBox(text: 'Günün Hadisleri'),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TextBox extends StatefulWidget {
  const TextBox({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  State<TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight * 0.04, width: context.screenWidth * 0.3,
      decoration: BoxDecoration(color: appThemeColor, borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Center(child: Text(widget.text, style: const TextStyle(color: Colors.white))),
    );
  }
}
