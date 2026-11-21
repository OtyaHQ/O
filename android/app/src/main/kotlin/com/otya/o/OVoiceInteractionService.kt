package com.otya.o

import android.content.Intent
import android.os.Bundle
import android.service.voice.VoiceInteractionService

/**
 * Lightweight always-on Android assistant entry point.
 *
 * Keep this service deliberately small. Conversation UI, network calls and AI
 * work belong in the session/app processes, not in the always-running service.
 */
class OVoiceInteractionService : VoiceInteractionService() {
    override fun onReady() {
        super.onReady()
    }

    override fun onLaunchVoiceAssistFromKeyguard() {
        val intent = Intent(this, OLockscreenActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        startActivity(intent)
    }

    override fun onGetSupportedVoiceActions(voiceActions: Set<String>): Set<String> {
        // Extended platform actions are enabled only when O implements them
        // end-to-end. Returning an empty set prevents false capability claims.
        return emptySet()
    }

    override fun onPrepareToShowSession(args: Bundle, flags: Int) {
        super.onPrepareToShowSession(args, flags)
    }
}
