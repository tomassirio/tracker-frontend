/// Request model for updating user profile
class UpdateProfileRequest {
  final String? displayName;
  final String? bio;
  final String? avatarUrl;

  UpdateProfileRequest({this.displayName, this.bio, this.avatarUrl});

  Map<String, dynamic> toJson() => {
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
}
