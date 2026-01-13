// lib/modules/scan/screen/recent_scans_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/modules/scan/screen/result_screen.dart';
import '../../../services/ads/ads_service.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../db/database/scan_db.dart';
import '../db/model/scanned_plant.dart';

class RecentScansScreen extends StatelessWidget {
  const RecentScansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('Recent Scans', style: TextStyle(color: Colors.white),),
        elevation: 4,
        shadowColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<List<ScannedPlant>>(
        stream: ScanDB.watchScans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          final scans = snapshot.data ?? [];

          if (scans.isEmpty) {
            return _EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: scans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final scan = scans[index];
              return _ScanTile(scan: scan);
            },
          );
        },
      ),
    );
  }
}
class _ScanTile extends StatelessWidget {
  final ScannedPlant scan;

  const _ScanTile({required this.scan});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'MMM d, yyyy • hh:mm a',
    ).format(scan.scannedAt);

    return InkWell(
      onTap: () async{
         await AdService.instance.showRewardedAndWait(
           onReward: () {
        print("✅ User earned reward!");
       Navigator.push(
         context,
           MaterialPageRoute(builder: (_) => ResultScreen(scannedPlant: scan)),
          );
      },
       );
       },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8), // ✅ Add margin
        child: Row(
          children: [
            // Image Section
            Container(
              width: 70, // Fixed width
              height: 70, // Fixed height
              margin: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: scan.imagePath != null
                    ? Image.file(
                  File(scan.imagePath!),
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 70,
                  height: 70,
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  child: const Icon(Icons.eco, color: AppColors.primaryGreen),
                ),
              ),
            ),

            // Text Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      scan.name ?? "Unknown Plant",
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // ✅ Prevent overflow
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Arrow Icon
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
class _ScanTile extends StatelessWidget {
  final ScannedPlant scan;

  const _ScanTile({required this.scan});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'MMM d, yyyy • hh:mm a',
    ).format(scan.scannedAt);

    return InkWell(
      // onTap: () async{
      //   // Navigate to ResultScreen (with image path)
      //   await AdService.instance.showRewardedAndWait(
      //     onReward: () {
      //       print("✅ User earned reward!");
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (_) => ResultScreen(scannedPlant: scan)),
      //       );
      //     },
      //   );
      // },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: scan.imagePath != null
                ? Image.file(
                    File(scan.imagePath!), // 👈 convert String path → File
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    child: const Icon(Icons.eco, color: AppColors.primaryGreen),
                ),
          ),
          title: Text(
            scan.name ?? "Unknown Plant",
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            formattedDate,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
*/

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: AppColors.primaryGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "No recent scans yet",
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your scanned plants will appear here.",
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
