package com.paisaji.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.google.android.gms.auth.api.phone.SmsRetriever
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.common.api.Status
import java.util.regex.Pattern

class SmsBroadcastReceiver : BroadcastReceiver() {

    companion object {
        var listener: SmsListener? = null
    }

    interface SmsListener {
        fun onOtpReceived(otp: String)
        fun onConsentIntent(intent: Intent)
        fun onTimeout()
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent == null) return

        if (SmsRetriever.SMS_RETRIEVED_ACTION == intent.action) {
            val extras: Bundle? = intent.extras
            val status = extras?.get(SmsRetriever.EXTRA_STATUS) as? Status

            when (status?.statusCode) {
                CommonStatusCodes.SUCCESS -> {
                    val message = extras.getString(SmsRetriever.EXTRA_SMS_MESSAGE)
                    if (!message.isNullOrEmpty()) {
                        val pattern = Pattern.compile("\\b(\\d{6})\\b")
                        val matcher = pattern.matcher(message)
                        if (matcher.find()) {
                            val otp = matcher.group(1)
                            if (otp != null) {
                                listener?.onOtpReceived(otp)
                                return
                            }
                        }
                    }

                    val consentIntent = extras.getParcelable<Intent>(SmsRetriever.EXTRA_CONSENT_INTENT)
                    if (consentIntent != null) {
                        listener?.onConsentIntent(consentIntent)
                    }
                }
                CommonStatusCodes.TIMEOUT -> {
                    listener?.onTimeout()
                }
            }
        }
    }
}
