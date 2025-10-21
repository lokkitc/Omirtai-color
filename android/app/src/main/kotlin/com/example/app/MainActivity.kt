package com.example.app

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.webkit.WebView

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Enable WebView debugging for release builds
        WebView.setWebContentsDebuggingEnabled(true)
    }
}