//
//  NSObjectWrapper.swift
//  DetectItCore
//
//  Created by Илья Харабет on 21/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public final class NSObjectWrapper<T>: NSObject {
    
    public let object: T
    
    public init(_ object: T) {
        self.object = object
    }
    
}
