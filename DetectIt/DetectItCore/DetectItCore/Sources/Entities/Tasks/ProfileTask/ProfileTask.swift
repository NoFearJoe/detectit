//
//  ProfileTask.swift
//  DetectItCore
//
//  Created by Илья Харабет on 22/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

/// Задание "Профайл".
public struct ProfileTask: Codable {
    
    /// Идентификатор задания.
    public let id: String
    
    /// Название задания.
    public let title: String
    
    /// Вводные данные.
    public let preposition: String
    
    /// Список случаев.
    public let cases: [Case]
    
    /// Список приложений.
    public let attachments: [Attachment]
    
    /// Список вопросов.
    public let questions: [Question]
    
}
