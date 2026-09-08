package com.appylab.synctasks

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

/**
 * Transparent overlay activity launched by the home screen widget "+" button.
 * Renders Flutter's /quick-add route on a translucent window so the task
 * sheet floats over the home screen.
 */
class QuickAddActivity : FlutterActivity() {

    override fun getInitialRoute(): String = "/quick-add"

    override fun onCreate(savedInstanceState: Bundle?) {
        intent.putExtra("background_mode", "transparent")
        super.onCreate(savedInstanceState)
    }
}

