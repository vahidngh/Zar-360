package ir.zar360.maaher

import android.annotation.SuppressLint
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import com.pos.sdk.accessory.POIGeneralAPI
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import ir.zar360.maaher.pos.p10.TosanPrinter
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject

class MainActivity : FlutterActivity() {

    private val channelName = "my_channel"
    private val paymentChannelName = "ir.zar360.maaher/intent"
    private val urlLauncherChannelName = "com.asnaf.app/url_launcher"
    private lateinit var channel: MethodChannel
    private lateinit var paymentChannel: MethodChannel
    private lateinit var urlLauncherChannel: MethodChannel
    var tempResult: MethodChannel.Result? = null
    var posDeviceTypes: PosDeviceTypes = PosDeviceTypes.unkown

    var intentData: String? = null
    var deeplinkData: String? = null

    private val TAG = "MainActivityy"

    @SuppressLint("LongLogTag")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setPosDeviceTypes()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the main channel
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "intentToPaymentApp" -> try {
                    val amount = call.argument<String>("amount")
                    intentToPaymentApp(amount, result)
                } catch (exception: ActivityNotFoundException) {
                    result.error("ERROR", exception.message, null)
                }

                "print" -> try {
                    val image = call.argument<String>("image")
                    result.success(printImage(image!!))
                } catch (exception: ActivityNotFoundException) {
                    result.error("ERROR", exception.message, null)
                }

                "getDeviceSerial" -> try {
                    val coroutineScope = CoroutineScope(Dispatchers.Main)
                    coroutineScope.launch {
                        val deviceSerial = getPosDeviceSerial()
                        if (deviceSerial != null) {
                            result.success(deviceSerial)
                        } else {
                            result.error("ERROR", "Device info retrieval failed", null)
                        }
                    }
                } catch (exception: ActivityNotFoundException) {
                    result.error("ERROR", exception.message, null)
                }

                "getDeviceInfo" -> try {
                    val coroutineScope = CoroutineScope(Dispatchers.Main)
                    coroutineScope.launch {
                        val deviceInfo = getPosDeviceInfo()
                        if (deviceInfo != null) {
                            result.success(deviceInfo)
                        } else {
                            result.error("ERROR", "Device info retrieval failed", null)
                        }
                    }
                } catch (exception: ActivityNotFoundException) {
                    result.error("ERROR", exception.message, null)
                }

