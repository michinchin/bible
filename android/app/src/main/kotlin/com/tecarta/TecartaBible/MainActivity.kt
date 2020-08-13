package com.tecarta.TecartaBible

import android.os.Bundle
import android.view.View
import android.view.WindowInsets
import android.view.WindowManager
import androidx.core.view.ViewCompat.requestApplyInsets
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    var navBarHeight = -1f;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.decorView.setOnApplyWindowInsetsListener { view, insets ->
            if (navBarHeight < 0) {
                val density = resources.displayMetrics.density
                navBarHeight = insets.systemWindowInsetBottom / density

                if (navBarHeight == 16f) {
                    window.setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
                }
            }

            insets
        };
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        if (navBarHeight < 0) {
            window.decorView.requestApplyInsets();
        }
    }
}
