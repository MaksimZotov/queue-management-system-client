package com.maksimzotov.queue_management_system_client

import android.app.admin.DevicePolicyManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    companion object {
        const val LOCK_TASK_CHANNEL = "lockTaskChannel"
        const val ENABLE_LOCK_TASK = "enableLockTask"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LOCK_TASK_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == ENABLE_LOCK_TASK) {
                try {
                    result.success(enableKioskMode())
                } catch (e: Exception) {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun enableKioskMode(): Boolean {
        val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val adminComponentName = MyDeviceAdminReceiver.getComponentName(this)
        devicePolicyManager.setLockTaskPackages(adminComponentName, arrayOf(packageName))
        if (!devicePolicyManager.isLockTaskPermitted(packageName)) {
            return false
        }
        startLockTask()
        return true
    }
}
