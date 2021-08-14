import 'package:device_info/device_info.dart';
import 'dart:io';


class DeviceInfoProvider{

  // Get device info
  static Future<String> gerDeviceInfo() async{
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    late String deviceInfo;
    if (Platform.isAndroid){
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      deviceInfo = 'Android_'+androidDeviceInfo.androidId;
    } else if (Platform.isIOS){
      IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      deviceInfo = 'iOS_'+iosDeviceInfo.identifierForVendor;
    } else {
      deviceInfo = 'not_supported';
    }
    return deviceInfo;
  }

}