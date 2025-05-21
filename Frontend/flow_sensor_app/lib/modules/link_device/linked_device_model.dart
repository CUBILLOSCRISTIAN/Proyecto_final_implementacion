class LinkedDevice {
  final String? id;
  final String name;
  final String serial;
  final DateTime? createdAt;

  LinkedDevice({
    this.id,
    required this.name,
    required this.serial,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'serial': serial};

  factory LinkedDevice.fromJson(Map<String, dynamic> json) {
    return LinkedDevice(
      id: json['id'],
      name: json['name'],
      serial: json['serial'],
    );
  }
}
