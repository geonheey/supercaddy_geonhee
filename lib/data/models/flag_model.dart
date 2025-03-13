class FlagModel {
  final int hz;
  final int vr;
  final String name;
  final String unit;

  FlagModel({
    required this.hz,
    required this.vr,
    required this.name,
    required this.unit,
  });

  factory FlagModel.fromJson(Map<String, dynamic> json) {
    return FlagModel(
      hz: json['hz'],
      vr: json['vr'],
      name: json['name'],
      unit: json['unit'],
    );
  }
}
