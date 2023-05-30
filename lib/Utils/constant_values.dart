import 'package:imsakiye_namaz_vakitleri/Utils/screen_resolutions.dart';
import 'package:flutter/material.dart';

Color appThemeColorDark = const Color.fromRGBO(108, 141, 151, 1);
Color appThemeColor = const Color.fromRGBO(150, 194, 210, 1);

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  //final Color backgroundColor = Colors.red;
  final String title;

  const BaseAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text(title), centerTitle: true,
        backgroundColor: appThemeColor, elevation: 0,
        leading: Navigator.canPop(context) ? IconButton(
            splashColor: Colors.transparent, highlightColor: Colors.transparent,
            icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.of(context).pop()) : null);
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}

List<Widget> moreActionIcons = [
  Builder(builder: (BuildContext context) => Icon(Icons.notifications_active_rounded, size: context.screenWidth * 0.07, color: appThemeColorDark)),
  Builder(builder: (BuildContext context) => Icon(Icons.rate_review_outlined, size: context.screenWidth * 0.07, color: appThemeColorDark)),
  Builder(builder: (BuildContext context) => Icon(Icons.star_border_rounded, size: context.screenWidth * 0.07, color: appThemeColorDark)),
  Builder(builder: (BuildContext context) => Icon(Icons.email_outlined, size: context.screenWidth * 0.07, color: appThemeColorDark))
];


Map<String, String> requestHeaders = {
  'Content-type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Basic bW9iaWxlQXBwczpHR0ZRd0NDNlUyOUpqakMyMnBtY1ZNV1VmZ1BRaER4bQ=='
};

List<String> prayerTimeNames = [
  "İmsak",
  "Güneş",
  "Öğle",
  "İkindi",
  "İftar",
  "Yatsı"
];

List<String> apiPrayerTimeNames = [
  "Fajr",
  "Sunrise",
  "Dhuhr",
  "Asr",
  "Sunset",
  "Isha"
];

List<String> moreActionTitles = [
  "Bildirimler",
  "Hata Bildir / Öneride Bulun",
  "Bizi Değerlendir",
  "Bize Ulaş"
];

List<String> appIcons = [
  "assets/images/happy_mom_icon.png",
  "assets/images/happy_kids_icon.png",
  "assets/images/pedometer_icon.png",
  "assets/images/peride_icon.png",
  "assets/images/happy_photos_icon.png"
];

List<String> appTitles = [
  "Happy Mom",
  "Happy Kids",
  "Adım Sayar",
  "Peride",
  "Happy Photos"
];

List<String> appDescriptions = [
  "Hamilelik Takip Uygulaması",
  "0-4 Yaş Çocuk Gelişim Takip Uygulaması",
  "Adım Sayar ve Su Hatırlatıcı",
  "Regl/Adet Takvimi",
  "Ücretsiz Fotoğraf Düzenleyici"
];

List<String> iOSAppUrlPaths = [
  "/app/mutlu-anne-hamilelik-takibi/id1141379201",
  "/app/happy-kids-bebek-geli%C5%9Fimi/id1349245161",
  "/app/ad%C4%B1m-sayar/id736071203",
  "/app/periyot-g%C3%BCnl%C3%BC%C4%9F%C3%BC-peride/id577097723",
  "/app/happy-photos/id1317783824",
];

List<String> androidAppUrlPaths = [
  "/store/apps/details?id=tr.com.happydigital.happymom",
  "/store/apps/details?id=tr.com.happydigital.happykids",
  "/store/apps/details?id=tr.com.happydigital.pedometer",
  "/store/apps/details?id=tr.com.happydigital.peride",
  "/store/apps/details?id=tr.com.happydigital.happyphotos",
];

