//
//  TasksOnboardingScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 16.09.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class TasksOnboardingScreen: UIPageViewController {
    
    var onFinish: (() -> Void)?
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
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
        
        setViewControllers([makeScreen(for: .ciphers)], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.logScreenShow(.tasksOnboarding)
    }
    
}

extension TasksOnboardingScreen: UIPageViewControllerDelegate {}

extension TasksOnboardingScreen: UIPageViewControllerDataSource {
    
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

private extension TasksOnboardingScreen {
    
    enum Page: Int, CaseIterable {
        case ciphers
        case profiles
        case blitz
        case quests
    }
    
    func makeScreen(for page: Page) -> UIViewController {
        let taskKind: TaskKind = {
            switch page {
            case .ciphers:
                return .cipher
            case .profiles:
                return .profile
            case .blitz:
                return .blitz
            case .quests:
                return .quest
            }
        }()
        
        let screen = HelpScreen(taskKind: taskKind)
        screen.view.tag = page.rawValue
        
        return screen
    }
    
}
