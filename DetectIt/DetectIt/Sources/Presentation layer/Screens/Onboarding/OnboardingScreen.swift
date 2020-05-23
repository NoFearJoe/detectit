//
//  OnboardingScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 13/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

final class OnboardingScreen: UIPageViewController {
    
    var onFinish: (() -> Void)?
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = .darkGray
        pageControl.currentPageIndicatorTintColor = .yellow
        
        view.subviews.forEach {
            ($0 as? UIScrollView)?.delaysContentTouches = false
        }
        
        delegate = self
        dataSource = self
        
        setViewControllers([makeScreen(for: .welcome)], direction: .forward, animated: false, completion: nil)
    }
    
}

extension OnboardingScreen: UIPageViewControllerDelegate {}

extension OnboardingScreen: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        Page.allCases.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageRawValue = viewController.view.tag
        guard let page = Page(rawValue: pageRawValue - 1) else { return nil }
        
        return makeScreen(for: page)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let pageRawValue = viewController.view.tag
        guard let page = Page(rawValue: pageRawValue + 1) else { return nil }
        
        return makeScreen(for: page)
    }
    
}

private extension OnboardingScreen {
    
    enum Page: Int, CaseIterable {
        case welcome
        case noChance
        case enterName
    }
    
    func makeScreen(for page: Page) -> UIViewController {
        let screen = OnboardingPage()
        screen.view.tag = page.rawValue
        
        switch page {
        case .welcome:
            screen.configure(
                icon: nil,
                title: "onboarding_first_page_title".localized,
                subtitle: "onboarding_first_page_subtitle".localized
            )
        case .noChance:
            screen.configure(
                icon: nil,
                title: "onboarding_second_page_title".localized,
                subtitle: "onboarding_second_page_subtitle".localized
            )
        case .enterName:
            let screen = OnboardingEnterNamePage()
            screen.configure(
                icon: nil,
                title: "onboarding_last_page_title".localized,
                subtitle: "onboarding_last_page_subtitle".localized
            )
            screen.onFinish = { [unowned self] in
                self.onFinish?()
            }
            screen.view.tag = page.rawValue
            return screen
        }
        
        return screen
    }
    
}
