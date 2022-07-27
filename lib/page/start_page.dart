import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:get/get.dart';

import 'home_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isAndroid) {
        var androidConfig = const FlutterBackgroundAndroidConfig(
          notificationTitle: "Motion Sensor",
          notificationText: "background 처리를 위해 필요합니다.",
          notificationImportance: AndroidNotificationImportance.Default,
          notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'),
        );

        bool success = await FlutterBackground.initialize(androidConfig: androidConfig);

        debugPrint("FlutterBackground $success");
        bool hasPermissions = await FlutterBackground.hasPermissions;
      }

      Get.off(() => const HomePage());
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white);
  }
}
