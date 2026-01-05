package ir.zar360.maaher

import android.annotation.SuppressLint
import android.app.Activity.RESULT_OK
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.device.DeviceManager
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Base64
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import com.pos.sdk.accessory.POIGeneralAPI
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import ir.dena360.pos.i9100.UrovoPrinterUtil
import ir.ikccc.externalpayment.Library
import ir.ikccc.externalpayment.Library.PURCHASE_REQUEST_CODE
import ir.ikccc.externalpayment.TransactionRequest
import ir.ikccc.externalpayment.TransactionType
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
        else if (posDeviceTypes == PosDeviceTypes.urovo_i9100) {
            try {
                // Convert base64 string to Bitmap
                val imageBytes = Base64.decode(image, Base64.DEFAULT)
                val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)

                if (bitmap != null) {
                    // Use native SDK printer
                    val success = UrovoPrinterUtil.printBitmap(bitmap)
                    if (success) {
                        Log.i(TAG, "Print successful for urovo_i9100")
                    } else {
                        Log.e(TAG, "Print failed for urovo_i9100")
                    }
                } else {
                    Log.e(TAG, "Failed to decode bitmap from base64 string for urovo_i9100")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error printing on urovo_i9100: ${e.message}")
            }
        }
        return ""
    }

    suspend fun getPosDeviceSerial(): String? {
        if (posDeviceTypes == PosDeviceTypes.toasn_p10 || posDeviceTypes == PosDeviceTypes.toasn_p3 || posDeviceTypes == PosDeviceTypes.tosan_m500) {
            return POIGeneralAPI.getDefault().getVersion(POIGeneralAPI.VERSION_TYPE_DSN)
        } else if (posDeviceTypes == PosDeviceTypes.urovo_i9100) {
            val deviceSerial = withContext(Dispatchers.IO) {
                try {
                    val mDevice = DeviceManager()
                    val SNNumber = mDevice.deviceId
                    SNNumber ?: ""
                } catch (e: Exception) {
                    Log.e(TAG, "Error getting device serial for urovo_i9100: ${e.message}")
                    ""
                }
            }
            return deviceSerial
        }

        return ""
    }


    suspend fun getPosDeviceInfo(): String? {

        val deviceManufacturer = Build.MANUFACTURER
        val deviceModel = Build.MODEL
        var deviceSerial = ""

        if (posDeviceTypes == PosDeviceTypes.toasn_p10 || posDeviceTypes == PosDeviceTypes.toasn_p3 || posDeviceTypes == PosDeviceTypes.tosan_m500) {
            deviceSerial = POIGeneralAPI.getDefault().getVersion(POIGeneralAPI.VERSION_TYPE_DSN)
        } else if (posDeviceTypes == PosDeviceTypes.urovo_i9100) {
            val serial = withContext(Dispatchers.IO) {
                try {
                    val mDevice = DeviceManager()
                    val SNNumber = mDevice.deviceId
                    SNNumber ?: ""
                } catch (e: Exception) {
                    Log.e(TAG, "Error getting device serial for urovo_i9100: ${e.message}")
                    ""
                }
            }
            deviceSerial = serial
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
        else if (deviceManufacturer.equals("UBX") && deviceModel.equals("i9100/W")) posDeviceTypes =
            PosDeviceTypes.urovo_i9100
    }






    private fun intentToPaymentApp(
        amount: String?,
        result: MethodChannel.Result
    ) {
        try {
            if (posDeviceTypes == PosDeviceTypes.urovo_i9100) {
                // Handle payment for urovo_i9100 using TransactionRequest
                tempResult = result
                val transactionRequest = TransactionRequest(this)
                transactionRequest.setRequestType(TransactionType.PURCHASE_WITH_ID.getTransactionType())
                transactionRequest.setAmount(amount ?: "0")
                transactionRequest.setPrint(true)
                transactionRequest.setShowReceipt(true)
                // Generate unique payment ID using timestamp (seconds since epoch)
                val uniquePaymentId = (System.currentTimeMillis() / 1000).toString()
                transactionRequest.setId(uniquePaymentId)

                if (transactionRequest.send()) {
                    Log.i(TAG, "Payment request sent successfully for urovo_i9100")
                } else {
                    Log.e(TAG, "Failed to send payment request for urovo_i9100")
                    result.error("ERROR", "خطا در ارسال درخواست پرداخت", null)
                    tempResult = null
                }
            }
            else{

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
            }


        } catch (e: Exception) {
            result.error("ERROR", e.message, null)
            tempResult = null // Clear the stored result
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when {
            requestCode == PURCHASE_REQUEST_CODE  -> {
                handleIranKishPaymentResult(resultCode, data)
            }
            requestCode == 1002 && tempResult != null -> {
                handlePardakhtNovinPaymentResult(resultCode, data)
            }
        }
    }

    /**
     * مدیریت نتیجه پرداخت از نرم‌افزار Iran Kish (urovo_i9100)
     */
    private fun handleIranKishPaymentResult(resultCode: Int, data: Intent?) {
        try {
            Log.i(TAG, "handleIranKishPaymentResult: resultCode=$resultCode")

            if (resultCode == 0 && data != null) {
                val paymentData = extractIranKishPaymentData(data)
                logIranKishPaymentData(paymentData)

                val resultJson = createIranKishResultJson(paymentData)
                tempResult?.success(resultJson.toString())
            } else {
                Log.i(TAG, "پرداخت لغو شد یا ناموفق بود، resultCode: $resultCode")
                val cancelledResult = createCancelledResultJson()
                tempResult?.success(cancelledResult.toString())
            }
        } catch (e: Exception) {
            Log.e(TAG, "خطا در handleIranKishPaymentResult: ${e.message}")
            tempResult?.error("PAYMENT_ERROR", e.message, null)
        } finally {
            tempResult = null
        }
    }

    /**
     * مدیریت نتیجه پرداخت از نرم‌افزار Pardakht Novin
     */
    private fun handlePardakhtNovinPaymentResult(resultCode: Int, data: Intent?) {
        try {
            Log.i(TAG, "handlePardakhtNovinPaymentResult: resultCode=$resultCode")

            if (resultCode == RESULT_OK) {
                val resultData = data?.getStringExtra("Result")
                Log.i(TAG, "داده‌های نتیجه پرداخت: $resultData")

                if (resultData != null) {
                    tempResult?.success(resultData)
                } else {
                    Log.i(TAG, "داده‌ای وجود ندارد، برگرداندن نتیجه تستی")
                    val mockResult = createMockSuccessResultJson()
                    tempResult?.success(mockResult)
                }
            } else {
                Log.i(TAG, "پرداخت لغو شد یا ناموفق بود، resultCode: $resultCode")
                val cancelledResult = createMockCancelledResultJson()
                tempResult?.success(cancelledResult)
            }
        } catch (e: Exception) {
            Log.e(TAG, "خطا در handlePardakhtNovinPaymentResult: ${e.message}")
            tempResult?.error("PAYMENT_ERROR", e.message, null)
        } finally {
            tempResult = null
        }
    }

    /**
     * استخراج داده‌های پرداخت از Intent برای Iran Kish
     */
    private fun extractIranKishPaymentData(data: Intent): Map<String, String> {
        return mapOf(
            "paymentAmount" to (data.getStringExtra("paymentAmount") ?: ""),
            "paymentId" to (data.getStringExtra("paymentId") ?: ""),
            "message" to (data.getStringExtra("message") ?: ""),
            "cardNumber" to (data.getStringExtra("cardNumber") ?: ""),
            "cardBank" to (data.getStringExtra("cardBank") ?: ""),
            "referenceCode" to (data.getStringExtra("referenceCode") ?: ""),
            "dateTime" to (data.getStringExtra("dateTime") ?: ""),
            "merchantID" to (data.getStringExtra("merchantID") ?: ""),
            "terminalID" to (data.getStringExtra("terminalID") ?: ""),
            "stan" to (data.getStringExtra("stan") ?: ""),
            "txResponseCode" to (data.getStringExtra("txResponseCode") ?: ""),
            "txResponseTitle" to (data.getStringExtra("txResponseTitle") ?: ""),
            "phoneNumber" to (data.getStringExtra("phoneNumber") ?: ""),
            "serial" to (data.getStringExtra("serial") ?: ""),
            "merchantName" to (data.getStringExtra("merchantName") ?: "")
        )
    }

    /**
     * لاگ کردن داده‌های پرداخت Iran Kish
     */
    private fun logIranKishPaymentData(paymentData: Map<String, String>) {
        Log.i(TAG, "نتیجه پرداخت برای urovo_i9100:")
        Log.i(TAG, "paymentAmount: ${paymentData["paymentAmount"]}")
        Log.i(TAG, "paymentId: ${paymentData["paymentId"]}")
        Log.i(TAG, "message: ${paymentData["message"]}")
        Log.i(TAG, "cardNumber: ${paymentData["cardNumber"]}")
        Log.i(TAG, "referenceCode: ${paymentData["referenceCode"]}")
    }

    /**
     * ایجاد JSON نتیجه پرداخت برای Iran Kish
     */
    private fun createIranKishResultJson(paymentData: Map<String, String>): JSONObject {
        val txResponseCode = paymentData["txResponseCode"] ?: ""
        val message = paymentData["message"] ?: ""
        val isSuccess = txResponseCode == "00" || message.contains("موفق", ignoreCase = true)

        return JSONObject().apply {
            put("Status", if (isSuccess) "OK" else "FAILED")
            put("RRN", paymentData["referenceCode"])
            put("CustomerCardNO", paymentData["cardNumber"])
            put("paymentAmount", paymentData["paymentAmount"])
            put("paymentId", paymentData["paymentId"])
            put("message", paymentData["message"])
            put("cardBank", paymentData["cardBank"])
            put("dateTime", paymentData["dateTime"])
            put("merchantID", paymentData["merchantID"])
            put("terminalID", paymentData["terminalID"])
            put("stan", paymentData["stan"])
            put("txResponseCode", paymentData["txResponseCode"])
            put("txResponseTitle", paymentData["txResponseTitle"])
            put("phoneNumber", paymentData["phoneNumber"])
            put("serial", paymentData["serial"])
            put("merchantName", paymentData["merchantName"])
        }
    }

    /**
     * ایجاد JSON نتیجه لغو شده برای Iran Kish
     */
    private fun createCancelledResultJson(): JSONObject {
        return JSONObject().apply {
            put("Status", "CANCELLED")
            put("RRN", "")
            put("CustomerCardNO", "")
        }
    }

    /**
     * ایجاد JSON نتیجه موفق تستی برای Pardakht Novin
     */
    private fun createMockSuccessResultJson(): String {
        return """
        {
            "Status": "OK",
            "RRN": "",
            "CustomerCardNO": ""
        }
        """.trimIndent()
    }

    /**
     * ایجاد JSON نتیجه لغو شده تستی برای Pardakht Novin
     */
    private fun createMockCancelledResultJson(): String {
        return """
        {
            "Status": "CANCELLED",
            "RRN": "",
            "CustomerCardNO": ""
        }
        """.trimIndent()
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
    unkown, toasn_p10, toasn_p3, tosan_m500, morefun_mf919, aisino_a75_pro, aisino_a99, urovo_i9100
}

//data class AppInfo(
//    val packageName: String,
//    val name: String,
//    val versionName: String,
//    val versionNumber: Int
//)


