class MeasurementEntity {
  final String id;
  final String deviceId;
  final double waterFlow;
  final DateTime timestamp;

  MeasurementEntity({
    required this.id,
    required this.deviceId,
    required this.waterFlow,
    required this.timestamp,
  });
}
