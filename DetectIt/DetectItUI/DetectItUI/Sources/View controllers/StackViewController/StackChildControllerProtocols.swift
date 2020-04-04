//
//  StackChildControllerProtocols.swift
//  DesignKit
//
//  Created by i.kharabet on 16/07/2019.
//  Copyright © 2019 ProjectX. All rights reserved.
//

import UIKit

/// Describes a stack child controller with static height.
public protocol StaticHeightStackChildController: AnyObject {
    
    /// The height of the controller.
    var height: CGFloat { get }
    
}

/// Describes a stack child controller with dynamic height.
public protocol DynamicHeightStackChildController: AnyObject {
    
    /// The closure, which should be called when the height of the controller has changed.
    var onChangeHeight: ((CGFloat) -> Void)? { get set }
    
}
