# WorkManager (usato da AdMob): Room istanzia WorkDatabase_Impl via reflection.
-keep class androidx.work.** { *; }
-keep class * extends androidx.room.RoomDatabase
-dontwarn com.google.android.play.core.**
