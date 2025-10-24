/// Visibility levels for trips and content
enum Visibility {
  /// Only the owner can view
  private,

  /// Followers or users with a shared link can view
  protected,

  /// Everyone can view
  public;

  /// Convert visibility to string for API
  String toJson() {
    switch (this) {
      case Visibility.private:
        return 'PRIVATE';
      case Visibility.protected:
        return 'PROTECTED';
      case Visibility.public:
        return 'PUBLIC';
    }
  }

  /// Parse visibility from API response
  static Visibility fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'PRIVATE':
        return Visibility.private;
      case 'PROTECTED':
        return Visibility.protected;
      case 'PUBLIC':
        return Visibility.public;
      default:
        throw ArgumentError('Invalid visibility value: $value');
    }
  }
}

/// Status for trips
enum TripStatus {
  /// Trip is being created
  created,

  /// Trip is currently ongoing
  inProgress,

  /// Trip is paused
  paused,

  /// Trip has finished
  finished;

  /// Convert status to string for API
  String toJson() {
    switch (this) {
      case TripStatus.created:
        return 'CREATED';
      case TripStatus.inProgress:
        return 'IN_PROGRESS';
      case TripStatus.paused:
        return 'PAUSED';
      case TripStatus.finished:
        return 'FINISHED';
    }
  }

  /// Parse status from API response
  static TripStatus fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'CREATED':
        return TripStatus.created;
      case 'IN_PROGRESS':
        return TripStatus.inProgress;
      case 'PAUSED':
        return TripStatus.paused;
      case 'FINISHED':
        return TripStatus.finished;
      default:
        throw ArgumentError('Invalid trip status value: $value');
    }
  }
}
