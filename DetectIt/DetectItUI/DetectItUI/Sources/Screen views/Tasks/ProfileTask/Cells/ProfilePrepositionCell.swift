//
//  ProfilePrepositionCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 31/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ProfilePrepositionCell: AutosizingCollectionViewCell {
    
    public static let identifier = String(describing: ProfilePrepositionCell.self)
    
    // MARK: - Subviews
    
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
        
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public typealias Model = PaperSheetView.Model
    
    public func configure(model: Model) {
        titleLabel.text = model.title
        textLabel.attributedText = makeAttributedText(from: model.text)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        
        titleLabel.font = .heading1
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        contentView.addSubview(textLabel)
        
        textLabel.font = .text3
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func makeAttributedText(from string: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.paragraphSpacing = 4
        paragraphStyle.hyphenationFactor = 0
        
        return NSAttributedString(
            string: string,
            attributes: [
                NSAttributedString.Key.kern: 0.25,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
    }
    
}



//public final class ProfilePrepositionCell: AutosizingCollectionViewCell {
//
//    public static let identifier = String(describing: ProfilePrepositionCell.self)
//
//    // MARK: - Subviews
//
//    private let pageSheetView = PaperSheetView()
//
//    // MARK: - Init
//
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setupViews()
//    }
//
//    @available(*, unavailable)
//    public required init?(coder: NSCoder) { fatalError() }
//
//    // MARK: - Configuration
//
//    public typealias Model = PaperSheetView.Model
//
//    public func configure(model: Model) {
//        pageSheetView.configure(model: model)
//    }
//
//    // MARK: - Setup
//
//    private func setupViews() {
//        contentView.addSubview(pageSheetView)
//
//        pageSheetView.configureShadow(
//            radius: 4,
//            opacity: 0.1,
//            color: .black,
//            offset: CGSize(width: 0, height: 2)
//        )
//
//        pageSheetView.pin(to: contentView)
//    }
//
//}
