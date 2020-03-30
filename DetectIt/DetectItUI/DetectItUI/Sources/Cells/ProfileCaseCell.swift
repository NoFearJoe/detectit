//
//  ProfileCaseCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 29/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

/// Ячейка, отображающая случай из "Профайла".
public final class ProfileCaseCell: AutosizingCollectionViewCell {
    
    public static let identifier = String(describing: ProfileCaseCell.self)
    
    // MARK: - Actions
    
    public var onTapEvidence: (() -> Void)?
    
    @objc private func onTapEvidenceView() {
        onTapEvidence?()
    }
    
    // MARK: - Subviews
    
    private let caseView = PaperSheetView()
    private let evidenceView = PhotoCardView()
    
    private var evidenceViewUnderlayConstraint: NSLayoutConstraint!
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public struct Model {
        public let `case`: PaperSheetView.Model
        public let evidence: PhotoCardView.Model?
    }
    
    public func configure(model: Model) {
        caseView.configure(model: model.case)
        
        if let evidence = model.evidence {
            evidenceView.configure(model: evidence)
            
            evidenceViewUnderlayConstraint.constant = 52
        } else {
            evidenceViewUnderlayConstraint.constant = 0
        }
    }
    
    // MARK: - Overrides
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        evidenceViewUnderlayConstraint.constant = 0
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(caseView)
        
        caseView.configureShadow(
            radius: 4,
            opacity: 0.1,
            color: .black,
            offset: CGSize(width: 0, height: 2)
        )
        
        NSLayoutConstraint.activate([
            caseView.topAnchor.constraint(equalTo: contentView.topAnchor),
            caseView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            caseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        contentView.addSubview(evidenceView)
        contentView.sendSubviewToBack(evidenceView)
        
        evidenceView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onTapEvidenceView))
        )
        
        evidenceViewUnderlayConstraint = evidenceView.bottomAnchor.constraint(equalTo: caseView.bottomAnchor)
        
        NSLayoutConstraint.activate([
            evidenceViewUnderlayConstraint,
            evidenceView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            evidenceView.trailingAnchor.constraint(equalTo: caseView.trailingAnchor, constant: -12)
        ])
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            evidenceView.widthAnchor.constraint(equalToConstant: 256).isActive = true
        } else {
            evidenceView.widthAnchor.constraint(equalTo: caseView.widthAnchor, multiplier: 0.75).isActive = true
        }
    }
    
}
