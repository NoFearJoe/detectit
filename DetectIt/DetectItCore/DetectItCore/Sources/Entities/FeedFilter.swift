//
//  FeedFilter.swift
//  DetectItCore
//
//  Created by Илья Харабет on 24/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

public enum FeedFilter: String, CaseIterable {
    case ciphers
    case blitz
    case profiles
    case bundles
    case easy, normal, hard, nightmare
}

public extension FeedFilter {
    
    var localizedTitle: String {
        "feed_filter_\(rawValue)".localized
    }
    
}
