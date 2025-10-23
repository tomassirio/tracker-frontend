import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/presentation/widgets/create_trip/create_trip_button.dart';
import 'package:tracker_frontend/presentation/widgets/create_trip/date_range_selector.dart';
import 'package:tracker_frontend/presentation/widgets/create_trip/trip_description_field.dart';
import 'package:tracker_frontend/presentation/widgets/create_trip/trip_title_field.dart';
import 'package:tracker_frontend/presentation/widgets/create_trip/visibility_selector.dart';

/// Main form widget for creating a trip
class CreateTripForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final Visibility selectedVisibility;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isLoading;
  final ValueChanged<Visibility> onVisibilityChanged;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;
  final VoidCallback onClearStartDate;
  final VoidCallback onClearEndDate;
  final VoidCallback onSubmit;

  const CreateTripForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.selectedVisibility,
    this.startDate,
    this.endDate,
    required this.isLoading,
    required this.onVisibilityChanged,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
    required this.onClearStartDate,
    required this.onClearEndDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TripTitleField(controller: titleController),
          const SizedBox(height: 16),
          TripDescriptionField(controller: descriptionController),
          const SizedBox(height: 24),
          VisibilitySelector(
            selectedVisibility: selectedVisibility,
            onVisibilityChanged: onVisibilityChanged,
          ),
          const SizedBox(height: 24),
          DateRangeSelector(
            startDate: startDate,
            endDate: endDate,
            onSelectStartDate: onSelectStartDate,
            onSelectEndDate: onSelectEndDate,
            onClearStartDate: onClearStartDate,
            onClearEndDate: onClearEndDate,
          ),
          const SizedBox(height: 32),
          CreateTripButton(
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

