import 'package:android_id/android_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:nurbanhoney/config/config.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  
  KakaoSdk.init(
    nativeAppKey: kakaoNativeAppKey,
  );

  const androidIdPlugin = AndroidId();

  final String androidId = await androidIdPlugin.getId() ?? '';

  runApp(ProviderScope(
    child: App(
      deviceId: androidId,
    ),
  ));
}

