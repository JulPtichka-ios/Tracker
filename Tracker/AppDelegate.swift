//
//  AppDelegate.swift
//  Tracker
//
//  Created by Воробьева Юлия on 13.01.2026.
//

import CoreData
import UIKit
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("🚀 APP DELEGATE WORKS!")

        _ = CoreDataManager.shared

        if let configuration = YMMYandexMetricaConfiguration(apiKey: "a923fb7e-1a82-4307-a669-8e1829bbc4f9") {
            YMMYandexMetrica.activate(with: configuration)
            print("✅ AppMetrica активирована")
        }

        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}
