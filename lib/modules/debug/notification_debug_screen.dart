// lib/modules/debug/notification_debug_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/notification/notification_debug_helper.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_style.dart';

class NotificationDebugScreen extends StatefulWidget {
  const NotificationDebugScreen({super.key});

  @override
  State<NotificationDebugScreen> createState() => _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  final _debugHelper = NotificationDebugHelper.instance;
  bool _isLoading = true;
  Map<String, dynamic> _systemInfo = {};
  Map<String, dynamic> _permissionInfo = {};
  List<Map<String, dynamic>> _pendingNotifications = [];
  String? _diagnosticReport;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);
    
    try {
      final systemInfo = await _debugHelper.getSystemInfo();
      final permissionInfo = await _debugHelper.checkNotificationPermissions();
      final pendingNotifications = await _debugHelper.getPendingNotificationDetails();
      
      setState(() {
        _systemInfo = systemInfo;
        _permissionInfo = permissionInfo;
        _pendingNotifications = pendingNotifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load debug info: $e');
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      final success = await _debugHelper.sendTestNotification();
      final message = success 
          ? '✅ Test notification sent! Check your notifications panel.'
          : '❌ Failed to send test notification. Check logs for details.';
      
      _showInfoSnackBar(message);
    } catch (e) {
      _showErrorSnackBar('Error sending test notification: $e');
    }
  }

  Future<void> _scheduleTestNotification() async {
    try {
      final success = await _debugHelper.sendTestScheduledNotification();
      final message = success 
          ? '⏰ Test notification scheduled for 1 minute from now!'
          : '❌ Failed to schedule test notification. Check logs for details.';
      
      _showInfoSnackBar(message);
      
      // Refresh pending notifications list
      final pending = await _debugHelper.getPendingNotificationDetails();
      setState(() => _pendingNotifications = pending);
    } catch (e) {
      _showErrorSnackBar('Error scheduling test notification: $e');
    }
  }

  Future<void> _generateDiagnosticReport() async {
    setState(() => _isLoading = true);
    
    try {
      final report = await _debugHelper.generateDiagnosticReport();
      setState(() {
        _diagnosticReport = report;
        _isLoading = false;
      });
      
      _showDiagnosticReportDialog(report);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to generate report: $e');
    }
  }

  Future<void> _clearTestNotifications() async {
    try {
      await _debugHelper.clearTestNotifications();
      _showInfoSnackBar('✅ Test notifications cleared');
      
      // Refresh pending notifications list
      final pending = await _debugHelper.getPendingNotificationDetails();
      setState(() => _pendingNotifications = pending);
    } catch (e) {
      _showErrorSnackBar('Error clearing test notifications: $e');
    }
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDiagnosticReportDialog(String report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnostic Report'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            child: Text(
              report,
              style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: report));
              Navigator.pop(context);
              _showInfoSnackBar('Report copied to clipboard');
            },
            child: const Text('Copy to Clipboard'),
          ),
          ElevatedButton(
            onPressed: () {
              Share.share(
                report,
                subject: 'AI Tree Plant - Notification Diagnostic Report',
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notification Debug'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
            tooltip: 'Refresh debug info',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActionsSection(),
                  const SizedBox(height: 24),
                  _buildSystemInfoSection(),
                  const SizedBox(height: 24),
                  _buildPermissionInfoSection(),
                  const SizedBox(height: 24),
                  _buildPendingNotificationsSection(),
                  const SizedBox(height: 24),
                  _buildDeviceSpecificWarningsSection(),
                  const SizedBox(height: 24),
                  _buildGenerateReportSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Tests',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendTestNotification,
                    icon: const Icon(Icons.notifications),
                    label: const Text('Test Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _scheduleTestNotification,
                    icon: const Icon(Icons.schedule),
                    label: const Text('Schedule Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearTestNotifications,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Test Notifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Information',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._systemInfo.entries.where((e) => e.key != 'deviceWarnings').map(
              (entry) => _buildInfoRow(entry.key, entry.value.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Permissions',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._permissionInfo.entries.where((e) => e.key != 'pendingDetails').map(
              (entry) => _buildInfoRow(
                entry.key,
                entry.value.toString(),
                isStatus: ['notificationPermission', 'canScheduleExact', 'batteryOptimizationDisabled'].contains(entry.key),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingNotificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending Notifications (${_pendingNotifications.length})',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_pendingNotifications.isEmpty)
              Text(
                'No pending notifications',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              ..._pendingNotifications.map(
                (notification) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: ${notification['id']}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        notification['title'],
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (notification['body'].isNotEmpty)
                        Text(
                          notification['body'],
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSpecificWarningsSection() {
    final warnings = _systemInfo['deviceWarnings'] as List<dynamic>?;
    
    if (warnings == null || warnings.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: AppColors.accentOrange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Device-Specific Recommendations',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...warnings.map(
              (warning) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        warning.toString(),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateReportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnostic Report',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Generate a comprehensive report with all debug information that can be shared with support.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateDiagnosticReport,
                icon: const Icon(Icons.assessment),
                label: const Text('Generate Full Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String key, String value, {bool isStatus = false}) {
    Color? statusColor;
    IconData? statusIcon;
    
    if (isStatus) {
      final isTrue = value.toLowerCase() == 'true';
      statusColor = isTrue ? AppColors.success : AppColors.error;
      statusIcon = isTrue ? Icons.check_circle : Icons.error;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key.replaceAllMapped(
                RegExp(r'([A-Z])'),
                (match) => ' ${match.group(1)}',
              ).toLowerCase().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (statusIcon != null) ...[
                  Icon(statusIcon, size: 16, color: statusColor),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: statusColor ?? AppColors.textPrimary,
                      fontWeight: isStatus ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
