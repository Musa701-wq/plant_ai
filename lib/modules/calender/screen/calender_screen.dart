// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// //import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../../../services/ads/AdsProvider.dart';
// import '../../../utils/app_colors.dart';
// import '../../../utils/app_text_style.dart';
// import '../../my_garden/db/model/garden_plant.dart';
// import '../../my_garden/provider/garden_provider.dart';
// import '../provider/calender_provider.dart';
// import '../widgets/calender_header.dart';
// import '../widgets/calender_section.dart';
// import '../widgets/remainder_section.dart';
//
// class CalendarScreen extends StatefulWidget {
//   const CalendarScreen({super.key});
//
//   @override
//   State<CalendarScreen> createState() => _CalendarScreenState();
// }
//
// class _CalendarScreenState extends State<CalendarScreen> {
//   @override
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize providers when screen first builds
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final gardenProvider = context.read<GardenProvider>();
//       final calendarProvider = context.read<CalendarProvider>();
//       final adProvider = context.read<AdProvider>();
//
//       await gardenProvider.init();
//       await calendarProvider.init();
//
//       // Preload calendar ad
//       adProvider.preloadAd(AdType.calendarAd, adSize: TemplateType.small);
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final calendarProvider = context.watch<CalendarProvider>();
//     final gardenProvider = context.watch<GardenProvider>();
//
//     if (calendarProvider.isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     final allReminders = calendarProvider.allReminders;
//     final filteredReminders = calendarProvider.filteredReminders;
//
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 375;
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           children: [
//             // Header Section
//             CalendarHeader(
//               screenWidth: screenWidth,
//               reminderCount: allReminders.length,
//               activeFilter: calendarProvider.activeFilter,
//               onFilterChanged: (newFilter) {
//                 calendarProvider.changeFilter(newFilter);
//               },
//             ),
//
//             // Calendar Section
//             CalendarSection(
//               screenWidth: screenWidth,
//               isSmallScreen: isSmallScreen,
//               calendarProvider: calendarProvider,
//               reminders: allReminders,
//               selectedDate: calendarProvider.selectedDate,
//               onPreviousMonth: calendarProvider.previousMonth,
//               onNextMonth: calendarProvider.nextMonth,
//               onDateTap: _showDateRemindersDialog,
//             ),
//
//             // Calendar Native Ad - Before Reminder Section
//             _buildCalendarNativeAd(context),
//
//             // Reminder Section
//             ReminderSection(
//               activeFilter: calendarProvider.activeFilter,
//               filteredReminders: filteredReminders,
//               gardenProvider: gardenProvider,
//               onShowDetails: _showReminderDetailsDialog,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//  // ---------- CALENDAR NATIVE AD WIDGET ----------
//   Widget _buildCalendarNativeAd(BuildContext context) {
//     final adProvider = context.watch<AdProvider>();
//     final isAdLoaded = adProvider.isCalendarAd;
//     final nativeAd = adProvider.calendarAd;
//
//     if (!isAdLoaded || nativeAd == null) {
//       return const SizedBox.shrink();
//     }
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//       child: Container(
//         height: 130, // Minimum 120dp + padding for AdMob requirements
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: AdWidget(ad: nativeAd),
//         ),
//       ),
//     );
//   }
//
//   //-----------------------Detail Dialogs-----------------------
//
//   void _showReminderDetailsDialog(PlantReminder reminder) {
//     final displayDt = _reminderDateTimeForDisplay(reminder);
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Icon(Icons.eco, color: AppColors.primaryGreen),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text('Reminder Details', style: AppTextStyles.headlineSmall),
//             ),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildDetailItem('Plant', reminder.plantName),
//               _buildDetailItem('Task', reminder.task),
//               _buildDetailItem('Status', reminder.isActive ? 'Active' : 'Completed'),
//               _buildDetailItem('Time', DateFormat.jm().format(displayDt)),
//               _buildDetailItem(
//                 'Date',
//                 reminder.nextReminderDateTime != null
//                     ? DateFormat.yMMMd().format(reminder.nextReminderDateTime!)
//                     : 'Not set',
//               ),
//               _buildDetailItem(
//                 'Repeats',
//                 '${reminder.repeatInterval} ${reminder.repeatType}',
//               ),
//               _buildDetailItem(
//                 'Next Round',
//                 reminder.nextReminderDateTime != null
//                     ? DateFormat.yMMMd().add_jm().format(reminder.nextReminderDateTime!)
//                     : 'Not scheduled',
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
//           const SizedBox(height: 4),
//           Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
//         ],
//       ),
//     );
//   }
//
//   void _showDateRemindersDialog(DateTime date, List<PlantReminder> reminders) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('${DateFormat('MMMM d, yyyy').format(date)} Reminders',
//             style: AppTextStyles.headlineSmall),
//         content: Container(
//           width: double.maxFinite,
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.6,
//           ),
//           child: ListView.builder(
//             itemCount: reminders.length,
//             itemBuilder: (context, index) {
//               final reminder = reminders[index];
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 child: ListTile(
//                   leading: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: AppColors.backgroundCard,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.eco, color: AppColors.primaryGreen),
//                   ),
//                   title: Text(
//                     reminder.plantName,
//                     style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(reminder.task),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Time: ${DateFormat.jm().format(reminder.nextReminderDateTime ?? reminder.time)}',
//                         style: AppTextStyles.caption,
//                       ),
//                     ],
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _showReminderDetailsDialog(reminder);
//                   },
//                 ),
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
//         ],
//       ),
//     );
//   }
//
//   DateTime _reminderDateTimeForDisplay(PlantReminder r) {
//     try {
//       if (r.time.year <= 0) {
//         final now = DateTime.now();
//         return DateTime(now.year, now.month, now.day, r.time.hour, r.time.minute);
//       } else {
//         return r.nextReminderDateTime ?? r.time;
//       }
//     } catch (_) {
//       final now = DateTime.now();
//       return DateTime(now.year, now.month, now.day, r.time.hour, r.time.minute);
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../Auth/apple_auth.dart';
import '../../../Auth/auth_state.dart';
import '../../../Auth/google_auth.dart';
import '../../../services/ads/AdsProvider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../my_garden/db/model/garden_plant.dart';
import '../../my_garden/provider/garden_provider.dart';
import '../provider/calender_provider.dart';
import '../widgets/calender_header.dart';
import '../widgets/calender_section.dart';
import '../widgets/remainder_section.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize providers when screen first builds
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gardenProvider = context.read<GardenProvider>();
      final calendarProvider = context.read<CalendarProvider>();
      final adProvider = context.read<AdProvider>();

      await gardenProvider.init();
      await calendarProvider.init();

      // Preload calendar ad
      adProvider.preloadAd(AdType.calendarAd, adSize: TemplateType.small);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();

    // Check if user is signed in
    if (!authState.isUserSignedIn) {
      return _buildSignInRequiredScreen(context);
    }

    // User is signed in, show calendar interface
    final calendarProvider = context.watch<CalendarProvider>();
    final gardenProvider = context.watch<GardenProvider>();

    if (calendarProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final allReminders = calendarProvider.allReminders;
    final filteredReminders = calendarProvider.filteredReminders;

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Section
            CalendarHeader(
              screenWidth: screenWidth,
              reminderCount: allReminders.length,
              activeFilter: calendarProvider.activeFilter,
              onFilterChanged: (newFilter) {
                calendarProvider.changeFilter(newFilter);
              },
            ),

            // Calendar Section
            CalendarSection(
              screenWidth: screenWidth,
              isSmallScreen: isSmallScreen,
              calendarProvider: calendarProvider,
              reminders: allReminders,
              selectedDate: calendarProvider.selectedDate,
              onPreviousMonth: calendarProvider.previousMonth,
              onNextMonth: calendarProvider.nextMonth,
              onDateTap: _showDateRemindersDialog,
            ),

            // Calendar Native Ad - Before Reminder Section
            _buildCalendarNativeAd(context),

            // Reminder Section
            ReminderSection(
              activeFilter: calendarProvider.activeFilter,
              filteredReminders: filteredReminders,
              gardenProvider: gardenProvider,
              onShowDetails: _showReminderDetailsDialog,
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Sign-in required screen for Calendar
  Widget _buildSignInRequiredScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Calendar Icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen.withOpacity(0.2),
                        AppColors.secondaryGreen.withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    size: 80,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Plant Care Calendar',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Sign in to track your plant care schedule and reminders',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Features List
                _buildFeatureItem(
                  icon: Icons.notifications_active,
                  title: 'Smart Reminders',
                  description: 'Never miss watering or fertilizing your plants',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.event_repeat,
                  title: 'Custom Schedules',
                  description: 'Set recurring reminders for each plant',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.calendar_today,
                  title: 'Visual Calendar',
                  description: 'See all your plant care tasks at a glance',
                ),
                const SizedBox(height: 40),

                // Sign-in Buttons
                _buildSignInButton(
                  context: context,
                  onPressed: () async {
                    //await signInWithGoogleUI(context);
                    await GoogleAuth.signInWithGoogleUI(context);
                  },
                  icon: Icons.g_mobiledata,
                  label: 'Continue with Google',
                  backgroundColor: Colors.white,
                  textColor: AppColors.textPrimary,
                  borderColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                _buildSignInButton(
                  context: context,
                  onPressed: () async {
                    await AppleAuth.signInWithAppleUI(context);
                  },
                  icon: Icons.apple,
                  label: 'Continue with Apple',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 24),

                // Privacy Note
                Text(
                  'Your plant care data is secure and private',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: borderColor != null ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- CALENDAR NATIVE AD WIDGET ----------
  Widget _buildCalendarNativeAd(BuildContext context) {
    final adProvider = context.watch<AdProvider>();
    final isAdLoaded = adProvider.isCalendarAd;
    final nativeAd = adProvider.calendarAd;

    if (!isAdLoaded || nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Container(
        height: 130, // Minimum 120dp + padding for AdMob requirements
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AdWidget(ad: nativeAd),
        ),
      ),
    );
  }

  //-----------------------Detail Dialogs-----------------------

  void _showReminderDetailsDialog(PlantReminder reminder) {
    final displayDt = _reminderDateTimeForDisplay(reminder);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // ✅ Dialog background white
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            Icon(Icons.eco, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                  'Reminder Details',
                  style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Plant', reminder.plantName),
              _buildDetailItem('Task', reminder.task),
              _buildDetailItem('Status', reminder.isActive ? 'Active' : 'Completed'),
              _buildDetailItem('Time', DateFormat.jm().format(displayDt)),
              _buildDetailItem(
                'Date',
                reminder.nextReminderDateTime != null
                    ? DateFormat.yMMMd().format(reminder.nextReminderDateTime!)
                    : 'Not set',
              ),
              _buildDetailItem(
                'Repeats',
                '${reminder.repeatInterval} ${reminder.repeatType}',
              ),
              _buildDetailItem(
                'Next Round',
                reminder.nextReminderDateTime != null
                    ? DateFormat.yMMMd().add_jm().format(reminder.nextReminderDateTime!)
                    : 'Not scheduled',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: AppColors.primaryGreen), // ✅ Green color
              )
          ),
        ],
      ),
    );
  }
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              )
          ),
          const SizedBox(height: 4),
          Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              )
          ),
        ],
      ),
    );
  }
