import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medimate_ai/providers/reminder_provider.dart';
import 'package:medimate_ai/utils/constants.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedView = 'Day';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // View selector
            _buildViewSelector(),
            
            // History content
            Expanded(
              child: _buildHistoryContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(
              Icons.history,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            AppStrings.history,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Row(
        children: [
          _buildViewButton('Day', 'Day'),
          const SizedBox(width: AppSizes.paddingS),
          _buildViewButton('Week', 'Week'),
          const SizedBox(width: AppSizes.paddingS),
          _buildViewButton('Month', 'Month'),
        ],
      ),
    );
  }

  Widget _buildViewButton(String text, String value) {
    final isSelected = _selectedView == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedView = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          child: Text(
            text,
            style: AppTextStyles.body2.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryContent() {
    switch (_selectedView) {
      case 'Day':
        return _buildDayView();
      case 'Week':
        return _buildWeekView();
      case 'Month':
        return _buildMonthView();
      default:
        return _buildDayView();
    }
  }

  Widget _buildDayView() {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        final todayReminders = reminderProvider.todayReminders;
        
        if (todayReminders.isEmpty) {
          return _buildEmptyState('No reminders for today');
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          itemCount: todayReminders.length,
          itemBuilder: (context, index) {
            final reminder = todayReminders[index];
            return _buildHistoryCard(reminder, 'Today');
          },
        );
      },
    );
  }

  Widget _buildWeekView() {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        // Get reminders for the current week
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        
        final weekReminders = <Widget>[];
        
        for (int i = 0; i < 7; i++) {
          final date = weekStart.add(Duration(days: i));
          final reminders = reminderProvider.getRemindersForDate(date);
          
          if (reminders.isNotEmpty) {
            weekReminders.add(
              _buildDateHeader(date),
            );
            
            for (final reminder in reminders) {
              weekReminders.add(
                _buildHistoryCard(reminder, DateFormat('MMM dd').format(date)),
              );
            }
          }
        }
        
        if (weekReminders.isEmpty) {
          return _buildEmptyState('No reminders for this week');
        }
        
        return ListView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          children: weekReminders,
        );
      },
    );
  }

  Widget _buildMonthView() {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        // Get reminders for the current month
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        
        final monthReminders = <Widget>[];
        
        for (int i = 0; i < monthEnd.day; i++) {
          final date = monthStart.add(Duration(days: i));
          final reminders = reminderProvider.getRemindersForDate(date);
          
          if (reminders.isNotEmpty) {
            monthReminders.add(
              _buildDateHeader(date),
            );
            
            for (final reminder in reminders) {
              monthReminders.add(
                _buildHistoryCard(reminder, DateFormat('MMM dd').format(date)),
              );
            }
          }
        }
        
        if (monthReminders.isEmpty) {
          return _buildEmptyState('No reminders for this month');
        }
        
        return ListView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          children: monthReminders,
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.paddingL, bottom: AppSizes.paddingM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS,
            ),
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : AppColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: AppTextStyles.caption.copyWith(
                color: isToday ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ReminderModel reminder, String dateLabel) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSizes.paddingM),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(reminder.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Icon(
            _getStatusIcon(reminder.status),
            color: _getStatusColor(reminder.status),
            size: 24,
          ),
        ),
        title: Text(
          reminder.medicineName,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              reminder.dosage,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${reminder.timeString} • $dateLabel',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingS,
            vertical: AppSizes.paddingXS,
          ),
          decoration: BoxDecoration(
            color: _getStatusColor(reminder.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Text(
            _getStatusText(reminder.status),
            style: AppTextStyles.caption.copyWith(
              color: _getStatusColor(reminder.status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your medication history will appear here',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.taken:
        return AppColors.success;
      case ReminderStatus.missed:
        return AppColors.error;
      case ReminderStatus.snoozed:
        return AppColors.warning;
      case ReminderStatus.pending:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.taken:
        return Icons.check_circle;
      case ReminderStatus.missed:
        return Icons.cancel;
      case ReminderStatus.snoozed:
        return Icons.snooze;
      case ReminderStatus.pending:
        return Icons.access_time;
    }
  }

  String _getStatusText(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.taken:
        return AppStrings.taken;
      case ReminderStatus.missed:
        return AppStrings.missed;
      case ReminderStatus.snoozed:
        return 'Snoozed';
      case ReminderStatus.pending:
        return 'Pending';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
