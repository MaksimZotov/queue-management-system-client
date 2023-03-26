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
    private val lockTaskChannel = "lockTaskChannel"
    private lateinit var mAdminComponentName: ComponentName
    private lateinit var mDevicePolicyManager: DevicePolicyManager

    @RequiresApi(Build.VERSION_CODES.P)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            lockTaskChannel
        ).setMethodCallHandler { call, result ->
            if (call.method == "enableLockTask") {
                try {
                    manageKioskMode(true)
                } catch (e: Exception) {
                    print(e)
                }
            } else if (call.method == "disableLockTask") {
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
