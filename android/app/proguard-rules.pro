# Add project specific ProGuard rules here.
# Simplified ProGuard rules to prevent APK corruption

# Basic Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep reflection and serialization safe
-keepattributes *Annotation*
-keepattributes Signature

# Keep SQLite/Database classes
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }
