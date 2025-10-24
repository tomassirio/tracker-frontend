import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/repositories/create_trip_repository.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/create_trip/create_trip_form.dart';

/// Screen for creating a new trip
class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final CreateTripRepository _repository = CreateTripRepository();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Visibility _selectedVisibility = Visibility.public;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _repository.createTrip(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        visibility: _selectedVisibility,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Trip created successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorMessage(context, 'Error creating trip: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Trip'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CreateTripForm(
          formKey: _formKey,
          titleController: _titleController,
          descriptionController: _descriptionController,
          selectedVisibility: _selectedVisibility,
          startDate: _startDate,
          endDate: _endDate,
          isLoading: _isLoading,
          onVisibilityChanged: (visibility) {
            setState(() {
              _selectedVisibility = visibility;
            });
          },
          onSelectStartDate: _selectStartDate,
          onSelectEndDate: _selectEndDate,
          onClearStartDate: () {
            setState(() {
              _startDate = null;
            });
          },
          onClearEndDate: () {
            setState(() {
              _endDate = null;
            });
          },
          onSubmit: _createTrip,
        ),
      ),
    );
  }
}
