import 'package:flutter/material.dart';

import '../components/custom_appbar.dart';
import '../components/custom_menu_item.dart';
import '../components/text_title.dart';
import '../services/shared_preference.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _onOffAccelerometer = true;
  bool _onOffUserAccelerometer = true;
  bool _onOffGyroscope = true;
  bool _onOffMagnetometer = true;

  String _offSetAccelerometer = "0.01";
  String _offSetUserAccelerometer = "0.01";
  String _offSetGyroscope = "0.01";
  String _offSetMagnetometer = "0.01";

  String _samplingRate = "10";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _onOffAccelerometer = await SharedPreference().getSaveAccelerometer();
      _onOffUserAccelerometer = await SharedPreference().getSaveUserAccelerometer();
      _onOffGyroscope = await SharedPreference().getSaveGyroscope();
      _onOffMagnetometer = await SharedPreference().getSaveMagnetometer();

      _offSetAccelerometer = await SharedPreference().getOffsetAccelerometer();
      _offSetUserAccelerometer = await SharedPreference().getOffsetUserAccelerometer();
      _offSetGyroscope = await SharedPreference().getOffsetGyroscope();
      _offSetMagnetometer = await SharedPreference().getOffsetMagnetometer();
      _samplingRate = await SharedPreference().getSamplingRate();

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(iconData: Icons.arrow_back),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const TextTitle(
                titleText: "onOff",
                fontSize: 22,
              ),
              CustomMenuItem(
                title: "accelerometer",
                iconData: Icons.compare_arrows_outlined,
                isSwitchItem: true,
                switchOnOff: _onOffAccelerometer,
                onPressed: () async {
                  _onOffAccelerometer = !_onOffAccelerometer;
                  SharedPreference().saveSaveAccelerometer(_onOffAccelerometer);

                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
              CustomMenuItem(
                title: "userAccelerometer",
                iconData: Icons.compare_arrows_rounded,
                isSwitchItem: true,
                switchOnOff: _onOffUserAccelerometer,
                onPressed: () async {
                  _onOffUserAccelerometer = !_onOffUserAccelerometer;
                  SharedPreference().saveSaveUserAccelerometer(_onOffUserAccelerometer);

                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
              // CustomMenuItem(
              //   title: "gyroscope",
              //   iconData: Icons.sports_gymnastics,
              //   isSwitchItem: true,
              //   switchOnOff: _onOffGyroscope,
              //   onPressed: () async {
              //     _onOffGyroscope = !_onOffGyroscope;
              //     SharedPreference().saveSaveGyroscope(_onOffGyroscope);
              //
              //     if (mounted) {
              //       setState(() {});
              //     }
              //   },
              // ),
              // CustomMenuItem(
              //   title: "magnetometer",
              //   iconData: Icons.change_circle_rounded,
              //   isSwitchItem: true,
              //   switchOnOff: _onOffMagnetometer,
              //   onPressed: () async {
              //     _onOffMagnetometer = !_onOffMagnetometer;
              //     SharedPreference().saveSaveMagnetometer(_onOffMagnetometer);
              //
              //     if (mounted) {
              //       setState(() {});
              //     }
              //   },
              // ),
              const SizedBox(height: 20),
              // const TextTitle(
              //   titleText: "offset",
              //   fontSize: 22,
              // ),
              // CustomMenuItem(
              //   title: "accelerometer",
              //   iconData: Icons.compare_arrows_outlined,
              //   isTextItem: true,
              //   textItemValue: _offSetAccelerometer,
              //   onPressed: () async {
              //     String? result = await showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return OffSetDialog(
              //           title: "accelerometer",
              //           value: _offSetAccelerometer,
              //         );
              //       },
              //       barrierDismissible: false,
              //     );
              //
              //     if (result != null && result.isNotEmpty) {
              //       _offSetAccelerometer = result;
              //
              //       if (mounted) {
              //         setState(() {});
              //       }
              //     }
              //   },
              // ),
              // CustomMenuItem(
              //   title: "userAccelerometer",
              //   iconData: Icons.compare_arrows_rounded,
              //   isTextItem: true,
              //   textItemValue: _offSetUserAccelerometer,
              //   onPressed: () async {
              //     String? result = await showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return OffSetDialog(
              //           title: "userAccelerometer",
              //           value: _offSetUserAccelerometer,
              //         );
              //       },
              //       barrierDismissible: false,
              //     );
              //
              //     if (result != null && result.isNotEmpty) {
              //       _offSetUserAccelerometer = result;
              //
              //       if (mounted) {
              //         setState(() {});
              //       }
              //     }
              //   },
              // ),
              // CustomMenuItem(
              //   title: "gyroscope",
              //   isTextItem: true,
              //   textItemValue: _offSetGyroscope,
              //   iconData: Icons.sports_gymnastics,
              //   onPressed: () async {
              //     String? result = await showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return OffSetDialog(
              //           title: "gyroscope",
              //           value: _offSetGyroscope,
              //         );
              //       },
              //       barrierDismissible: false,
              //     );
              //
              //     if (result != null && result.isNotEmpty) {
              //       _offSetGyroscope = result;
              //
              //       if (mounted) {
              //         setState(() {});
              //       }
              //     }
              //   },
              // ),
              // CustomMenuItem(
              //   title: "magnetometer",
              //   isTextItem: true,
              //   textItemValue: _offSetMagnetometer,
              //   iconData: Icons.change_circle_rounded,
              //   onPressed: () async {
              //     String? result = await showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return OffSetDialog(
              //           title: "magnetometer",
              //           value: _offSetMagnetometer,
              //         );
              //       },
              //       barrierDismissible: false,
              //     );
              //
              //     if (result != null && result.isNotEmpty) {
              //       _offSetMagnetometer = result;
              //
              //       if (mounted) {
              //         setState(() {});
              //       }
              //     }
              //   },
              // ),
              // const TextTitle(
              //   titleText: "Sampling Rate",
              //   fontSize: 22,
              // ),
              // CustomMenuItem(
              //   title: "Sampling Rate",
              //   isTextItem: true,
              //   textItemValue: _samplingRate,
              //   iconData: Icons.change_circle_rounded,
              //   onPressed: () async {
              //     String? result = await showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return OffSetDialog(
              //           title: "sampling rate",
              //           value: _samplingRate,
              //         );
              //       },
              //       barrierDismissible: false,
              //     );
              //
              //     if (result != null && result.isNotEmpty) {
              //       _samplingRate = result;
              //
              //       if (mounted) {
              //         setState(() {});
              //       }
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
