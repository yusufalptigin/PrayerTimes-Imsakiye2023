import 'package:flutter/material.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/constant_values.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/screen_resolutions.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:shared_preferences/shared_preferences.dart';

class RamadanTimes extends StatefulWidget {
  const RamadanTimes({Key? key}) : super(key: key);

  @override
  State<RamadanTimes> createState() => _RamadanTimesState();
}

class _RamadanTimesState extends State<RamadanTimes> {

  List<String> prayerTimeStrings = ['İmsak', 'Güneş', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
  List<String> ramadanTimes = [];
  int hijriStart = 21;

  @override
  void initState() {
    loadRamadanData();
    super.initState();
  }

  void loadRamadanData() async {
    String userCityChoiceString = await getUserCityChoice();
    String lowercaseUserCityChoiceString = "";
    for (int i = 0; i < turkeyCities.length; i++) {
      if (turkeyCities[i]["name"] == userCityChoiceString) {
        lowercaseUserCityChoiceString = turkeyCities[i]["lowercaseName"];
        break;
      }
    }
    final ramadanWebsiteUrl = Uri.parse('https://www.sabah.com.tr/imsakiye/$lowercaseUserCityChoiceString');
    final ramadanTimesResponse = await http.get(ramadanWebsiteUrl);
    dom.Document ramadanTimesHtmlSource = dom.Document.html(ramadanTimesResponse.body);
    final ramadanTimesTable = ramadanTimesHtmlSource.querySelectorAll('tr[data-dateint] > td');
    setState(() { ramadanTimes = ramadanTimesTable.map((e) => e.innerHtml.trim()).toList(); });
  }

  String getDateString(String unformattedDate) {
    List<String> splitStrings = unformattedDate.split(' ');
    return '${splitStrings[0]} ${splitStrings[1]}, ${splitStrings[2]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: "Ramazan İmsakiyesi"),
      body: ramadanTimes.isEmpty ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Center(child: CircularProgressIndicator(color: appThemeColor))]) :
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            SizedBox(height: context.screenHeight * 0.01),
            for(int i = 0; i < ramadanTimes.length / 8; i++)
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: context.screenWidth * 0.94,
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: const BorderRadius.all(Radius.circular(8))),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                                    child: Text(getDateString(ramadanTimes[8 * i + 1]), style: const TextStyle(fontSize: 16))),
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 10, 5),
                                    child: Text('${(hijriStart + i) % 30} Şaban 1444', style: const TextStyle(fontSize: 16)))
                              ],
                            ),
                            SizedBox(width: context.screenWidth * 0.9, child: Divider(color: Colors.grey.shade700)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for(int j = 0; j < 6; j++)
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                        child: Text(prayerTimeStrings[j], style: const TextStyle(fontSize: 16))
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                                          child: Text(ramadanTimes[8 * i + j + 2], style: const TextStyle(fontSize: 16)))
                                    ],
                                  )
                              ],
                            ),
                          ],
                        )
                      ),
                      SizedBox(height: context.screenHeight * 0.02)
                    ],
                  )
                ),
          ],
        ),
      ),
    );
  }
}
