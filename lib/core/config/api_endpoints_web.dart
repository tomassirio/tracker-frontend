import 'dart:js_interop';

/// Web-specific implementation using JavaScript interop
/// Reads configuration from window.appConfig injected by Docker

@JS('window.appConfig')
external JSAny? get _appConfig;

String getConfigValue(String key, String defaultValue) {
  try {
    final config = _appConfig;
    if (config != null && config.isA<JSObject>()) {
      final jsObj = config as JSObject;
      final value = jsObj[key.toJS];
      if (value != null && value.isA<JSString>()) {
        final strValue = (value as JSString).toDart;
        if (strValue.isNotEmpty) {
          return strValue;
        }
      }
    }
  } catch (e) {
    // Fall back to default if any error occurs
  }
  return defaultValue;
}

@JS()
extension _JSObjectExtension on JSObject {
  external JSAny? operator [](JSString key);
}
