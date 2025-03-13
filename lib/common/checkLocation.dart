import 'dart:ui';

import 'package:geolocator/geolocator.dart';

Future<bool> isInKorea() async {
  // 위치 권한 요청
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  LocationPermission permission = await Geolocator.checkPermission();

  if (!serviceEnabled || permission == LocationPermission.denied) {
    return false; // 위치 서비스가 꺼져 있거나 권한이 없으면 false
  }

  // 현재 위치 가져오기
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  double latitude = position.latitude;
  double longitude = position.longitude;

  // 한국의 위도/경도 범위 확인
  if (latitude >= 33.0 && latitude <= 38.5 && longitude >= 124.0 && longitude <= 131.0) {
    return true;  // 한국 안에 있음
  } else {
    return false;  // 한국 밖에 있음
  }
}
bool isKoreanSystemLocale() {
  Locale locale = PlatformDispatcher.instance.locale; // Flutter 3.13 이상
  return locale.languageCode == 'ko';
}