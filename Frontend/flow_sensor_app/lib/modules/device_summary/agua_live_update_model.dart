class AguaLiveUpdate {
  final String deviceId;
  final List<DailyResult> dailyResult;
  final List<HourData> last5HoursData;

  AguaLiveUpdate({
    required this.deviceId,
    required this.dailyResult,
    required this.last5HoursData,
  });

  factory AguaLiveUpdate.fromJson(Map<String, dynamic> json) {
    return AguaLiveUpdate(
      deviceId: json['deviceId'],
      dailyResult:
          (json['dailyResult'] as List<dynamic>)
              .map((e) => DailyResult.fromJson(e))
              .toList(),
      last5HoursData:
          (json['last5HoursData'] as List<dynamic>)
              .map((e) => HourData.fromJson(e))
              .toList(),
    );
  }
}

class DailyResult {
  final String? id;
  final double dailyVolume;

  DailyResult({required this.id, required this.dailyVolume});

  factory DailyResult.fromJson(Map<String, dynamic> json) {
    return DailyResult(
      id: json['_id'],
      dailyVolume: (json['dailyVolume'] as num).toDouble(),
    );
  }
}

class HourData {
  final String id;
  final double flowRate;
  final double secVolume;
  final double totalVolume;
  final DateTime timestamp;
  final String deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  HourData({
    required this.id,
    required this.flowRate,
    required this.secVolume,
    required this.totalVolume,
    required this.timestamp,
    required this.deviceId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory HourData.fromJson(Map<String, dynamic> json) {
    return HourData(
      id: json['_id'],
      flowRate: (json['flowRate'] as num).toDouble(),
      secVolume: (json['secVolume'] as num).toDouble(),
      totalVolume: (json['totalVolume'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      deviceId: json['deviceId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'] ?? 0,
    );
  }
}
