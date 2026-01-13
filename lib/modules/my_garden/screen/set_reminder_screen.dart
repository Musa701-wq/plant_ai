// // lib/modules/my_garden/ui/set_reminder_screen.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../../utils/app_colors.dart';
// import '../../../utils/app_text_style.dart';
// import '../db/model/garden_plant.dart';
// import '../provider/garden_provider.dart';
// import '../widgets/modern_plant_card.dart';
//
// class SetReminderScreen extends StatefulWidget {
//   final GardenPlant? plant;
//
//   const SetReminderScreen({super.key, required this.plant});
//
//   @override
//   State<SetReminderScreen> createState() => _SetReminderScreenState();
// }
//
// class _SetReminderScreenState extends State<SetReminderScreen> {
//   late GardenProvider _gardenProvider;
//   final List<String> _repeatUnits = ['days', 'weeks', 'months'];
//   final List<String> _tasks = [
//     "Misting",
//     "Watering",
//     "Rotating",
//     "Fertilizing",
//   ];
//
//   final List<String> _previousFertilizingOptions = [
//     "Today",
//     "Yesterday",
//     "1 week ago",
//     "2 weeks ago",
//     "More than 2 weeks ago",
//   ];
//
//   final List<Map<String, dynamic>> _roundsOptions = [
//     {'label': 'Infinite (Until I stop)', 'value': 0},
//     {'label': '1 Round', 'value': 1},
//     {'label': '2 Rounds', 'value': 2},
//     {'label': '3 Rounds', 'value': 3},
//     {'label': '5 Rounds', 'value': 5},
//     {'label': '10 Rounds', 'value': 10},
//     {'label': 'Custom', 'value': -1},
//   ];
//
//   String? _validationMessage;
//
//   String _displayUnit(String unit) =>
//       unit.isEmpty ? unit : '${unit[0].toUpperCase()}${unit.substring(1)}';
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     _gardenProvider = context.read<GardenProvider>();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // 🧩 If plant is provided (navigated from a plant), select it automatically
//       if (widget.plant != null) {
//         _gardenProvider.selectPlant(widget.plant!);
//       } else {
//         _gardenProvider.clearSelectedPlant();
//       }
//       _gardenProvider.resetReminderForm();
//     });
//     // 🧹 Reset previous reminder state when screen opens fresh
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     // 🧹 Clear all selections when navigating back
//     _gardenProvider.resetReminderForm();
//     _gardenProvider.clearSelectedPlant();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<GardenProvider>(
//       builder: (context, provider, _) {
//         final plant = widget.plant;
//
//         return Scaffold(
//           backgroundColor: AppColors.backgroundLight,
//           appBar: AppBar(
//             title: const Text("Set Reminder"),
//             backgroundColor: AppColors.primaryGreen,
//             foregroundColor: AppColors.textOnPrimary,
//             elevation: 0,
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Modern Plant Card
//                 Consumer<GardenProvider>(
//                   builder: (context, provider, _) {
//                     final selected = provider.selectedPlant ?? widget.plant;
//                     return ModernPlantCard(plant: selected);
//                   },
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Reminder Configuration Cards
//                 _buildReminderConfigurationCard(
//                   context,
//                   provider,
//                   "Remind me about",
//                   _buildTaskSelector(provider),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildReminderConfigurationCard(
//                   context,
//                   provider,
//                   "Repeat",
//                   _buildRepeatPicker(provider),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildReminderConfigurationCard(
//                   context,
//                   provider,
//                   "Time",
//                   _buildTimeSelector(provider),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildReminderConfigurationCard(
//                   context,
//                   provider,
//                   "Number of Rounds",
//                   _buildRoundsSelector(provider),
//                 ),
//
//                 // Fertilizing Section (Conditional)
//                 if (provider.selectedTask?.toLowerCase() == 'fertilizing') ...[
//                   const SizedBox(height: 16),
//                   _buildReminderConfigurationCard(
//                     context,
//                     provider,
//                     "Previous Fertilizing",
//                     _buildFertilizingSelector(provider),
//                   ),
//                 ],
//
//                 // Plant Information Card
//                 const SizedBox(height: 16),
//
//                 Consumer<GardenProvider>(
//                   builder: (context, provider, _) {
//                     final selected = provider.selectedPlant ?? widget.plant;
//                     return _buildModernPlantInfoCard(selected);
//                   },
//                 ),
//
//                 // Next Reminder Date
//                 if (provider.upcomingReminderDate != null) ...[
//                   const SizedBox(height: 16),
//                   _buildNextReminderCard(provider),
//                 ],
//
//                 // Validation Message
//                 if (_validationMessage != null) ...[
//                   const SizedBox(height: 16),
//                   _buildValidationCard(),
//                 ],
//
//                 // Action Button
//                 const SizedBox(height: 30),
//                 _buildActionButton(provider),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//
//   Widget _buildReminderConfigurationCard(
//       BuildContext context,
//       GardenProvider provider,
//       String title,
//       Widget content,
//       ) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.shade100),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: AppTextStyles.bodyLarge.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 12),
//             content,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTaskSelector(GardenProvider provider) {
//     return _buildSelectorCard(
//       title: provider.selectedTask ?? "Select a task",
//       subtitle: "Choose what to remind you about",
//       icon: Icons.assignment_outlined,
//       onTap: () => _showTaskPicker(context, provider),
//     );
//   }
//
//   Widget _buildTimeSelector(GardenProvider provider) {
//     return _buildSelectorCard(
//       title: provider.selectedTime == null
//           ? "Select time"
//           : provider.selectedTime!.format(context),
//       subtitle: "When to trigger reminder",
//       icon: Icons.access_time_outlined,
//       onTap: () => _pickTime(context, provider),
//     );
//   }
//
//   Widget _buildRoundsSelector(GardenProvider provider) {
//     return _buildSelectorCard(
//       title: _getRoundsDisplayText(provider),
//       subtitle: "How many times to repeat this reminder",
//       icon: Icons.repeat_outlined,
//       onTap: () => _showRoundsPicker(context, provider),
//     );
//   }
//
//   Widget _buildFertilizingSelector(GardenProvider provider) {
//     return _buildSelectorCard(
//       title: provider.selectedPrevFertilizingLabel ?? "Select",
//       subtitle: "When did you last fertilize this plant?",
//       icon: Icons.history_outlined,
//       onTap: () => _showPrevFertilizingPicker(context, provider),
//     );
//   }
//
//   Widget _buildSelectorCard({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 0,
//       color: AppColors.backgroundCard,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryGreen.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   icon,
//                   color: AppColors.primaryGreen,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: AppTextStyles.bodyMedium.copyWith(
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: AppTextStyles.caption.copyWith(
//                         color: AppColors.textHint,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: Colors.grey.shade400,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRepeatPicker(GardenProvider provider) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundCard,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Every",
//                   style: AppTextStyles.caption.copyWith(
//                     color: AppColors.textHint,
//                   ),
//                 ),
//                 TextField(
//                   keyboardType: TextInputType.number,
//                   style: AppTextStyles.bodyLarge.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     hintText: "1",
//                     contentPadding: EdgeInsets.zero,
//                   ),
//                   onChanged: (val) {
//                     final parsed = int.tryParse(val);
//                     if (parsed != null) {
//                       provider.setRepeat(provider.repeatType ?? 'days', parsed);
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: DropdownButton<String>(
//                 value: provider.repeatType,
//                 hint: Text(
//                   "Select unit",
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.textHint,
//                   ),
//                 ),
//                 isExpanded: true,
//                 underline: const SizedBox(),
//                 icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
//                 items: _repeatUnits
//                     .map(
//                       (unit) => DropdownMenuItem(
//                     value: unit,
//                     child: Text(
//                       _displayUnit(unit),
//                       style: AppTextStyles.bodyMedium,
//                     ),
//                   ),
//                 )
//                     .toList(),
//                 onChanged: (val) {
//                   if (val != null) {
//                     provider.setRepeat(val, provider.repeatInterval ?? 1);
//                   }
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildModernPlantInfoCard(GardenPlant? plant) {
//
//     // 🛡️ Handle null plant gracefully
//     if (plant == null) {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.info_outline, color: Colors.grey, size: 20),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'No plant selected. Please choose a plant to view details.',
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     final upcomingReminder = plant.reminders
//         .where((r) => r.isActive && r.nextReminderDateTime != null)
//         .where((r) => r.nextReminderDateTime!.isAfter(DateTime.now()))
//         .isNotEmpty
//         ? plant.reminders
//         .where((r) => r.isActive && r.nextReminderDateTime != null)
//         .where((r) => r.nextReminderDateTime!.isAfter(DateTime.now()))
//         .reduce((a, b) => a.nextReminderDateTime!.isBefore(b.nextReminderDateTime!) ? a : b)
//         : null;
//
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Colors.blue.shade50,
//             Colors.green.shade50,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.blue.shade100),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.eco_outlined,
//                   color: AppColors.primaryGreen,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Plant Information',
//                   style: AppTextStyles.headlineSmall.copyWith(
//                     color: AppColors.primaryGreen,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//
//             if (upcomingReminder != null) ...[
//               _buildInfoItem(
//                 icon: Icons.notifications_active_outlined,
//                 label: 'Next ${upcomingReminder.task}',
//                 value: _formatTimeFromNow(upcomingReminder.nextReminderDateTime!),
//                 color: Colors.orange,
//               ),
//               const SizedBox(height: 12),
//             ],
//
//             _buildInfoItem(
//               icon: Icons.calendar_today_outlined,
//               label: 'Added to Garden',
//               value: DateFormat('MMM d, yyyy').format(plant.addedDate),
//               color: Colors.blue,
//             ),
//             const SizedBox(height: 12),
//
//             _buildInfoItem(
//               icon: Icons.favorite_outlined,
//               label: 'Health Status',
//               value: '${plant.health}%',
//               color: _getHealthColor(plant.health),
//             ),
//             const SizedBox(height: 12),
//
//             _buildInfoItem(
//               icon: Icons.local_florist_outlined,
//               label: 'Plant Type',
//               value: plant.type,
//               color: AppColors.primaryGreen,
//             ),
//
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.lightbulb_outline,
//                     color: Colors.amber.shade600,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Set reminders based on your plant\'s specific needs',
//                       style: AppTextStyles.caption.copyWith(
//                         color: AppColors.textSecondary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoItem({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Row(
//       children: [
//         Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, size: 18, color: color),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: AppTextStyles.caption.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: AppColors.textPrimary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildNextReminderCard(GardenProvider provider) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.primaryGreen.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.calendar_today_outlined,
//             color: AppColors.primaryGreen,
//             size: 24,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Next reminder:",
//                   style: AppTextStyles.caption.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 Text(
//                   DateFormat('EEEE, MMM d, yyyy').format(provider.upcomingReminderDate!.toLocal()),
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.primaryGreen,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildValidationCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.orange.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.orange.shade200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: Colors.orange.shade100,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.warning_amber_rounded,
//               color: Colors.orange.shade600,
//               size: 18,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               _validationMessage!,
//               style: AppTextStyles.caption.copyWith(
//                 color: Colors.orange.shade700,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildActionButton(GardenProvider provider) {
//     return SizedBox(
//       width: double.infinity,
//       child: Material(
//         borderRadius: BorderRadius.circular(16),
//         elevation: 4,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           decoration: BoxDecoration(
//             gradient: provider.isFormValid && !provider.isSaving
//                 ? LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 AppColors.primaryGreen,
//                 Colors.green.shade600,
//               ],
//             )
//                 : LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.grey.shade400,
//                 Colors.grey.shade500,
//               ],
//             ),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: provider.isFormValid && !provider.isSaving
//                 ? [
//               BoxShadow(
//                 color: AppColors.primaryGreen.withOpacity(0.4),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ]
//                 : null,
//           ),
//           child: InkWell(
//             borderRadius: BorderRadius.circular(16),
//             onTap: provider.isFormValid && !provider.isSaving
//                 ? () => _setReminder(provider)
//                 : null,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (provider.isSaving)
//                     SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   else
//                     Icon(
//                       Icons.notifications_active_outlined,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   const SizedBox(width: 8),
//                   Text(
//                     provider.isSaving ? "Setting Reminder..." : "Turn On Reminder",
//                     style: AppTextStyles.button.copyWith(
//                       fontSize: 16,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _setReminder(GardenProvider provider) async {
//     if (widget.plant == null) {
//       debugPrint('[SetReminderScreen] ❌ No plant selected, cannot set reminder.');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: const [
//                 Icon(Icons.warning_amber_rounded, color: Colors.white),
//                 SizedBox(width: 8),
//                 Text("Please select a plant before setting a reminder."),
//               ],
//             ),
//             backgroundColor: Colors.orangeAccent,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         );
//       }
//       return;
//     }
//
//     debugPrint('[SetReminderScreen] Set reminder tapped for plant ${widget.plant!.name}');
//
//     try {
//       final selectedTime = provider.selectedTime;
//       final now = DateTime.now();
//
//       final scheduledDateTime = DateTime(
//         now.year,
//         now.month,
//         now.day,
//         selectedTime?.hour ?? 8,
//         selectedTime?.minute ?? 0,
//       );
//
//       // ✅ Safe unwrap with required checks
//       if (provider.selectedTask == null ||
//           provider.repeatType == null ||
//           provider.repeatInterval == null) {
//         debugPrint('[SetReminderScreen] ⚠️ Missing reminder configuration.');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: const [
//                   Icon(Icons.error_outline, color: Colors.white),
//                   SizedBox(width: 8),
//                   Text("Please complete reminder details first."),
//                 ],
//               ),
//               backgroundColor: Colors.redAccent,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//           );
//         }
//         return;
//       }
//
//       final reminder = PlantReminder(
//         id: provider.generateId(),
//         task: provider.selectedTask!,
//         frequency: "custom",
//         isActive: true,
//         repeatType: provider.repeatType!,
//         repeatInterval: provider.repeatInterval!,
//         time: scheduledDateTime,
//         plantId: widget.plant!.id,
//         plantName: widget.plant!.name,
//         totalRounds: provider.selectedRounds ?? 0,
//         previousFertilizingLabel:
//         provider.selectedTask == "Fertilizing"
//             ? provider.selectedPrevFertilizingLabel
//             : null,
//         previousFertilizingDate:
//         provider.selectedTask == "Fertilizing"
//             ? provider.selectedPrevFertilizingDate
//             : null,
//       );
//
//       debugPrint(
//           '[SetReminderScreen] Creating reminder for ${reminder.task} at $scheduledDateTime (${reminder.repeatType}, every ${reminder.repeatInterval})');
//
//       await provider.addReminder(widget.plant!.id, reminder);
//
//       debugPrint('[SetReminderScreen] Reminder added & scheduled successfully ✅');
//
//       provider.resetReminderForm();
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: const [
//                 Icon(Icons.check_circle, color: Colors.white),
//                 SizedBox(width: 8),
//                 Text("Reminder added successfully 🎉"),
//               ],
//             ),
//             backgroundColor: AppColors.primaryGreen,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e, st) {
//       debugPrint('[SetReminderScreen] Error setting reminder: $e\n$st');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: const [
//                 Icon(Icons.error_outline, color: Colors.white),
//                 SizedBox(width: 8),
//                 Text("Failed to add reminder"),
//               ],
//             ),
//             backgroundColor: Colors.redAccent,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         );
//       }
//     }
//   }
//
//   // Keep all the existing helper methods unchanged (_buildImagePreview, _buildPlaceholder,
//   // _showTaskPicker, _showPrevFertilizingPicker, _calculatePreviousDate, _getRoundsDisplayText,
//   // _showRoundsPicker, _showCustomRoundsDialog, _validateReminderTime, _pickTime,
//   // _formatTimeAgo, _formatTimeFromNow, _getHealthColor, _getCareLevelColor)
//   // ... [All existing helper methods remain exactly the same]
//
//   void _showTaskPicker(BuildContext context, GardenProvider provider) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => ListView(
//         shrinkWrap: true,
//         children: _tasks.map((task) {
//           return ListTile(
//             title: Text(task),
//             onTap: () {
//               provider.selectTask(task);
//               Navigator.pop(context);
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   void _showPrevFertilizingPicker(
//       BuildContext context,
//       GardenProvider provider,
//       ) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => ListView(
//         shrinkWrap: true,
//         children: _previousFertilizingOptions.map((option) {
//           return ListTile(
//             title: Text(option),
//             onTap: () {
//               final date = _calculatePreviousDate(option);
//               provider.setPreviousFertilizing(option, date);
//               Navigator.pop(context);
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   DateTime _calculatePreviousDate(String option) {
//     final now = DateTime.now();
//     switch (option) {
//       case "Yesterday":
//         return now.subtract(const Duration(days: 1));
//       case "1 week ago":
//         return now.subtract(const Duration(days: 7));
//       case "2 weeks ago":
//         return now.subtract(const Duration(days: 14));
//       case "More than 2 weeks ago":
//         return now.subtract(const Duration(days: 21));
//       default:
//         return now;
//     }
//   }
//
//   String _getRoundsDisplayText(GardenProvider provider) {
//     if (provider.selectedRounds == null) return "Select rounds";
//     if (provider.selectedRounds! <= 0) return "Infinite (Until I stop)";
//     if (provider.selectedRounds! == 1) return "1 Round";
//     return "${provider.selectedRounds} Rounds";
//   }
//
//   void _showRoundsPicker(BuildContext context, GardenProvider provider) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               "Select Number of Rounds",
//               style: AppTextStyles.headlineSmall.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               shrinkWrap: true,
//               children: _roundsOptions.map((option) {
//                 return ListTile(
//                   title: Text(option['label']),
//                   onTap: () {
//                     if (option['value'] == -1) {
//                       Navigator.pop(context);
//                       _showCustomRoundsDialog(context, provider);
//                     } else {
//                       provider.setRounds(option['value']);
//                       Navigator.pop(context);
//                     }
//                   },
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showCustomRoundsDialog(BuildContext context, GardenProvider provider) {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Custom Rounds"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Enter the number of rounds you want:"),
//             const SizedBox(height: 12),
//             TextField(
//               controller: controller,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: "Number of rounds",
//                 border: OutlineInputBorder(),
//                 hintText: "e.g., 15",
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final value = int.tryParse(controller.text);
//               if (value != null && value > 0) {
//                 provider.setRounds(value);
//                 Navigator.pop(context);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("Please enter a valid number greater than 0"),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             child: const Text("Set"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String? _validateReminderTime(GardenProvider provider) {
//     if (provider.selectedTime == null) return null;
//
//     final now = DateTime.now();
//     final selectedDateTime = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       provider.selectedTime!.hour,
//       provider.selectedTime!.minute,
//     );
//
//     if (selectedDateTime.isBefore(now)) {
//       final tomorrow = selectedDateTime.add(const Duration(days: 1));
//       if (tomorrow.difference(now).inHours < 1) {
//         return "⚠️ Reminder must be at least 1 hour from now";
//       }
//     } else {
//       if (selectedDateTime.difference(now).inHours < 1) {
//         return "⚠️ Reminder must be at least 1 hour from now";
//       }
//     }
//
//     return null;
//   }
//
//   Future<void> _pickTime(BuildContext context, GardenProvider provider) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: provider.selectedTime ?? TimeOfDay.now(),
//     );
//     if (picked != null) {
//       provider.setTime(picked);
//       setState(() {
//         _validationMessage = _validateReminderTime(provider);
//       });
//     }
//   }
//
//   String _formatTimeFromNow(DateTime date) {
//     final now = DateTime.now();
//     final difference = date.difference(now);
//
//     if (difference.inDays > 0) {
//       return 'in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
//     } else if (difference.inHours > 0) {
//       return 'in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
//     } else if (difference.inMinutes > 0) {
//       return 'in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
//     } else {
//       return 'now';
//     }
//   }
//
//   Color _getHealthColor(int health) {
//     if (health >= 80) return Colors.green;
//     if (health >= 60) return Colors.orange;
//     return Colors.red;
//   }
// }

// lib/modules/my_garden/ui/set_reminder_screen.dart

/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../db/model/garden_plant.dart';
import '../provider/garden_provider.dart';
import '../widgets/modern_plant_card.dart';

class SetReminderScreen extends StatefulWidget {
  final GardenPlant? plant;

  const SetReminderScreen({super.key, required this.plant});

  @override
  State<SetReminderScreen> createState() => _SetReminderScreenState();
}

class _SetReminderScreenState extends State<SetReminderScreen> {
  late GardenProvider _gardenProvider;
  final List<String> _repeatUnits = ['days', 'weeks', 'months'];
  final List<String> _tasks = [
    "Misting",
    "Watering",
    "Rotating",
    "Fertilizing",
  ];

  final List<String> _previousFertilizingOptions = [
    "Today",
    "Yesterday",
    "1 week ago",
    "2 weeks ago",
    "More than 2 weeks ago",
  ];

  final List<Map<String, dynamic>> _roundsOptions = [
    {'label': 'Infinite (Until I stop)', 'value': 0},
    {'label': '1 Round', 'value': 1},
    {'label': '2 Rounds', 'value': 2},
    {'label': '3 Rounds', 'value': 3},
    {'label': '5 Rounds', 'value': 5},
    {'label': '10 Rounds', 'value': 10},
    {'label': 'Custom', 'value': -1},
  ];

  String? _validationMessage;

  // Responsive helper methods
  double _getResponsivePadding(double screenWidth) {
    if (screenWidth > 600) return 24;
    if (screenWidth > 400) return 20;
    return 16;
  }

  double _getResponsiveFontSize(double screenWidth, double baseSize) {
    if (screenWidth > 600) return baseSize * 1.1;
    if (screenWidth < 360) return baseSize * 0.9;
    return baseSize;
  }

  double _getCardPadding(double screenWidth) {
    if (screenWidth > 600) return 20;
    return 16;
  }

  double _getSpacing(double screenWidth) {
    if (screenWidth > 600) return 20;
    return 16;
  }

  String _displayUnit(String unit) =>
      unit.isEmpty ? unit : '${unit[0].toUpperCase()}${unit.substring(1)}';

  @override
  void initState() {
    _gardenProvider = context.read<GardenProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.plant != null) {
        _gardenProvider.selectPlant(widget.plant!);
      } else {
        _gardenProvider.clearSelectedPlant();
      }
      _gardenProvider.resetReminderForm();
    });
    super.initState();
  }

  @override
  void dispose() {
    _gardenProvider.resetReminderForm();
    _gardenProvider.clearSelectedPlant();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = _getResponsivePadding(screenWidth);
    final spacing = _getSpacing(screenWidth);

    return Consumer<GardenProvider>(
      builder: (context, provider, _) {
        final plant = widget.plant;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text(
              "Set Reminder",
              style: TextStyle(
                fontSize: _getResponsiveFontSize(screenWidth, 20),
              ),
            ),
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(horizontalPadding),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modern Plant Card
                      Consumer<GardenProvider>(
                        builder: (context, provider, _) {
                          final selected = provider.selectedPlant ?? widget.plant;
                          return ModernPlantCard(plant: selected);
                        },
                      ),
                      SizedBox(height: spacing),

                      // Reminder Configuration Cards
                      _buildReminderConfigurationCard(
                        context,
                        provider,
                        "Remind me about",
                        _buildTaskSelector(provider, screenWidth),
                        screenWidth,
                      ),

                      SizedBox(height: spacing),

                      _buildReminderConfigurationCard(
                        context,
                        provider,
                        "Repeat",
                        _buildRepeatPicker(provider, screenWidth),
                        screenWidth,
                      ),

                      SizedBox(height: spacing),

                      _buildReminderConfigurationCard(
                        context,
                        provider,
                        "Time",
                        _buildTimeSelector(provider, screenWidth),
                        screenWidth,
                      ),

                      SizedBox(height: spacing),

                      _buildReminderConfigurationCard(
                        context,
                        provider,
                        "Number of Rounds",
                        _buildRoundsSelector(provider, screenWidth),
                        screenWidth,
                      ),

                      // Fertilizing Section (Conditional)
                      if (provider.selectedTask?.toLowerCase() == 'fertilizing') ...[
                        SizedBox(height: spacing),
                        _buildReminderConfigurationCard(
                          context,
                          provider,
                          "Previous Fertilizing",
                          _buildFertilizingSelector(provider, screenWidth),
                          screenWidth,
                        ),
                      ],

                      // Plant Information Card
                      SizedBox(height: spacing),

                      Consumer<GardenProvider>(
                        builder: (context, provider, _) {
                          final selected = provider.selectedPlant ?? widget.plant;
                          return _buildModernPlantInfoCard(selected, screenWidth);
                        },
                      ),

                      // Next Reminder Date
                      if (provider.upcomingReminderDate != null) ...[
                        SizedBox(height: spacing),
                        _buildNextReminderCard(provider, screenWidth),
                      ],

                      // Validation Message
                      if (_validationMessage != null) ...[
                        SizedBox(height: spacing),
                        _buildValidationCard(screenWidth),
                      ],

                      // Extra spacing for bottom padding
                      SizedBox(height: spacing * 1.5),
                    ],
                  ),
                ),
              ),

              // Fixed Action Button at bottom
              _buildFixedActionButton(provider, screenWidth),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderConfigurationCard(
      BuildContext context,
      GardenProvider provider,
      String title,
      Widget content,
      double screenWidth,
      ) {
    final cardPadding = _getCardPadding(screenWidth);
    final fontSize = _getResponsiveFontSize(screenWidth, 16);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth > 600 ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: fontSize,
              ),
            ),
            SizedBox(height: screenWidth > 600 ? 14 : 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSelector(GardenProvider provider, double screenWidth) {
    return _buildSelectorCard(
      title: provider.selectedTask ?? "Select a task",
      subtitle: "Choose what to remind you about",
      icon: Icons.assignment_outlined,
      onTap: () => _showTaskPicker(context, provider),
      screenWidth: screenWidth,
    );
  }

  Widget _buildTimeSelector(GardenProvider provider, double screenWidth) {
    return _buildSelectorCard(
      title: provider.selectedTime == null
          ? "Select time"
          : provider.selectedTime!.format(context),
      subtitle: "When to trigger reminder",
      icon: Icons.access_time_outlined,
      onTap: () => _pickTime(context, provider),
      screenWidth: screenWidth,
    );
  }

  Widget _buildRoundsSelector(GardenProvider provider, double screenWidth) {
    return _buildSelectorCard(
      title: _getRoundsDisplayText(provider),
      subtitle: "How many times to repeat this reminder",
      icon: Icons.repeat_outlined,
      onTap: () => _showRoundsPicker(context, provider),
      screenWidth: screenWidth,
    );
  }

  Widget _buildFertilizingSelector(GardenProvider provider, double screenWidth) {
    return _buildSelectorCard(
      title: provider.selectedPrevFertilizingLabel ?? "Select",
      subtitle: "When did you last fertilize this plant?",
      icon: Icons.history_outlined,
      onTap: () => _showPrevFertilizingPicker(context, provider),
      screenWidth: screenWidth,
    );
  }

  Widget _buildSelectorCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    final cardPadding = _getCardPadding(screenWidth);
    final titleSize = _getResponsiveFontSize(screenWidth, 14);
    final subtitleSize = _getResponsiveFontSize(screenWidth, 12);
    final iconSize = screenWidth > 600 ? 44.0 : 40.0;
    final iconInnerSize = screenWidth > 600 ? 22.0 : 20.0;

    return Card(
      elevation: 0,
      color: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: iconInnerSize,
                ),
              ),
              SizedBox(width: screenWidth > 600 ? 14 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: titleSize,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                        fontSize: subtitleSize,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: screenWidth > 600 ? 18 : 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatPicker(GardenProvider provider, double screenWidth) {
    final cardPadding = _getCardPadding(screenWidth);
    final fontSize = _getResponsiveFontSize(screenWidth, 14);
    final captionSize = _getResponsiveFontSize(screenWidth, 12);
    final inputSize = _getResponsiveFontSize(screenWidth, 18);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Every",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                    fontSize: captionSize,
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: inputSize,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "1",
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) {
                      provider.setRepeat(provider.repeatType ?? 'days', parsed);
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth > 600 ? 16 : 12),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 14 : 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<String>(
                value: provider.repeatType,
                hint: Text(
                  "Select unit",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                    fontSize: fontSize,
                  ),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down,
                    color: AppColors.primaryGreen),
                items: _repeatUnits
                    .map(
                      (unit) => DropdownMenuItem(
                    value: unit,
                    child: Text(
                      _displayUnit(unit),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    provider.setRepeat(val, provider.repeatInterval ?? 1);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPlantInfoCard(GardenPlant? plant, double screenWidth) {
    if (plant == null) {
      return Container(
        padding: EdgeInsets.all(_getCardPadding(screenWidth)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No plant selected. Please choose a plant to view details.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: _getResponsiveFontSize(screenWidth, 14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final upcomingReminder = plant.reminders
        .where((r) => r.isActive && r.nextReminderDateTime != null)
        .where((r) => r.nextReminderDateTime!.isAfter(DateTime.now()))
        .isNotEmpty
        ? plant.reminders
        .where((r) => r.isActive && r.nextReminderDateTime != null)
        .where((r) => r.nextReminderDateTime!.isAfter(DateTime.now()))
        .reduce((a, b) =>
    a.nextReminderDateTime!.isBefore(b.nextReminderDateTime!)
        ? a
        : b)
        : null;

    final cardPadding = _getCardPadding(screenWidth);
    final titleSize = _getResponsiveFontSize(screenWidth, 18);
    final iconSize = screenWidth > 600 ? 28.0 : 24.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.green.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(screenWidth > 600 ? 24 : 20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.eco_outlined,
                  color: AppColors.primaryGreen,
                  size: iconSize,
                ),
                SizedBox(width: screenWidth > 600 ? 10 : 8),
                Text(
                  'Plant Information',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth > 600 ? 18 : 16),

            if (upcomingReminder != null) ...[
              _buildInfoItem(
                icon: Icons.notifications_active_outlined,
                label: 'Next ${upcomingReminder.task}',
                value: _formatTimeFromNow(upcomingReminder.nextReminderDateTime!),
                color: Colors.orange,
                screenWidth: screenWidth,
              ),
              SizedBox(height: screenWidth > 600 ? 14 : 12),
            ],

            _buildInfoItem(
              icon: Icons.calendar_today_outlined,
              label: 'Added to Garden',
              value: DateFormat('MMM d, yyyy').format(plant.addedDate),
              color: Colors.blue,
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenWidth > 600 ? 14 : 12),

            _buildInfoItem(
              icon: Icons.favorite_outlined,
              label: 'Health Status',
              value: '${plant.health}%',
              color: _getHealthColor(plant.health),
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenWidth > 600 ? 14 : 12),

            _buildInfoItem(
              icon: Icons.local_florist_outlined,
              label: 'Plant Type',
              value: plant.type,
              color: AppColors.primaryGreen,
              screenWidth: screenWidth,
            ),

            SizedBox(height: screenWidth > 600 ? 18 : 16),
            Container(
              padding: EdgeInsets.all(screenWidth > 600 ? 14 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber.shade600,
                    size: screenWidth > 600 ? 20 : 18,
                  ),
                  SizedBox(width: screenWidth > 600 ? 10 : 8),
                  Expanded(
                    child: Text(
                      'Set reminders based on your plant\'s specific needs',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: _getResponsiveFontSize(screenWidth, 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double screenWidth,
  }) {
    final iconSize = screenWidth > 600 ? 40.0 : 36.0;
    final iconInnerSize = screenWidth > 600 ? 20.0 : 18.0;
    final labelSize = _getResponsiveFontSize(screenWidth, 11);
    final valueSize = _getResponsiveFontSize(screenWidth, 13);

    return Row(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: iconInnerSize, color: color),
        ),
        SizedBox(width: screenWidth > 600 ? 14 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: labelSize,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: valueSize,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextReminderCard(GardenProvider provider, double screenWidth) {
    final cardPadding = _getCardPadding(screenWidth);
    final iconSize = screenWidth > 600 ? 28.0 : 24.0;
    final captionSize = _getResponsiveFontSize(screenWidth, 12);
    final bodySize = _getResponsiveFontSize(screenWidth, 14);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: AppColors.primaryGreen,
            size: iconSize,
          ),
          SizedBox(width: screenWidth > 600 ? 14 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Next reminder:",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: captionSize,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d, yyyy')
                      .format(provider.upcomingReminderDate!.toLocal()),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: bodySize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationCard(double screenWidth) {
    final cardPadding = _getCardPadding(screenWidth);
    final iconSize = screenWidth > 600 ? 36.0 : 32.0;
    final iconInnerSize = screenWidth > 600 ? 20.0 : 18.0;
    final fontSize = _getResponsiveFontSize(screenWidth, 12);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade600,
              size: iconInnerSize,
            ),
          ),
          SizedBox(width: screenWidth > 600 ? 14 : 12),
          Expanded(
            child: Text(
              _validationMessage!,
              style: AppTextStyles.caption.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedActionButton(GardenProvider provider, double screenWidth) {
    final horizontalPadding = _getResponsivePadding(screenWidth);
    final buttonHeight = screenWidth > 600 ? 60.0 : 56.0;
    final fontSize = _getResponsiveFontSize(screenWidth, 16);
    final iconSize = screenWidth > 600 ? 22.0 : 20.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: Material(
          borderRadius: BorderRadius.circular(screenWidth > 600 ? 18 : 16),
          elevation: 4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: provider.isFormValid && !provider.isSaving
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen,
                  Colors.green.shade600,
                ],
              )
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade400,
                  Colors.grey.shade500,
                ],
              ),
              borderRadius: BorderRadius.circular(screenWidth > 600 ? 18 : 16),
              boxShadow: provider.isFormValid && !provider.isSaving
                  ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(screenWidth > 600 ? 18 : 16),
              onTap: provider.isFormValid && !provider.isSaving
                  ? () => _setReminder(provider)
                  : null,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.isSaving)
                      SizedBox(
                        height: iconSize,
                        width: iconSize,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    SizedBox(width: screenWidth > 600 ? 10 : 8),
                    Text(
                      provider.isSaving
                          ? "Setting Reminder..."
                          : "Turn On Reminder",
                      style: AppTextStyles.button.copyWith(
                        fontSize: fontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setReminder(GardenProvider provider) async {
    if (widget.plant == null) {
      debugPrint('[SetReminderScreen] ❌ No plant selected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("Please select a plant before setting a reminder."),
              ],
            ),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    try {
      final selectedTime = provider.selectedTime;
      final now = DateTime.now();

      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime?.hour ?? 8,
        selectedTime?.minute ?? 0,
      );

      if (provider.selectedTask == null ||
          provider.repeatType == null ||
          provider.repeatInterval == null) {
        debugPrint('[SetReminderScreen] ⚠️ Missing reminder configuration.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Please complete reminder details first."),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      final reminder = PlantReminder(
        id: provider.generateId(),
        task: provider.selectedTask!,
        frequency: "custom",
        isActive: true,
        repeatType: provider.repeatType!,
        repeatInterval: provider.repeatInterval!,
        time: scheduledDateTime,
        plantId: widget.plant!.id,
        plantName: widget.plant!.name,
        totalRounds: provider.selectedRounds ?? 0,
        previousFertilizingLabel: provider.selectedTask == "Fertilizing"
            ? provider.selectedPrevFertilizingLabel
            : null,
        previousFertilizingDate: provider.selectedTask == "Fertilizing"
            ? provider.selectedPrevFertilizingDate
            : null,
      );

      await provider.addReminder(widget.plant!.id, reminder);

      provider.resetReminderForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Reminder added successfully 🎉"),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e, st) {
      debugPrint('[SetReminderScreen] Error setting reminder: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text("Failed to add reminder"),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showTaskPicker(BuildContext context, GardenProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: _tasks.map((task) {
          return ListTile(
            title: Text(task),
            onTap: () {
              provider.selectTask(task);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showPrevFertilizingPicker(
      BuildContext context,
      GardenProvider provider,
      ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: _previousFertilizingOptions.map((option) {
          return ListTile(
            title: Text(option),
            onTap: () {
              final date = _calculatePreviousDate(option);
              provider.setPreviousFertilizing(option, date);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  DateTime _calculatePreviousDate(String option) {
    final now = DateTime.now();
    switch (option) {
      case "Yesterday":
        return now.subtract(const Duration(days: 1));
      case "1 week ago":
        return now.subtract(const Duration(days: 7));
      case "2 weeks ago":
        return now.subtract(const Duration(days: 14));
      case "More than 2 weeks ago":
        return now.subtract(const Duration(days: 21));
      default:
        return now;
    }
  }

  String _getRoundsDisplayText(GardenProvider provider) {
    if (provider.selectedRounds == null) return "Select rounds";
    if (provider.selectedRounds! <= 0) return "Infinite (Until I stop)";
    if (provider.selectedRounds! == 1) return "1 Round";
    return "${provider.selectedRounds} Rounds";
  }

  void _showRoundsPicker(BuildContext context, GardenProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Select Number of Rounds",
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: _roundsOptions.map((option) {
                return ListTile(
                  title: Text(option['label']),
                  onTap: () {
                    if (option['value'] == -1) {
                      Navigator.pop(context);
                      _showCustomRoundsDialog(context, provider);
                    } else {
                      provider.setRounds(option['value']);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomRoundsDialog(BuildContext context, GardenProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Custom Rounds"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter the number of rounds you want:"),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Number of rounds",
                border: OutlineInputBorder(),
                hintText: "e.g., 15",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                provider.setRounds(value);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a valid number greater than 0"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Set"),
          ),
        ],
      ),
    );
  }

  String? _validateReminderTime(GardenProvider provider) {
    if (provider.selectedTime == null) return null;

    final now = DateTime.now();
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      provider.selectedTime!.hour,
      provider.selectedTime!.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      final tomorrow = selectedDateTime.add(const Duration(days: 1));
      if (tomorrow.difference(now).inHours < 1) {
        return "⚠️ Reminder must be at least 1 hour from now";
      }
    } else {
      if (selectedDateTime.difference(now).inHours < 1) {
        return "⚠️ Reminder must be at least 1 hour from now";
      }
    }

    return null;
  }

  Future<void> _pickTime(BuildContext context, GardenProvider provider) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: provider.selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      provider.setTime(picked);
      setState(() {
        _validationMessage = _validateReminderTime(provider);
      });
    }
  }

  String _formatTimeFromNow(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'now';
    }
  }

  Color _getHealthColor(int health) {
    if (health >= 80) return Colors.green;
    if (health >= 60) return Colors.orange;
    return Colors.red;
  }
}*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../db/model/garden_plant.dart';
import '../provider/garden_provider.dart';
import '../widgets/modern_plant_card.dart';

class SetReminderScreen extends StatefulWidget {
  final GardenPlant? plant;

  const SetReminderScreen({super.key, required this.plant});

  @override
  State<SetReminderScreen> createState() => _SetReminderScreenState();
}

class _SetReminderScreenState extends State<SetReminderScreen> {
  late GardenProvider _gardenProvider;
  final List<String> _repeatUnits = ['days', 'weeks', 'months'];
  final List<String> _tasks = [
    "Misting",
    "Watering",
    "Rotating",
    "Fertilizing",
  ];

  final List<String> _previousFertilizingOptions = [
    "Today",
    "Yesterday",
    "1 week ago",
    "2 weeks ago",
    "More than 2 weeks ago",
  ];

  final List<Map<String, dynamic>> _roundsOptions = [
    {'label': 'Infinite (Until I stop)', 'value': 0},
    {'label': '1 Round', 'value': 1},
    {'label': '2 Rounds', 'value': 2},
    {'label': '3 Rounds', 'value': 3},
    {'label': '5 Rounds', 'value': 5},
    {'label': '10 Rounds', 'value': 10},
    {'label': 'Custom', 'value': -1},
  ];

  String? _validationMessage;

  // Responsive helper methods
  double _getResponsivePadding(double screenWidth) {
    if (screenWidth > 600) return 24;
    if (screenWidth > 400) return 20;
    return 16;
  }

  double _getResponsiveFontSize(double screenWidth, double baseSize) {
    if (screenWidth > 600) return baseSize * 1.1;
    if (screenWidth < 360) return baseSize * 0.9;
    return baseSize;
  }

  double _getCardPadding(double screenWidth) {
    if (screenWidth > 600) return 20;
    return 16;
  }

  double _getSpacing(double screenWidth) {
    if (screenWidth > 600) return 20;
    return 16;
  }

  String _displayUnit(String unit) =>
      unit.isEmpty ? unit : '${unit[0].toUpperCase()}${unit.substring(1)}';

  // 🆕 NEW: Check if plant has active reminder for selected task
  bool _hasActiveReminderForTask(GardenPlant? plant, String? task) {
    if (plant == null || task == null) return false;

    return plant.reminders.any((reminder) =>
    reminder.task.toLowerCase() == task.toLowerCase() &&
        reminder.isActive &&
        !reminder.isAllRoundsCompleted
    );
  }

  // 🆕 NEW: Get existing active reminder for the selected task
  PlantReminder? _getActiveReminderForTask(GardenPlant? plant, String? task) {
    if (plant == null || task == null) return null;

    try {
      return plant.reminders.firstWhere((reminder) =>
      reminder.task.toLowerCase() == task.toLowerCase() &&
          reminder.isActive &&
          !reminder.isAllRoundsCompleted
      );
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    _gardenProvider = context.read<GardenProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.plant != null) {
        _gardenProvider.selectPlant(widget.plant!);
      } else {
        _gardenProvider.clearSelectedPlant();
      }
      _gardenProvider.resetReminderForm();
    });
    super.initState();
  }

  @override
  void dispose() {
    _gardenProvider.resetReminderForm();
    _gardenProvider.clearSelectedPlant();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = _getResponsivePadding(screenWidth);
    final spacing = _getSpacing(screenWidth);

    return Consumer<GardenProvider>(
      builder: (context, provider, _) {
        final plant = widget.plant;
        final hasActiveReminder = _hasActiveReminderForTask(plant, provider.selectedTask);
        final activeReminder = _getActiveReminderForTask(plant, provider.selectedTask);

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text(
              "Set Reminder",
              style: TextStyle(
                fontSize: _getResponsiveFontSize(screenWidth, 20),
              ),
            ),
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(horizontalPadding),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modern Plant Card
                      Consumer<GardenProvider>(
                        builder: (context, provider, _) {
                          final selected = provider.selectedPlant ?? widget.plant;
                          return ModernPlantCard(plant: selected);
                        },
                      ),
                      SizedBox(height: spacing),

                      // 🆕 NEW: Warning if active reminder exists for selected task
                      if (hasActiveReminder && activeReminder != null) ...[
                        _buildActiveReminderWarning(activeReminder, screenWidth),
                        SizedBox(height: spacing),
                      ],

                      // Reminder Configuration Cards
                      _buildReminderConfigurationCard(
                        context,
                        provider,
                        "Remind me about",
                        _buildTaskSelector(provider, screenWidth),
                        screenWidth,
                      ),

                      SizedBox(height: spacing),

                      _buildReminderConfigurationCard(
                        context,
                        provider,
                        "Repeat",
                        _buildRepeatPicker(provider, screenWidth),
                        screenWidth,
                      ),

                      SizedBox(height: spacing),

                      _buildReminderConfigurationCard(
                        context,
                        provider,
                        "Time",
                        _buildTimeSelector(provider, screenWidth),
                        screenWidth,
                      ),

                      SizedBox(height: spacing),

                      _buildReminderConfigurationCard(
                        context,
                        provider,
                        "Number of Rounds",
                        _buildRoundsSelector(provider, screenWidth),
                        screenWidth,
                      ),

                      // Fertilizing Section (Conditional)
                      if (provider.selectedTask?.toLowerCase() == 'fertilizing') ...[
                        SizedBox(height: spacing),
                        _buildReminderConfigurationCard(
                          context,
                          provider,
                          "Previous Fertilizing",
                          _buildFertilizingSelector(provider, screenWidth),
                          screenWidth,
                        ),
                      ],

                      // Plant Information Card
                      SizedBox(height: spacing),

                      Consumer<GardenProvider>(
                        builder: (context, provider, _) {
                          final selected = provider.selectedPlant ?? widget.plant;
                          return _buildModernPlantInfoCard(selected, screenWidth);
                        },
                      ),

                      // Next Reminder Date
                      if (provider.upcomingReminderDate != null) ...[
                        SizedBox(height: spacing),
                        _buildNextReminderCard(provider, screenWidth),
                      ],

                      // Validation Message
                      if (_validationMessage != null) ...[
                        SizedBox(height: spacing),
                        _buildValidationCard(screenWidth),
                      ],

                      // Extra spacing for bottom padding
                      SizedBox(height: spacing * 1.5),
                    ],
                  ),
                ),
              ),

              // Fixed Action Button at bottom
              _buildFixedActionButton(provider, screenWidth, hasActiveReminder),
            ],
          ),
        );
      },
    );
  }

  // 🆕 NEW: Warning card when active reminder exists
  Widget _buildActiveReminderWarning(PlantReminder activeReminder, double screenWidth) {
    final cardPadding = _getCardPadding(screenWidth);
    final iconSize = screenWidth > 600 ? 36.0 : 32.0;
    final iconInnerSize = screenWidth > 600 ? 20.0 : 18.0;
    final fontSize = _getResponsiveFontSize(screenWidth, 13);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              color: Colors.amber.shade700,
              size: iconInnerSize,
            ),
          ),
          SizedBox(width: screenWidth > 600 ? 14 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Reminder Exists',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize + 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You already have an active ${activeReminder.task} reminder for this plant. Complete it first to set a new one.',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.w500,
                    fontSize: fontSize,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Next: ${DateFormat('MMM d, yyyy').format(activeReminder.nextReminderDateTime ?? activeReminder.time)}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize - 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderConfigurationCard(
      BuildContext context,
      GardenProvider provider,
      String title,
      Widget content,
      double screenWidth,
      ) {
    final cardPadding = _getCardPadding(screenWidth);
    final fontSize = _getResponsiveFontSize(screenWidth, 16);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth > 600 ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: fontSize,
              ),
            ),
            SizedBox(height: screenWidth > 600 ? 14 : 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSelector(GardenProvider provider, double screenWidth) {
    return _buildSelectorCard(
      title: provider.selectedTask ?? "Select a task",
      subtitle: "Choose what to remind you about",
      icon: Icons.assignment_outlined,
      onTap: () => _showTaskPicker(context, provider),
      screenWidth: screenWidth,
    );
  }

  Widget _buildTimeSelector(GardenProvider provider, double screenWidth) {
    return _buildSelectorCard(
      title: provider.selectedTime == null
          ? "Select time"
          : provider.selectedTime!.format(context),
      subtitle: "When to trigger reminder",
      icon: Icons.access_time_outlined,
      onTap: () => _pickTime(context, provider),
      screenWidth: screenWidth,
    );
  }

  Widget _buildRoundsSelector(GardenProvider provider, double screenWidth) {
    return _buildSelectorCard(
      title: _getRoundsDisplayText(provider),
      subtitle: "How many times to repeat this reminder",
      icon: Icons.repeat_outlined,
      onTap: () => _showRoundsPicker(context, provider),
      screenWidth: screenWidth,
    );
  }

  Widget _buildFertilizingSelector(GardenProvider provider, double screenWidth) {
    return _buildSelectorCard(
      title: provider.selectedPrevFertilizingLabel ?? "Select",
      subtitle: "When did you last fertilize this plant?",
      icon: Icons.history_outlined,
      onTap: () => _showPrevFertilizingPicker(context, provider),
      screenWidth: screenWidth,
    );
  }

  Widget _buildSelectorCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    final cardPadding = _getCardPadding(screenWidth);
    final titleSize = _getResponsiveFontSize(screenWidth, 14);
    final subtitleSize = _getResponsiveFontSize(screenWidth, 12);
    final iconSize = screenWidth > 600 ? 44.0 : 40.0;
    final iconInnerSize = screenWidth > 600 ? 22.0 : 20.0;

    return Card(
      elevation: 0,
      color: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: iconInnerSize,
                ),
              ),
              SizedBox(width: screenWidth > 600 ? 14 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: titleSize,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                        fontSize: subtitleSize,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: screenWidth > 600 ? 18 : 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatPicker(GardenProvider provider, double screenWidth) {
    final cardPadding = _getCardPadding(screenWidth);
    final fontSize = _getResponsiveFontSize(screenWidth, 14);
    final captionSize = _getResponsiveFontSize(screenWidth, 12);
    final inputSize = _getResponsiveFontSize(screenWidth, 18);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Every",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                    fontSize: captionSize,
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: inputSize,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "1",
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) {
                      provider.setRepeat(provider.repeatType ?? 'days', parsed);
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth > 600 ? 16 : 12),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 14 : 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<String>(
                value: provider.repeatType,
                hint: Text(
                  "Select unit",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                    fontSize: fontSize,
                  ),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                icon: Icon(Icons.arrow_drop_down,
                    color: AppColors.primaryGreen),
                items: _repeatUnits
                    .map(
                      (unit) => DropdownMenuItem(
                    value: unit,
                    child: Text(
                      _displayUnit(unit),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    provider.setRepeat(val, provider.repeatInterval ?? 1);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPlantInfoCard(GardenPlant? plant, double screenWidth) {
    if (plant == null) {
      return Container(
        padding: EdgeInsets.all(_getCardPadding(screenWidth)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No plant selected. Please choose a plant to view details.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: _getResponsiveFontSize(screenWidth, 14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final upcomingReminder = plant.reminders
        .where((r) => r.isActive && r.nextReminderDateTime != null)
        .where((r) => r.nextReminderDateTime!.isAfter(DateTime.now()))
        .isNotEmpty
        ? plant.reminders
        .where((r) => r.isActive && r.nextReminderDateTime != null)
        .where((r) => r.nextReminderDateTime!.isAfter(DateTime.now()))
        .reduce((a, b) =>
    a.nextReminderDateTime!.isBefore(b.nextReminderDateTime!)
        ? a
        : b)
        : null;

    final cardPadding = _getCardPadding(screenWidth);
    final titleSize = _getResponsiveFontSize(screenWidth, 18);
    final iconSize = screenWidth > 600 ? 28.0 : 24.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.green.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(screenWidth > 600 ? 24 : 20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.eco_outlined,
                  color: AppColors.primaryGreen,
                  size: iconSize,
                ),
                SizedBox(width: screenWidth > 600 ? 10 : 8),
                Text(
                  'Plant Information',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth > 600 ? 18 : 16),

            if (upcomingReminder != null) ...[
              _buildInfoItem(
                icon: Icons.notifications_active_outlined,
                label: 'Next ${upcomingReminder.task}',
                value: _formatTimeFromNow(upcomingReminder.nextReminderDateTime!),
                color: Colors.orange,
                screenWidth: screenWidth,
              ),
              SizedBox(height: screenWidth > 600 ? 14 : 12),
            ],

            _buildInfoItem(
              icon: Icons.calendar_today_outlined,
              label: 'Added to Garden',
              value: DateFormat('MMM d, yyyy').format(plant.addedDate),
              color: Colors.blue,
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenWidth > 600 ? 14 : 12),

            _buildInfoItem(
              icon: Icons.favorite_outlined,
              label: 'Health Status',
              value: '${plant.health}%',
              color: _getHealthColor(plant.health),
              screenWidth: screenWidth,
            ),
            SizedBox(height: screenWidth > 600 ? 14 : 12),

            _buildInfoItem(
              icon: Icons.local_florist_outlined,
              label: 'Plant Type',
              value: plant.type,
              color: AppColors.primaryGreen,
              screenWidth: screenWidth,
            ),

            SizedBox(height: screenWidth > 600 ? 18 : 16),
            Container(
              padding: EdgeInsets.all(screenWidth > 600 ? 14 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber.shade600,
                    size: screenWidth > 600 ? 20 : 18,
                  ),
                  SizedBox(width: screenWidth > 600 ? 10 : 8),
                  Expanded(
                    child: Text(
                      'Set reminders based on your plant\'s specific needs',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: _getResponsiveFontSize(screenWidth, 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required double screenWidth,
  }) {
    final iconSize = screenWidth > 600 ? 40.0 : 36.0;
    final iconInnerSize = screenWidth > 600 ? 20.0 : 18.0;
    final labelSize = _getResponsiveFontSize(screenWidth, 11);
    final valueSize = _getResponsiveFontSize(screenWidth, 13);

    return Row(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: iconInnerSize, color: color),
        ),
        SizedBox(width: screenWidth > 600 ? 14 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: labelSize,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: valueSize,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextReminderCard(GardenProvider provider, double screenWidth) {
    final cardPadding = _getCardPadding(screenWidth);
    final iconSize = screenWidth > 600 ? 28.0 : 24.0;
    final captionSize = _getResponsiveFontSize(screenWidth, 12);
    final bodySize = _getResponsiveFontSize(screenWidth, 14);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: AppColors.primaryGreen,
            size: iconSize,
          ),
          SizedBox(width: screenWidth > 600 ? 14 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Next reminder:",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: captionSize,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d, yyyy')
                      .format(provider.upcomingReminderDate!.toLocal()),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: bodySize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationCard(double screenWidth) {
    final cardPadding = _getCardPadding(screenWidth);
    final iconSize = screenWidth > 600 ? 36.0 : 32.0;
    final iconInnerSize = screenWidth > 600 ? 20.0 : 18.0;
    final fontSize = _getResponsiveFontSize(screenWidth, 12);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade600,
              size: iconInnerSize,
            ),
          ),
          SizedBox(width: screenWidth > 600 ? 14 : 12),
          Expanded(
            child: Text(
              _validationMessage!,
              style: AppTextStyles.caption.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 UPDATED: Button now checks for active reminders
  Widget _buildFixedActionButton(GardenProvider provider, double screenWidth, bool hasActiveReminder) {
    final horizontalPadding = _getResponsivePadding(screenWidth);
    final buttonHeight = screenWidth > 600 ? 60.0 : 56.0;
    final fontSize = _getResponsiveFontSize(screenWidth, 16);
    final iconSize = screenWidth > 600 ? 22.0 : 20.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: Material(
          borderRadius: BorderRadius.circular(screenWidth > 600 ? 18 : 16),
          elevation: 4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: provider.isFormValid && !provider.isSaving && !hasActiveReminder
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen,
                  Colors.green.shade600,
                ],
              )
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade400,
                  Colors.grey.shade500,
                ],
              ),
              borderRadius: BorderRadius.circular(screenWidth > 600 ? 18 : 16),
              boxShadow: provider.isFormValid && !provider.isSaving && !hasActiveReminder
                  ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(screenWidth > 600 ? 18 : 16),
              onTap: provider.isFormValid && !provider.isSaving && !hasActiveReminder
                  ? () => _setReminder(provider)
                  : null,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.isSaving)
                      SizedBox(
                        height: iconSize,
                        width: iconSize,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    SizedBox(width: screenWidth > 600 ? 10 : 8),
                    Text(
                      provider.isSaving
                          ? "Setting Reminder..."
                          : "Turn On Reminder",
                      style: AppTextStyles.button.copyWith(
                        fontSize: fontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setReminder(GardenProvider provider) async {
    if (widget.plant == null) {
      debugPrint('[SetReminderScreen] ❌ No plant selected');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("Please select a plant before setting a reminder."),
              ],
            ),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    try {
      final selectedTime = provider.selectedTime;
      final now = DateTime.now();

      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime?.hour ?? 8,
        selectedTime?.minute ?? 0,
      );

      if (provider.selectedTask == null ||
          provider.repeatType == null ||
          provider.repeatInterval == null) {
        debugPrint('[SetReminderScreen] ⚠️ Missing reminder configuration.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Please complete reminder details first."),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      final reminder = PlantReminder(
        id: provider.generateId(),
        task: provider.selectedTask!,
        frequency: "custom",
        isActive: true,
        repeatType: provider.repeatType!,
        repeatInterval: provider.repeatInterval!,
        time: scheduledDateTime,
        plantId: widget.plant!.id,
        plantName: widget.plant!.name,
        totalRounds: provider.selectedRounds ?? 0,
        previousFertilizingLabel: provider.selectedTask == "Fertilizing"
            ? provider.selectedPrevFertilizingLabel
            : null,
        previousFertilizingDate: provider.selectedTask == "Fertilizing"
            ? provider.selectedPrevFertilizingDate
            : null,
      );

      await provider.addReminder(widget.plant!.id, reminder);

      provider.resetReminderForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Reminder added successfully 🎉"),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e, st) {
      debugPrint('[SetReminderScreen] Error setting reminder: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text("Failed to add reminder"),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showTaskPicker(BuildContext context, GardenProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: _tasks.map((task) {
          return ListTile(
            title: Text(task),
            onTap: () {
              provider.selectTask(task);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showPrevFertilizingPicker(
      BuildContext context,
      GardenProvider provider,
      ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: _previousFertilizingOptions.map((option) {
          return ListTile(
            title: Text(option),
            onTap: () {
              final date = _calculatePreviousDate(option);
              provider.setPreviousFertilizing(option, date);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  DateTime _calculatePreviousDate(String option) {
    final now = DateTime.now();
    switch (option) {
      case "Yesterday":
        return now.subtract(const Duration(days: 1));
      case "1 week ago":
        return now.subtract(const Duration(days: 7));
      case "2 weeks ago":
        return now.subtract(const Duration(days: 14));
      case "More than 2 weeks ago":
        return now.subtract(const Duration(days: 21));
      default:
        return now;
    }
  }

  String _getRoundsDisplayText(GardenProvider provider) {
    if (provider.selectedRounds == null) return "Select rounds";
    if (provider.selectedRounds! <= 0) return "Infinite (Until I stop)";
    if (provider.selectedRounds! == 1) return "1 Round";
    return "${provider.selectedRounds} Rounds";
  }

  void _showRoundsPicker(BuildContext context, GardenProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Select Number of Rounds",
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: _roundsOptions.map((option) {
                return ListTile(
                  title: Text(option['label']),
                  onTap: () {
                    if (option['value'] == -1) {
                      Navigator.pop(context);
                      _showCustomRoundsDialog(context, provider);
                    } else {
                      provider.setRounds(option['value']);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomRoundsDialog(BuildContext context, GardenProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Custom Rounds"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter the number of rounds you want:"),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Number of rounds",
                border: OutlineInputBorder(),
                hintText: "e.g., 15",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                provider.setRounds(value);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a valid number greater than 0"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Set"),
          ),
        ],
      ),
    );
  }

  String? _validateReminderTime(GardenProvider provider) {
    if (provider.selectedTime == null) return null;

    final now = DateTime.now();
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      provider.selectedTime!.hour,
      provider.selectedTime!.minute,
    );

    if (selectedDateTime.isBefore(now)) {
      final tomorrow = selectedDateTime.add(const Duration(days: 1));
      if (tomorrow.difference(now).inHours < 1) {
        return "⚠️ Reminder must be at least 1 hour from now";
      }
    } else {
      if (selectedDateTime.difference(now).inHours < 1) {
        return "⚠️ Reminder must be at least 1 hour from now";
      }
    }

    return null;
  }

  Future<void> _pickTime(BuildContext context, GardenProvider provider) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: provider.selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      provider.setTime(picked);
      setState(() {
        _validationMessage = _validateReminderTime(provider);
      });
    }
  }

  String _formatTimeFromNow(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'now';
    }
  }

  Color _getHealthColor(int health) {
    if (health >= 80) return Colors.green;
    if (health >= 60) return Colors.orange;
    return Colors.red;
  }
}