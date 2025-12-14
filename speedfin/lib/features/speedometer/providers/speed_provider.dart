// /speedfin/lib/features/speedometer/providers/speed_provider.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speedfin/core/services/location_service.dart';
import 'package:speedfin/core/services/audio_service.dart';
import 'package:speedfin/core/services/api_service.dart'; // NEW: ApiService
import 'package:speedfin/features/fines/providers/fine_provider.dart';
import 'package:speedfin/utils/app_logger.dart';

class SpeedProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService(); // NEW: ApiService
  final FineProvider _fineProvider;

  double _currentSpeed = 0.0;
  double _speedLimit = 90.0;
  bool _isOverspeeding = false;
  bool _isOverspeedingAlertActive = false;
  bool _isFetchingSpeedLimit = false;
  DateTime? _lastFineLogged;

  SpeedProvider(this._fineProvider);

  double get currentSpeed => _currentSpeed;
  double get speedLimit => _speedLimit;
  bool get isOverspeeding => _isOverspeeding;

  void startListening() async {
    // 1. Service ආරම්භ කිරීම
    await _audioService.init();
    bool hasPermission = await _locationService.checkLocationPermission();

    if (!hasPermission) {
      logger.e('Location Permission Denied.');
      return;
    }

    logger.i('SpeedProvider: Location Listening Started.');

    _locationService.getPositionStream().listen((Position position) {
      _currentSpeed = position.speed * 3.6; // m/s සිට km/h

      // Map API ඇමතුම් වාරණය (Rate Limiter)
      if (!_isFetchingSpeedLimit) {
        // සෑම තත්පර 10කට වරක් පමණක් Map API ඇමතීම
        fetchSpeedLimit(position.latitude, position.longitude);
      }

      _isOverspeeding = _currentSpeed > _speedLimit + 5; // 5 km/h tolerance

      // Audio Alert සහ Fine Logic
      if (_isOverspeeding) {
        if (!_isOverspeedingAlertActive) {
          _audioService.playAlert();
          _isOverspeedingAlertActive = true;
        }

        // 10 km/h ට වඩා වැඩිවීම සහ වාර්තා කිරීමට සුදුසු නම්
        if (_currentSpeed > _speedLimit + 10 && _shouldLogFine()) {
          logViolation(position, _speedLimit);
        }
      } else {
        _isOverspeedingAlertActive = false;
      }

      notifyListeners();
    });
  }

  // Rate Limiter
  void fetchSpeedLimit(double lat, double lon) async {
    _isFetchingSpeedLimit = true;
    _speedLimit = await _apiService.fetchSpeedLimit(lat, lon);
    _isFetchingSpeedLimit = false;
    notifyListeners();

    // ඊළඟ ඇමතුම සඳහා ප්‍රමාදය
    await Future.delayed(const Duration(seconds: 10));
    _isFetchingSpeedLimit = false;
  }

  bool _shouldLogFine() {
    // අවසන් දඩපත සටහන් කර විනාඩි 1කට වඩා ගත වී ඇත්දැයි බලන්න
    if (_lastFineLogged == null) return true;
    return DateTime.now().difference(_lastFineLogged!).inMinutes >= 1;
  }

  void logViolation(Position position, double limit) async {
    _lastFineLogged = DateTime.now(); // Fine Block Start

    // Backend එකට දඩපත යවන්න
    final bool isLogged = await _apiService.logFine(
      actualSpeed: _currentSpeed,
      speedLimit: limit,
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (isLogged) {
      // Backend එකේ සාර්ථකව සටහන් වූ පසු පමණක් Local FineProvider වෙත එක් කරන්න
      _fineProvider.addFine(
        actualSpeed: _currentSpeed,
        speedLimit: limit,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      logger.w('Fine successfully added to local history.');
    } else {
      logger.e('Fine logging failed at the Backend.');
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
