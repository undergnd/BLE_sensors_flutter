
package com.example.sensors

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.charset.Charset

val sensorFill = byteArrayOf(0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x30)
var scannedbytes = ByteArray(500)
val sensors_number = 16
var pac_size = 31

private lateinit var bthAdapter: BluetoothAdapter
private var bleScanner: BluetoothLeScanner? = null



class MainActivity: FlutterActivity() {

    private val CHANNEL = "samples.flutter.dev/ble_scanning"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // This method is invoked on the main thread.
                call, result ->
            if (call.method == "get_raw_scanning_data") {
                val scanbytes = get_raw_scanning_data()
                result.success(scanbytes)
             //   println("call get_raw_scanning_data() ok")
            } else {
              //  println("problem with call get_raw_scanning_data() ")
                result.notImplemented()
            }
        }

    }


    @RequiresApi(Build.VERSION_CODES.M)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        println("we are in onCreate()")

        for (i in 0..(sensors_number*pac_size)) {
            scannedbytes[i] = 0x00
        }

        //bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        bthAdapter = BluetoothAdapter.getDefaultAdapter()

        if (bthAdapter == null) {
            Toast.makeText(this, "Bluetooth not supported", Toast.LENGTH_SHORT).show()
            finish()
        }
        val REQUEST_ENABLE_BT = 1
        if (!bthAdapter.isEnabled) {
            val enableBluetoothIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            if (ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.BLUETOOTH_SCAN
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                // TODO: Consider calling
                //    ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                //                                          int[] grantResults)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.

                return
            }
            startActivityForResult(enableBluetoothIntent, REQUEST_ENABLE_BT)
        }

        if(bthAdapter.isEnabled)
        {
            println("BLE enabled")
        }
        else
        {
            println("BLE disabled")
        }
        startBLEscan()

    }

    @RequiresApi(Build.VERSION_CODES.M)
    private fun startBLEscan(): String {

        println("we are in startBLEscan()")

        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.BLUETOOTH_SCAN
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            ActivityCompat.requestPermissions(this@MainActivity, arrayOf(Manifest.permission.BLUETOOTH_SCAN), 2)
            println("permissions granted")
            return "granted"
        }
        val ble_address_filter = "02:80:E1:88:77:00"
        val scanFilterList: MutableList<ScanFilter> = ArrayList()
        scanFilterList.add(ScanFilter.Builder()
            .setDeviceAddress(ble_address_filter)
            .build())

        val scanSettings =
            ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                .build()

        bleScanner = bthAdapter.bluetoothLeScanner;

        if(bleScanner != null) {
            bleScanner?.startScan(scanFilterList, scanSettings, scanCallback);
            println("bleScanner not null - startScan()")
        }
        else
        {
            println("bleScanner is null - startScan() failed")
        }

        return "null"
    }

    private val scanCallback: ScanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {

            super.onScanResult(callbackType, result)
            val scanRecord: ByteArray = result.scanRecord!!.bytes
            val sensorBytes: ByteArray =
                scanRecord.copyOf((scanRecord[0] + 1)) // raw bytes of advertising packets

            //println(sensorBytes.toString())

            var pac_size_temp = sensorBytes[0].toInt()
            val buffer = ByteBuffer.wrap(sensorBytes)
            buffer.order(ByteOrder.LITTLE_ENDIAN)

            var sensor_number = sensorBytes[1]
            for(g in 0..pac_size_temp) {
                scannedbytes[ (sensor_number * pac_size) + g] = sensorBytes[g]
            }
        }
    }

    private fun get_raw_scanning_data(): ByteArray {
        println("buffer: ${scannedbytes[0]} ${scannedbytes[1]} ${scannedbytes[2]} ${scannedbytes[3]} ${scannedbytes[4]} ${scannedbytes[5]}")
        return scannedbytes
     }
}






