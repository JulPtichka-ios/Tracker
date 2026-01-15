//
//  MainTabBarController.swift
//  Tracker
//
//  Created by Воробьева Юлия on 13.01.2026.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ MainTabBarController: viewDidLoad")
        view.backgroundColor = UIColor(named: "ypWhite")
        setupTabBar()
    }

    private func setupTabBar() {
        print("✅ MainTabBarController: setupTabBar")
        
        let trackersVC = TrackersViewController()
        trackersVC.title = "Трекеры"
        let trackersNav = UINavigationController(rootViewController: trackersVC)
        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            tag: 0
        )

        let statisticsVC = StatisticsViewController()
        statisticsVC.title = "Статистика"
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        statisticsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare"),
            tag: 1
        )

        viewControllers = [trackersNav, statisticsNav]
        
        // Стили TabBar
        tabBar.backgroundColor = UIColor(named: "ypBackground")
        tabBar.tintColor = UIColor(named: "ypBlue")
        tabBar.unselectedItemTintColor = UIColor(named: "ypGray")
        tabBar.layer.borderColor = UIColor(named: "ypGray")?.withAlphaComponent(0.3).cgColor
        tabBar.layer.borderWidth = 0.5
        tabBar.itemPositioning = .fill
    }
}
