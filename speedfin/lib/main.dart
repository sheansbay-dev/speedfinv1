// /speedfin/lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/speedometer/presentation/speedometer_screen.dart';
import 'features/speedometer/providers/speed_provider.dart';
import 'features/fines/providers/fine_provider.dart';

// ප්‍රධාන ශ්‍රිතය (main function)
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        // 1. FineProvider එක මුලින්ම සාදන්න
        ChangeNotifierProvider(create: (_) => FineProvider()),

        // 2. SpeedProvider එක සාදන විට, FineProvider instance එක එයට යවන්න (Read)
        ChangeNotifierProvider(
          create: (context) => SpeedProvider(
            // Provider.of භාවිතයෙන් FineProvider instance එක ලබා ගෙන SpeedProvider වෙත යැවීම
            Provider.of<FineProvider>(context, listen: false),
          ),
        ),
      ],
      child: const SpeedFinApp(),
    ),
  );
}

// ප්‍රධාන යෙදුම් Widget එක
class SpeedFinApp extends StatelessWidget {
  const SpeedFinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeedFin Europe',
      // ඔබගේ UI Sketch එකට අනුව Dark Theme එකක් තෝරා ගැනීම
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red, // වේගය ඉක්මවූ විට රතු පැහැය භාවිත කරන්න
        useMaterial3: true,
      ),
      home: const SpeedometerScreen(), // MVP හි ආරම්භක තිරය
    );
  }
}
