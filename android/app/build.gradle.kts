plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.konsumtracker.konsum_tracker_pro"
    compileSdk = 35  // AKTUALISIERT auf SDK 35
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

    buildTypes {
        named("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"), // Use optimized proguard
                "proguard-rules.pro"
            )
            // Enable R8 full mode for better optimization
            proguardFile("proguard-rules.pro")
        }
        named("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // MultiDex support
    implementation("androidx.multidex:multidex:2.0.1")
}
