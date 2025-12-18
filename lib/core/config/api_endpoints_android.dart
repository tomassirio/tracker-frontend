/// Android-specific implementation for API endpoint configuration
/// Reads configuration from environment variables injected via BuildConfig
/// or uses sensible defaults for Android development

String getConfigValue(String key, String defaultValue) {
  // For Android, we use environment-specific defaults
  // Android emulator uses 10.0.2.2 to access host machine's localhost
  // In production, these would be configured via BuildConfig
  
  // Map of default values for Android development
  final androidDefaults = {
    'commandBaseUrl': 'http://10.0.2.2:8081/api/1',
    'queryBaseUrl': 'http://10.0.2.2:8082/api/1',
    'authBaseUrl': 'http://10.0.2.2:8083/api/1',
    'googleMapsApiKey': '', // Should be provided via environment
  };
  
  // Check if we have an Android-specific default
  if (androidDefaults.containsKey(key)) {
    return androidDefaults[key]!;
  }
  
  // Otherwise use the provided default
  return defaultValue;
}
