import UIKit
import Flutter
import AVFoundation


@UIApplicationMain


@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    do {
        if #available(iOS 10.0, *){
            try AVAudioSession.sharedInstance().setActive(true)
        }
    } catch {
        print(error)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
