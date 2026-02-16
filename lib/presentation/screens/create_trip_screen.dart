import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/core/constants/enums.dart';
import 'package:tracker_frontend/data/repositories/create_trip_repository.dart';
import 'package:tracker_frontend/data/services/trip_plan_service.dart';
import 'package:tracker_frontend/data/services/trip_service.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/helpers/ui_helpers.dart';
import 'package:tracker_frontend/presentation/widgets/create_trip/create_trip_form.dart';
import 'package:tracker_frontend/presentation/screens/trip_detail_screen.dart';

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
  TripPlan? _selectedTripPlan;
  List<TripPlan> _tripPlans = [];
  late final TripPlanService _tripPlanService;
  late final TripService _tripService;

  @override
  void initState() {
    super.initState();
    _tripPlanService = TripPlanService();
    _tripService = TripService();
    _loadTripPlans();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTripPlans() async {
    try {
      final plans = await _tripPlanService.getUserTripPlans();
      setState(() {
        _tripPlans = plans;
      });
    } catch (e) {
      // Log error but allow user to continue with manual trip creation
      // User may not have any trip plans yet or may not be authenticated
      debugPrint('Failed to load trip plans: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatPlanType(String planType) {
    // Convert SIMPLE to Simple, MULTI_DAY to Multi Day, etc.
    return planType
        .split('_')
        .map((word) => word[0] + word.substring(1).toLowerCase())
        .join(' ');
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
    // If a trip plan is selected, create from plan
    if (_selectedTripPlan != null) {
      await _createTripFromPlan();
      return;
    }

    // Otherwise, create trip normally
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tripId = await _repository.createTrip(
        name: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        visibility: _selectedVisibility,
        startDate: _startDate,
        endDate: _endDate,
      );

      // Fetch the created trip to get full details
      final trip = await _repository.getTripById(tripId);

      if (mounted) {
        UiHelpers.showSuccessMessage(context, 'Trip created successfully!');
        // Navigate to trip detail screen, replacing current screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailScreen(trip: trip),
          ),
        );
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

  Future<void> _createTripFromPlan() async {
    if (_selectedTripPlan == null) return;

    // Show visibility selection dialog
    final visibility = await showDialog<Visibility>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Visibility'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Public'),
              subtitle: const Text('Visible to everyone'),
              onTap: () => Navigator.pop(context, Visibility.public),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Private'),
              subtitle: const Text('Only visible to you'),
              onTap: () => Navigator.pop(context, Visibility.private),
            ),
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Protected'),
              subtitle: const Text('Visible to friends only'),
              onTap: () => Navigator.pop(context, Visibility.protected),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (visibility == null || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final tripId = await _tripService.createTripFromPlan(
          _selectedTripPlan!.id, visibility);

      // Fetch the created trip to get full details
      final trip = await _tripService.getTripById(tripId);

      if (mounted) {
        UiHelpers.showSuccessMessage(
          context,
          'Trip created from plan successfully!',
        );
        // Navigate to trip detail screen, replacing current screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailScreen(trip: trip),
          ),
        );
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trip Plan Selector Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Create from Trip Plan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_tripPlans.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'You don\'t have any trip plans yet. Create a trip plan first to use this feature.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<TripPlan>(
                        value: _selectedTripPlan,
                        decoration: const InputDecoration(
                          labelText: 'Select a trip plan (optional)',
                          border: OutlineInputBorder(),
                          hintText: 'Choose a plan or create manually',
                        ),
                        items: [
                          const DropdownMenuItem<TripPlan>(
                            value: null,
                            child: Text('None - Create manually'),
                          ),
                          ..._tripPlans.map((plan) {
                            return DropdownMenuItem<TripPlan>(
                              value: plan,
                              child: Text(plan.name),
                            );
                          }),
                        ],
                        onChanged: (plan) {
                          setState(() {
                            _selectedTripPlan = plan;
                          });
                        },
                      ),
                    if (_selectedTripPlan != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Plan Details:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Type: ${_formatPlanType(_selectedTripPlan!.planType)}',
                            ),
                            if (_selectedTripPlan!.startDate != null &&
                                _selectedTripPlan!.endDate != null)
                              Text(
                                'Dates: ${_formatDate(_selectedTripPlan!.startDate!)} - ${_formatDate(_selectedTripPlan!.endDate!)}',
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedTripPlan != null)
              const Divider(height: 32)
            else
              const Text(
                'Or create a trip manually:',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 16),
            // Manual Trip Creation Form
            if (_selectedTripPlan == null)
              CreateTripForm(
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
              )
            else
              ElevatedButton(
                onPressed: _isLoading ? null : _createTrip,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Create Trip from Plan',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
