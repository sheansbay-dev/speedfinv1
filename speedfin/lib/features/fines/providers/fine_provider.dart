// /speedfin/lib/features/fines/providers/fine_provider.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:speedfin/core/models/fine_model.dart';
import 'package:speedfin/utils/app_logger.dart'; // NEW: logger utility එක import කරන්න

class FineProvider with ChangeNotifier {
  // සටහන: pubspec.yaml වෙත uuid package එක එකතු කර ඇති බවට තහවුරු කර ගන්න.
  final Uuid _uuid = const Uuid();
  final List<Fine> _fines = []; // සියලු දඩපත් ගබඩා කරන ලැයිස්තුව

  List<Fine> get fines => _fines;

  // නව දඩපතක් එකතු කිරීම
  void addFine({
    required double actualSpeed,
    required double speedLimit,
    required double latitude,
    required double longitude,
  }) {
    // 1. අලුත් Fine object එකක් නිර්මාණය කිරීම
    final newFine = Fine(
      id: _uuid.v4(), // Universal Unique Identifier
      timestamp: DateTime.now(),
      actualSpeed: actualSpeed,
      speedLimit: speedLimit,
      latitude: latitude,
      longitude: longitude,
    );

    // 2. ලැයිස්තුවට එකතු කිරීම
    _fines.add(newFine);

    // 3. යෙදුම දැනුම්වත් කිරීම (දඩපත් ඉතිහාස තිරය යාවත්කාලීන කිරීමට)
    notifyListeners();

    // 4. Console එකේ ලොග් කිරීම (Good Practice)
    // 'print' වෙනුවට 'logger' භාවිත කරන්න
    logger.w(
      // Warning level එක භාවිත කරන්නේ වැදගත් සිදුවීමක් නිසා
      'NEW FINE LOGGED! Speed: ${newFine.actualSpeed.toStringAsFixed(1)} KM/H in ${newFine.speedLimit.round()} Zone',
    );
    // Debug level එකෙන් අමතර විස්තර ලොග් කිරීම
    logger.d(
      'Fine Details: ID=${newFine.id}, Location=(${newFine.latitude.toStringAsFixed(4)}, ${newFine.longitude.toStringAsFixed(4)})',
    );
  }

  // අනාගතයේදී:
  // void markAsPaid(String fineId) {}
  // void fetchFinesFromLocalDb() {}
}
