plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.tomassirio.wanderer.tracker_frontend"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tomassirio.wanderer.tracker_frontend"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // API endpoint configuration from environment variables
        // These can be overridden at build time with: flutter build apk --dart-define=COMMAND_BASE_URL=...
        // The app uses defaults in api_endpoints_android.dart if not provided
        buildConfigField("String", "COMMAND_BASE_URL", "\"${System.getenv("COMMAND_BASE_URL") ?: ""}\"")
        buildConfigField("String", "QUERY_BASE_URL", "\"${System.getenv("QUERY_BASE_URL") ?: ""}\"")
        buildConfigField("String", "AUTH_BASE_URL", "\"${System.getenv("AUTH_BASE_URL") ?: ""}\"")

        // Google Maps API Key from environment
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = System.getenv("GOOGLE_MAPS_API_KEY") ?: "YOUR_GOOGLE_MAPS_API_KEY_HERE"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
