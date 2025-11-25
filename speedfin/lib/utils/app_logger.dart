// /speedfin/lib/utils/app_logger.dart

import 'package:logger/logger.dart';

// Logger instance එක නිර්මාණය කිරීම
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // පෙන්වන stack trace ගණන
    errorMethodCount: 5, // දෝෂ ඇති විට පෙන්වන stack trace ගණන
    lineLength: 50, // ලොග් පණිවිඩයේ උපරිම දිග
    colors: true, // ලොග් කිරීමේදී වර්ණ භාවිත කරන්න
    dateTimeFormat:
        DateTimeFormat.onlyTimeAndSinceStart, //  // වේලාව මුද්‍රණය කරන්න
  ),
);

// සටහන: ඔබට අවශ්‍ය නම් මෙහිදී production එකේදී ලොග් කිරීම නවත්වන 
// තර්කනයක් ද (උදා: if (kReleaseMode)) එකතු කළ හැක.