import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<void> removeExistingDeviceName() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey("wifi name")) {
      await preferences.remove('wifi name');
    }
  }

  Future<bool?> checkIfUserCancelledDeviceNameMismatchPrompt() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.containsKey("cancelled");
  }

  setUserCancelledDeviceNameMismatchPrompt() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("cancelled", true);
  }

  removeUserCancelledDeviceNameMismatchPrompt() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("cancelled")) {
      sharedPreferences.remove("cancelled");
    }
  }

  Future<bool> doesPreviousDeviceExist() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey("wifi name");
  }

  Future<void> saveWiFiName(String name) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString("wifi name", name);
  }

  Future<String?> previousWiFiName() async {
    final preferences = await SharedPreferences.getInstance();
    String? wifiName = preferences.getString('wifi name');
    // Logger.i('Previous WiFi name is $wifiName');
    return wifiName;
  }

  Future<void> saveVoiceSpeed(int speed) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('voice speed', speed);
  }

  Future<void> saveVoicePitch(int pitch) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('voice pitch', pitch);
  }

  Future<void> saveLanguage(int lang) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('language', lang);
  }

  Future<void> saveProcessingSoundState(bool play) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('processing sound', play);
  }

  Future<void> saveTermsAndConditionsState(bool shown) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('terms', shown);
  }

  Future<int> getVoiceSpeed() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey("voice speed")
        ? preferences.getInt('voice speed') ?? 0
        : 0;
  }

  Future<int> getVoicePitch() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey("voice pitch")
        ? preferences.getInt('voice pitch') ?? 0
        : 0;
  }

  Future<int> getLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey("language")
        ? preferences.getInt('language') ?? 0
        : 0;
  }

  Future<bool?> getProcessingSoundState() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey("processing sound")
        ? preferences.getBool('processing sound')
        : true;
  }

  Future<bool?> getTermsAndConditionsState() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey("terms")
        ? preferences.getBool('terms')
        : false;
  }

  Future<void> saveSelectedLanguage(String language) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString("selected_language", language);
  }

  Future<String?> getSelectedLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    String? language = preferences.getString('selected_language');
    // Logger.i('Previous WiFi name is $wifiName');
    return language;
  }

}
