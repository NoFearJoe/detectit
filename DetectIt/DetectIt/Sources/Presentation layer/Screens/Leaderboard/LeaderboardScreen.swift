//
//  LeaderboardScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 22/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItAPI
import DetectItCore

final class LeaderboardScreen: Screen {
    
    // MARK: - UI components
    
    private let closeButton = SolidButton.closeButton()
    private let titleLabel = UILabel()
    private let leaderboardView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    // MARK: - Services
    
    private let api = DetectItAPI()
    
    // MARK: - State
    
    private var leaderboard: Leaderboard?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        titleLabel.font = .heading1
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.text = "leaderboard_title".localized
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset)
        ])
        
        leaderboardView.delegate = self
        leaderboardView.dataSource = self
        leaderboardView.showsVerticalScrollIndicator = false
        leaderboardView.registerEmptyCell()
        leaderboardView.register(LeaderboardCell.self, forCellWithReuseIdentifier: LeaderboardCell.identifier)
        leaderboardView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(leaderboardView)
        
        NSLayoutConstraint.activate([
            leaderboardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            leaderboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leaderboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            leaderboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(screenLoadingView)
        screenLoadingView.pin(to: leaderboardView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func refresh() {
        super.refresh()
        
        loadLeaderboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.logScreenShow(.leaderboard)
    }
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func loadLeaderboard() {
        screenLoadingView.setVisible(true, animated: true)
        screenPlaceholderView.setVisible(false, animated: false)
        
        api.obtain(
            Leaderboard.self,
            target: .leaderboard,
            cacheKey: .init("leaderboard")
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(leaderboard):
                self.leaderboard = leaderboard
                self.leaderboardView.reloadData()
            case .failure:
                self.screenPlaceholderView.configure(
                    title: "network_error_title".localized,
                    message: "network_error_message".localized,
                    onRetry: { [unowned self] in self.loadLeaderboard() },
                    onClose: { [unowned self] in self.dismiss(animated: true, completion: nil) },
                    onReport: { [unowned self] in ReportProblemRoute(root: self).show() }
                )
                self.screenPlaceholderView.setVisible(true, animated: false)
                
                Analytics.logScreenError(screen: .leaderboard)
            }
            
            self.screenLoadingView.setVisible(false, animated: true)
        }
    }
    
}

extension LeaderboardScreen: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let leaderboard = leaderboard else { return 0 }
                
        return leaderboard.items.count + (isUserInTop() ? 0 : 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isCurrentUserNotInTop = !isUserInTop() && indexPath.item == leaderboard?.items.count ?? -1
        
        guard let item = isCurrentUserNotInTop ? leaderboard?.userItem : leaderboard?.items[indexPath.item] else {
            return collectionView.dequeueEmptyCell(for: indexPath)
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LeaderboardCell.identifier, for: indexPath) as? LeaderboardCell
        
        let position = isCurrentUserNotInTop ? (leaderboard?.userPosition ?? 0) : indexPath.item + 1
        
        cell?.configure(
            model: LeaderboardCell.Model(
                position: "\(position)",
                positionColor: positionColor(for: position),
                alias: item.alias,
                isCurrentUser: item.alias == User.shared.alias,
                correctAnswersPercent: "\(item.correctAnswersPercent.rounded(precision: 2))%",
                totalScore: "\(item.score)"
            )
        )
        
        return cell ?? collectionView.dequeueEmptyCell(for: indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width: CGFloat = {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let width = collectionView.bounds.width
                    - collectionView.contentInset.left
                    - collectionView.contentInset.right

                return width * 0.75
            } else {
                return collectionView.bounds.width
                    - collectionView.contentInset.left
                    - collectionView.contentInset.right
            }
        }()

        return CGSize(width: width, height: 48)
    }
    
}

private extension LeaderboardScreen {
    
    func isUserInTop() -> Bool {
        leaderboard?.userItem.map { item in
            leaderboard?.items.contains(where: {
                $0.alias == item.alias
            }) ?? false
        } ?? false
    }
    
    func positionColor(for position: Int) -> UIColor {
        switch position {
        case 1: return .yellow
        case 2: return .white
        case 3: return .orange
        default: return .lightGray
        }
    }
    
}
