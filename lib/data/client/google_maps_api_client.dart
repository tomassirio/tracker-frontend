import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Client for Google Maps Static API
/// Handles generation of static map image URLs
class GoogleMapsApiClient {
  final String _apiKey;

  GoogleMapsApiClient(this._apiKey);

  /// Generate a static map image URL
  ///
  /// Parameters:
  /// - [center]: Center point of the map
  /// - [size]: Image size in format "widthxheight" (e.g., "600x450")
  /// - [markers]: List of markers to display
  /// - [path]: Optional path/polyline to display
  /// - [zoom]: Optional zoom level (if null, auto-zooms to fit content)
  String generateStaticMapUrl({
    required LatLng center,
    String size = '600x450',
    List<MapMarker>? markers,
    MapPath? path,
    int? zoom,
  }) {
    final baseUrl = 'https://maps.googleapis.com/maps/api/staticmap';
    final params = <String>[];

    // Center
    params.add('center=${center.latitude},${center.longitude}');

    // Size
    params.add('size=$size');

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

    return '$baseUrl?${params.join('&')}';
  }

  /// Generate a static map URL centered between two points showing a route
  String generateRouteMapUrl({
    required LatLng startPoint,
    required LatLng endPoint,
    String? encodedPolyline,
    String size = '600x450',
    String startLabel = 'A',
    String endLabel = 'B',
    String startColor = 'green',
    String endColor = 'red',
    String pathColor = '0x0088ffff',
    int pathWeight = 4,
  }) {
    // Calculate center point
    final centerLat = (startPoint.latitude + endPoint.latitude) / 2;
    final centerLng = (startPoint.longitude + endPoint.longitude) / 2;
    final center = LatLng(centerLat, centerLng);

    // Create markers
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

    return generateStaticMapUrl(
      center: center,
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
      params.add('enc:$encodedPolyline');
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
