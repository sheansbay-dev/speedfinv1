// /speedfin/lib/features/speedometer/presentation/speedometer_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speedfin/features/fines/presentation/fine_history_screen.dart';
import 'package:speedfin/features/speedometer/providers/speed_provider.dart';

class SpeedometerScreen extends StatefulWidget {
  const SpeedometerScreen({super.key});

  @override
  State<SpeedometerScreen> createState() => _SpeedometerScreenState();
}

class _SpeedometerScreenState extends State<SpeedometerScreen> {
  @override
  void initState() {
    super.initState();
    // යෙදුම ආරම්භයේදීම GPS සවන් දීම ආරම්භ කරන්න
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SpeedProvider>(context, listen: false).startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    // SpeedProvider වෙත සවන් දෙන්න
    return Consumer<SpeedProvider>(
      builder: (context, speedProvider, child) {
        // වේගය ඉක්මවූ විට රතු පැහැය තෝරන්න
        final Color displayColor = speedProvider.isOverspeeding
            ? Colors.red
            : Colors.white;

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 1. වත්මන් වේගය
                Text(
                  '${speedProvider.currentSpeed.round()}', // දශම රහිත අගය
                  style: TextStyle(
                    fontSize: 150,
                    fontWeight: FontWeight.bold,
                    color: displayColor,
                  ),
                ),
                Text(
                  'KM/H',
                  style: TextStyle(fontSize: 24, color: displayColor),
                ),
                const SizedBox(height: 50),

                // 2. වේග සීමාව
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.red, width: 8),
                  ),
                  child: Text(
                    '${speedProvider.speedLimit.round()}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. වේගය ඉක්මවූ විට අනතුරු ඇඟවීමේ පණිවිඩය
                if (speedProvider.isOverspeeding)
                  const Text(
                    'SPEED LIMIT EXCEEDED!',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          // 4. දඩපත් තිරය වෙත යාමට Navigation
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FineHistoryScreen(),
                  ),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.drive_eta),
                label: 'Drive',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long),
                label: 'Fines',
              ),
            ],
          ),
        );
      },
    );
  }
}
