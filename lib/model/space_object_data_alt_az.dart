class SpaceObjectDataAltAz {
  final double alt;
  final double az;
  final String name;

  SpaceObjectDataAltAz
({
    required this.alt,
    required this.az,
    required this.name,

  });

  double get getAlt => alt;
  double get getAz => az;
  String get getName => name;

}