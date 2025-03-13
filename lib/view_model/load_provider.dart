import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Provider 정의
// final loadingProvider = StateProvider<bool>((ref) => false);
//
// // LoadingController 클래스 (선택적 - 필요에 따라 사용)
// class LoadingController {
//   final Ref ref;
//
//   LoadingController(this.ref);
//
//   bool get isLoading => ref.watch(loadingProvider);
//   set isLoading(bool value) => ref.read(loadingProvider.notifier).state = value;
//
// // 정적 인스턴스 대신 Provider 사용 권장
// // static LoadingController get to => 사용하지 않음
// }
//
// // 사용 예시를 위한 Provider 설정
// final loadingControllerProvider = Provider<LoadingController>((ref) {
//   return LoadingController(ref);
// });



final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier();
});

// Notifier class
class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void setLoading(bool value) {
    state = value;
  }
}

// // LoadingController Provider 정의
// final loadingControllerProvider = Provider<LoadingController>((ref) {
//   return LoadingController(ref);
// });
//
// final loadingProvider = StateProvider<bool>((ref) => false);
//
// class LoadingController {
//   final Ref ref;
//   LoadingController(this.ref);
//   bool get isLoading => ref.watch(loadingProvider);
//   set isLoading(bool value) => ref.read(loadingProvider.notifier).state = value;
// }