import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/constant_values.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/screen_resolutions.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

class Compass extends StatefulWidget {
  const Compass({Key? key}) : super(key: key);

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  String localCity = "";
  String localDistrict = "";

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  Future<void> getLocation() async {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    List<Placemark> localPosition = await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      localCity = localPosition[0].administrativeArea!;
      localDistrict = localPosition[0].subAdministrativeArea!;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: const BaseAppBar(title: "Kıble Pusulası"),
      body: StreamBuilder(
        stream: FlutterQiblah.qiblahStream,
        builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: appThemeColorDark));
          }
          final qiblahDirection = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: context.screenHeight * 0.03),
                Row(
                  children: [
                    SizedBox(width: context.screenWidth * 0.04),
                    Text("${qiblahDirection.direction.toInt() % 360}º", style: TextStyle(color: appThemeColorDark, fontSize: context.screenHeight * 0.07)),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(localCity, style: TextStyle(color: appThemeColorDark, fontSize: context.screenHeight * 0.025)),
                        Text(localDistrict, style: TextStyle(color: appThemeColorDark, fontSize: context.screenHeight * 0.025)),
                      ],
                    ),
                    SizedBox(width: context.screenWidth * 0.04)
                  ],
                ),
                SizedBox(height: context.screenHeight * 0.1),
                SizedBox(
                    height: context.screenHeight * 0.4, width: context.screenWidth * 0.92,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Transform.rotate(
                            angle: (qiblahDirection.direction * (pi / 180) * -1),
                            child: Image.asset('assets/images/pusula.png')),
                        SizedBox(
                          height: context.screenHeight * 0.23,
                          child: Transform.rotate(
                              angle: (qiblahDirection.qiblah * (pi / 180) * -1),
                              child: SvgPicture.asset('assets/needle.svg')),
                        ),
                      ],
                    )
                )
              ],
            ),
          );
        }
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}
