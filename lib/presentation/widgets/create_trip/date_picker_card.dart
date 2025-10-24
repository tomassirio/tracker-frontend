import 'package:flutter/material.dart';

/// Date picker widget for selecting trip dates
class DatePickerCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const DatePickerCard({
    super.key,
    required this.label,
    required this.icon,
    this.selectedDate,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(
          selectedDate != null
              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
              : 'Not set',
        ),
        trailing: selectedDate != null && onClear != null
            ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
            : null,
        onTap: onTap,
      ),
    );
  }
}
