library wifi_easy_connect;

import 'package:flutter/services.dart';

part 'src/capability.dart';
part 'src/error.dart';
part 'src/result.dart';

/// The `wifi_easy_connect` plugin entry point.
///
/// To get a new instance, call [WiFiEasyConnect.instance].
class WiFiEasyConnect {
  WiFiEasyConnect._();

  /// Singleton instance of [WiFiEasyConnect].
  static final instance = WiFiEasyConnect._();

  final _channel = const MethodChannel('wifi_easy_connect');

  /// Check if supports Wi-Fi Easy connect (Device Provisioning Protocol).
  ///
  /// Returns [WiFiEasyConnectCapability] value.
  Future<WiFiEasyConnectCapability> hasCapability() async {
    final capabilityCode = await _channel.invokeMethod<int>("hasCapability");
    return _deserializeCapability(capabilityCode!);
  }

  /// Onboard a device to join network via Wi-Fi Easy Connect (DPP).
  ///
  /// TODO: more info about args and return value.
  Future<Result<OnboardingInfo, OnboardErrors>> onboard(Uri dppUri,
      {List<int>? bands}) async {
    assert(dppUri.scheme.toUpperCase() == "DPP", "Valid scheme for DPP URI");

    final map = await _channel.invokeMapMethod("onboard", {
      "dppUri": dppUri.toString(),
      "brands": bands,
    });

    // check if any error - return Result._error if any
    final errorCode = map!["error"];
    if (errorCode != null) {
      return Result._error(_deserializeOnboardingError(errorCode));
    }
    // parse and return list of WiFiAccessPoint
    return Result._value(OnboardingInfo._fromMap(map["value"]));
  }
}

/// Information about Wi-Fi Easy Connect (DPP) onboarding flow.
///
/// For more info, see [WiFiEasyConnect.onboard].
class OnboardingInfo {
  OnboardingInfo._fromMap(Map map);
}
