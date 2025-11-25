// /speedfin/lib/features/fines/presentation/fine_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speedfin/core/models/fine_model.dart';
import 'package:speedfin/features/fines/providers/fine_provider.dart';

class FineHistoryScreen extends StatelessWidget {
  const FineHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fine History')),
      body: Consumer<FineProvider>(
        builder: (context, fineProvider, child) {
          if (fineProvider.fines.isEmpty) {
            return const Center(
              child: Text('No violations logged yet. Safe driving!'),
            );
          }

          return ListView.builder(
            itemCount: fineProvider.fines.length,
            itemBuilder: (context, index) {
              final Fine fine = fineProvider.fines[index];
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(
                  'Violation: ${fine.actualSpeed.round()} KM/H in ${fine.speedLimit.round()} KM/H zone',
                ),
                subtitle: Text(
                  'Time: ${fine.timestamp.toString().substring(0, 16)} - Lat: ${fine.latitude.toStringAsFixed(2)}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