List<Map<String, dynamic>> turkeyCities = const [
  {"id": 1, "name": "ADANA", "lowercaseName": "adana"},
  {"id": 2, "name": "ADIYAMAN", "lowercaseName": "adiyaman"},
  {"id": 3, "name": "AFYONKARAHİSAR", "lowercaseName": "afyonkarahisar"},
  {"id": 4, "name": "AĞRI", "lowercaseName": "agri"},
  {"id": 68, "name": "AKSARAY", "lowercaseName": "aksaray"},
  {"id": 5, "name": "AMASYA", "lowercaseName": "amasya"},
  {"id": 6, "name": "ANKARA", "lowercaseName": "ankara"},
  {"id": 7, "name": "ANTALYA", "lowercaseName": "antalya"},
  {"id": 75, "name": "ARDAHAN", "lowercaseName": "ardahan"},
  {"id": 8, "name": "ARTVİN", "lowercaseName": "artvin"},
  {"id": 9, "name": "AYDIN", "lowercaseName": "aydin"},
  {"id": 10, "name": "BALIKESİR", "lowercaseName": "balikesir"},
  {"id": 74, "name": "BARTIN", "lowercaseName": "bartin"},
  {"id": 72, "name": "BATMAN", "lowercaseName": "batman"},
  {"id": 69, "name": "BAYBURT", "lowercaseName": "bayburt"},
  {"id": 11, "name": "BİLECİK", "lowercaseName": "bilecik"},
  {"id": 12, "name": "BİNGÖL", "lowercaseName": "bingol"},
  {"id": 13, "name": "BİTLİS", "lowercaseName": "bitlis"},
  {"id": 14, "name": "BOLU", "lowercaseName": "bolu"},
  {"id": 15, "name": "BURDUR", "lowercaseName": "burdur"},
  {"id": 16, "name": "BURSA", "lowercaseName": "bursa"},
  {"id": 17, "name": "ÇANAKKALE", "lowercaseName": "canakkale"},
  {"id": 18, "name": "ÇANKIRI", "lowercaseName": "cankiri"},
  {"id": 19, "name": "ÇORUM", "lowercaseName": "corum"},
  {"id": 20, "name": "DENİZLİ", "lowercaseName": "denizli"},
  {"id": 21, "name": "DİYARBAKIR", "lowercaseName": "diyarbakir"},
  {"id": 81, "name": "DÜZCE", "lowercaseName": "duzce"},
  {"id": 22, "name": "EDİRNE", "lowercaseName": "edirne"},
  {"id": 23, "name": "ELAZIĞ", "lowercaseName": "elazıg"},
  {"id": 24, "name": "ERZİNCAN", "lowercaseName": "erzincan"},
  {"id": 25, "name": "ERZURUM", "lowercaseName": "erzurum"},
  {"id": 26, "name": "ESKİŞEHİR", "lowercaseName": "eskisehir"},
  {"id": 27, "name": "GAZİANTEP", "lowercaseName": "gaziantep"},
  {"id": 28, "name": "GİRESUN", "lowercaseName": "giresun"},
  {"id": 29, "name": "GÜMÜŞHANE", "lowercaseName": "gumushane"},
  {"id": 30, "name": "HAKKARİ", "lowercaseName": "hakkari"},
  {"id": 31, "name": "HATAY", "lowercaseName": "hatay"},
  {"id": 76, "name": "IĞDIR", "lowercaseName": "igdir"},
  {"id": 32, "name": "ISPARTA", "lowercaseName": "isparta"},
  {"id": 34, "name": "İSTANBUL", "lowercaseName": "istanbul"},
  {"id": 35, "name": "İZMİR", "lowercaseName": "izmir"},
  {"id": 46, "name": "KAHRAMANMARAŞ", "lowercaseName": "kahramanmaras"},
  {"id": 78, "name": "KARABÜK", "lowercaseName": "karabuk"},
  {"id": 70, "name": "KARAMAN", "lowercaseName": "karaman"},
  {"id": 36, "name": "KARS", "lowercaseName": "kars"},
  {"id": 37, "name": "KASTAMONU", "lowercaseName": "kastamonu"},
  {"id": 38, "name": "KAYSERİ", "lowercaseName": "kayseri"},
  {"id": 71, "name": "KIRIKKALE", "lowercaseName": "kirikkale"},
  {"id": 39, "name": "KIRKLARELİ", "lowercaseName": "kirklareli"},
  {"id": 40, "name": "KIRŞEHİR", "lowercaseName": "kirsehir"},
  {"id": 79, "name": "KİLİS", "lowercaseName": "kilis"},
  {"id": 41, "name": "KOCAELİ", "lowercaseName": "kocaeli"},
  {"id": 42, "name": "KONYA", "lowercaseName": "konya"},
  {"id": 43, "name": "KÜTAHYA", "lowercaseName": "kutahya"},
  {"id": 44, "name": "MALATYA", "lowercaseName": "malatya"},
  {"id": 45, "name": "MANİSA", "lowercaseName": "manisa"},
  {"id": 47, "name": "MARDİN", "lowercaseName": "mardin"},
  {"id": 33, "name": "MERSİN", "lowercaseName": "mersin"},
  {"id": 48, "name": "MUĞLA", "lowercaseName": "mugla"},
  {"id": 49, "name": "MUŞ", "lowercaseName": "mus"},
  {"id": 50, "name": "NEVŞEHİR", "lowercaseName": "nevsehir"},
  {"id": 51, "name": "NİĞDE", "lowercaseName": "nigde"},
  {"id": 52, "name": "ORDU", "lowercaseName": "ordu"},
  {"id": 80, "name": "OSMANİYE", "lowercaseName": "osmaniye"},
  {"id": 53, "name": "RİZE", "lowercaseName": "rize"},
  {"id": 54, "name": "SAKARYA", "lowercaseName": "sakarya"},
  {"id": 55, "name": "SAMSUN", "lowercaseName": "samsun"},
  {"id": 56, "name": "SİİRT", "lowercaseName": "siirt"},
  {"id": 57, "name": "SİNOP", "lowercaseName": "sinop"},
  {"id": 58, "name": "SİVAS", "lowercaseName": "sivas"},
  {"id": 63, "name": "ŞANLIURFA", "lowercaseName": "sanliurfa"},
  {"id": 73, "name": "ŞIRNAK", "lowercaseName": "sirnak"},
  {"id": 59, "name": "TEKİRDAĞ", "lowercaseName": "tekirdag"},
  {"id": 60, "name": "TOKAT", "lowercaseName": "tokat"},
  {"id": 61, "name": "TRABZON", "lowercaseName": "trabzon"},
  {"id": 62, "name": "TUNCELİ", "lowercaseName": "tunceli"},
  {"id": 64, "name": "UŞAK", "lowercaseName": "usak"},
  {"id": 65, "name": "VAN", "lowercaseName": "van"},
  {"id": 77, "name": "YALOVA", "lowercaseName": "yalova"},
  {"id": 66, "name": "YOZGAT", "lowercaseName": "yozgat"},
  {"id": 67, "name": "ZONGULDAK", "lowercaseName": "zonguldak"}
];