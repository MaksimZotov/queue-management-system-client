package com.maksimzotov.queue_management_system_client

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val kioskModeChannel = "kioskModeLocked"
    private lateinit var mAdminComponentName: ComponentName
    private lateinit var mDevicePolicyManager: DevicePolicyManager

    @RequiresApi(Build.VERSION_CODES.P)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            kioskModeChannel
        ).setMethodCallHandler { call, result ->
            if (call.method == "startKioskMode") {
                try {
                    manageKioskMode(true)
                } catch (e: Exception) {
                    print(e)
                }
            } else if (call.method == "stopKioskMode") {
                try {
                    manageKioskMode(false)
                } catch (e: Exception) {}
            } else {
                result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.P)
    private fun manageKioskMode(enable: Boolean) {
        mDevicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        mAdminComponentName = MyDeviceAdminReceiver.getComponentName(this)
        mDevicePolicyManager.setLockTaskPackages(mAdminComponentName, arrayOf(packageName))
        if (enable) {
            this.startLockTask()
        } else {
            this.stopLockTask()
            mDevicePolicyManager.clearDeviceOwnerApp(packageName)
        }
    }
}
