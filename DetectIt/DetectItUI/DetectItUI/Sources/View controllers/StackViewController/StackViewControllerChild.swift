//
//  StackViewControllerChild.swift
//  DesignKit
//
//  Created by i.kharabet on 16/07/2019.
//  Copyright © 2019 ProjectX. All rights reserved.
//

import UIKit

/// Describes a child controller of the StackViewController.
public protocol StackViewControllerChild {
    
    /// Returns UIViewController's instance.
    var asViewController: UIViewController { get }
    
}

extension UIViewController: StackViewControllerChild {
    
    public var asViewController: UIViewController {
        return self
    }
    
}

extension UIView: StackViewControllerChild {
    
    public var asViewController: UIViewController {
        if let wrapper = next as? UIViewController {
            return wrapper
        }
        return WrapperViewController(view: self)
    }
    
}
