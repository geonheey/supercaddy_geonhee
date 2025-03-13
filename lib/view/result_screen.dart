import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResultScreen extends ConsumerState {
  final double distance;

  ResultScreen({required this.distance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Distance Result")),
      body: Center(
        child: Text('Distance to the flag: $distance meters'),
      ),
    );
  }
}
