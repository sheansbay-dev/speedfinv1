// /speedfin/lib/features/speedometer/providers/speed_provider.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speedfin/core/services/location_service.dart';
import 'package:speedfin/core/services/map_api_service.dart';
import 'package:speedfin/core/services/audio_service.dart'; // NEW: AudioService
import 'package:speedfin/features/fines/providers/fine_provider.dart';
import 'package:speedfin/utils/app_logger.dart'; // NEW: Logger

class SpeedProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  final MapApiService _mapApiService = MapApiService();
  final AudioService _audioService =
      AudioService(); // NEW: AudioService instance
  final FineProvider _fineProvider; // Store Fine provider

  // NEW: FineProvider instance එක constructor හරහා ලබා ගනී
  SpeedProvider(this._fineProvider);

  // State Variables
  double _currentSpeed = 0.0; // km/h
  double _speedLimit = 0.0; // km/h (ප්‍රථමයෙන් 0.0)
  bool _isOverspeeding = false;

  // NEW: Audio Alert State
  bool _isOverspeedingAlertActive =
      false; // අනතුරු ඇඟවීම දැනට ක්‍රියාත්මකදැයි පෙන්වයි

  // Throttling Variables
  bool _isFetchingSpeedLimit = false;
  DateTime _lastViolationTime = DateTime.now().subtract(
    const Duration(days: 1),
  );
  final int _violationLogIntervalSeconds =
      15; // දඩපත් සටහන් කිරීමේ අවම කාල පරතරය (තත්පර)

  // API Throttling
  DateTime _lastApiCallTime = DateTime.now().subtract(
    const Duration(minutes: 5),
  );
  final int _apiCallIntervalSeconds = 15; // වේග සීමා API ඇමතීමේ කාල පරතරය

  // Getters
  double get currentSpeed => _currentSpeed;
  double get speedLimit => _speedLimit;
  bool get isOverspeeding => _isOverspeeding;

  // -----------------------------------------------------------
  // GPS/Listening Logic
  // -----------------------------------------------------------

  void startListening() async {
    // 1. AudioService ආරම්භ කිරීම
    await _audioService.init();
    logger.i('SpeedProvider: Audio Service Initialized.');

    bool hasPermission = await _locationService.checkLocationPermission();
    if (!hasPermission) {
      logger.w(
        'SpeedProvider: Location permission denied. Cannot start monitoring.',
      );
      return;
    }

    logger.i('SpeedProvider: Location stream started.');

    _locationService.getPositionStream().listen((Position position) {
      // 1. වේගය යාවත්කාලීන කිරීම (m/s සිට km/h දක්වා)
      _currentSpeed = position.speed > 0 ? position.speed * 3.6 : 0.0;

      // 2. වේග සීමාව ඉක්මවා ඇත්දැයි පරීක්ෂා කිරීම
      _isOverspeeding = _speedLimit > 0 && (_currentSpeed > _speedLimit + 5);

      // 3. Map API එක ඇමතීම - Throttling භාවිතයෙන්
      if (!_isFetchingSpeedLimit &&
          DateTime.now().difference(_lastApiCallTime).inSeconds >=
              _apiCallIntervalSeconds) {
        fetchSpeedLimit(position.latitude, position.longitude);
      }

      // 4. Audio Alert Logic
      if (_isOverspeeding) {
        if (!_isOverspeedingAlertActive) {
          _audioService.playAlert();
          _isOverspeedingAlertActive = true;
          logger.w(
            'Overspeeding Alert Triggered: ${_currentSpeed.round()} > ${_speedLimit.round()}',
          );
        }

        // 5. දඩපතක් සටහන් කිරීම
        if (position.accuracy < 10 && _shouldLogFine()) {
          logViolation(position, _speedLimit);
        }
      } else {
        // වේග සීමාව තුළ තිබේ නම් අනතුරු ඇඟවීම නවත්වන්න (නැවත වාදනය වීම නවත්වන්න)
        _isOverspeedingAlertActive = false;
        // Note: අපගේ AudioService එක repeat වෙන්නේ නැති නිසා stop කිරීමට අවශ්‍ය නොවේ.
      }

      notifyListeners();
    });
  }

  // **අවශ්‍යයි: Provider එක dispose කිරීම**
  @override
  void dispose() {
    _audioService.dispose(); // Audio Player එක නිදහස් කිරීම
    logger.i('SpeedProvider: Disposed.');
    super.dispose();
  }

  // -----------------------------------------------------------
  // API Logic
  // -----------------------------------------------------------

  void fetchSpeedLimit(double lat, double lon) async {
    _isFetchingSpeedLimit = true;
    _lastApiCallTime = DateTime.now();

    try {
      _speedLimit = await _mapApiService.fetchSpeedLimit(lat, lon);
      logger.d('API Call: New speed limit set to ${_speedLimit.round()} km/h');
    } catch (e) {
      logger.e('API Error: Failed to fetch speed limit: $e');
      // API අසාර්ථක වුවහොත්, පෙරනිමි නාගරික වේග සීමාවක් භාවිත කරන්න
      _speedLimit = 50.0;
    }

    _isFetchingSpeedLimit = false;

    // වේග සීමාව 0.0 නම් පෙරනිමි අගයක් ලබා දෙන්න
    if (_speedLimit == 0.0) {
      _speedLimit = 50.0;
      logger.w('Speed Limit was 0.0, defaulting to 50.0 km/h');
    }
    notifyListeners();
  }

  // -----------------------------------------------------------
  // Fine Logging Logic
  // -----------------------------------------------------------

  bool _shouldLogFine() {
    // දඩපත් සටහන් කිරීමේ අවම කාල පරතරය පරීක්ෂා කිරීම
    return DateTime.now().difference(_lastViolationTime).inSeconds >=
        _violationLogIntervalSeconds;
  }

  void logViolation(Position position, double limit) {
    if (!_shouldLogFine()) {
      logger.d(
        'Fine blocked: Violation occurred but within ${_violationLogIntervalSeconds}s interval.',
      );
      return;
    }

    // දඩපත් සටහන් කිරීම
    _fineProvider.addFine(
      actualSpeed: _currentSpeed,
      speedLimit: limit,
      latitude: position.latitude,
      longitude: position.longitude,
    );

    // අවසාන දඩපත් සටහන් කළ කාලය යාවත්කාලීන කිරීම
    _lastViolationTime = DateTime.now();
    logger.w(
      'FINE LOGGED! Current Fine Blocked until ${_lastViolationTime.add(Duration(seconds: _violationLogIntervalSeconds))}',
    );
  }
}
