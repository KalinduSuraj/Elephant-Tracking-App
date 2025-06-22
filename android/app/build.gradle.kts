plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Must come after android/kotlin
}

android {
    namespace = "com.example.elephant_tracking_app"

    // ✅ Set compileSdk manually (not from flutter object)
    compileSdk = 35

    // ✅ Explicitly set the correct NDK version (required by Firebase & geolocator)
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.elephant_tracking_app"

        // ✅ Set minimum and target SDKs manually (not from flutter object)
        minSdk = 23
        targetSdk = 34

        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
