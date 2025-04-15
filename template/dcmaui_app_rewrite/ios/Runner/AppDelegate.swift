import UIKit
import Flutter
import yoga

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "main engine")
    
   
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DivergeToDCMAUI()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
