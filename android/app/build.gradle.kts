plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.konsumtracker.konsum_tracker_pro"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // Core library desugaring aktivieren
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        named("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.konsumtracker.konsum_tracker_pro"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        
        // Enable multidex support
        multiDexEnabled = true
    }

    // App signing configuration
    signingConfigs {
        named("debug") {
            storeFile = file("debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        named("release") {
            // Reduced optimization to prevent APK corruption
            isMinifyEnabled = false  // Disabled minification
            isShrinkResources = false  // Disabled resource shrinking
            isDebuggable = false
            // Simplified proguard setup
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),  // Use basic proguard instead of optimize
                "proguard-rules.pro"
            )
        }
        named("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // MultiDex support - simplified
    implementation("androidx.multidex:multidex:2.0.1")
}
