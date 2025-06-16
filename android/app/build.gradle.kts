plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.nongki_yuk"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    ndkVersion = "28.1.13356709"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    compileSdk = 35

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.nongki_yuk"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = 35
//        minSdk = flutter.minSdkVersion
//        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Enable R8 full mode
        proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // Enable R8
            isMinifyEnabled = true
            isShrinkResources = true
            
            // Enable split APKs
            splits {
                abi {
                    isEnable = true
                    reset()
                    include("armeabi-v7a", "arm64-v8a", "x86_64")
                    isUniversalApk = true
                }
            }
        }
        
        debug {
            // Disable R8 for debug builds
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // Enable build cache
    buildFeatures {
        buildConfig = true
    }

    // Enable parallel execution
    dexOptions {
        javaMaxHeapSize = "4g"
        preDexLibraries = true
        maxProcessCount = 8
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add performance monitoring
    implementation("com.google.firebase:firebase-perf-ktx:20.5.2")
//    implementation("me.carda.awesome:notifications:0.8.0")
}
