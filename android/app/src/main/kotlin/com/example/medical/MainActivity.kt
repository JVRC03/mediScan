package com.example.medical

import android.util.Log
import android.widget.Toast
import com.google.android.gms.common.moduleinstall.ModuleInstall
import com.google.android.gms.common.moduleinstall.ModuleInstallClient
import com.google.android.gms.common.moduleinstall.ModuleInstallRequest
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.codescanner.GmsBarcodeScanner
import com.google.mlkit.vision.codescanner.GmsBarcodeScannerOptions
import com.google.mlkit.vision.codescanner.GmsBarcodeScanning
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private lateinit var methodChannelResult: MethodChannel.Result

    private val options = GmsBarcodeScannerOptions.Builder()
        .setBarcodeFormats(Barcode.FORMAT_ALL_FORMATS)
        .build()

    private lateinit var moduleInstallClient: ModuleInstallClient
    private lateinit var scanner: GmsBarcodeScanner

    // List of valid IDs and corresponding summaries
    private val reportMap = mapOf(
        "1" to "The report shows slightly elevated liver enzyme levels (ALT & AST), indicating potential liver inflammation or damage",
        "2" to "The blood report indicates mostly normal values, with slightly low haemoglobin, red blood cell indices, and eosinophil percentage.",
        "3" to "Charlie",
        "4" to "The ECG is within normal limits and shows a sinus rhythm, but clinical correlation is advised",
        "5" to "Bob",
        "6" to "The report shows a Prostate-Specific Antigen (PSA) level of 0.87 ng/mL, which is below the reference range of <4.0 ng/mL",
        "7" to "Alice",
        "8" to "Elevated TT3 and TT4 with suppressed TSH indicate hyperthyroidism for Mr. V. Suresh."
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "scanPlatform"
        ).setMethodCallHandler { call, result ->
            methodChannelResult = result
            when (call.method) {
                "scan" -> {
                    scanner = GmsBarcodeScanning.getClient(this, options)
                    moduleInstallClient = ModuleInstall.getClient(this)
                    checkIfApiAvailable()
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkIfApiAvailable() {
        moduleInstallClient
            .areModulesAvailable(scanner)
            .addOnSuccessListener {
                if (it.areModulesAvailable()) {
                    startScan()
                } else {
                    installModule()
                }
            }
            .addOnFailureListener {
                installModule()
            }
    }

    private fun installModule() {
        val moduleInstallRequest = ModuleInstallRequest.newBuilder()
            .addApi(scanner)
            .build()

        moduleInstallClient.installModules(moduleInstallRequest)
            .addOnSuccessListener {
                if (it.areModulesAlreadyInstalled()) {
                    startScan()
                } else {
                    Log.i("ModuleInstall", "Downloading required modules...")
                }
            }
            .addOnFailureListener { e ->
                Log.e("ModuleInstallError", e.message.toString())
                moduleInstallClient.deferredInstall(scanner)
            }
    }

    private fun startScan() {
        scanner.startScan()
            .addOnSuccessListener { barcode ->
                val rawValue: String? = barcode.rawValue
                Log.i("ScanResult", rawValue.toString())

                if (rawValue != null && reportMap.containsKey(rawValue)) {
                    // ✅ Valid QR code
                    val reportText = reportMap[rawValue]!!
                    Toast.makeText(this, "Processing...", Toast.LENGTH_SHORT).show()
                    methodChannelResult.success(reportText)
                } else {
                    // ❌ Invalid QR code
                    Toast.makeText(this, "Please scan the proper report QR code.", Toast.LENGTH_SHORT).show()
                    methodChannelResult.error(
                        "invalid_qr",
                        "Please scan the proper report QR code.",
                        "Invalid QR code"
                    )
                }
            }
            .addOnCanceledListener {
                Log.i("ScanCancelled", "User cancelled scan")
                methodChannelResult.error("cancelled", "cancelled", "cancelled")
            }
            .addOnFailureListener { e ->
                Log.e("ScanFailure", e.message.toString())
                methodChannelResult.error(e.message.toString(), e.message.toString(), e.message.toString())
            }
    }
}
