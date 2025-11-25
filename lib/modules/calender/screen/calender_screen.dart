import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
        title: Row(
          children: [
            Icon(Icons.eco, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Reminder Details', style: AppTextStyles.headlineSmall),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
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
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

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
