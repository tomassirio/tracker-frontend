import 'package:flutter/material.dart' hide Visibility;
import 'package:tracker_frontend/data/models/trip_models.dart';
import 'package:tracker_frontend/presentation/screens/profile_screen.dart';
import 'package:tracker_frontend/presentation/helpers/page_transitions.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';

/// Widget displaying trip information card
class TripInfoCard extends StatelessWidget {
  final Trip trip;

  const TripInfoCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WandererTheme.backgroundCard,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with status chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  trip.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: WandererTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration:
                    WandererTheme.statusChipDecoration(trip.status.toJson()),
                child: Text(
                  trip.status.toJson().toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: WandererTheme.statusTextColor(trip.status.toJson()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // User info row
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                PageTransitions.slideRight(
                  ProfileScreen(userId: trip.userId),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: WandererTheme.primaryOrange,
                    child: Text(
                      trip.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '@${trip.username}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: WandererTheme.primaryOrange,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: WandererTheme.primaryOrange,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              _buildStatItem(
                Icons.comment_outlined,
                '${trip.commentsCount}',
                'comments',
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                _getVisibilityIcon(trip.visibility.toJson()),
                trip.visibility.toJson(),
                '',
              ),
            ],
          ),
          // Description if present
          if (trip.description != null && trip.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WandererTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trip.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: WandererTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: WandererTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label.isEmpty ? value : '$value $label',
          style: TextStyle(
            fontSize: 13,
            color: WandererTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getVisibilityIcon(String visibility) {
    switch (visibility.toLowerCase()) {
      case 'public':
        return Icons.public;
      case 'private':
        return Icons.lock;
      case 'protected':
        return Icons.shield;
      default:
        return Icons.visibility;
    }
  }
}
