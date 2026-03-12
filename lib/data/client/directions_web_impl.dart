import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// JS interop bindings for Google Maps JavaScript API DirectionsService.

@JS('google.maps.DirectionsService')
extension type _JSDirectionsService._(JSObject _) implements JSObject {
  external _JSDirectionsService();
  external JSPromise<JSAny?> route(_JSDirectionsRequest request);
}

@JS()
extension type _JSDirectionsRequest._(JSObject _) implements JSObject {
  external factory _JSDirectionsRequest({
    JSAny origin,
    JSAny destination,
    JSArray<_JSDirectionsWaypoint>? waypoints,
    JSString travelMode,
  });
}

@JS()
extension type _JSDirectionsWaypoint._(JSObject _) implements JSObject {
  external factory _JSDirectionsWaypoint({
    JSAny location,
    JSBoolean stopover,
  });
}

@JS('google.maps.LatLng')
extension type _JSLatLng._(JSObject _) implements JSObject {
  external _JSLatLng(JSNumber lat, JSNumber lng);
}

/// Web implementation that uses the Google Maps JavaScript DirectionsService.
/// This avoids CORS issues that block the Directions REST API from browsers.
Future<String?> getDirectionsPolylineWeb(
  List<LatLng> points,
  String apiKey,
) async {
  if (points.length < 2) return null;

  try {
    final origin = points.first;
    final destination = points.last;
    final intermediates =
        points.length > 2 ? points.sublist(1, points.length - 1) : <LatLng>[];

    final jsOrigin = _JSLatLng(origin.latitude.toJS, origin.longitude.toJS);
    final jsDestination =
        _JSLatLng(destination.latitude.toJS, destination.longitude.toJS);

    final jsWaypoints = intermediates
        .map(
          (wp) => _JSDirectionsWaypoint(
            location: _JSLatLng(wp.latitude.toJS, wp.longitude.toJS),
            stopover: true.toJS,
          ),
        )
        .toList()
        .toJS;

    final request = _JSDirectionsRequest(
      origin: jsOrigin,
      destination: jsDestination,
      waypoints: jsWaypoints,
      travelMode: 'WALKING'.toJS,
    );

    final service = _JSDirectionsService();
    final jsResult = await service.route(request).toDart;

    if (jsResult == null) return null;

    final result = jsResult as JSObject;
    final routesAny = result['routes'];
    if (routesAny == null || !routesAny.isA<JSArray>()) return null;
    final routes = routesAny as JSArray;
    final routesList = routes.toDart;
    if (routesList.isEmpty) return null;

    final firstRoute = routesList.first as JSObject;
    final overviewPolyline = firstRoute['overview_polyline'];
    if (overviewPolyline == null) return null;

    // The JS API overview_polyline can be a string or an object with points
    if (overviewPolyline.isA<JSString>()) {
      final str = (overviewPolyline as JSString).toDart;
      return str.isNotEmpty ? str : null;
    }

    if (overviewPolyline.isA<JSObject>()) {
      final obj = overviewPolyline as JSObject;
      final pointsProp = obj['points'];
      if (pointsProp != null && pointsProp.isA<JSString>()) {
        final str = (pointsProp as JSString).toDart;
        return str.isNotEmpty ? str : null;
      }
    }

    return null;
  } catch (e) {
    debugPrint('DirectionsWeb: Error calling JS DirectionsService: $e');
    return null;
  }
}
