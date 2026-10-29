package com.paisaji.app

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.hardware.fingerprint.FingerprintManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.ContactsContract
import android.provider.Settings
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.annotation.NonNull
import androidx.biometric.BiometricManager
import com.google.android.gms.auth.api.phone.SmsRetriever
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.common.api.Status
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.charset.StandardCharsets
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.MessageDigest
import java.security.PrivateKey
import java.security.Signature
import java.security.spec.ECGenParameterSpec
import java.util.Arrays
import java.util.regex.Pattern

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL_PAISAJI = "com.paisaji.app/device_keystore"
    private val CHANNEL_LEGACY = "com.zeokash.zeokash/device_keystore"
    private val CONTACTS_CHANNEL = "com.paisaji.app/contacts"
    private val SMS_RETRIEVER_CHANNEL = "com.paisaji.app/sms_retriever"
    private val KEY_ALIAS = "paisaji_auth_device_key"

    private val REQUEST_CODE_PICK_CONTACT = 2002
    private val SMS_CONSENT_REQUEST = 2003
    private var pendingContactResult: MethodChannel.Result? = null

    // Channel for Flutter communication
    private var smsMethodChannel: MethodChannel? = null
    private var smsReceiver: BroadcastReceiver? = null
    private var isListeningSms = false

    @Suppress("DEPRECATION")
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        smsMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_RETRIEVER_CHANNEL)

        // 1. SMS Retriever & User Consent Method Channel Handler
        smsMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppSignature" -> {
                    try {
                        val signatures = getAppSignatures()
                        result.success(signatures)
                    } catch (e: Exception) {
                        result.error("APP_SIGNATURE_ERROR", e.localizedMessage, null)
                    }
                }
                "startListening" -> {
                    try {
                        val senderNumber = call.argument<String>("senderNumber")
                        startSmsRetrieverAndConsent(senderNumber)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("START_LISTENING_FAILED", e.localizedMessage, null)
                    }
                }
                "stopListening" -> {
                    stopSmsListening()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 2. Contacts Method Channel Handler
        val contactsHandler = MethodChannel.MethodCallHandler { call, result ->
            when (call.method) {
                "pickContact" -> {
                    if (pendingContactResult != null) {
                        try {
                            pendingContactResult?.error("CANCELLED", "Subsequent pick initiated", null)
                        } catch (_: Exception) {}
                        pendingContactResult = null
                    }
                    try {
                        pendingContactResult = result
                        val intent = Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI)
                        startActivityForResult(intent, REQUEST_CODE_PICK_CONTACT)
                    } catch (e: Exception) {
                        pendingContactResult = null
                        result.error("PICKER_ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTACTS_CHANNEL).setMethodCallHandler(contactsHandler)

        // 3. Keystore & Device Security Method Channel Handler
        val keystoreHandler = MethodChannel.MethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "isHardwareKeystoreSupported" -> {
                        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
                        result.success(ks != null)
                    }
                    "isBiometricAvailable" -> {
                        val biometricManager = BiometricManager.from(applicationContext)
                        val canAuth = biometricManager.canAuthenticate(
                            BiometricManager.Authenticators.BIOMETRIC_STRONG or BiometricManager.Authenticators.BIOMETRIC_WEAK
                        )
                        result.success(canAuth == BiometricManager.BIOMETRIC_SUCCESS)
                    }
                    "isFingerprintAvailable" -> {
                        val biometricManager = BiometricManager.from(applicationContext)
                        val canAuth = biometricManager.canAuthenticate(
                            BiometricManager.Authenticators.BIOMETRIC_STRONG or BiometricManager.Authenticators.BIOMETRIC_WEAK
                        )
                        var hasHardware = canAuth == BiometricManager.BIOMETRIC_SUCCESS
                        if (!hasHardware && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val fingerprintManager = getSystemService(Context.FINGERPRINT_SERVICE) as? FingerprintManager
                            if (fingerprintManager != null && fingerprintManager.isHardwareDetected && fingerprintManager.hasEnrolledFingerprints()) {
                                hasHardware = true
                            }
                        }
                        result.success(hasHardware)
                    }
                    "openSecuritySettings" -> {
                        try {
                            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                Intent(Settings.ACTION_BIOMETRIC_ENROLL).apply {
                                    putExtra(
                                        Settings.EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED,
                                        BiometricManager.Authenticators.BIOMETRIC_STRONG or BiometricManager.Authenticators.BIOMETRIC_WEAK
                                    )
                                }
                            } else {
                                Intent(Settings.ACTION_SECURITY_SETTINGS)
                            }
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            try {
                                val fallbackIntent = Intent(Settings.ACTION_SECURITY_SETTINGS).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(fallbackIntent)
                                result.success(true)
                            } catch (e2: Exception) {
                                result.error("SETTINGS_ERROR", e2.localizedMessage, null)
                            }
                        }
                    }
                    "createDeviceKeyPair" -> {
                        val alias = call.argument<String>("alias") ?: KEY_ALIAS
                        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
                        if (ks.containsAlias(alias)) {
                            ks.deleteEntry(alias)
                        }

                        val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
                        val builder = KeyGenParameterSpec.Builder(
                            alias,
                            KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
                        )
                            .setDigests(KeyProperties.DIGEST_SHA256)
                            .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))

                        kpg.initialize(builder.build())
                        val kp = kpg.generateKeyPair()
                        val b64PublicKey = Base64.encodeToString(kp.public.encoded, Base64.NO_WRAP)
                        result.success(b64PublicKey)
                    }
                    "getPublicKey" -> {
                        val alias = call.argument<String>("alias") ?: KEY_ALIAS
                        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
                        if (!ks.containsAlias(alias)) {
                            val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
                            val builder = KeyGenParameterSpec.Builder(
                                alias,
                                KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
                            )
                                .setDigests(KeyProperties.DIGEST_SHA256)
                                .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))

                            kpg.initialize(builder.build())
                            val kp = kpg.generateKeyPair()
                            val b64PublicKey = Base64.encodeToString(kp.public.encoded, Base64.NO_WRAP)
                            result.success(b64PublicKey)
                        } else {
                            val cert = ks.getCertificate(alias)
                            val b64PublicKey = Base64.encodeToString(cert.publicKey.encoded, Base64.NO_WRAP)
                            result.success(b64PublicKey)
                        }
                    }
                    "signChallenge" -> {
                        val alias = call.argument<String>("alias") ?: KEY_ALIAS
                        val nonce = call.argument<String>("nonce")
                        if (nonce == null) {
                            result.error("INVALID_ARGUMENT", "Nonce is required", null)
                            return@MethodCallHandler
                        }

                        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
                        if (!ks.containsAlias(alias)) {
                            val kpg = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
                            val builder = KeyGenParameterSpec.Builder(
                                alias,
                                KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
                            )
                                .setDigests(KeyProperties.DIGEST_SHA256)
                                .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))

                            kpg.initialize(builder.build())
                            kpg.generateKeyPair()
                            ks.load(null)
                        }

                        val privateKey = ks.getKey(alias, null) as PrivateKey
                        val s = Signature.getInstance("SHA256withECDSA").apply {
                            initSign(privateKey)
                            update(nonce.toByteArray(Charsets.UTF_8))
                        }
                        val signatureBytes = s.sign()
                        val b64Sig = Base64.encodeToString(signatureBytes, Base64.NO_WRAP)
                        result.success(b64Sig)
                    }
                    "deleteKey" -> {
                        val alias = call.argument<String>("alias") ?: KEY_ALIAS
                        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
                        if (ks.containsAlias(alias)) {
                            ks.deleteEntry(alias)
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("KEYSTORE_ERROR", e.localizedMessage, e.message)
            }
        }

        // Register keystore handler on BOTH channels for full compatibility
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_PAISAJI).setMethodCallHandler(keystoreHandler)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_LEGACY).setMethodCallHandler(keystoreHandler)
    }

    /**
     * Starts official Google SMS Retriever client and registers broadcast receiver
     * with SMS User Consent API fallback.
     */
    private fun startSmsRetrieverAndConsent(senderNumber: String?) {
        stopSmsListening()

        // 1. Start SMS Retriever Client (Automatic, zero user interaction if hash matches)
        val retrieverClient = SmsRetriever.getClient(this)
        retrieverClient.startSmsRetriever()
            .addOnSuccessListener {
                // SMS Retriever started
            }
            .addOnFailureListener {
                // Fallback can still trigger
            }

        // 2. Start SMS User Consent Client (For standard/DLT SMS without hash)
        retrieverClient.startSmsUserConsent(senderNumber)
            .addOnSuccessListener {
                // User Consent listener active
            }
            .addOnFailureListener {
                // Handled gracefully
            }

        // 3. Register Receiver for SMS Retriever & Consent Broadcasts
        smsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent == null) return
                val action = intent.action

                if (SmsRetriever.SMS_RETRIEVED_ACTION == action) {
                    val extras: Bundle? = intent.extras
                    val status = extras?.get(SmsRetriever.EXTRA_STATUS) as? Status
                    when (status?.statusCode) {
                        CommonStatusCodes.SUCCESS -> {
                            // First try: Direct SMS message content (SMS Retriever API)
                            val message = extras.getString(SmsRetriever.EXTRA_SMS_MESSAGE)
                            if (!message.isNullOrEmpty()) {
                                extractAndDispatchOtp(message)
                            } else {
                                // Second try: User Consent Intent (Requires user click in system dialog)
                                val consentIntent = extras.getParcelable<Intent>(SmsRetriever.EXTRA_CONSENT_INTENT)
                                if (consentIntent != null) {
                                    try {
                                        startActivityForResult(consentIntent, SMS_CONSENT_REQUEST)
                                    } catch (_: Exception) {}
                                }
                            }
                        }
                        CommonStatusCodes.TIMEOUT -> {
                            smsMethodChannel?.invokeMethod("onTimeout", null)
                        }
                    }
                }
            }
        }

        val intentFilter = IntentFilter(SmsRetriever.SMS_RETRIEVED_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(smsReceiver, intentFilter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(smsReceiver, intentFilter)
        }
        isListeningSms = true
    }

    private fun extractAndDispatchOtp(message: String) {
        val pattern = Pattern.compile("\b(\d{6})\b")
        val matcher = pattern.matcher(message)
        if (matcher.find()) {
            val otp = matcher.group(1)
            runOnUiThread {
                smsMethodChannel?.invokeMethod("onOtpReceived", otp)
            }
        }
    }

    private fun stopSmsListening() {
        if (isListeningSms && smsReceiver != null) {
            try {
                unregisterReceiver(smsReceiver)
            } catch (_: Exception) {}
            smsReceiver = null
            isListeningSms = false
        }
    }

    override fun onDestroy() {
        stopSmsListening()
        super.onDestroy()
    }

    /**
     * Computes the official 11-character hash signatures required by SMS Retriever API
     * for all signing certificates of this app package.
     */
    private fun getAppSignatures(): List<String> {
        val appCodes = ArrayList<String>()
        try {
            val packageName = packageName
            val packageManager = packageManager
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
                packageInfo.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                val packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
                @Suppress("DEPRECATION")
                packageInfo.signatures
            }

            if (signatures != null) {
                for (sig in signatures) {
                    val hash = hash(packageName, sig.toCharsString())
                    if (hash != null) {
                        appCodes.add(hash)
                    }
                }
            }
        } catch (_: Exception) {}
        return appCodes
    }

    private fun hash(packageName: String, signature: String): String? {
        val appInfo = "$packageName $signature"
        try {
            val messageDigest = MessageDigest.getInstance("SHA-256")
            messageDigest.update(appInfo.toByteArray(StandardCharsets.UTF_8))
            var hashSignature = messageDigest.digest()
            hashSignature = Arrays.copyOfRange(hashSignature, 0, 9)
            var base64Hash = Base64.encodeToString(hashSignature, Base64.NO_PADDING or Base64.NO_WRAP)
            base64Hash = base64Hash.substring(0, 11)
            return base64Hash
        } catch (_: Exception) {
            return null
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        // 1. Handle SMS User Consent Dialog Result
        if (requestCode == SMS_CONSENT_REQUEST) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val message = data.getStringExtra(SmsRetriever.EXTRA_SMS_MESSAGE)
                if (!message.isNullOrEmpty()) {
                    extractAndDispatchOtp(message)
                }
            } else {
                // User denied or dismissed consent dialog: quietly proceed without throwing error
                smsMethodChannel?.invokeMethod("onConsentDenied", null)
            }
            return
        }

        // 2. Handle Contact Picker Result
        if (requestCode == REQUEST_CODE_PICK_CONTACT) {
            val callback = pendingContactResult
            pendingContactResult = null
            if (callback == null) return

            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val contactUri: Uri = data.data!!
                try {
                    var number: String? = null
                    var name: String? = null

                    val projection = arrayOf(
                        ContactsContract.CommonDataKinds.Phone.NUMBER,
                        ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME
                    )
                    try {
                        contentResolver.query(contactUri, projection, null, null, null)?.use { cursor ->
                            if (cursor.moveToFirst()) {
                                val numberIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                                val nameIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
                                if (numberIndex != -1) number = cursor.getString(numberIndex)
                                if (nameIndex != -1) name = cursor.getString(nameIndex)
                            }
                        }
                    } catch (_: Exception) {}

                    if (number == null) {
                        val contactId = contactUri.lastPathSegment
                        if (contactId != null) {
                            try {
                                contentResolver.query(
                                    ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                                    projection,
                                    "${ContactsContract.CommonDataKinds.Phone.CONTACT_ID} = ?",
                                    arrayOf(contactId),
                                    null
                                )?.use { cursor ->
                                    if (cursor.moveToFirst()) {
                                        val numberIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                                        val nameIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
                                        if (numberIndex != -1) number = cursor.getString(numberIndex)
                                        if (nameIndex != -1) name = cursor.getString(nameIndex)
                                    }
                                }
                            } catch (_: Exception) {}
                        }
                    }

                    callback.success(mapOf(
                        "name" to name,
                        "phoneNumber" to number
                    ))
                } catch (e: Exception) {
                    callback.error("QUERY_FAILED", e.localizedMessage, null)
                }
            } else {
                callback.success(null)
            }
        }
    }
}