/*
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
*/

/*
  void _showDateRemindersDialog(DateTime date, List<PlantReminder> reminders) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${DateFormat('MMMM d, yyyy').format(date)} Reminders',
            style: AppTextStyles.headlineSmall),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.eco, color: AppColors.primaryGreen),
                  ),
                  title: Text(
                    reminder.plantName,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reminder.task),
                      const SizedBox(height: 4),
                      Text(
                        'Time: ${DateFormat.jm().format(reminder.nextReminderDateTime ?? reminder.time)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showReminderDetailsDialog(reminder);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
*/
  void _showDateRemindersDialog(DateTime date, List<PlantReminder> reminders) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // ✅ Dialog background white
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
            '${DateFormat('MMMM d, yyyy').format(date)} Reminders',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: ListView.builder(
            itemCount: reminders.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.eco, color: AppColors.primaryGreen, size: 20),
                  ),
                  title: Text(
                    reminder.plantName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.task,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time: ${DateFormat.jm().format(reminder.nextReminderDateTime ?? reminder.time)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showReminderDetailsDialog(reminder);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: AppColors.primaryGreen), // ✅ Green color
              )
          ),
        ],
      ),
    );
  }
  DateTime _reminderDateTimeForDisplay(PlantReminder r) {
    try {
      if (r.time.year <= 0) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, r.time.hour, r.time.minute);
      } else {
        return r.nextReminderDateTime ?? r.time;
      }
    } catch (_) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, r.time.hour, r.time.minute);
    }
  }
}