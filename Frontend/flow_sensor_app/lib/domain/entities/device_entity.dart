class DeviceEntity {
  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;

  DeviceEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
  });
}
