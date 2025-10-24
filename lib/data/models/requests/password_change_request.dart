/// Request model for changing password (when logged in)
class PasswordChangeRequest {
  final String oldPassword;
  final String newPassword;

  PasswordChangeRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'old_password': oldPassword,
        'new_password': newPassword,
      };
}

