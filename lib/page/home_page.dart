import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:get/get.dart';
import 'package:motionsensor/dialog/filename_dialog.dart';
import 'package:motionsensor/page/setting_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock/wakelock.dart';

import '../components/snake.dart';
import '../services/shared_preference.dart';
import 'file_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class SensorValue {
  String? valueX;
  String? valueY;
  String? valueZ;
  String? timeStamp;

  SensorValue({this.valueX, this.valueY, this.valueZ, this.timeStamp});
}

class _HomePageState extends State<HomePage> {
  static const int _snakeRows = 20;
  static const int _snakeColumns = 36;
  static const double _snakeCellSize = 8.0;
  static const int _maxListLength = 50;

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  final List<SensorValue> _accelerometerList = [];
  final List<SensorValue> _userAccelerometerList = [];
  final List<SensorValue> _gyroscopeList = [];
  final List<SensorValue> _magnetometerList = [];

  List<SensorValue> _storedAccelerometerList = [];
  List<SensorValue> _storedUserAccelerometerList = [];
  List<SensorValue> _storedGyroscopeList = [];
  List<SensorValue> _storedMagnetometerList = [];

  bool _selectAccelerometer = true;
  bool _selectUserAccelerometer = false;
  bool _selectGyroscope = false;
  bool _selectMagnetometer = false;

  bool _onOffAccelerometer = true;
  bool _onOffUserAccelerometer = true;
  bool _onOffGyroscope = true;
  bool _onOffMagnetometer = true;

  String _offSetAccelerometer = "0.05";
  String _offSetUserAccelerometer = "0.05";
  String _offSetGyroscope = "0.05";
  String _offSetMagnetometer = "0.10";

  String _samplingRate = "10";

  bool _isRecording = false;
  bool _isSaving = false;

  String? _saveFileName = "";

  bool _useOnlyAccelerometer = true;

  @override
  void initState() {
    super.initState();
    loadStoredValues();
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      Wakelock.disable();
    } else {
      FlutterBackground.disableBackgroundExecution();
    }

