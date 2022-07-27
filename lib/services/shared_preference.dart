import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  static String offsetAccelerometerKey = "offset_accelerometer";
  static String offsetUserAccelerometerKey = "offset_user_accelerometer";
  static String offsetGyroscopeKey = "offset_gyroscope2";
  static String offsetMagnetometerKey = "offset_magnetometer";
  static String samplingRateKey = "sampling_rate";

  static String saveAccelerometerKey = "save_accelerometer";
  static String saveUserAccelerometerKey = "save_user_accelerometer";
  static String saveGyroscopeKey = "save_gyroscope";
  static String saveMagnetometerKey = "save_magnetometer";

  Future<bool> saveOffsetAccelerometer(String accelerometer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(offsetAccelerometerKey, accelerometer);
  }

  Future<bool> saveOffsetUserAccelerometer(String userAccelerometer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(offsetUserAccelerometerKey, userAccelerometer);
  }

  Future<bool> saveOffsetGyroscope(String gyroscope) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(offsetGyroscopeKey, gyroscope);
  }

  Future<bool> saveOffsetMagnetometer(String magnetometer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(offsetMagnetometerKey, magnetometer);
  }

  Future<bool> saveSamplingRate(String rate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(samplingRateKey, rate);
  }

  Future<String> getOffsetAccelerometer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(offsetAccelerometerKey) ?? '0.50';
  }

  Future<String> getOffsetUserAccelerometer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(offsetUserAccelerometerKey) ?? '0.50';
  }

  Future<String> getOffsetGyroscope() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(offsetGyroscopeKey) ?? '0.25';
  }

  Future<String> getOffsetMagnetometer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(offsetMagnetometerKey) ?? '2.00';
  }

  Future<String> getSamplingRate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(samplingRateKey) ?? '10';
  }

  Future<bool> saveSaveAccelerometer(bool onOff) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(saveAccelerometerKey, onOff);
  }

  Future<bool> saveSaveUserAccelerometer(bool onOff) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(saveUserAccelerometerKey, onOff);
  }

  Future<bool> saveSaveGyroscope(bool onOff) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(saveGyroscopeKey, onOff);
  }

  Future<bool> saveSaveMagnetometer(bool onOff) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(saveMagnetometerKey, onOff);
  }

  Future<bool> getSaveAccelerometer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(saveAccelerometerKey) ?? true;
  }

  Future<bool> getSaveUserAccelerometer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(saveUserAccelerometerKey) ?? true;
  }

  Future<bool> getSaveGyroscope() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(saveGyroscopeKey) ?? true;
  }

  Future<bool> getSaveMagnetometer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(saveMagnetometerKey) ?? true;
  }

  Future clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(offsetAccelerometerKey);
    prefs.remove(offsetUserAccelerometerKey);
    prefs.remove(offsetGyroscopeKey);
    prefs.remove(offsetMagnetometerKey);

    prefs.remove(saveAccelerometerKey);
    prefs.remove(saveUserAccelerometerKey);
    prefs.remove(saveGyroscopeKey);
    prefs.remove(saveMagnetometerKey);
  }
}
