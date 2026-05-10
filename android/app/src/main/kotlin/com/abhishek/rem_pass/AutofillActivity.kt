package com.dev.abhishek.rempass

import io.flutter.embedding.android.FlutterActivity

class AutofillActivity : FlutterActivity() {
    override fun getDartEntrypointFunctionName(): String {
        return "autofillEntryPoint"
    }
}
