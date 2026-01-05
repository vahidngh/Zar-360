package ir.dena360.pos.i9100

import android.device.PrinterManager
import android.graphics.Bitmap
import android.util.Log

/**
 * Utility class for printing on Urovo i9100 devices using the native SDK
 * Uses android.device.PrinterManager from urovi_i9100_platform_sdk
 */
object UrovoPrinterUtil {
    private const val TAG = "UrovoPrinterUtil"
    
    // Printer status constants
    private const val PRNSTS_OK = 0 // OK
    private const val PRNSTS_OUT_OF_PAPER = -1 // Out of paper
    private const val PRNSTS_OVER_HEAT = -2 // Over heat
    private const val PRNSTS_UNDER_VOLTAGE = -3 // Under voltage
    private const val PRNSTS_BUSY = -4 // Device is busy
    private const val PRNSTS_ERR = -256 // Common error
    private const val PRNSTS_ERR_DRIVER = -257 // Printer Driver error
    
    // Default paper width (384 pixels for 58mm paper)
    private const val DEFAULT_PAPER_WIDTH = 384
    
    /**
     * Print a bitmap image
     * @param bitmap The bitmap to print
     * @return true if print was successful, false otherwise
     */
    fun printBitmap(bitmap: Bitmap?): Boolean {
        if (bitmap == null) {
            Log.e(TAG, "Bitmap is null, cannot print")
            return false
        }
        
        var printerManager: PrinterManager? = null
        try {
            // Initialize printer manager
            printerManager = PrinterManager()
            printerManager.open()
            
            // Check printer status
            val status = printerManager.status
            Log.i(TAG, "Printer status: $status")
            
            if (status != PRNSTS_OK) {
                Log.e(TAG, "Printer is not ready. Status: $status")
                when (status) {
                    PRNSTS_OUT_OF_PAPER -> Log.e(TAG, "Printer is out of paper")
                    PRNSTS_OVER_HEAT -> Log.e(TAG, "Printer is over heated")
                    PRNSTS_UNDER_VOLTAGE -> Log.e(TAG, "Printer has under voltage")
                    PRNSTS_BUSY -> Log.e(TAG, "Printer is busy")
                    PRNSTS_ERR -> Log.e(TAG, "Printer has common error")
                    PRNSTS_ERR_DRIVER -> Log.e(TAG, "Printer driver error")
                }
                return false
            }
            
            // Setup page size (width, height: -1 means auto height)
            printerManager.setupPage(DEFAULT_PAPER_WIDTH, -1)
            
            // Draw bitmap at position (x=30, y=0)
            printerManager.drawBitmap(bitmap, 30, 0)
            
            // Execute printing
            val printResult = printerManager.printPage(0)
            
            if (printResult == PRNSTS_OK) {
                // Paper feed after printing
                printerManager.paperFeed(16)
                Log.i(TAG, "Print successful")
                return true
            } else {
                Log.e(TAG, "Print failed with status: $printResult")
                return false
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error during printing: ${e.message}", e)
            return false
        } finally {
            // Close printer manager
            try {
                printerManager?.close()
            } catch (e: Exception) {
                Log.e(TAG, "Error closing printer: ${e.message}")
            }
        }
    }
}