                else -> result.notImplemented()
            }
        }

        // Set up the payment channel
        paymentChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, paymentChannelName)
        paymentChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "intentToPaymentApp" -> {
                    val amount = call.argument<String>("amount")
                    try {
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            data = Uri.parse("myketpayment://pay/?amount=$amount")
                            `package` = "ir.mservices.market"
                        }
                        startActivity(intent)
                        result.success("Payment intent launched successfully")
                    } catch (e: Exception) {
                        result.error("PAYMENT_ERROR", "Failed to launch payment app", e.message)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Set up the URL launcher channel
        urlLauncherChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, urlLauncherChannelName)
        urlLauncherChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    try {
                        if (url != null) {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                            startActivity(intent)
                            result.success("URL opened successfully")
                        } else {
                            result.error("URL_ERROR", "URL is null", null)
                        }
                    } catch (e: Exception) {
                        result.error("URL_ERROR", "Failed to open URL", e.message)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun printImage(image: String): Any {

        if (posDeviceTypes == PosDeviceTypes.toasn_p10 || posDeviceTypes == PosDeviceTypes.toasn_p3 || posDeviceTypes == PosDeviceTypes.tosan_m500) {
            TosanPrinter.print(this, image)
//            P3Printer.printerTest(this)
        }
        return ""
    }

    suspend fun getPosDeviceSerial(): String? {
        if (posDeviceTypes == PosDeviceTypes.toasn_p10 || posDeviceTypes == PosDeviceTypes.toasn_p3 || posDeviceTypes == PosDeviceTypes.tosan_m500) {
            return POIGeneralAPI.getDefault().getVersion(POIGeneralAPI.VERSION_TYPE_DSN)
        }
        return ""
    }


    suspend fun getPosDeviceInfo(): String? {

        val deviceManufacturer = Build.MANUFACTURER
        val deviceModel = Build.MODEL
        var deviceSerial = ""

        if (posDeviceTypes == PosDeviceTypes.toasn_p10 || posDeviceTypes == PosDeviceTypes.toasn_p3 || posDeviceTypes == PosDeviceTypes.tosan_m500) {
            deviceSerial = POIGeneralAPI.getDefault().getVersion(POIGeneralAPI.VERSION_TYPE_DSN)
        }

        var deviceInfoMap: MutableMap<String, String> = mutableMapOf(
            "serial" to deviceSerial,
            "brand" to deviceManufacturer,
            "model" to deviceModel
        )

        val jsonString = mapToJsonString(deviceInfoMap)
        Log.i(TAG, "getPosDeviceInfo: jsonString" + jsonString)
        return jsonString
    }

    fun mapToJsonString(map: Map<String, String>): String {
        val jsonString = StringBuilder("{")
        var isFirst = true
        for ((key, value) in map) {
            if (!isFirst) jsonString.append(",")
            isFirst = false
            jsonString.append("\"$key\":\"$value\"")
        }
        jsonString.append("}")
        return jsonString.toString()
    }


    fun setPosDeviceTypes() {
        val deviceManufacturer = Build.MANUFACTURER
        val deviceModel = Build.MODEL

//        Log.i(TAG, "POIGeneralAPI: deviceManufacturer: " + deviceManufacturer)
//        Log.i(TAG, "POIGeneralAPI: deviceModel: " + deviceModel)

        if (deviceManufacturer.equals("Kozen") && deviceModel.equals("P10")) posDeviceTypes =
            PosDeviceTypes.toasn_p10
        else if (deviceManufacturer.equals("Kozen") && deviceModel.equals("P3")) posDeviceTypes =
            PosDeviceTypes.toasn_p3
        else if (deviceManufacturer.equals("TOSAN TECHNO") && deviceModel.equals("M500")) posDeviceTypes =
            PosDeviceTypes.tosan_m500
        else if (deviceManufacturer.equals("Morefun") && deviceModel.equals("MF919")) posDeviceTypes =
            PosDeviceTypes.morefun_mf919
        else if (deviceManufacturer.equals("Vanstone") && deviceModel.equals("A75 Pro")) posDeviceTypes =
            PosDeviceTypes.aisino_a75_pro
        else if (deviceManufacturer.equals("Vanstone") && deviceModel.equals("A99")) posDeviceTypes =
            PosDeviceTypes.aisino_a99
    }






    private fun intentToPaymentApp(
        amount: String?,
        result: MethodChannel.Result
    ) {
        try {
            val jsonObject = JSONObject().apply {
                put("AndroidPosMessageHeader", "@@PNA@@")
                put("ECRType", "1")
                put("Amount", amount)
                put("TransactionType", "00")
                put("OriginalAmount", amount)
            }

            tempResult = result  // Store the result for later use
            val intent = Intent("ir.co.pna.pos.view.cart.IAPCActivity").apply {
                putExtra("Data", jsonObject.toString())
            }

            startActivityForResult(intent, 1002)
        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
            tempResult = null // Clear the stored result
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == 1002 && tempResult != null) {
            try {
                val resultData = data?.getStringExtra("Result")
                if (resultData != null) {
                    // Send the complete result back to Flutter
                    tempResult?.success(resultData)
                } else {
//                    tempResult?.error("PAYMENT_ERROR", "No result data received", null)
                    tempResult?.error("PAYMENT_ERROR", "نتیجه ای دریافت نشد!", null)
                }
            } catch (e: Exception) {
                tempResult?.error("PAYMENT_ERROR", e.message, null)
            } finally {
                tempResult = null // Always clear the stored result
            }
        }
    }

    fun restartApp() {
        val intent = Intent(this, MainActivity::class.java)

        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        startActivity(intent)
        finish()
    }







//    data class AppInfo(
//        @SerializedName("package_name") val packageName: String,
//        @SerializedName("name") val name: String,
//        @SerializedName("version_name") val versionName: String,
//        @SerializedName("version_number") val versionNumber: Int
//    )

//    data class AppListWrapper(
//        @SerializedName("myApps") val myApps: List<AppInfo>
//    )

//    fun getInstalledApps(context: Context): String {
//        val packageManager: PackageManager = context.packageManager
//        val appsList = mutableListOf<AppInfo>()
//
//        val packages: List<PackageInfo> =
//            packageManager.getInstalledPackages(PackageManager.GET_META_DATA)
//
//        for (packageInfo in packages) {
//            val appName = packageManager.getApplicationLabel(packageInfo.applicationInfo).toString()
//            val packageName = packageInfo.packageName
//            val versionName = packageInfo.versionName ?: "N/A"
//            val versionNumber = packageInfo.versionCode
//
//            val appInfo = AppInfo(
//                packageName = packageName,
//                name = appName,
//                versionName = versionName,
//                versionNumber = versionNumber
//            )
//
//            appsList.add(appInfo)
//        }
//
//        val appListWrapper = AppListWrapper(appsList)
//        return Gson().toJson(appListWrapper)
//
//
//}


}

enum class PosDeviceTypes {
    unkown, toasn_p10, toasn_p3, tosan_m500, morefun_mf919, aisino_a75_pro, aisino_a99
}

//data class AppInfo(
//    val packageName: String,
//    val name: String,
//    val versionName: String,
//    val versionNumber: Int
//)