    super.dispose();
    stopSubscription();
  }

  void stopSubscription() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  Future loadStoredValues() async {
    stopSubscription();

    debugPrint("loadStoredValues");

    _onOffAccelerometer = await SharedPreference().getSaveAccelerometer();
    _onOffUserAccelerometer = await SharedPreference().getSaveUserAccelerometer();

    if (!_useOnlyAccelerometer) {
      _onOffGyroscope = await SharedPreference().getSaveGyroscope();
      _onOffMagnetometer = await SharedPreference().getSaveMagnetometer();
    } else {
      _onOffGyroscope = false;
      _onOffMagnetometer = false;
    }

    if (!_useOnlyAccelerometer) {
      _offSetAccelerometer = await SharedPreference().getOffsetAccelerometer();
      _offSetUserAccelerometer = await SharedPreference().getOffsetUserAccelerometer();
      _offSetGyroscope = await SharedPreference().getOffsetGyroscope();
      _offSetMagnetometer = await SharedPreference().getOffsetMagnetometer();
      _samplingRate = await SharedPreference().getSamplingRate();
    } else {
      _offSetAccelerometer = "0.001";
      _offSetUserAccelerometer = "0.001";
      _offSetGyroscope = "0.001";
      _offSetMagnetometer = "0.001";
    }

    if (_onOffAccelerometer) {
      _streamSubscriptions.add(
        accelerometerEvents.listen(
          (AccelerometerEvent event) {
            _accelerometerValues = <double>[event.x, event.y, event.z];

            String valueX = event.x.toStringAsFixed(4);
            String valueY = event.y.toStringAsFixed(4);
            String valueZ = event.z.toStringAsFixed(4);

            if (valueX == "-0.000") {
              valueX = "0.000";
            }

            if (valueY == "-0.000") {
              valueY = "0.000";
            }

            if (valueZ == "-0.000") {
              valueZ = "0.000";
            }

            // if (_accelerometerList.isNotEmpty) {
            // SensorValue? value = _accelerometerList[_accelerometerList.length - 1];

            // if (!_useOnlyAccelerometer) {
            //   if (value.valueX == valueX && value.valueY == valueY && value.valueZ == valueZ) {
            //     return;
            //   }
            //
            //   double changeOffset = double.parse(_offSetAccelerometer);
            //
            //   if ((double.parse(value.valueX ?? "0") - double.parse(valueX)).abs() <= changeOffset &&
            //       (double.parse(value.valueY ?? "0") - double.parse(valueY)).abs() <= changeOffset &&
            //       (double.parse(value.valueZ ?? "0") - double.parse(valueZ)).abs() <= changeOffset) {
            //     return;
            //   }
            // }
            // }

            DateTime now = DateTime.now();
            int currentMilliSeconds = now.millisecondsSinceEpoch;
            DateTime date = DateTime.fromMillisecondsSinceEpoch(currentMilliSeconds);

            if (!_isRecording) {
              if (_accelerometerList.length > _maxListLength) {
                _accelerometerList.removeAt(0);
              }

              _accelerometerList.add(
                SensorValue(valueX: valueX, valueY: valueY, valueZ: valueZ, timeStamp: date.toString().substring(11)),
              );
            }

            if (_isRecording && _onOffAccelerometer) {
              _storedAccelerometerList.add(
                SensorValue(valueX: valueX, valueY: valueY, valueZ: valueZ, timeStamp: date.toString()),
              );
            }

            if (!_isRecording && mounted) {
              setState(() {});
            }
          },
        ),
      );
    }

    if (_onOffUserAccelerometer) {
      _streamSubscriptions.add(
        userAccelerometerEvents.listen(
          (UserAccelerometerEvent event) {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];

            String valueX = event.x.toStringAsFixed(4);
            String valueY = event.y.toStringAsFixed(4);
            String valueZ = event.z.toStringAsFixed(4);

            if (valueX == "-0.0000") {
              valueX = "0.0000";
            }

            if (valueY == "-0.0000") {
              valueY = "0.0000";
            }

            if (valueZ == "-0.0000") {
              valueZ = "0.0000";
            }

            // if (_userAccelerometerList.isNotEmpty) {
            // SensorValue? value = _userAccelerometerList[_userAccelerometerList.length - 1];

            // if (value.valueX == valueX && value.valueY == valueY && value.valueZ == valueZ) {
            //   return;
            // }
            //
            // double changeOffset = double.parse(_offSetUserAccelerometer);
            //
            // if ((double.parse(value.valueX ?? "0") - double.parse(valueX)).abs() <= changeOffset &&
            //     (double.parse(value.valueY ?? "0") - double.parse(valueY)).abs() <= changeOffset &&
            //     (double.parse(value.valueZ ?? "0") - double.parse(valueZ)).abs() <= changeOffset) {
            //   return;
            // }
            // }

            DateTime now = DateTime.now();
            int currentMilliSeconds = now.millisecondsSinceEpoch;
            DateTime date = DateTime.fromMillisecondsSinceEpoch(currentMilliSeconds);

            if (!_isRecording) {
              if (_userAccelerometerList.length > _maxListLength) {
                _userAccelerometerList.removeAt(0);
              }

              _userAccelerometerList.add(
                SensorValue(valueX: valueX, valueY: valueY, valueZ: valueZ, timeStamp: date.toString().substring(11)),
              );
            }

            if (_isRecording && _onOffUserAccelerometer) {
              _storedUserAccelerometerList.add(
                SensorValue(valueX: valueX, valueY: valueY, valueZ: valueZ, timeStamp: date.toString()),
              );
            }

            if (!_isRecording && mounted) {
              setState(() {});
            }
          },
        ),
      );
    }

    if (!_useOnlyAccelerometer) {
      // if (_onOffGyroscope) {
      //   _streamSubscriptions.add(
      //     gyroscopeEvents.listen(
      //       (GyroscopeEvent event) {
      //         _gyroscopeValues = <double>[event.x, event.y, event.z];
      //
      //         String valueX = event.x.toStringAsFixed(2);
      //         String valueY = event.y.toStringAsFixed(2);
      //         String valueZ = event.z.toStringAsFixed(2);
      //
      //         if (valueX == "-0.00") {
      //           valueX = "0.00";
      //         }
      //
      //         if (valueY == "-0.00") {
      //           valueY = "0.00";
      //         }
      //
      //         if (valueZ == "-0.00") {
      //           valueZ = "0.00";
      //         }
      //
      //         if (_gyroscopeList.isNotEmpty) {
      //           SensorValue? value = _gyroscopeList[_gyroscopeList.length - 1];
      //
      //           if (value.valueX == valueX && value.valueY == valueY && value.valueZ == valueZ) {
      //             return;
      //           }
      //
      //           double changeOffset = double.parse(_offSetGyroscope);
      //
      //           if ((double.parse(value.valueX ?? "0") - double.parse(valueX)).abs() <= changeOffset &&
      //               (double.parse(value.valueY ?? "0") - double.parse(valueY)).abs() <= changeOffset &&
      //               (double.parse(value.valueZ ?? "0") - double.parse(valueZ)).abs() <= changeOffset) {
      //             return;
      //           }
      //         }
      //
      //         if (_gyroscopeList.length > _maxListLength) {
      //           _gyroscopeList.removeAt(0);
      //         }
      //
      //         DateTime now = DateTime.now();
      //         int currentMilliSeconds = now.millisecondsSinceEpoch;
      //         DateTime date = DateTime.fromMillisecondsSinceEpoch(currentMilliSeconds);
      //
      //         _gyroscopeList.add(
      //           SensorValue(valueX: valueX, valueY: valueY, valueZ: valueZ, timeStamp: date.toString().substring(11)),
      //         );
      //
      //         if (_isRecording && _onOffGyroscope) {
      //           _storedGyroscopeList.add(
      //             SensorValue(valueX: valueX, valueY: valueY, valueZ: valueZ, timeStamp: date.toString()),
      //           );
      //         }
      //
      //         if (mounted) {
      //           setState(() {});
      //         }
      //       },
      //     ),
      //   );
      // }
      //
      // if (_onOffMagnetometer) {
      //   _streamSubscriptions.add(
      //     magnetometerEvents.listen(
      //       (MagnetometerEvent event) {
      //         _magnetometerValues = <double>[event.x, event.y, event.z];
      //
      //         String valueX = event.x.toStringAsFixed(2);
      //         String valueY = event.y.toStringAsFixed(2);
      //         String valueZ = event.z.toStringAsFixed(2);
      //
      //         if (valueX == "-0.00") {
      //           valueX = "0.00";
      //         }
      //
      //         if (valueY == "-0.00") {
      //           valueY = "0.00";
      //         }
      //
      //         if (valueZ == "-0.00") {
      //           valueZ = "0.00";
      //         }
      //
      //         if (_magnetometerList.isNotEmpty) {
      //           SensorValue? value = _magnetometerList[_magnetometerList.length - 1];
      //
      //           if (value.valueX == valueX && value.valueY == valueY && value.valueZ == valueZ) {
      //             return;
      //           }
      //
      //           double changeOffset = double.parse(_offSetMagnetometer);
      //
      //           if ((double.parse(value.valueX ?? "0") - double.parse(valueX)).abs() <= changeOffset &&
      //               (double.parse(value.valueY ?? "0") - double.parse(valueY)).abs() <= changeOffset &&
      //               (double.parse(value.valueZ ?? "0") - double.parse(valueZ)).abs() <= changeOffset) {
      //             return;
      //           }
      //         }
      //
      //         if (_magnetometerList.length > _maxListLength) {
      //           _magnetometerList.removeAt(0);
      //         }
      //
      //         DateTime now = DateTime.now();
      //         int currentMilliSeconds = now.millisecondsSinceEpoch;
      //         DateTime date = DateTime.fromMillisecondsSinceEpoch(currentMilliSeconds);
      //
      //         _magnetometerList.add(
      //           SensorValue(valueX: valueX, valueY: valueY, valueZ: valueZ, timeStamp: date.toString().substring(11)),
      //         );
      //
      //         if (_isRecording && _onOffMagnetometer) {
      //           _storedMagnetometerList.add(
      //             SensorValue(valueX: valueX, valueY: valueY, valueZ: valueZ, timeStamp: date.toString()),
      //           );
      //         }
      //
      //         if (mounted) {
      //           setState(() {});
      //         }
      //       },
      //     ),
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accelerometer = _accelerometerValues?.map((double v) {
      String value = v.toStringAsFixed(4);
      if (value == "-0.0000") {
        value = "0.0000";
      }
      return value;
    }).toList();

    final userAccelerometer = _userAccelerometerValues?.map((double v) {
      String value = v.toStringAsFixed(4);
      if (value == "-0.0000") {
        value = "0.0000";
      }
      return value;
    }).toList();

    if (false) {
      final gyroscope = _gyroscopeValues?.map((double v) {
        String value = v.toStringAsFixed(2);
        if (value == "-0.00") {
          value = "0.00";
        }
        return value;
      }).toList();

      final magnetometer = _magnetometerValues?.map((double v) {
        String value = v.toStringAsFixed(2);
        if (value == "-0.00") {
          value = "0.00";
        }
        return value;
      }).toList();
    }

    return SafeArea(
      top: true,
      bottom: false,
      child: Scaffold(
        appBar: null,
        backgroundColor: const Color(0xFFF2F2F2),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(width: 4),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: Colors.black38),
                    color: const Color(0xFFE2E2E2),
                  ),
                  child: SizedBox(
                    height: _snakeRows * _snakeCellSize,
                    width: _snakeColumns * _snakeCellSize,
                    child: Snake(
                      rows: _snakeRows,
                      columns: _snakeColumns,
                      cellSize: _snakeCellSize,
                      selectAccelerometer: _selectAccelerometer,
                      selectGyroscope: _selectGyroscope,
                      selectUserAccelerometer: _selectUserAccelerometer,
                      selectMagnetometer: _selectMagnetometer,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (_isRecording) {
                                return;
                              }

                              _saveFileName = "";
                              _saveFileName = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const FileNameDialog();
                                    },
                                    barrierDismissible: false,
                                  ) ??
                                  "";

                              if (_saveFileName == null) {
                                return;
                              }

                              _isRecording = true;

                              if (Platform.isIOS) {
                                Wakelock.enable();
                              } else {
                                await FlutterBackground.enableBackgroundExecution();
                              }

                              Get.snackbar("저장", "저장시작",
                                  snackPosition: SnackPosition.BOTTOM, duration: const Duration(milliseconds: 3000));

                              if (mounted) {
                                setState(() {});
                              }
                            },
                            child: Icon(Icons.fiber_smart_record, color: _isRecording ? Colors.grey : Colors.black),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (!_isRecording) {
                                return;
                              }

                              _isRecording = false;

                              if (Platform.isIOS) {
                                Wakelock.disable();
                              } else {
                                await FlutterBackground.disableBackgroundExecution();
                              }

                              _isSaving = true;

                              if (mounted) {
                                setState(() {});
                              }

                              String directoryPath = "";
                              if (Platform.isAndroid) {
                                final directory = await getTemporaryDirectory();
                                directoryPath = directory.path;
                              } else {
                                final directory = await getApplicationDocumentsDirectory();
                                directoryPath = directory.path;
                              }

                              debugPrint("directoryPath $directoryPath");

                              DateTime now = DateTime.now();

                              String savedFileNames = "";

                              checkFileExist(directoryPath);

                              if (_onOffAccelerometer && _storedAccelerometerList.isNotEmpty) {
                                String accelerometerName = "";
                                String resultStr = "";

                                // if (_samplingRate.isNotEmpty &&
                                //     int.tryParse(_samplingRate) != null &&
                                //     int.tryParse(_samplingRate)! > 0) {
                                //   if (_saveFileName != null && _saveFileName!.isNotEmpty) {
                                //     accelerometerName =
                                //         "$directoryPath/accelerometer_${_saveFileName}_${_samplingRate}ms.csv";
                                //   } else {
                                //     accelerometerName =
                                //         "$directoryPath/accelerometer_${now.toString()}_${_samplingRate}ms.csv";
                                //   }
                                //
                                //   File accelerometerFile10ms = File(accelerometerName);
                                //
                                //   resultStr = makeSavedStringToFile(
                                //       _storedAccelerometerList, int.tryParse(_samplingRate) ?? 10);
                                //   await accelerometerFile10ms.writeAsString(resultStr);
                                //   savedFileNames = "${accelerometerName.split("/").last}\n";
                                // }

                                // accelerometerName = "";
                                // if (_saveFileName != null && _saveFileName!.isNotEmpty) {
                                //   accelerometerName = "$directoryPath/accelerometer_${_saveFileName}_5ms.csv";
                                // } else {
                                //   accelerometerName = "$directoryPath/accelerometer_${now.toString()}_5ms.csv";
                                // }
                                //
                                // File accelerometerFile5ms = File(accelerometerName);
                                // resultStr = "";
                                // resultStr = makeSavedStringToFile(_storedAccelerometerList, 5);
                                // await accelerometerFile5ms.writeAsString(resultStr);
                                // savedFileNames = "${accelerometerName.split("/").last}\n";

                                accelerometerName = "";
                                if (_saveFileName != null && _saveFileName!.isNotEmpty) {
                                  accelerometerName = "$directoryPath/accelerometer_$_saveFileName.csv";
                                } else {
                                  accelerometerName = "$directoryPath/accelerometer_${now.toString()}.csv";
                                }

                                File accelerometerFile = File(accelerometerName);
                                resultStr = "";
                                for (int i = 0; i < _storedAccelerometerList.length; i++) {
                                  if (resultStr.isNotEmpty) {
                                    resultStr += "\n";
                                  }

                                  resultStr +=
                                      "${_storedAccelerometerList[i].timeStamp},${_storedAccelerometerList[i].valueX},${_storedAccelerometerList[i].valueY},${_storedAccelerometerList[i].valueZ}";
                                }
                                await accelerometerFile.writeAsString(resultStr);
                                _storedAccelerometerList = [];

                                savedFileNames += "${accelerometerName.split("/").last}\n";
                              }

                              if (_onOffUserAccelerometer && _storedUserAccelerometerList.isNotEmpty) {
                                String userAccelerometerName = "";
                                String resultStr = "";

                                // if (_samplingRate.isNotEmpty &&
                                //     int.tryParse(_samplingRate) != null &&
                                //     int.tryParse(_samplingRate)! > 0) {
                                //   if (_saveFileName != null && _saveFileName!.isNotEmpty) {
                                //     userAccelerometerName =
                                //         "$directoryPath/user_accelerometer_${_saveFileName}_${_samplingRate}ms.csv";
                                //   } else {
                                //     userAccelerometerName =
                                //         "$directoryPath/user_accelerometer_${now.toString()}_${_samplingRate}ms.csv";
                                //   }
                                //   File userAccelerometerFile10ms = File(userAccelerometerName);
                                //
                                //   resultStr = makeSavedStringToFile(
                                //       _storedUserAccelerometerList, int.tryParse(_samplingRate) ?? 10);
                                //
                                //   await userAccelerometerFile10ms.writeAsString(resultStr);
                                //   savedFileNames += "${userAccelerometerName.split("/").last}\n";
                                // }

                                // userAccelerometerName = "";
                                // if (_saveFileName != null && _saveFileName!.isNotEmpty) {
                                //   userAccelerometerName = "$directoryPath/user_accelerometer_${_saveFileName}_5ms.csv";
                                // } else {
                                //   userAccelerometerName = "$directoryPath/user_accelerometer_${now.toString()}_5ms.csv";
                                // }
                                // File userAccelerometerFile5ms = File(userAccelerometerName);
                                //
                                // resultStr = "";
                                // resultStr = makeSavedStringToFile(_storedUserAccelerometerList, 5);
                                // await userAccelerometerFile5ms.writeAsString(resultStr);
                                // savedFileNames += "${userAccelerometerName.split("/").last}\n";

                                userAccelerometerName = "";
                                if (_saveFileName != null && _saveFileName!.isNotEmpty) {
                                  userAccelerometerName = "$directoryPath/user_accelerometer_$_saveFileName.csv";
                                } else {
                                  userAccelerometerName = "$directoryPath/user_accelerometer_${now.toString()}.csv";
                                }

                                File userAccelerometerFile = File(userAccelerometerName);

                                resultStr = "";
                                for (int i = 0; i < _storedUserAccelerometerList.length; i++) {
                                  if (resultStr.isNotEmpty) {
                                    resultStr += "\n";
                                  }

                                  resultStr +=
                                      "${_storedUserAccelerometerList[i].timeStamp},${_storedUserAccelerometerList[i].valueX},${_storedUserAccelerometerList[i].valueY},${_storedUserAccelerometerList[i].valueZ}";
                                }

                                await userAccelerometerFile.writeAsString(resultStr);

                                _storedUserAccelerometerList = [];
                                savedFileNames += "${userAccelerometerName.split("/").last}\n";
                              }

                              if (false) {
                                if (_onOffGyroscope && _storedGyroscopeList.isNotEmpty) {
                                  String gyroscopeName = "";

                                  if (_saveFileName != null || _saveFileName!.isNotEmpty) {
                                    gyroscopeName = "$directoryPath/gyroscope_$_saveFileName.csv";
                                  } else {
                                    gyroscopeName = "$directoryPath/gyroscope_${now.toString()}.csv";
                                  }
                                  File gyroscopeFile = File(gyroscopeName);

                                  debugPrint("item count ${_storedGyroscopeList.length}");

                                  String resultStr = "";
                                  for (int i = 0; i < _storedGyroscopeList.length; i++) {
                                    resultStr +=
                                        "\n${_storedGyroscopeList[i].timeStamp};${_storedGyroscopeList[i].valueX};${_storedGyroscopeList[i].valueY};${_storedGyroscopeList[i].valueZ};";
                                  }
                                  await gyroscopeFile.writeAsString(resultStr);

                                  _storedGyroscopeList = [];
                                  savedFileNames += "${gyroscopeName.split("/").last}\n";
                                }

                                if (_onOffMagnetometer && _storedMagnetometerList.isNotEmpty) {
                                  String magnetometerName = "";

                                  if (_saveFileName != null || _saveFileName!.isNotEmpty) {
                                    magnetometerName = "$directoryPath/magnetometer_$_saveFileName.csv";
                                  } else {
                                    magnetometerName = "$directoryPath/magnetometer_${now.toString()}.csv";
                                  }
                                  File magnetometerFile = File(magnetometerName);

                                  debugPrint("item count ${_storedMagnetometerList.length}");

                                  String resultStr = "";
                                  for (int i = 0; i < _storedMagnetometerList.length; i++) {
                                    resultStr +=
                                        "\n${_storedMagnetometerList[i].timeStamp};${_storedMagnetometerList[i].valueX};${_storedMagnetometerList[i].valueY};${_storedMagnetometerList[i].valueZ};";
                                  }
                                  await magnetometerFile.writeAsString(resultStr);

                                  _storedMagnetometerList = [];
                                  savedFileNames += "${magnetometerName.split("/").last}\n";
                                }
                              }

                              _isSaving = false;

                              if (mounted) {
                                setState(() {});
                              }

                              Get.snackbar("저장종료", "$savedFileNames 파일이 저장되었습니다.",
                                  snackPosition: SnackPosition.BOTTOM, duration: const Duration(milliseconds: 3000));

                              if (mounted) {
                                setState(() {});
                              }
                            },
                            child: Icon(Icons.stop, color: !_isRecording ? Colors.grey : Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              _isRecording = false;

                              stopSubscription();
                              await Get.to(() => const FileListPage());
                              loadStoredValues();
                            },
                            child: const Icon(Icons.receipt_long_rounded),
                          ),
                          GestureDetector(
                            onTap: () async {
                              _isRecording = false;

                              stopSubscription();
                              await Get.to(() => const SettingPage());
                              loadStoredValues();

                              if (mounted) {
                                setState(() {});
                              }
                            },
                            child: const Icon(Icons.settings),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_selectAccelerometer || _onOffAccelerometer == false) {
                          return;
                        }

                        _selectAccelerometer = true;
                        _selectUserAccelerometer = false;
                        _selectGyroscope = false;
                        _selectMagnetometer = false;

                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectAccelerometer ? const Color(0xFFE3E3FF) : Colors.white,
                          border: Border.all(
                            color: (_isRecording && _onOffAccelerometer) ? Colors.red : Colors.transparent,
                            width: (_isRecording && _onOffAccelerometer) ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(color: Colors.black, offset: Offset(0, 0.5), blurRadius: 0.5),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Column(
                          children: [
                            Container(
                              height: 24,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: const Text(
                                "Accelerometer",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            Container(
                              height: 20,
                              alignment: Alignment.center,
                              child: Text(
                                "$accelerometer",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: _accelerometerList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    index = (_accelerometerList.length - 1) - index;

                                    return Row(
                                      children: [
                                        const SizedBox(width: 4),
                                        Text(
                                          "[${_accelerometerList[index].timeStamp ?? ""}]",
                                          style: const TextStyle(
                                            fontSize: 8,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "${_accelerometerList[index].valueX}",
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "${_accelerometerList[index].valueY}",
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "${_accelerometerList[index].valueZ}",
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_selectUserAccelerometer || _onOffUserAccelerometer == false) {
                          return;
                        }

                        _selectAccelerometer = false;
                        _selectUserAccelerometer = true;
                        _selectGyroscope = false;
                        _selectMagnetometer = false;

                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectUserAccelerometer ? const Color(0xFFE3E3FF) : Colors.white,
                          border: Border.all(
                            color: (_isRecording && _onOffUserAccelerometer) ? Colors.teal : Colors.transparent,
                            width: (_isRecording && _onOffUserAccelerometer) ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(color: Colors.black, offset: Offset(0, 0.5), blurRadius: 0.5),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Column(
                          children: [
                            Container(
                              height: 24,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: const Text(
                                "UserAccelerometer",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                            Container(
                              height: 20,
                              alignment: Alignment.center,
                              child: Text(
                                "$userAccelerometer",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: _userAccelerometerList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Row(
                                      children: [
                                        const SizedBox(width: 4),
                                        Text(
                                          "[${_userAccelerometerList[index].timeStamp ?? ""}]",
                                          style: const TextStyle(
                                            fontSize: 8,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "${_userAccelerometerList[index].valueX}",
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "${_userAccelerometerList[index].valueY}",
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "${_userAccelerometerList[index].valueZ}",
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 8,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Expanded(
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: GestureDetector(
            //           onTap: () {
            //             if (_selectGyroscope || _onOffGyroscope == false) {
            //               return;
            //             }
            //
            //             _selectAccelerometer = false;
            //             _selectUserAccelerometer = false;
            //             _selectGyroscope = true;
            //             _selectMagnetometer = false;
            //
            //             if (mounted) {
            //               setState(() {});
            //             }
            //           },
            //           child: Container(
            //             decoration: BoxDecoration(
            //               color: _selectGyroscope ? const Color(0xFFE3E3FF) : Colors.white,
            //               border: Border.all(
            //                 color: (_isRecording && _onOffGyroscope) ? Colors.blueAccent : Colors.transparent,
            //                 width: (_isRecording && _onOffGyroscope) ? 3 : 1,
            //               ),
            //               borderRadius: BorderRadius.circular(4),
            //               boxShadow: const [
            //                 BoxShadow(color: Colors.black, offset: Offset(0, 0.5), blurRadius: 0.5),
            //               ],
            //             ),
            //             padding: const EdgeInsets.symmetric(vertical: 4),
            //             margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            //             child: Column(
            //               children: [
            //                 Container(
            //                   height: 24,
            //                   alignment: Alignment.center,
            //                   padding: const EdgeInsets.symmetric(horizontal: 12),
            //                   child: const Text(
            //                     "Gyroscope",
            //                     style: TextStyle(
            //                       fontSize: 16,
            //                       fontWeight: FontWeight.w700,
            //                       color: Colors.blueAccent,
            //                     ),
            //                   ),
            //                 ),
            //                 Container(
            //                   height: 20,
            //                   alignment: Alignment.center,
            //                   child: Text(
            //                     "$gyroscope",
            //                     style: const TextStyle(
            //                       fontSize: 16,
            //                       fontWeight: FontWeight.w700,
            //                       color: Colors.black,
            //                     ),
            //                   ),
            //                 ),
            //                 const SizedBox(height: 6),
            //                 Expanded(
            //                   child: SingleChildScrollView(
            //                     child: ListView.builder(
            //                       shrinkWrap: true,
            //                       physics: const ClampingScrollPhysics(),
            //                       itemCount: _gyroscopeList.length,
            //                       itemBuilder: (BuildContext context, int index) {
            //                         return Row(
            //                           children: [
            //                             const SizedBox(width: 4),
            //                             Text(
            //                               "[${_gyroscopeList[index].timeStamp ?? ""}]",
            //                               style: const TextStyle(
            //                                 fontSize: 10,
            //                                 color: Colors.grey,
            //                                 fontWeight: FontWeight.w400,
            //                               ),
            //                             ),
            //                             const SizedBox(width: 6),
            //                             Expanded(
            //                               child: Text(
            //                                 "${_gyroscopeList[index].valueX}",
            //                                 textAlign: TextAlign.right,
            //                                 style: const TextStyle(
            //                                   fontSize: 10,
            //                                   color: Colors.black,
            //                                   fontWeight: FontWeight.w700,
            //                                 ),
            //                               ),
            //                             ),
            //                             Expanded(
            //                               child: Text(
            //                                 "${_gyroscopeList[index].valueY}",
            //                                 textAlign: TextAlign.right,
            //                                 style: const TextStyle(
            //                                   fontSize: 10,
            //                                   color: Colors.black,
            //                                   fontWeight: FontWeight.w700,
            //                                 ),
            //                               ),
            //                             ),
            //                             Expanded(
            //                               child: Text(
            //                                 "${_gyroscopeList[index].valueZ}",
            //                                 textAlign: TextAlign.right,
            //                                 style: const TextStyle(
            //                                   fontSize: 10,
            //                                   color: Colors.black,
            //                                   fontWeight: FontWeight.w700,
            //                                 ),
            //                               ),
            //                             ),
            //                             const SizedBox(width: 6),
            //                           ],
            //                         );
            //                       },
            //                     ),
            //                   ),
            //                 ),
            //                 const SizedBox(height: 4),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //       Expanded(
            //         child: GestureDetector(
            //           onTap: () {
            //             if (_selectMagnetometer || _onOffMagnetometer == false) {
            //               return;
            //             }
            //
            //             _selectAccelerometer = false;
            //             _selectUserAccelerometer = false;
            //             _selectGyroscope = false;
            //             _selectMagnetometer = true;
            //
            //             if (mounted) {
            //               setState(() {});
            //             }
            //           },
            //           child: Container(
            //             decoration: BoxDecoration(
            //               color: _selectMagnetometer ? const Color(0xFFE3E3FF) : Colors.white,
            //               border: Border.all(
            //                 color: (_isRecording && _onOffMagnetometer) ? Colors.deepPurple : Colors.transparent,
            //                 width: (_isRecording && _onOffMagnetometer) ? 3 : 1,
            //               ),
            //               borderRadius: BorderRadius.circular(4),
            //               boxShadow: const [
            //                 BoxShadow(color: Colors.black, offset: Offset(0, 0.5), blurRadius: 0.5),
            //               ],
            //             ),
            //             padding: const EdgeInsets.symmetric(vertical: 4),
            //             margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            //             child: Column(
            //               children: [
            //                 Container(
            //                   height: 24,
            //                   alignment: Alignment.center,
            //                   padding: const EdgeInsets.symmetric(horizontal: 12),
            //                   child: const Text(
            //                     "Magnetometer",
            //                     style: TextStyle(
            //                       fontSize: 16,
            //                       fontWeight: FontWeight.w700,
            //                       color: Colors.deepPurple,
            //                     ),
            //                   ),
            //                 ),
            //                 Container(
            //                   height: 20,
            //                   alignment: Alignment.center,
            //                   child: Text(
            //                     "$magnetometer",
            //                     style: const TextStyle(
            //                       fontSize: 14,
            //                       fontWeight: FontWeight.w700,
            //                       color: Colors.black,
            //                     ),
            //                   ),
            //                 ),
            //                 const SizedBox(height: 6),
            //                 Expanded(
            //                   child: SingleChildScrollView(
            //                     child: ListView.builder(
            //                       shrinkWrap: true,
            //                       physics: const ClampingScrollPhysics(),
            //                       itemCount: _magnetometerList.length,
            //                       itemBuilder: (BuildContext context, int index) {
            //                         return Row(
            //                           children: [
            //                             const SizedBox(width: 2),
            //                             Text(
            //                               "[${_magnetometerList[index].timeStamp ?? ""}]",
            //                               style: const TextStyle(
            //                                 fontSize: 9,
            //                                 color: Colors.grey,
            //                                 fontWeight: FontWeight.w400,
            //                               ),
            //                             ),
            //                             const SizedBox(width: 4),
            //                             Expanded(
            //                               child: Text(
            //                                 "${_magnetometerList[index].valueX}",
            //                                 textAlign: TextAlign.right,
            //                                 style: const TextStyle(
            //                                   fontSize: 9,
            //                                   color: Colors.black,
            //                                   fontWeight: FontWeight.w700,
            //                                 ),
            //                               ),
            //                             ),
            //                             Expanded(
            //                               child: Text(
            //                                 "${_magnetometerList[index].valueY}",
            //                                 textAlign: TextAlign.right,
            //                                 style: const TextStyle(
            //                                   fontSize: 9,
            //                                   color: Colors.black,
            //                                   fontWeight: FontWeight.w700,
            //                                 ),
            //                               ),
            //                             ),
            //                             Expanded(
            //                               child: Text(
            //                                 "${_magnetometerList[index].valueZ}",
            //                                 textAlign: TextAlign.right,
            //                                 maxLines: 1,
            //                                 style: const TextStyle(
            //                                   fontSize: 9,
            //                                   color: Colors.black,
            //                                   fontWeight: FontWeight.w700,
            //                                 ),
            //                               ),
            //                             ),
            //                             const SizedBox(width: 4),
            //                           ],
            //                         );
            //                       },
            //                     ),
            //                   ),
            //                 ),
            //                 const SizedBox(height: 4),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Future checkFileExist(String directoryPath) async {
    if (_saveFileName == null || _saveFileName!.isEmpty) {
      return;
    }

    int index = 1;

    while (true) {
      String accelerometerName = "$directoryPath/accelerometer_$_saveFileName.csv";
      // String userAccelerometerName = "$directoryPath/user_accelerometer_$_saveFileName.csv";
      // String gyroscopeName = "$directoryPath/gyroscope_$_saveFileName.csv";
      // String magnetometerName = "$directoryPath/magnetometer_$_saveFileName.csv";

      if (File(accelerometerName).existsSync()
          // || File(userAccelerometerName).existsSync() ||
          // File(gyroscopeName).existsSync() ||
          // File(magnetometerName).existsSync()
          ) {
        if (_saveFileName!.contains("_(")) {
          _saveFileName = "${_saveFileName!.substring(0, _saveFileName!.indexOf("_("))}_(${index.toString()})";
        } else {
          _saveFileName = "${_saveFileName}_(${index.toString()})";
        }

        index++;
      } else {
        break;
      }
    }
  }

  String makeSavedStringToFile(List<SensorValue> pList, int duration) {
    String resultStr = "";

    if (pList.isEmpty) {
      return "";
    }

    DateTime startTime = DateTime.parse(pList[0].timeStamp!);
    DateTime endTime = DateTime.parse(pList[pList.length - 1].timeStamp!);

    int index = 0;
    while (startTime.compareTo(endTime) <= 0) {
      DateTime time = DateTime.parse(pList[index].timeStamp!);

      while (startTime.compareTo(time) > 0) {
        index++;
        time = DateTime.parse(pList[index].timeStamp!);
      }

      String valueX = pList[index].valueX!;
      String valueY = pList[index].valueY!;
      String valueZ = pList[index].valueZ!;

      if (resultStr.isNotEmpty) {
        resultStr += "\n";
      }

      resultStr += "${startTime.toString()},$valueX,$valueY,$valueZ";
      startTime = startTime.add(Duration(milliseconds: duration));
    }

    return resultStr;
  }
}
