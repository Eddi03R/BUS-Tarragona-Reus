package com.example.reus_tarragona_bus

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Widget "Prossimo bus": mostra le prossime corse "Torna a casa" e
 * "Alla fermata abituale". I dati (orari delle prossime 72 ore) li prepara
 * l'app Flutter e li salva in SharedPreferences ("flutter.widget_data"):
 * il widget li legge e mostra solo quelli ancora futuri, anche ad app chiusa.
 */
class NextBusWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val data = readData(context)
        for (id in ids) {
            manager.updateAppWidget(id, buildViews(context, data))
        }
        scheduleNext(context, data)
    }

    companion object {
        /** Aggiorna tutti i widget presenti (chiamato dall'app quando cambiano i dati). */
        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, NextBusWidgetProvider::class.java))
            if (ids.isEmpty()) return
            val data = readData(context)
            for (id in ids) manager.updateAppWidget(id, buildViews(context, data))
            scheduleNext(context, data)
        }

        private fun readData(context: Context): JSONObject? {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val raw = prefs.getString("flutter.widget_data", null) ?: return null
            return try { JSONObject(raw) } catch (e: Exception) { null }
        }

        private fun hhmm(epoch: Long): String =
            SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(epoch))

        /** Corse ancora future di una rotta: lista di [partenza, arrivo] in millisecondi. */
        private fun upcoming(route: JSONObject, now: Long): List<LongArray> {
            val arr = route.optJSONArray("times") ?: return emptyList()
            val out = ArrayList<LongArray>()
            for (i in 0 until arr.length()) {
                val t = arr.getJSONArray(i)
                val dep = t.getLong(0)
                if (dep >= now - 30_000) out.add(longArrayOf(dep, t.getLong(1)))
            }
            return out
        }

        private fun fill(
            views: RemoteViews, route: JSONObject?, labels: JSONObject?, now: Long,
            title: Int, next: Int, inn: Int, more: Int, box: Int,
        ) {
            if (route == null) {
                views.setViewVisibility(box, View.GONE)
                return
            }
            views.setViewVisibility(box, View.VISIBLE)
            views.setTextViewText(title, route.optString("title"))
            val list = upcoming(route, now)
            if (list.isEmpty()) {
                views.setTextViewText(next, "—")
                views.setTextViewText(inn, labels?.optString("noTrips") ?: "")
                views.setTextViewText(more, "")
                return
            }
            val first = list[0]
            views.setTextViewText(next, hhmm(first[0]))
            val minutes = Math.max(0L, (first[0] - now + 59_999) / 60_000)
            val prefix = labels?.optString("inPrefix") ?: ""
            val suffix = labels?.optString("minSuffix") ?: "min"
            views.setTextViewText(inn, "$prefix $minutes $suffix  →  ${hhmm(first[1])}".trim())
            val others = list.drop(1).take(3).joinToString(" · ") { hhmm(it[0]) }
            views.setTextViewText(more, others)
        }

        private fun buildViews(context: Context, data: JSONObject?): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.next_bus_widget)
            val open = Intent(context, MainActivity::class.java)
            val pi = PendingIntent.getActivity(
                context, 1, open, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pi)

            val labels = data?.optJSONObject("labels")
            val routes = data?.optJSONArray("routes")
            val configured = data?.optBoolean("configured", false) ?: false
            if (data == null || !configured || routes == null || routes.length() < 2) {
                views.setViewVisibility(R.id.route1, View.GONE)
                views.setViewVisibility(R.id.route2, View.GONE)
                views.setViewVisibility(R.id.widget_msg, View.VISIBLE)
                views.setTextViewText(R.id.widget_msg, labels?.optString("setup") ?: "ErasBus Tarragona")
                return views
            }
            views.setViewVisibility(R.id.widget_msg, View.GONE)
            val now = System.currentTimeMillis()
            fill(views, routes.getJSONObject(0), labels, now, R.id.r1_title, R.id.r1_next, R.id.r1_in, R.id.r1_more, R.id.route1)
            fill(views, routes.getJSONObject(1), labels, now, R.id.r2_title, R.id.r2_next, R.id.r2_in, R.id.r2_more, R.id.route2)
            return views
        }

        /** Programma il prossimo aggiornamento: poco dopo la prossima partenza (max 5 minuti). */
        private fun scheduleNext(context: Context, data: JSONObject?) {
            val now = System.currentTimeMillis()
            var at = now + 5 * 60_000
            val routes = data?.optJSONArray("routes")
            if (routes != null) {
                for (i in 0 until routes.length()) {
                    val first = upcoming(routes.getJSONObject(i), now).firstOrNull() ?: continue
                    at = Math.min(at, first[0] + 30_000)
                }
            }
            at = Math.max(at, now + 60_000)
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, NextBusWidgetProvider::class.java))
            if (ids.isEmpty()) return
            val intent = Intent(context, NextBusWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            val pi = PendingIntent.getBroadcast(
                context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            val alarm = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarm.set(AlarmManager.RTC, at, pi) // non esatto: non serve permesso
        }
    }
}
