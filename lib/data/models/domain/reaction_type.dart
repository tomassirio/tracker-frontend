/// Reaction types
enum ReactionType {
  like,
  love,
  wow,
  haha,
  sad;

  String toJson() {
    switch (this) {
      case ReactionType.like:
        return 'LIKE';
      case ReactionType.love:
        return 'LOVE';
      case ReactionType.wow:
        return 'WOW';
      case ReactionType.haha:
        return 'HAHA';
      case ReactionType.sad:
        return 'SAD';
    }
  }

  static ReactionType fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'LIKE':
        return ReactionType.like;
      case 'LOVE':
        return ReactionType.love;
      case 'WOW':
        return ReactionType.wow;
      case 'HAHA':
        return ReactionType.haha;
      case 'SAD':
        return ReactionType.sad;
      default:
        throw ArgumentError('Invalid reaction type: $value');
    }
  }
}

