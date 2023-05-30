import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/screen_resolutions.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/constant_values.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/shared_preferences.dart';
import 'package:imsakiye_namaz_vakitleri/Views/More/helpers.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:imsakiye_namaz_vakitleri/Views/Reminders/reminders.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class More extends StatefulWidget {
  const More({Key? key}) : super(key: key);

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> with AutomaticKeepAliveClientMixin {

  Future<String> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? systemVersion;
    String? deviceModel;
    if(Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      systemVersion = androidDeviceInfo.version.toString();
      deviceModel = "${androidDeviceInfo.model}, ${androidDeviceInfo.device}";
    } else {
      IosDeviceInfo iOSDeviceInfo = await deviceInfo.iosInfo;
      systemVersion = iOSDeviceInfo.systemVersion;
      deviceModel = iOSDeviceInfo.localizedModel;
    }
    return "Sistem Sürümü: $systemVersion\nCihaz Modeli: $deviceModel";
  }

  void sendEmail(String subject, String body, String recipientEmail) async {
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: [recipientEmail],
      isHTML: false,
    );
    try {
      await FlutterEmailSender.send(email);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Telefonda mail uygulaması bulunamadı.")));
    }
  }

  Future<String> getDeviceInfoString() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String appVersion = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    String deviceInfo = await getDeviceInfo();
    String oneSignalPlayerId = "-";
    await OneSignal.shared.getDeviceState().then((deviceState) {
      String? playerId = deviceState?.userId;
      // print("OneSignal: device state: ${deviceState?.jsonRepresentation()}");
      if (playerId != null) {
        oneSignalPlayerId = playerId;
      } else {
        oneSignalPlayerId = "-";
      }
    });
    String deviceInfoFullString = "\n\n\nLütfen mesajınızı bu satırların üzerine yazınız.\nUygulama Sürümü: "
        "$appVersion ($buildNumber)\n$deviceInfo\nKullanıcı Id: $oneSignalPlayerId\n\n\n$appName";
    return deviceInfoFullString;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: const BaseAppBar(title: "Daha Fazla"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: context.screenHeight * 0.01),
            for(int i = 0; i < moreActionTitles.length; i++)
              Column(children: [
                if (i != 0 && i != 2)
                  InkWell(
                    splashColor: Colors.transparent, highlightColor: Colors.transparent,
                    onTap: () => getDeviceInfoString().then((String deviceInfoString) => sendEmail(
                      i == 1 ? "Happy Apps - Hata Bildirisi / Öneri" : "Bize Ulaşın",
                      deviceInfoString,
                      "happy@happydigital.com.tr",
                    )),
                    child: CustomRow(icon: moreActionIcons[i], actionText: moreActionTitles[i]),
                  )
                else if (i == 0)
                  InkWell(
                    splashColor: Colors.transparent, highlightColor: Colors.transparent,
                    onTap: () async {
                      String userCityChoice = await getUserCityChoice();
                      if (!mounted) return;
                      if (userCityChoice == 'Şehir Seçiniz') {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bildirim ayarlarmadan önce şehir seçiniz.')));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Reminders()));
                      }
                    },
                    child: CustomRow(icon: moreActionIcons[i], actionText: moreActionTitles[i]),
                  )
                else InkWell(
                    splashColor: Colors.transparent, highlightColor: Colors.transparent,
                    onTap: () => popUp(Platform.isIOS ? '/app/i-msakiye-namaz-vakitleri/id1672049086' : '/store/apps/developer?id=HAPPY+DIGITAL'),
                    child: CustomRow(icon: moreActionIcons[i], actionText: moreActionTitles[i]),
                  ),
                if (i != moreActionTitles.length - 1) SizedBox(width: context.screenWidth * 0.96, child: const Divider(color: Colors.grey))
              ]),
            const HappyAppsTitle(),
            SizedBox(height: context.screenHeight * 0.01),
            for(int i = 0; i < appTitles.length; i++)
              HappyApp(
                appIcon: appIcons[i],
                appTitle: appTitles[i],
                appDescription: appDescriptions[i],
                callback: () => popUp(Platform.isIOS ? iOSAppUrlPaths[i] : androidAppUrlPaths[i]),
              )
          ],
        ),
      ),
    );
  }

  void popUp (String appUrlPath) {
    Widget continueButton = TextButton(
      style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
      child: const Text("Evet", style: TextStyle(color: Colors.black) ),
      onPressed: () async {
        Uri url = Uri(scheme: 'https', host: Platform.isIOS ? "apps.apple.com" : "play.google.com", path: appUrlPath);
        Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 400));
        if (await canLaunchUrl(url)) await launchUrl(url);
      },
    );
    Widget cancelButton = TextButton(
      style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
      child: const Text("Hayır", style: TextStyle(color: Colors.black)),
      onPressed: () { Navigator.pop(context); },
    );
    showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Uygulamadan Çıkılacak"),
          content: const Text("Devam Edilsin mi?"),
          actions: [
            cancelButton,
            continueButton,
          ],
        )
    );
  }

  @override
  bool get wantKeepAlive => true;

}


