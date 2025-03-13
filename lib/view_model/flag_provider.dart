import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;


import '../data/models/flag_model.dart';
import '../data/repository/flag_repository.dart';
import '../view/finder/screen/finder.dart';

// State class to hold all the data
class FlagState {
  final String golfPlace;
  final int selectGolfPlace;
  final int selectFlagH;
  final int selectFlagV;
  final double selectLatitude;
  final double selectLongitude;
  final String selectUnit;
  final List<String> placeNames;
  final List<String> placeDistance;
  final List<double> placeLatitude;
  final List<double> placeLongitude;
  final List<bool> downFlag;
  final List<FlagModel?> flags;

  FlagState({
    this.golfPlace = "",
    this.selectGolfPlace = -1,
    this.selectFlagH = -1,
    this.selectFlagV = -1,
    this.selectLatitude = -1.0,
    this.selectLongitude = -1.0,
    this.selectUnit = "",
    this.placeNames = const [],
    this.placeDistance = const [],
    this.placeLatitude = const [],
    this.placeLongitude = const [],
    this.downFlag = const [],
    this.flags = const [],
  });

  FlagState copyWith({
    String? golfPlace,
    int? selectGolfPlace,
    int? selectFlagH,
    int? selectFlagV,
    double? selectLatitude,
    double? selectLongitude,
    String? selectUnit,
    List<String>? placeNames,
    List<String>? placeDistance,
    List<double>? placeLatitude,
    List<double>? placeLongitude,
    List<bool>? downFlag,
    List<FlagModel?>? flags,
  }) {
    return FlagState(
      golfPlace: golfPlace ?? this.golfPlace,
      selectGolfPlace: selectGolfPlace ?? this.selectGolfPlace,
      selectFlagH: selectFlagH ?? this.selectFlagH,
      selectFlagV: selectFlagV ?? this.selectFlagV,
      selectLatitude: selectLatitude ?? this.selectLatitude,
      selectLongitude: selectLongitude ?? this.selectLongitude,
      selectUnit: selectUnit ?? this.selectUnit,
      placeNames: placeNames ?? this.placeNames,
      placeDistance: placeDistance ?? this.placeDistance,
      placeLatitude: placeLatitude ?? this.placeLatitude,
      placeLongitude: placeLongitude ?? this.placeLongitude,
      downFlag: downFlag ?? this.downFlag,
      flags: flags ?? this.flags,
    );
  }
}

// StateNotifier for FlagController
class FlagController extends StateNotifier<FlagState> {
  // final FlagRepository? flagRepository;
  final Ref ref;
  static const String apiKey = "AIzaSyAxBp8JosSR1DXqXzwomtEFlQDU-rZ9clU";
  //
  FlagController(this.ref,) : super(FlagState());
  //
  // Future<void> getFlags(String plcNM) async {
  //   if (flagRepository != null) {
  //     final flags = await flagRepository!.getFlagList(plcNM);
  //     state = state.copyWith(flags: flags);
  //   }
  // }

  Future<String?> insertFlag(int hz, int vr, String nm, String unit) async {
    // return await flagRepository!.insertFlag(hz, vr, nm, unit);
  }

  Future<void> getGolfCourses(double latitude, double longitude, String query) async {
    state = state.copyWith(
      placeNames: [],
      placeDistance: [],
      placeLatitude: [],
      placeLongitude: [],
    );

    print(query);
    String url = '';
    try {
      if (query.isEmpty) {
        url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=golf+course&location=$latitude,$longitude&radius=5000&key=$apiKey';
      } else {
        url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query+golf+course&key=$apiKey';
      }

      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String responseString = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(responseString);
        final List<dynamic> results = jsonData['results'];

        List<Map<String, dynamic>> golfCourses = [];

        for (var result in results) {
          String placeName = result['name'];
          double lat = result['geometry']['location']['lat'];
          double lng = result['geometry']['location']['lng'];

          double distance = Geolocator.distanceBetween(
            latitude,
            longitude,
            lat,
            lng,
          ) / 1000; // Convert to kilometers

          golfCourses.add({
            'name': placeName,
            'distance': distance,
            'latitude': lat,
            'longitude': lng,
          });
        }

        // Sort by distance
        golfCourses.sort((a, b) => a['distance'].compareTo(b['distance']));

        // Update state with sorted results
        state = state.copyWith(
          placeNames: golfCourses.map((e) => e['name'] as String).toList(),
          placeDistance: golfCourses
              .map((e) => (e['distance'] as double).toStringAsFixed(1))
              .toList(),
          placeLatitude: golfCourses.map((e) => e['latitude'] as double).toList(),
          placeLongitude: golfCourses.map((e) => e['longitude'] as double).toList(),
        );

        print("Sorted Golf Courses: ${state.placeNames}");
        print("Sorted Distances: ${state.placeDistance}");
        print("Sorted Latitudes: ${state.placeLatitude}");
        print("Sorted Longitudes: ${state.placeLongitude}");

        // Insert flags for new places
        for (final placeName in state.placeNames) {
          // await getFlags(placeName);
          if (state.flags.isEmpty) {
            await insertFlag(46, 35, placeName, "cm");
            await insertFlag(50, 35, placeName, "cm");
          }
        }
      } else {
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> getGolfNear(double latitude, double longitude) async {
    await getGolfCourses(latitude, longitude, "");
  }
}

// // Provider setup
// final flagControllerProvider = StateNotifierProvider<FlagController, FlagState>((ref) {
//   final flagRepository = ref.watch(flagRepositoryProvider); // Assuming you have this provider
//   return FlagController(ref, flagRepository: flagRepository);
// });

// Example usage of AddressController with Riverpod
final addressControllerProvider = Provider<AddressController>((ref) {
  return AddressController(); // Adjust based on your actual AddressController setup
});