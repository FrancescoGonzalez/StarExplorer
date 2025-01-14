class SpaceObjectData {
  final double ra;
  final double dec;
  final String name;

  SpaceObjectData({
    required this.ra,
    required this.dec,
    required this.name,
  });

  double get getRa => ra;
  double get getDec => dec;
  String get getName => name;
}
