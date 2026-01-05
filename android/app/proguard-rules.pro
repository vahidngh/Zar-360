# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep all classes from native SDK libraries
-keep class android.device.** { *; }
-keep class com.pos.sdk.** { *; }
-keep class ir.dena360.pos.i9100.** { *; }
-keep class ir.zar360.maaher.** { *; }

# Keep printer utility classes
-keep class ir.dena360.pos.i9100.UrovoPrinterUtil { *; }
-keep class ir.zar360.maaher.pos.p10.TosanPrinter { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep classes that use native methods
-keepclasseswithmembers class * {
    native <methods>;
}

# Don't obfuscate native library classes
-dontobfuscate
-dontwarn android.device.**
-dontwarn com.pos.sdk.**

# Keep all methods in printer manager classes
-keepclassmembers class android.device.PrinterManager {
    *;
}

-keepclassmembers class com.pos.sdk.printer.POIPrinterManager {
    *;
}

# Keep all interfaces
-keep interface com.pos.sdk.printer.POIPrinterManager$IPrinterListener {
    *;
}

