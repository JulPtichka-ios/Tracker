//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Воробьева Юлия on 15.01.2026.
//

import UIKit

class OnboardingViewController: UIViewController {
    private let pageControl = UIPageControl()
    private let nextButton = UIButton(type: .system)
    private var currentPage = 0
    
    private let pages: [(image: String, title: String)] = [
        ("onboardingBlue", "Отслеживайте только то, что хотите"),
        ("onboardingRed", "Даже если это не литры воды и йога")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showPage(currentPage)
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPageIndicatorTintColor = UIColor(named: "ypBlack")
        pageControl.pageIndicatorTintColor = UIColor(named: "ypGray")
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        nextButton.setTitle("Вот это технологии!", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        nextButton.setTitleColor(.ypWhite, for: .normal)
        nextButton.backgroundColor = .ypBlack
        nextButton.layer.cornerRadius = 16
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -16),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            nextButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    private func showPage(_ index: Int) {
        view.subviews.forEach { subview in
            if subview is UIImageView || subview is UILabel {
                subview.removeFromSuperview()
            }
        }
        
        let page = pages[index]
        
        let imageView = UIImageView(image: UIImage(named: page.image))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let pageControlIndex = view.subviews.firstIndex(of: pageControl) {
            view.insertSubview(imageView, belowSubview: pageControl)
        } else {
            view.insertSubview(imageView, at: 0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = page.title
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .ypBlack
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(titleLabel, belowSubview: pageControl)

        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 70),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
        
        currentPage = index
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.pageControl.currentPage = index
        })
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left where currentPage < pages.count - 1:
            currentPage += 1
            showPage(currentPage)
        case .right where currentPage > 0:
            currentPage -= 1
            showPage(currentPage)
        default:
            return
        }
    }
    
    @objc private func nextButtonTapped() {
        if currentPage < pages.count - 1 {
            currentPage += 1
            showPage(currentPage)
        } else {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            
            let tabBarController = MainTabBarController()
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
}
