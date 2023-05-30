import 'dart:io';
import 'package:flutter/material.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/constant_values.dart';
import 'package:imsakiye_namaz_vakitleri/Utils/screen_resolutions.dart';


class VerseAndHadith extends StatefulWidget {
  const VerseAndHadith({Key? key, required this.listOfQuotes, required this.isVerse}) : super(key: key);

  final List listOfQuotes;
  final bool isVerse;

  @override
  State<VerseAndHadith> createState() => _VerseAndHadithState();
}

class _VerseAndHadithState extends State<VerseAndHadith> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(title: widget.isVerse ? 'Günün Ayetleri' : 'Günün Hadisleri'),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: context.screenWidth * 0.94,
            child: Column(
              children: [
                for(int i = 0; i < widget.listOfQuotes.length; i++)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(i == 0) SizedBox(height: context.screenHeight * 0.01),
                      Text(
                          widget.isVerse ? widget.listOfQuotes[i]['ayet'] : widget.listOfQuotes[i]['hadith'],
                          style: const TextStyle(fontSize: 14.8, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text(
                            widget.listOfQuotes[i]['author'],
                            style: const TextStyle(fontSize: 13)),
                      ),
                      SizedBox(width: context.screenWidth * 0.96, child: const Divider(color: Colors.grey)),
                      if(Platform.isIOS) if(i == widget.listOfQuotes.length - 1) SizedBox(height: context.screenHeight * 0.05),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
