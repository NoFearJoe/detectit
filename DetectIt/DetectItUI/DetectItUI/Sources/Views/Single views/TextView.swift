//
//  TextView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 11.10.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import SwiftUI

public struct TextViewSUI: UIViewRepresentable {
    let text: NSAttributedString
    
    public init(_ text: NSAttributedString) {
        self.text = text
    }
    
    public func makeUIView(context: Context) -> TextView {
        TextView()
    }
    
    public func updateUIView(_ uiView: TextView, context: Context) {
        uiView.attributedText = text
    }
}

public final class TextView: UITextView {
    
    public init() {
        super.init(frame: .zero, textContainer: nil)
        
        font = .text3
        textColor = .white
        backgroundColor = .clear
        isEditable = false
        isScrollEnabled = false
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        dataDetectorTypes = [.link, .phoneNumber]
        showsVerticalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
