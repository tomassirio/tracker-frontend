import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/widgets/home/trip_card.dart';
import 'package:tracker_frontend/presentation/widgets/home/empty_trips_view.dart';
import 'package:tracker_frontend/presentation/widgets/home/error_view.dart';

/// Main content widget for the home screen
class HomeContent extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Trip> trips;
  final bool isLoggedIn;
  final Future<void> Function() onRefresh;
  final Function(Trip) onTripTap;
  final VoidCallback? onLoginPressed;

  const HomeContent({
    super.key,
    required this.isLoading,
    this.error,
    required this.trips,
    required this.isLoggedIn,
    required this.onRefresh,
    required this.onTripTap,
    this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return ErrorView(
        error: error!,
        onRetry: onRefresh,
      );
    }

    if (trips.isEmpty) {
      return EmptyTripsView(
        isLoggedIn: isLoggedIn,
        onLoginPressed: onLoginPressed,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return TripCard(
            trip: trip,
            onTap: () => onTripTap(trip),
          );
        },
      ),
    );
  }
}

