package com.paisaji.app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.fingerprint.FingerprintManager
import android.net.Uri
import android.os.Build
import android.provider.ContactsContract
import android.provider.Settings
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.PrivateKey
import java.security.Signature
import java.security.spec.ECGenParameterSpec

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.paisaji.app/device_keystore"
    private val CONTACTS_CHANNEL = "com.paisaji.app/contacts"
    private val KEY_ALIAS = "paisaji_auth_device_key"

    private val REQUEST_CODE_PICK_CONTACT = 2002
    private var pendingContactResult: MethodChannel.Result? = null

    @Suppress("DEPRECATION")
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTACTS_CHANNEL).setMethodCallHandler { call, result ->
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
                        result.error("CONTACT_PICK_FAILED", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getAndroidId" -> {
                        val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                        result.success(androidId)
                    }
                    "getFingerprintStatus" -> {
                        val hasHardwareFeature = packageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT)
                        var isHardwareDetected = false
                        var hasEnrolledFingerprints = false

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val fingerprintManager = getSystemService(Context.FINGERPRINT_SERVICE) as? FingerprintManager
                            if (fingerprintManager != null) {
                                isHardwareDetected = fingerprintManager.isHardwareDetected
                                hasEnrolledFingerprints = fingerprintManager.hasEnrolledFingerprints()
                            }
                        }

                        val resultMap = mapOf(
                            "hasHardware" to (hasHardwareFeature || isHardwareDetected),
                            "isHardwareDetected" to isHardwareDetected,
                            "hasEnrolled" to (isHardwareDetected && hasEnrolledFingerprints)
                        )
                        result.success(resultMap)
                    }
                    "hasKey" -> {
                        val alias = call.argument<String>("alias") ?: KEY_ALIAS
                        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
                        result.success(ks.containsAlias(alias))
                    }
                    "createKeyPair" -> {
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
                            // Auto-generate key if not present
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
                            return@setMethodCallHandler
                        }

                        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
                        if (!ks.containsAlias(alias)) {
                            // Auto-generate key if not present
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
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_PICK_CONTACT) {
            val callback = pendingContactResult
            pendingContactResult = null
            if (callback == null) return

            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val contactUri: Uri = data.data!!
                val projection = arrayOf(
                    ContactsContract.CommonDataKinds.Phone.NUMBER,
                    ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME
                )
                try {
                    contentResolver.query(contactUri, projection, null, null, null)?.use { cursor ->
                        if (cursor.moveToFirst()) {
                            val numberIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                            val nameIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)

                            val number = if (numberIndex != -1) cursor.getString(numberIndex) else null
                            val name = if (nameIndex != -1) cursor.getString(nameIndex) else null

                            callback.success(mapOf(
                                "name" to name,
                                "phoneNumber" to number
                            ))
                            return
                        }
                    }
                    callback.success(null)
                } catch (e: Exception) {
                    callback.error("QUERY_FAILED", e.localizedMessage, null)
                }
            } else {
                callback.success(null)
            }
        }
    }
}
