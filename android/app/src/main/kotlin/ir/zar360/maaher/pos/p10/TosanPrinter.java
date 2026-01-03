package ir.zar360.maaher.pos.p10;


import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.util.Base64;
import android.util.Log;

import com.pos.sdk.printer.POIPrinterManager;
import com.pos.sdk.printer.models.BitmapPrintLine;
import com.pos.sdk.printer.models.PrintLine;
import com.pos.sdk.printer.models.TextPrintLine;

import org.jetbrains.annotations.NotNull;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class TosanPrinter {
    private static final String TAG = "TosanPrinter";

//    public static void printerTest(Context context) {
//        final POIPrinterManager printerManager = new POIPrinterManager(context);
//        printerManager.open();
//        int state = printerManager.getPrinterState();
//        Log.d(TAG, "printer state = " + state);
//        //printerManager.setPrintFont("/system/fonts/Android-1.ttf");
//        printerManager.setPrintGray(5);
//        printerManager.setLineSpace(5);
//        //printerManager.cleanCache();
//        String str1 = "This is an example of a receipt";
//        PrintLine p1 = new TextPrintLine(str1, PrintLine.CENTER);
//        printerManager.addPrintLine(p1);
//        Bitmap bitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.shopping_mall);
//        printerManager.addPrintLine(new BitmapPrintLine(bitmap, PrintLine.CENTER));
//        printerManager.setPrintFont("/system/fonts/ComingSoon.ttf");
//        String str2 = "Floor ** , Building **, No.*** LONG DONG Avenue, Pudong New District, Shanghai, China";
//        PrintLine p2 = new TextPrintLine(str2, PrintLine.LEFT, 20);
//        printerManager.addPrintLine(p2);
//        printerManager.setPrintFont("/system/fonts/DroidSansMono.ttf");
//        List<TextPrintLine> list1 = printList("24 June 2025", "     Assistant 6", "815002", 18, false);
//        printerManager.addPrintLine(list1);
//        List<TextPrintLine> list2 = printList("Item", "Quantity", "Price", 24, true);
//        printerManager.addPrintLine(list2);
//        List<TextPrintLine> list3 = printList("Tomato", "1", "$2.08", 24, false);
//        printerManager.addPrintLine(list3);
//        List<TextPrintLine> list4 = printList("Orange", "1", "$1.06", 24, false);
//        printerManager.addPrintLine(list4);
//        PrintLine p3 = new TextPrintLine("Total  $3.14", PrintLine.RIGHT);
//        printerManager.addPrintLine(p3);
//        printerManager.addPrintLine(new TextPrintLine(""));
//        // drawable/barcode.jpg  100*100
//        bitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.barcode);
//        printerManager.addPrintLine(new BitmapPrintLine(bitmap, PrintLine.CENTER));
//        printerManager.addPrintLine(new TextPrintLine(""));
//        String str3 = "Did you know you could have earned Rewards points on this purchase?";
//        PrintLine p4 = new TextPrintLine(str3, PrintLine.CENTER);
//        printerManager.addPrintLine(p4);
//        PrintLine p5 = new TextPrintLine("Simply sign up today for a Membership Card!", PrintLine.CENTER);
//        printerManager.addPrintLine(p5);
//        bitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.barcode_12345);
//        printerManager.addPrintLine(new BitmapPrintLine(bitmap, PrintLine.CENTER));
//        printerManager.addPrintLine(new TextPrintLine(" ", 0, 100));
//        POIPrinterManager.IPrinterListener listener = new POIPrinterManager.IPrinterListener() {
//            @Override
//            public void onStart() {}
//
//            @Override
//            public void onFinish() {
//                //printerManager.cleanCache();
//                printerManager.close();
//            }
//
//            @Override
//            public void onError(int code, String msg) {
//                Log.e("POIPrinterManager", "code: " + code + "msg: " + msg);
//                printerManager.close();
//            }
//        };
//        if(state == 4){
//            printerManager.close();
//            return;
//        }
//        printerManager.beginPrint(listener);
//    }
    public static void print(Context context,@NotNull String image) {
        final POIPrinterManager printerManager = new POIPrinterManager(context);
        printerManager.open();

        Bitmap bar = Bitmap.createBitmap(800 /*任意 بزرگ*/, 24, Bitmap.Config.ARGB_8888);
        bar.eraseColor(Color.BLACK);
        printerManager.addPrintLine(new BitmapPrintLine(bar, PrintLine.LEFT));

        int state = printerManager.getPrinterState();
        Log.d(TAG, "printer state = " + state);
        //printerManager.setPrintFont("/system/fonts/Android-1.ttf");



//        int paperWidthPx = 384;
        int paperWidthPx = 800;
        Bitmap raw = base64ToBitmap(image);
        Bitmap full = fitToPaper(raw, paperWidthPx);
//        printerManager.addPrintLine(new BitmapPrintLine(full, PrintLine.CENTER));
        printerManager.addPrintLine(
                new BitmapPrintLine(full, PrintLine.LEFT)   // LEFT = no centering
        );
        printerManager.addPrintLine(new TextPrintLine(" ", 0, 100));
        POIPrinterManager.IPrinterListener listener = new POIPrinterManager.IPrinterListener() {
            @Override
            public void onStart() {}

            @Override
            public void onFinish() {
                //printerManager.cleanCache();
                printerManager.close();
            }

            @Override
            public void onError(int code, String msg) {
                Log.e("POIPrinterManager", "code: " + code + "msg: " + msg);
                printerManager.close();
            }
        };
        if(state == 4){
            printerManager.close();
            return;
        }
        printerManager.beginPrint(listener);
    }

    private static List<TextPrintLine> printList(String leftStr, String centerStr, String rightStr, int size, boolean bold){
        TextPrintLine textPrintLine1 = new TextPrintLine(leftStr, PrintLine.LEFT, size, bold);
        TextPrintLine textPrintLine2 = new TextPrintLine(centerStr,PrintLine.CENTER, size, bold);
        TextPrintLine textPrintLine3 = new TextPrintLine(rightStr, PrintLine.RIGHT, size, bold);
        List<TextPrintLine> list = new ArrayList<>();
        list.add(textPrintLine1);
        list.add(textPrintLine2);
        list.add(textPrintLine3);
        return list;
    }

    public static Bitmap base64ToBitmap(String base64String) {
        // Remove the data:image/png;base64, prefix if present
        if (base64String.startsWith("data:image")) {
            base64String = base64String.substring(base64String.indexOf(',') + 1);
        }

        byte[] decodedBytes = Base64.decode(base64String, Base64.DEFAULT);
        InputStream inputStream = new ByteArrayInputStream(decodedBytes);

        return BitmapFactory.decodeStream(inputStream);
    }

    static public Bitmap fitToPaper(Bitmap src, int paperPx) {
        if (src.getWidth() == paperPx) return src;

        int newHeight = (int) ((float) src.getHeight() * paperPx / src.getWidth());
        return Bitmap.createScaledBitmap(src, paperPx, newHeight, true);
    }
}
