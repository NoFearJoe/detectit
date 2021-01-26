//
//  UserEntity.swift
//  DetectItAPI
//
//  Created by Илья Харабет on 28/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public struct UserEntity: Codable {
    public let id: Int?
    public let alias: String
    public let email: String
}
