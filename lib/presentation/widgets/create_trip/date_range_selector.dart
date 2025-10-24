import 'package:flutter/material.dart';
import 'package:tracker_frontend/presentation/widgets/create_trip/date_picker_card.dart';

/// Date range selector with start and end date pickers
class DateRangeSelector extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;
  final VoidCallback onClearStartDate;
  final VoidCallback onClearEndDate;

  const DateRangeSelector({
    super.key,
    this.startDate,
    this.endDate,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
    required this.onClearStartDate,
    required this.onClearEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dates (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DatePickerCard(
          label: 'Start Date',
          icon: Icons.calendar_today,
          selectedDate: startDate,
          onTap: onSelectStartDate,
          onClear: onClearStartDate,
        ),
        const SizedBox(height: 8),
        DatePickerCard(
          label: 'End Date',
          icon: Icons.event,
          selectedDate: endDate,
          onTap: onSelectEndDate,
          onClear: onClearEndDate,
        ),
      ],
    );
  }
}
