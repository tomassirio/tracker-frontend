import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/widgets/home/youtube_trip_card.dart';
import 'package:tracker_frontend/presentation/widgets/home/empty_trips_view.dart';
import 'package:tracker_frontend/presentation/widgets/home/error_view.dart';

/// YouTube-style home content with categorized trip sections
class YouTubeHomeContent extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<Trip> trips;
  final bool isLoggedIn;
  final String? currentUserId;
  final Future<void> Function() onRefresh;
  final Function(Trip) onTripTap;
  final VoidCallback? onLoginPressed;

  const YouTubeHomeContent({
    super.key,
    required this.isLoading,
    this.error,
    required this.trips,
    required this.isLoggedIn,
    this.currentUserId,
    required this.onRefresh,
    required this.onTripTap,
    this.onLoginPressed,
  });

  List<Trip> _filterMyTrips() {
    if (!isLoggedIn || currentUserId == null) return [];
    return trips.where((trip) => trip.userId == currentUserId).toList();
  }

  List<Trip> _filterFriendsTrips() {
    if (!isLoggedIn || currentUserId == null) return [];
    // For now, friends trips are those from other users that are not public
    // This logic can be enhanced when friend relationships are implemented
    return trips
        .where((trip) =>
            trip.userId != currentUserId &&
            trip.visibility.toJson() == 'FRIENDS')
        .toList();
  }

  List<Trip> _filterPublicTrips() {
    if (!isLoggedIn || currentUserId == null) {
      // Show all trips when not logged in
      return trips;
    }
    return trips
        .where((trip) =>
            trip.userId != currentUserId &&
            trip.visibility.toJson() == 'PUBLIC')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return ErrorView(error: error!, onRetry: onRefresh);
    }

    if (trips.isEmpty) {
      return EmptyTripsView(
        isLoggedIn: isLoggedIn,
        onLoginPressed: onLoginPressed,
      );
    }

    final myTrips = _filterMyTrips();
    final friendsTrips = _filterFriendsTrips();
    final publicTrips = _filterPublicTrips();

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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // My Trips Section
              if (myTrips.isNotEmpty) ...[
                _buildSectionHeader('My Trips', myTrips.length),
                const SizedBox(height: 12),
                _buildTripGrid(myTrips, crossAxisCount),
                const SizedBox(height: 32),
              ],
              // Friends Trips Section
              if (friendsTrips.isNotEmpty) ...[
                _buildSectionHeader('Friends Trips', friendsTrips.length),
                const SizedBox(height: 12),
                _buildTripGrid(friendsTrips, crossAxisCount),
                const SizedBox(height: 32),
              ],
              // Public Trips Section
              if (publicTrips.isNotEmpty) ...[
                _buildSectionHeader(
                  isLoggedIn ? 'Public Trips' : 'All Trips',
                  publicTrips.length,
                ),
                const SizedBox(height: 12),
                _buildTripGrid(publicTrips, crossAxisCount),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripGrid(List<Trip> trips, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.85, // Slightly taller for smaller cards with 4:3 ratio
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return YouTubeTripCard(
          trip: trip,
          onTap: () => onTripTap(trip),
        );
      },
    );
  }
}
