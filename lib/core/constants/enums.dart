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

/// Weather conditions from backend weather API
enum WeatherCondition {
  clear,
  mostlyClear,
  partlyCloudy,
  cloudy,
  fog,
  haze,
  drizzle,
  lightRain,
  rain,
  heavyRain,
  lightSnow,
  snow,
  heavySnow,
  sleet,
  hail,
  thunderstorm,
  windy,
  unknown;

  /// Convert weather condition to string for API
  String toJson() {
    switch (this) {
      case WeatherCondition.clear:
        return 'CLEAR';
      case WeatherCondition.mostlyClear:
        return 'MOSTLY_CLEAR';
      case WeatherCondition.partlyCloudy:
        return 'PARTLY_CLOUDY';
      case WeatherCondition.cloudy:
        return 'CLOUDY';
      case WeatherCondition.fog:
        return 'FOG';
      case WeatherCondition.haze:
        return 'HAZE';
      case WeatherCondition.drizzle:
        return 'DRIZZLE';
      case WeatherCondition.lightRain:
        return 'LIGHT_RAIN';
      case WeatherCondition.rain:
        return 'RAIN';
      case WeatherCondition.heavyRain:
        return 'HEAVY_RAIN';
      case WeatherCondition.lightSnow:
        return 'LIGHT_SNOW';
      case WeatherCondition.snow:
        return 'SNOW';
      case WeatherCondition.heavySnow:
        return 'HEAVY_SNOW';
      case WeatherCondition.sleet:
        return 'SLEET';
      case WeatherCondition.hail:
        return 'HAIL';
      case WeatherCondition.thunderstorm:
        return 'THUNDERSTORM';
      case WeatherCondition.windy:
        return 'WINDY';
      case WeatherCondition.unknown:
        return 'UNKNOWN';
    }
  }

  /// Parse weather condition from API response
  static WeatherCondition fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'CLEAR':
        return WeatherCondition.clear;
      case 'MOSTLY_CLEAR':
        return WeatherCondition.mostlyClear;
      case 'PARTLY_CLOUDY':
        return WeatherCondition.partlyCloudy;
      case 'CLOUDY':
        return WeatherCondition.cloudy;
      case 'FOG':
        return WeatherCondition.fog;
      case 'HAZE':
        return WeatherCondition.haze;
      case 'DRIZZLE':
        return WeatherCondition.drizzle;
      case 'LIGHT_RAIN':
        return WeatherCondition.lightRain;
      case 'RAIN':
        return WeatherCondition.rain;
      case 'HEAVY_RAIN':
        return WeatherCondition.heavyRain;
      case 'LIGHT_SNOW':
        return WeatherCondition.lightSnow;
      case 'SNOW':
        return WeatherCondition.snow;
      case 'HEAVY_SNOW':
        return WeatherCondition.heavySnow;
      case 'SLEET':
        return WeatherCondition.sleet;
      case 'HAIL':
        return WeatherCondition.hail;
      case 'THUNDERSTORM':
        return WeatherCondition.thunderstorm;
      case 'WINDY':
        return WeatherCondition.windy;
      default:
        return WeatherCondition.unknown;
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
