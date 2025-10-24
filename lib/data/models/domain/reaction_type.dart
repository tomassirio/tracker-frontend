/// Reaction types
enum ReactionType {
  heart,
  smiley,
  sad,
  laugh,
  anger;

  String toJson() {
    switch (this) {
      case ReactionType.heart:
        return 'HEART';
      case ReactionType.smiley:
        return 'SMILEY';
      case ReactionType.sad:
        return 'SAD';
      case ReactionType.laugh:
        return 'LAUGH';
      case ReactionType.anger:
        return 'ANGER';
    }
  }

  static ReactionType fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'HEART':
        return ReactionType.heart;
      case 'SMILEY':
        return ReactionType.smiley;
      case 'SAD':
        return ReactionType.sad;
      case 'LAUGH':
        return ReactionType.laugh;
      case 'ANGER':
        return ReactionType.anger;
      default:
        throw ArgumentError('Invalid reaction type: $value');
    }
  }
}
