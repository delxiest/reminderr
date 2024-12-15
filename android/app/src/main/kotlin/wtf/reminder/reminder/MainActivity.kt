package wtf.reminder.reminder

import Remind
import RemindHostApi
import android.content.Context
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

/*class HostApi : RemindHostApi {
    override fun getReminds() : List<Remind?> {

        val now = System.currentTimeMillis()

        return listOf(
            Remind(0, "name1", "body1", now + 10000L),
            Remind(1, "name2", "body2", now + 30000L),
            Remind(2, "name3", "body3", now + 40000L)
        )
    }

}*/

class Plugin : FlutterPlugin, RemindHostApi {
    lateinit var context : Context

    override fun getReminds() : List<Remind?> {

        val now = System.currentTimeMillis()

        return listOf(
            Remind(0, "name1", "body1", now + 10000L),
            Remind(1, "name2", "body2", now + 30000L),
            Remind(2, "name3", "body3", now + 40000L)
        )
    }

    override fun getLocalStorage() = context.filesDir.absolutePath;

    override fun onAttachedToEngine(
        binding : FlutterPlugin.FlutterPluginBinding
    ) {
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(
        binding : FlutterPlugin.FlutterPluginBinding
    ) { }

}

class MainActivity : FlutterActivity() {
//    private val CHANNEL = "reminder"

    override fun configureFlutterEngine(
        flutterEngine : FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)


//        val notifiesPlugin = FlutterLocalNotificationsPlugin()
        val plugin = Plugin();

        RemindHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, plugin)

        flutterEngine.plugins.add(plugin);
//        flutterEngine.plugins.add(notifiesPlugin);

//        notifiesPlugin.onMethodCall("requestExactAlarmsPermission", )


//        flutterEngine.plugins.bin

//        RemindHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, HostApi())

        /*MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

        }*/
    }
}
