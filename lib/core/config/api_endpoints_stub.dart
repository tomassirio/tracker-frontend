/// Stub implementation for non-web platforms (VM, tests, etc.)
/// Returns default values since there's no browser window to read config from
String getConfigValue(String key, String defaultValue) {
  return defaultValue;
}

