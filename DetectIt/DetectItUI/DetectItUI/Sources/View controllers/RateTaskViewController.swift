//
//  RateTaskViewController.swift
//  DetectItUI
//
//  Created by Илья Харабет on 23.08.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore
import DetectItAPI

public final class RateTaskViewController: UIViewController {
    
    private let containerView = UIStackView()
    private let ratingView = RatingView(maxRating: 5, size: .big)
    private let doneButton = SolidButton.primaryButton()
    
    private let api = DetectItAPI()
    
    private var selectedRating: Double?
    
    private var cachedRatingKey: String {
        "task_rating_\(task.kind.rawValue)_\(task.id)"
    }
    
    private let task: Task
    private let bundleID: String?
    
    public init(task: Task, bundleID: String?) {
        self.task = task
        self.bundleID = bundleID
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func loadView() {
        super.loadView()
        
        setupViews()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        UserDefaults.standard.set(nil, forKey: cachedRatingKey)
        
        selectedRating = UserDefaults.standard.value(forKey: cachedRatingKey) as? Double
        
        if let rating = selectedRating {
            ratingView.rating = rating
            ratingView.isEnabled = false
            doneButton.isHidden = true
        }
    }
    
    private func setupViews() {
        view.addSubview(containerView)
        containerView.axis = .horizontal
        containerView.alignment = .center
        containerView.spacing = 24
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        containerView.addArrangedSubview(ratingView)
        containerView.addArrangedSubview(doneButton)
        
        ratingView.backgroundColor = .lightGray
        ratingView.tintColor = .yellow
        ratingView.isEnabled = true
        ratingView.addTarget(self, action: #selector(didSelectRating), for: .valueChanged)
        
        doneButton.isEnabled = false
        doneButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        doneButton.setTitle("rate_task_widget_done_button_title".localized, for: .normal)
        doneButton.heightConstraint?.constant = 44
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
    }
    
    @objc private func didSelectRating() {
        selectedRating = ratingView.rating
        doneButton.isEnabled = true
    }
    
    @objc private func didTapDoneButton() {
        guard let rating = selectedRating else { return }
        
        UserDefaults.standard.set(rating, forKey: cachedRatingKey)
        
        let title: String = {
            switch Int(rating) {
            case 2: return "😔"
            case 3: return "😕"
            case 4: return "😃"
            case 5: return "🥰"
            default: return "😥"
            }
        }()
        
        UIView.transition(
            with: doneButton,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                self.doneButton.setTitle(title, for: .normal)
            },
            completion: nil
        )
        
        doneButton.isUserInteractionEnabled = false
        ratingView.isEnabled = false
        
        api.request(
            .setTaskRating(
                taskID: task.id,
                taskKind: task.kind.rawValue,
                bundleID: bundleID,
                rating: rating
            )
        ) { result in
            print(result)
        }
    }
    
}
