import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


// State class to hold all the data
class AddressState {
  final String currentAddress;
  final String currentWeatherData;
  final String currentWeatherWind;
  final String currentWeatherIcon;
  final double currentWeatherWindDegree;
  final double currentLatitude;
  final double currentLongitude;

  AddressState({
    this.currentAddress = "",
    this.currentWeatherData = "",
    this.currentWeatherWind = "",
    this.currentWeatherIcon = "",
    this.currentWeatherWindDegree = 0.0,
    this.currentLatitude = 0.0,
    this.currentLongitude = 0.0,
  });

  AddressState copyWith({
    String? currentAddress,
    String? currentWeatherData,
    String? currentWeatherWind,
    String? currentWeatherIcon,
    double? currentWeatherWindDegree,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    return AddressState(
      currentAddress: currentAddress ?? this.currentAddress,
      currentWeatherData: currentWeatherData ?? this.currentWeatherData,
      currentWeatherWind: currentWeatherWind ?? this.currentWeatherWind,
      currentWeatherIcon: currentWeatherIcon ?? this.currentWeatherIcon,
      currentWeatherWindDegree: currentWeatherWindDegree ?? this.currentWeatherWindDegree,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }
}

// StateNotifier for AddressController
class AddressController extends StateNotifier<AddressState> {
  final Ref ref;

  AddressController(this.ref) : super(AddressState()) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      state = state.copyWith(
        currentLatitude: position.latitude,
        currentLongitude: position.longitude,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      String address = "";
      if (placemarks.isNotEmpty) {
        var placemark = placemarks.first;
        if (Platform.isIOS) {
          address = "${placemark.administrativeArea} ${placemark.subLocality ?? ""}";
        } else {
          address =
          "${placemark.administrativeArea} ${placemark.locality} ${placemark.subLocality ?? ""} ${placemark.thoroughfare ?? ""}";
        }
      }

      state = state.copyWith(currentAddress: address.trim());

      // If UserInfoController is also converted to Riverpod, access it via ref
      // final userController = ref.read(userInfoControllerProvider.notifier);
      // // await userController.upDataUserNatoinInfo(state.currentAddress);
      //
      // await getWeather(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  Future<void> getCurrentOnlyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      state = state.copyWith(
        currentLatitude: position.latitude,
        currentLongitude: position.longitude,
      );
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  // Future<void> getWeather(double lat, double lon) async {
  //   try {
  //     WeatherFactory wf;
  //     // Note: Get.deviceLocale is removed, you might want to pass locale differently
  //     // For now, I'll use Platform.localeName as an alternative
  //     String localLang = Platform.localeName.substring(0, 2);
  //     if (localLang == "ko") {
  //       wf = WeatherFactory("29c6e0ee33deafea93d96b2c513ceaa8", language: Language.KOREAN);
  //     } else {
  //       wf = WeatherFactory("29c6e0ee33deafea93d96b2c513ceaa8", language: Language.ENGLISH);
  //     }
  //
  //     Weather w = await wf.currentWeatherByLocation(lat, lon);
  //
  //     state = state.copyWith(
  //       currentWeatherData: "${w.temperature!.celsius!.toStringAsFixed(1)}°C ${w.weatherDescription}",
  //       currentWeatherWind: "${w.windSpeed}",
  //       currentWeatherWindDegree: w.windDegree!,
  //       currentWeatherIcon: "${w.weatherIcon}",
  //     );
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
}

// Provider setup
final addressControllerProvider = StateNotifierProvider<AddressController, AddressState>((ref) {
  return AddressController(ref);
});

// // If UserInfoController needs to be accessed
// final userInfoControllerProvider = StateNotifierProvider<UserInfoController, UserInfoState>((ref) {
//   return UserInfoController(ref); // Adjust based on your UserInfoController implementation
// });