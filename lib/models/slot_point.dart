class SlotPoint {
  final double x;
  final double y;

  SlotPoint({required this.x, required this.y});

  factory SlotPoint.fromMap(Map<String, dynamic> map) {
    return SlotPoint(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
    );
  }
}
