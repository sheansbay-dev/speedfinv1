// /speedfin/lib/core/models/fine_model.dart

class Fine {
  final String id;
  final DateTime timestamp;
  final double actualSpeed;
  final double speedLimit;
  final double latitude;
  final double longitude;
  final bool isPaid; // ගෙවා ඇත්දැයි බැලීමට (අනාගතයේදී අවශ්‍ය විය හැක)

  Fine({
    required this.id,
    required this.timestamp,
    required this.actualSpeed,
    required this.speedLimit,
    required this.latitude,
    required this.longitude,
    this.isPaid = false,
  });

  // Database හෝ JSON වලින් දත්ත ලබා ගැනීමට factory constructor
  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      actualSpeed: (json['actualSpeed'] as num).toDouble(),
      speedLimit: (json['speedLimit'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isPaid: json['isPaid'] as bool,
    );
  }

  // Database හෝ JSON වෙත දත්ත යැවීමට Map එකක් බවට පත් කිරීම
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'actualSpeed': actualSpeed,
      'speedLimit': speedLimit,
      'latitude': latitude,
      'longitude': longitude,
      'isPaid': isPaid,
    };
  }
}
