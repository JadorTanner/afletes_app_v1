import UIKit
import Flutter
//import GoogleMaps
import Firebase
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //GMSServices.provideAPIKey("AIzaSyABWbV1Hy-mBKOhuhaIzzgBP32mloFhhBs")
    //GeneratedPluginRegistrant.register(with: self)

    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)

    GMSServices.provideAPIKey("AIzaSyABWbV1Hy-mBKOhuhaIzzgBP32mloFhhBs")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
