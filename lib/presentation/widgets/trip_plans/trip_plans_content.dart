import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/widgets/trip_plans/trip_plan_card.dart';
import 'package:tracker_frontend/presentation/widgets/trip_plans/empty_trip_plans_view.dart';
import 'package:tracker_frontend/presentation/widgets/trip_plans/trip_plans_error_view.dart';
import 'package:tracker_frontend/presentation/widgets/trip_plans/login_required_view.dart';

/// Main content widget for trip plans screen
class TripPlansContent extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<TripPlan> tripPlans;
  final bool isLoggedIn;
  final Future<void> Function() onRefresh;
  final Function(TripPlan) onTripPlanTap;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onCreatePressed;

  const TripPlansContent({
    super.key,
    required this.isLoading,
    this.error,
    required this.tripPlans,
    required this.isLoggedIn,
    required this.onRefresh,
    required this.onTripPlanTap,
    this.onLoginPressed,
    this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Show login required if not logged in
    if (!isLoggedIn) {
      return LoginRequiredView(onLoginPressed: onLoginPressed);
    }

    // Show loading indicator
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error view
    if (error != null) {
      return TripPlansErrorView(error: error!, onRetry: onRefresh);
    }

    // Show empty state
    if (tripPlans.isEmpty) {
      return EmptyTripPlansView(onCreatePressed: onCreatePressed);
    }

    // Show trip plans grid
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate number of columns based on screen width
          int crossAxisCount = 1;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 900) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 2;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: tripPlans.length,
            itemBuilder: (context, index) {
              return TripPlanCard(
                plan: tripPlans[index],
                onTap: () => onTripPlanTap(tripPlans[index]),
              );
            },
          );
        },
      ),
    );
  }
}
