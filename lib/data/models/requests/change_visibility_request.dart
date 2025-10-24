import '../../../core/constants/enums.dart';

/// Request model for changing trip visibility
class ChangeVisibilityRequest {
  final Visibility visibility;

  ChangeVisibilityRequest({required this.visibility});

  Map<String, dynamic> toJson() => {'visibility': visibility.toJson()};
}
