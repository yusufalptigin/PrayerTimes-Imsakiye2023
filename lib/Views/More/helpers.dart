import 'package:flutter/material.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/screen_resolutions.dart';

class HappyAppsTitle extends StatefulWidget {
  const HappyAppsTitle({Key? key}) : super(key: key);

  @override
  State<HappyAppsTitle> createState() => _HappyAppsTitleState();
}

class _HappyAppsTitleState extends State<HappyAppsTitle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.screenHeight * 0.06,
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Padding(
              padding: EdgeInsets.only(left: context.screenWidth * 0.02),
              child: Text("Mutlu Uygulamalar", style: TextStyle(fontSize: context.screenWidth * 0.04))
          ),
        ],
      ),
    );
  }
}

class CustomRow extends StatefulWidget {
  const CustomRow({Key? key, required this.icon, required this.actionText}) : super(key: key);

  final Widget icon;
  final String actionText;

  @override
  State<CustomRow> createState() => _CustomRowState();
}

class _CustomRowState extends State<CustomRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: context.screenWidth * 0.1, width: context.screenWidth * 0.15,
          child: widget.icon
        ),
        Text(widget.actionText, style: TextStyle(fontSize: context.screenWidth * 0.04)),
        const Spacer(),
        SizedBox(width: context.screenWidth * 0.02),
        const Icon(Icons.chevron_right),
        SizedBox(width: context.screenWidth * 0.02),
      ],
    );
  }
}

class HappyApp extends StatefulWidget {
  const HappyApp({Key? key, required this.appIcon, required this.appTitle, required this.appDescription, required this.callback}) : super(key: key);

  final String appIcon;
  final String appTitle;
  final String appDescription;
  final VoidCallback callback;

  @override
  State<HappyApp> createState() => _HappyAppState();
}

class _HappyAppState extends State<HappyApp> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent, highlightColor: Colors.transparent,
      onTap: widget.callback,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: context.screenWidth * 0.02),
              Container(
                height: context.screenWidth * 0.15, width: context.screenWidth * 0.15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(widget.appIcon),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(width: context.screenWidth * 0.02),
              SizedBox(
                height: context.screenWidth * 0.15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.appTitle, style: TextStyle(fontSize: context.screenWidth * 0.04)),
                    Text(widget.appDescription, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right),
              SizedBox(width: context.screenWidth * 0.02),
            ],
          ),
          SizedBox(width: context.screenWidth * 0.96, child: const Divider(color: Colors.grey))
        ],
      ),
    );
  }
}
