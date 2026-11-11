package com.example.reus_tarragona_bus

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // L'app avvisa il widget quando ha preparato nuovi orari.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.lumelabs.bustarragona/widget")
            .setMethodCallHandler { call, result ->
                if (call.method == "refresh") {
                    NextBusWidgetProvider.refreshAll(applicationContext)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onStop() {
        super.onStop()
        applyThemedIcon()
    }

    // Colore del tema (ThemeController, pref "app_seed_color") -> alias launcher del manifest.
    // Il tema predefinito e i colori sconosciuti usano IconDefault (icona gialla storica).
    private val iconAliases = mapOf(
        0xFF1565C0L to "IconBlue",
        0xFF3949ABL to "IconIndigo",
        0xFF7B1FA2L to "IconPurple",
        0xFFAD1457L to "IconMagenta",
        0xFFD84315L to "IconCoral",
        0xFFEF6C00L to "IconOrange",
        0xFFF9A825L to "IconAmber",
        0xFF00838FL to "IconTeal",
        0xFF00695CL to "IconPetrol",
        0xFF1F0800L to "IconHalloween",
        0xFFC62829L to "IconChristmas",
        0xFFB3261FL to "IconSantaTecla",
        0xFFC8431CL to "IconFiesta",
        0xFF008C46L to "IconItaly",
        0xFF1E2A5BL to "IconNewYearLight",
        0xFF0C1031L to "IconNewYearDark",
    )

    /// Attiva l'alias launcher del tema scelto. Si fa in onStop (app non più visibile)
    /// perché alcuni launcher chiudono l'app quando cambia l'icona.
    private fun applyThemedIcon() {
        // Le icone a tema sono adattive (API 26+): sotto resta quella predefinita.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        try {
            val seed = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .all["flutter.app_seed_color"] as? Long
            val wanted = seed?.let { iconAliases[it and 0xFFFFFFFFL] } ?: "IconDefault"
            val pkg = MainActivity::class.java.`package`!!.name
            fun set(alias: String, on: Boolean) {
                val cn = ComponentName(packageName, "$pkg.$alias")
                val cur = packageManager.getComponentEnabledSetting(cn)
                val isOn = cur == PackageManager.COMPONENT_ENABLED_STATE_ENABLED ||
                    (cur == PackageManager.COMPONENT_ENABLED_STATE_DEFAULT && alias == "IconDefault")
                if (isOn != on) {
                    packageManager.setComponentEnabledSetting(
                        cn,
                        if (on) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                        else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP,
                    )
                }
            }
            set(wanted, true)
            for (alias in iconAliases.values + "IconDefault") if (alias != wanted) set(alias, false)
        } catch (_: Exception) {
            // Best-effort: in caso di errore resta l'icona attuale.
        }
    }
}
