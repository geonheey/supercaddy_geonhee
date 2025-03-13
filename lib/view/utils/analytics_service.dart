// analytics_service.dart

import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  // 싱글톤 패턴으로 클래스 인스턴스 관리
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal() {
    // Firebase Analytics 인스턴스 초기화
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }

  late FirebaseAnalytics _analytics;
  late FirebaseAnalyticsObserver _observer;

  FirebaseAnalytics get analytics => _analytics;
  FirebaseAnalyticsObserver get observer => _observer;

  // 로그 이벤트를 기록하는 메서드
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

// 기타 Analytics 관련 메서드도 여기에 추가할 수 있습니다
}
