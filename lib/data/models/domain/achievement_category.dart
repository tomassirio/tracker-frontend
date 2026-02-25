/// Achievement type identifiers matching backend enum
enum AchievementType {
  // Distance achievements (kilometers walked in a single trip)
  distanceOneHundredKm,
  distanceTwoHundredKm,
  distanceFiveHundredKm,
  distanceEightHundredKm,
  distanceOneThousandKm,
  distanceSixteenHundredKm,
  distanceTwentyTwoHundredKm,

  // Update count achievements (posts per trip)
  updatesTen,
  updatesFifty,
  updatesOneHundred,

  // Duration achievements (trip length in days)
  durationSevenDays,
  durationThirtyDays,
  durationFortyFiveDays,
  durationSixtyDays,

  // Social - Followers (user-wide)
  followersTen,
  followersFifty,
  followersOneHundred,

  // Social - Friends (user-wide)
  friendsFive,
  friendsTwenty,
  friendsFifty;

  String toJson() {
    switch (this) {
      case AchievementType.distanceOneHundredKm:
        return 'DISTANCE_100KM';
      case AchievementType.distanceTwoHundredKm:
        return 'DISTANCE_200KM';
      case AchievementType.distanceFiveHundredKm:
        return 'DISTANCE_500KM';
      case AchievementType.distanceEightHundredKm:
        return 'DISTANCE_800KM';
      case AchievementType.distanceOneThousandKm:
        return 'DISTANCE_1000KM';
      case AchievementType.distanceSixteenHundredKm:
        return 'DISTANCE_1600KM';
      case AchievementType.distanceTwentyTwoHundredKm:
        return 'DISTANCE_2200KM';
      case AchievementType.updatesTen:
        return 'UPDATES_10';
      case AchievementType.updatesFifty:
        return 'UPDATES_50';
      case AchievementType.updatesOneHundred:
        return 'UPDATES_100';
      case AchievementType.durationSevenDays:
        return 'DURATION_7_DAYS';
      case AchievementType.durationThirtyDays:
        return 'DURATION_30_DAYS';
      case AchievementType.durationFortyFiveDays:
        return 'DURATION_45_DAYS';
      case AchievementType.durationSixtyDays:
        return 'DURATION_60_DAYS';
      case AchievementType.followersTen:
        return 'FOLLOWERS_10';
      case AchievementType.followersFifty:
        return 'FOLLOWERS_50';
      case AchievementType.followersOneHundred:
        return 'FOLLOWERS_100';
      case AchievementType.friendsFive:
        return 'FRIENDS_5';
      case AchievementType.friendsTwenty:
        return 'FRIENDS_20';
      case AchievementType.friendsFifty:
        return 'FRIENDS_50';
    }
  }

  static AchievementType fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'DISTANCE_100KM':
        return AchievementType.distanceOneHundredKm;
      case 'DISTANCE_200KM':
        return AchievementType.distanceTwoHundredKm;
      case 'DISTANCE_500KM':
        return AchievementType.distanceFiveHundredKm;
      case 'DISTANCE_800KM':
        return AchievementType.distanceEightHundredKm;
      case 'DISTANCE_1000KM':
        return AchievementType.distanceOneThousandKm;
      case 'DISTANCE_1600KM':
        return AchievementType.distanceSixteenHundredKm;
      case 'DISTANCE_2200KM':
        return AchievementType.distanceTwentyTwoHundredKm;
      case 'UPDATES_10':
        return AchievementType.updatesTen;
      case 'UPDATES_50':
        return AchievementType.updatesFifty;
      case 'UPDATES_100':
        return AchievementType.updatesOneHundred;
      case 'DURATION_7_DAYS':
        return AchievementType.durationSevenDays;
      case 'DURATION_30_DAYS':
        return AchievementType.durationThirtyDays;
      case 'DURATION_45_DAYS':
        return AchievementType.durationFortyFiveDays;
      case 'DURATION_60_DAYS':
        return AchievementType.durationSixtyDays;
      case 'FOLLOWERS_10':
        return AchievementType.followersTen;
      case 'FOLLOWERS_50':
        return AchievementType.followersFifty;
      case 'FOLLOWERS_100':
        return AchievementType.followersOneHundred;
      case 'FRIENDS_5':
        return AchievementType.friendsFive;
      case 'FRIENDS_20':
        return AchievementType.friendsTwenty;
      case 'FRIENDS_50':
        return AchievementType.friendsFifty;
      default:
        throw ArgumentError('Invalid achievement type: $value');
    }
  }

  /// Get the display category for grouping achievements
  String get category {
    final jsonValue = toJson();
    if (jsonValue.startsWith('DISTANCE_')) return 'Distance';
    if (jsonValue.startsWith('UPDATES_')) return 'Updates';
    if (jsonValue.startsWith('DURATION_')) return 'Duration';
    if (jsonValue.startsWith('FOLLOWERS_')) return 'Social';
    if (jsonValue.startsWith('FRIENDS_')) return 'Social';
    return 'Other';
  }
}
