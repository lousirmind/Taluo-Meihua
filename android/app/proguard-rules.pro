# Flutter specific
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep model classes
-keep class com.lingxitianji.tarot_meihua.** { *; }
-dontwarn com.lingxitianji.tarot_meihua.**
