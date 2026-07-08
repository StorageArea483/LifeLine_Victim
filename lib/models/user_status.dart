/// Model to hold user status information
class UserStatus {
  final bool isBlocked;
  final bool isDeleted; // True when user document is deleted from database
  final String email;
  final String uid;

  UserStatus({
    required this.isBlocked,
    required this.isDeleted,
    required this.email,
    required this.uid,
  });
}
