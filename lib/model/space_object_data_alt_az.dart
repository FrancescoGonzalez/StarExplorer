class SpaceObjectDataAltAz {
  final double alt;
  final double az;
  final String name;
  final double? magnitude;

  SpaceObjectDataAltAz
({
    required this.alt,
    required this.az,
    required this.name,
    this.magnitude,

  });

  double get getAlt => alt;
  double get getAz => az;
  String get getName => name;
  double? get getMagnitude => magnitude;

}