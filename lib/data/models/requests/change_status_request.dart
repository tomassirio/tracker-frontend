import '../../../core/constants/enums.dart';

/// Request model for changing trip status
class ChangeStatusRequest {
  final TripStatus status;

  ChangeStatusRequest({required this.status});

  Map<String, dynamic> toJson() => {'status': status.toJson()};
}
