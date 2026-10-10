package com.devjj.platform.nurbanhoney

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // 네이티브 스플래시(Theme.SplashScreen). Flutter 첫 프레임이 그려지면 사라진다.
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }
}
