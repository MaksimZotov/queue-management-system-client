package com.maksimzotov.queue_management_system_client

import android.app.admin.DeviceAdminReceiver
import android.content.ComponentName
import android.content.Context

class MyDeviceAdminReceiver : DeviceAdminReceiver() {
    companion object {
        fun getComponentName(context: Context): ComponentName {
            return ComponentName(context.applicationContext, MyDeviceAdminReceiver::class.java)
        }

        private val TAG = MyDeviceAdminReceiver::class.java.simpleName
    }
}