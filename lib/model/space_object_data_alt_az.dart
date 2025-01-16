class SpaceObjectDataAltAz {
  final double alt;
  final double az;
  final String name;
  final double? magnitude;
  final String? type;

  SpaceObjectDataAltAz({
    required this.alt,
    required this.az,
    required this.name,
    this.magnitude,
    this.type,
  });

  double get getAlt => alt;
  double get getAz => az;
  String get getName => name;
  double? get getMagnitude => magnitude;
  String? get getType => type;
}
