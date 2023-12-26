
// AppDelegate.swift
import UIKit
import FacebookCore
import flutter_local_notifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

            FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
                GeneratedPluginRegistrant.register(with: registry)
            }

            if #available(iOS 10.0, *) {
              UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
            }

            GeneratedPluginRegistrant.register(with: self)


        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
