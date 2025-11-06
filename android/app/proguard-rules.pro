# === FIX: Google ML Kit Text Recognition classes stripped by R8 ===
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# === Flutter framework classes (safe keep) ===
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# === Recommended attributes ===
-keepattributes *Annotation*, Signature, InnerClasses
