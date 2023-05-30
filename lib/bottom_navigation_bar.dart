import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/constant_values.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/shared_preferences.dart';
import 'package:imsakiye_namaz_vakitleri/Views/ramadan_2023.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Views/More/more.dart';
import 'Views/Home/home.dart';
import 'Views/compass.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({Key? key}) : super(key: key);

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {

  final PageController controller = PageController();  /// initializing controller for PageView
  int _currentIndex = 0;
  String errorString = "";

  Future<bool> isLocationPermissionGiven() async {
    LocationPermission permission;

    if (!await Geolocator.isLocationServiceEnabled()) {
      errorString = "Lokasyon servislerine erişilemedi. Pusulaya erişebilmek için lütfen telefonunuzun lokasyon servislerini açın.";
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) return true;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        errorString = "Lokasyon servislerine izin alınamadı. Pusulaya erişebilmek için lütfen uygulamanın lokasyona erişimine izin verin.";
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      errorString = "Lokasyon servislerine izin alınamadı. Pusulaya erişebilmek için lütfen uygulamanın lokasyona erişimine izin verin.";
      return false;
    }

    return true;
  }

  void showSnackBar(String message) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); }

  @override
  Widget build(BuildContext context) {
    List<Widget> body = [
      const MyHomePage(),
      const Compass(),
      const RamadanTimes(),
      const More()
    ];
    return Scaffold(
      body: PageView(        /// Wrapping the tabs with PageView
        controller: controller,
        children: body,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;     /// Switching bottom tabs
          });
        },
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12, unselectedFontSize: 12,
          selectedItemColor: appThemeColorDark, unselectedItemColor: appThemeColorDark,
          onTap: (int newIndex) async {
            if(newIndex == 1) {
              bool locationPermissionGiven = await isLocationPermissionGiven();
              if(!locationPermissionGiven) {
                showSnackBar(errorString);
                return;
              }
            }
            if(newIndex == 2 && await getUserCityChoice() == 'Şehir Seçiniz') {
              showSnackBar('Lütfen imsakiyeye bakmadan önce şehir seçiniz.');
              return;
            }
            controller.jumpToPage(newIndex);    /// Switching the PageView tabs
            setState(() {
              _currentIndex = newIndex;
            });
          },
          items: const [
            BottomNavigationBarItem(
              label: "Ezan Vakitleri",
              icon: Padding(padding: EdgeInsets.all(5), child: Icon(Icons.access_time_outlined))
            ),
            BottomNavigationBarItem(
              label: "Kıble Pusulası",
              icon: Padding(padding: EdgeInsets.all(5), child: ImageIcon(AssetImage("assets/images/kabe_icon.png")))
            ),
            BottomNavigationBarItem(
              label: "İmsakiye",
              icon: Padding(padding: EdgeInsets.all(5), child: Icon(Icons.calendar_month_outlined))
            ),
            BottomNavigationBarItem(
              label: "Daha Fazla",
              icon: Padding(padding: EdgeInsets.all(5), child: Icon(Icons.menu))
            )
          ],
        ),
      ),
    );
  }
}
