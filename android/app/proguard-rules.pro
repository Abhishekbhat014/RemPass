# Keep Hive generated adapters
-keep class com.dev.abhishek.rempass.models.** { *; }
-keep class * extends TypeAdapter

# Keep annotations (Hive uses them)
-keepattributes *Annotation*

# Don’t strip model classes
-keep class rem_pass.models.** { *; }
-keep class com.dev.abhishek.rempass.MainActivity { *; }

