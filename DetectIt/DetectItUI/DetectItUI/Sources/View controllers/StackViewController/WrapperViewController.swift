//
//  WrapperViewController.swift
//  DesignKit
//
//  Created by i.kharabet on 16/07/2019.
//  Copyright © 2019 ProjectX. All rights reserved.
//

import UIKit

final class WrapperViewController: UIViewController {

    private let wrappingView: UIView
    
    init(view: UIView) {
        wrappingView = view
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = wrappingView
    }
    
}
