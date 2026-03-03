import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'polyline_codec.dart';

/// Client for Google Maps Static API
/// Handles generation of static map image URLs
class GoogleMapsApiClient {
  final String _apiKey;

  /// Default width for static map images
  static const int defaultMapWidth = 600;

  /// Aspect ratio for card previews (16:9)
  static const double cardAspectRatio = 16 / 9;

  /// Default size for card preview maps (16:9 aspect ratio)
  static String get defaultCardSize =>
      '${defaultMapWidth}x${(defaultMapWidth / cardAspectRatio).round()}';

  /// Size for square thumbnail maps (1:1 aspect ratio)
  static String get defaultSquareSize => '${defaultMapWidth}x$defaultMapWidth';

  /// Maximum URL length for Static Maps API (unsigned URLs).
  static const int maxUrlLength = 8192;

  GoogleMapsApiClient(this._apiKey);

  /// Generate a static map image URL
  ///
  /// Parameters:
  /// - [center]: Center point of the map (if null, auto-fits to markers/path)
  /// - [size]: Image size in format "widthxheight" (defaults to 16:9 aspect ratio)
  /// - [markers]: List of markers to display
  /// - [path]: Optional path/polyline to display
  /// - [zoom]: Optional zoom level (if null, auto-zooms to fit content)
  String generateStaticMapUrl({
    LatLng? center,
    String? size,
    List<MapMarker>? markers,
    MapPath? path,
    int? zoom,
  }) {
    final baseUrl = 'https://maps.googleapis.com/maps/api/staticmap';
    final params = <String>[];

    // Center (omit to let API auto-fit to markers/path)
    if (center != null) {
      params.add('center=${center.latitude},${center.longitude}');
    }

    // Size (default to 16:9 card aspect ratio)
    params.add('size=${size ?? defaultCardSize}');

    // Zoom (optional)
    if (zoom != null) {
      params.add('zoom=$zoom');
    }

    // Markers
    if (markers != null && markers.isNotEmpty) {
      for (final marker in markers) {
        params.add(marker.toUrlParameter());
      }
    }

    // Path/Polyline
    if (path != null) {
      params.add(path.toUrlParameter());
    }

    // API Key
    params.add('key=$_apiKey');

    var url = '$baseUrl?${params.join('&')}';

    // If URL exceeds the limit and we have an encoded polyline path,
    // simplify the polyline by downsampling points to fit.
    if (url.length > maxUrlLength && path?.encodedPolyline != null) {
      final otherParams = params.where((p) => !p.startsWith('path=')).toList();
      final simplified = _simplifyPathForUrl(path!, baseUrl, otherParams);
      if (simplified != null) {
        final rebuiltParams = [...otherParams, simplified.toUrlParameter()];
        url = '$baseUrl?${rebuiltParams.join('&')}';
      }
    }

    return url;
  }

  /// Simplifies an encoded polyline so the resulting URL stays under
  /// [maxUrlLength]. Decodes the polyline, samples evenly-spaced points
  /// (always keeping the first and last), then re-encodes.
  static MapPath? _simplifyPathForUrl(
    MapPath original,
    String baseUrl,
    List<String> otherParams,
  ) {
    try {
      final points = PolylineCodec.decode(original.encodedPolyline!);
      if (points.length <= 2) return null;

      // Binary search for the max number of sample points that still fits
      int lo = 2;
      int hi = points.length;
      MapPath? best;

      while (lo <= hi) {
        final mid = (lo + hi) ~/ 2;
        final sampled = _samplePoints(points, mid);
        final candidate = MapPath.encoded(
          encodedPolyline: PolylineCodec.encode(sampled),
          color: original.color ?? '0x0088ffff',
          weight: original.weight ?? 4,
        );
        final testParams = [...otherParams, candidate.toUrlParameter()];
        final testUrl = '$baseUrl?${testParams.join('&')}';

        if (testUrl.length <= maxUrlLength) {
          best = candidate;
          lo = mid + 1;
        } else {
          hi = mid - 1;
        }
      }

      return best;
    } catch (_) {
      return null;
    }
  }

  /// Sample [count] evenly-spaced points, always including first and last.
  static List<LatLng> _samplePoints(List<LatLng> points, int count) {
    if (count >= points.length) return points;
    if (count <= 2) return [points.first, points.last];

    final result = <LatLng>[points.first];
    final step = (points.length - 1) / (count - 1);
    for (int i = 1; i < count - 1; i++) {
      result.add(points[(i * step).round()]);
    }
    result.add(points.last);
    return result;
  }

  /// Generate a static map URL centered between two points showing a route
  String generateRouteMapUrl({
    required LatLng startPoint,
    required LatLng endPoint,
    String? encodedPolyline,
    String? size,
    String startLabel = 'A',
    String endLabel = 'B',
    String startColor = 'green',
    String endColor = 'red',
    String pathColor = '0x0088ffff',
    int pathWeight = 4,
  }) {
    // Create markers for start and end points only
    final markers = [
      MapMarker(position: startPoint, color: startColor, label: startLabel),
      MapMarker(position: endPoint, color: endColor, label: endLabel),
    ];

    // Create path
    MapPath? path;
    if (encodedPolyline != null && encodedPolyline.isNotEmpty) {
      path = MapPath.encoded(
        encodedPolyline: encodedPolyline,
        color: pathColor,
        weight: pathWeight,
      );
    } else {
      // Fallback to straight line
      path = MapPath.straightLine(
        points: [startPoint, endPoint],
        color: pathColor,
        weight: pathWeight - 1,
      );
    }

    // Omit center so the API auto-fits the viewport to markers + path
    return generateStaticMapUrl(
      size: size,
      markers: markers,
      path: path,
    );
  }
}

/// Represents a marker on the static map
class MapMarker {
  final LatLng position;
  final String? color;
  final String? label;
  final String? size;

  MapMarker({required this.position, this.color, this.label, this.size});

  String toUrlParameter() {
    final params = <String>[];

    if (color != null) params.add('color:$color');
    if (label != null) params.add('label:$label');
    if (size != null) params.add('size:$size');

    params.add('${position.latitude},${position.longitude}');

    return 'markers=${params.join('|')}';
  }
}

/// Represents a path/polyline on the static map
class MapPath {
  final String? color;
  final int? weight;
  final String? encodedPolyline;
  final List<LatLng>? points;

  MapPath._({this.color, this.weight, this.encodedPolyline, this.points});

  /// Create a path from an encoded polyline
  factory MapPath.encoded({
    required String encodedPolyline,
    String color = '0x0088ffff',
    int weight = 4,
  }) {
    return MapPath._(
      color: color,
      weight: weight,
      encodedPolyline: encodedPolyline,
    );
  }

  /// Create a path from a list of points
  factory MapPath.straightLine({
    required List<LatLng> points,
    String color = '0x0088ffff',
    int weight = 3,
  }) {
    return MapPath._(color: color, weight: weight, points: points);
  }

  String toUrlParameter() {
    final params = <String>[];

    if (color != null) params.add('color:$color');
    if (weight != null) params.add('weight:$weight');

    String pathParam;
    if (encodedPolyline != null) {
      // URL-encode the polyline so characters like |, \, ^, ~, @ are not
      // misinterpreted as URL delimiters or Static Maps pipe separators.
      params.add('enc:${Uri.encodeComponent(encodedPolyline!)}');
      pathParam = params.join('|');
    } else if (points != null && points!.isNotEmpty) {
      pathParam = params.join('|');
      for (final point in points!) {
        pathParam += '|${point.latitude},${point.longitude}';
      }
    } else {
      return '';
    }

    return 'path=$pathParam';
  }
}
