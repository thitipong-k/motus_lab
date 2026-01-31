package com.example.motus_lab

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/// ตัวรับข้อมูล Native Widget ฝั่ง Android
/// คลาสนี้จะถูกเรียกโดย Android System เมื่อถึงเวลา Update หรือเมื่อ Flutter สั่งการ
class MotusWidget : HomeWidgetProvider() {

    /// ทำงานเมื่อถึงรอบเวลา Update หรือเมื่อ Flutter สั่งให้ Update
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Open App on Click (สามารถเปิดคอมเมนต์ด้านล่างเพื่อทำให้คลิกแล้วเปิด App ได้)
                // val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                //     context,
                //     MainActivity::class.java
                // )
                // setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                // อ่านข้อมูลที่ส่งมาจาก Flutter โดยใช้ key เดียวกัน (status_text)
                // หากไม่มีข้อมูล ให้แสดงคำว่า "Disconnected" เป็นค่าเริ่มต้น
                val status = widgetData.getString("status_text", "Disconnected")

                // นำข้อมูลไปแสดงผลบน Layout (XML) ที่ตำแหน่ง TextView ID: widget_status
                setTextViewText(R.id.widget_status, status)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
