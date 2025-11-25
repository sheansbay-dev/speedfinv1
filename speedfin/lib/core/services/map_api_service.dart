// /speedfin/lib/core/services/map_api_service.dart

// Map API වෙතින් වේග සීමා දත්ත ලබා ගැනීමට (සැබෑ ලෝකයේදී http භාවිත කරයි)
class MapApiService {
  // සටහන: සැබෑ ලෝකයේදී මෙහිදී ඔබ Google Roads API (Speed Limits) හෝ
  // වෙනත් Map Provider කෙනෙකුගේ API යතුරක් භාවිත කරනු ඇත.
  // එම සේවාවලට ගාස්තු අය කළ හැක.

  // තාවකාලික ක්‍රියාත්මක කිරීමක් (Mock Implementation)
  Future<double> fetchSpeedLimit(double lat, double lon) async {
    // API ඇමතුමක ප්‍රමාදය අනුකරණය කිරීම
    await Future.delayed(const Duration(milliseconds: 500));

    // ස්ථානය මත පදනම්ව වේග සීමාව අනුකරණය කිරීම
    // උදා: 40ට වැඩි අක්ෂාංශ තිබේ නම් (උතුරු යුරෝපය) අධිවේගී මාර්ගවල 130 km/h,
    // නැතිනම් නාගරික කලාපවල 50 km/h යැයි උපකල්පනය කරමු.
    if (lat > 40 && lat < 60) {
      // දකුණු යුරෝපයේ අධිවේගී මාර්ග (Mock)
      return 130.0;
    } else if (lat >= 60) {
      // උතුරු යුරෝපය (Mock)
      return 100.0;
    } else if (lat < 40 && lon > -10) {
      // නාගරික කලාප (Mock)
      return 50.0;
    }

    // පෙරනිමි අගය
    return 90.0;
  }
}
