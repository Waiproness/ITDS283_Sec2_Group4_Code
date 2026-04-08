import UIKit
import Flutter
import GoogleMaps // 👉 1. เพิ่มบรรทัดนี้ด้านบน

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 👉 2. เพิ่มบรรทัดนี้ และเอากุญแจมาใส่ (อยู่เหนือคำว่า GeneratedPluginRegistrant)
    GMSServices.provideAPIKey("AIzaSyAqWiSMrXIApFmturcirgWN2iKYFM0muOE") 

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}