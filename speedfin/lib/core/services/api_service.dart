// /speedfin/lib/core/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speedfin/utils/app_logger.dart';
import 'dart:io' show Platform; // NEW: Platform import කරන්න

class ApiService {
  // NEW: Platform එක අනුව Base URL තීරණය කරන්න
  // Android Emulator = 10.0.2.2
  // iOS Simulator / macOS = 127.0.0.1
  static final String _baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:5000/api' // Android Emulator සඳහා
      : 'http://127.0.0.1:5000/api'; // iOS Simulator / macOS සඳහා

  // වේග සීමාව ලබා ගැනීම
  Future<double> fetchSpeedLimit(double lat, double lon) async {
    final uri = Uri.parse('$_baseUrl/speedlimit?lat=$lat&lon=$lon');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i('API Success: Speed limit fetched: ${data['limit']}');
        return (data['limit'] as num).toDouble();
      } else {
        logger.e(
          'API Error: Status code ${response.statusCode}, Body: ${response.body}',
        );
        return 90.0;
      }
    } catch (e) {
      logger.e(
        'API Network Error: ClientException with SocketException: $e',
      ); // SocketException විස්තරය ලොග් කරන්න
      return 90.0;
    }
  }

  // ... logFine function ...
  Future<bool> logFine({
    required double actualSpeed,
    required double speedLimit,
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$_baseUrl/logfine');
    final Map<String, dynamic> fineData = {
      'actualSpeed': actualSpeed,
      'speedLimit': speedLimit,
      'latitude': latitude,
      'longitude': longitude,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(fineData),
      );

      if (response.statusCode == 201) {
        logger.w('Fine successfully sent to Backend.');
        return true;
      } else {
        logger.e('Failed to log fine. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      logger.e('Fine logging Network Error: $e');
      return false;
    }
  }
}

//class ApiService {
  // Backend එකේ URL
  // සටහන: Android Emulator එකේදී 127.0.0.1 වෙනුවට 10.0.2.2 භාවිත කරන්න
  //static const String _baseUrl = 'http://127.0.0.1:5000/api';