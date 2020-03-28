//
//  ProfileTask+Questions.swift
//  DetectItCore
//
//  Created by Илья Харабет on 25/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public extension ProfileTask {
    
    /// Вопрос.
    struct Question: Codable {
        
        /// Идентификатор вопроса.
        public let id: String
        
        /// Текст вопроса.
        public let title: String
        
        /// Количество баллов за правильный ответ.
        public let score: Int
        
        // Question details
        
        /// Вопрос на ввод числа.
        public let number: NumberQuestion?
        
        /// Вопрос на выбор из нескольких вариантов.
        public let variant: VariantsQuestion?
        
        /// Вопрос на ввод ответа из словаря.
        public let variantFromDictionary: VariantsFromDictionaryQuestion?
        
        /// Вопрос на ввод точного ответа.
        public let exactAnswer: ExactAnswerQuestion?
        
        /// Вопрос на да/нет.
        public let boolAnswer: BoolQuestion?
        
    }
    
}

public extension ProfileTask {
    
    /// Вопрос на ввод числа (количество преступников, возраст и тд).
    struct NumberQuestion: Codable {
        
        /// Ответ.
        public struct Answer: Codable {
            
            /// Пояснение ответа.
            public let description: String
            
            /// Правильный ответ.
            public let correctNumber: Int
            
        }
        
        /// Ответ.
        public let answer: Answer
        
    }
    
}

public extension ProfileTask {
    
    /// Вопрос на выбор из нескольких вариантов (до 6). Например, "Преступление совершено одним, группой или разными людьми", "Какой был мотив у преступника".
    struct VariantsQuestion: Codable {
        
        /// Вариант ответа.
        public struct Variant: Codable {
            
            /// Идентификатор варианта.
            public let id: String
            
            /// Текст варианта.
            public let text: String
            
        }
        
        /// Ответ.
        public struct Answer: Codable {
            
            /// Пояснение ответа.
            public let description: String
            
            /// Идентификатор верного варианта.
            public let correctVariantID: String
            
        }
        
        /// Варианты ответа.
        public let variants: [Variant]
        
        /// Ответ.
        public let answer: Answer
        
    }
    
}

public extension ProfileTask {
    
    /// Вопрос на ввод ответа из словаря. Например, "Назовите профессию преступника", "Назовите место преступления".
    struct VariantsFromDictionaryQuestion: Codable {
        
        /// Название словаря с вариантоами.
        /// Словарь хранится в бандле, не в директории с заданием.
        let dictionaryName: String
        
        /// Ответ.
        public let answer: String
        
    }
    
}

public extension ProfileTask {
    
    /// Вопрос на ввод точного ответа. Например, "Как зовут преступника", "Назовите город, в котором произошло преступление".
    struct ExactAnswerQuestion: Codable {
        
        /// Самый точный ответ.
        public let answer: String
        
        /// Возможные ответы. Например, если ответом может быть несколько или один ответ может быть записан по-разному.
        public let possibleAnswers: [String]
        
    }
    
}

public extension ProfileTask {
    
    /// Вопрос на да/нет. Непример, "Преуступление было запланиованным", "Преступник был пьян".
    struct BoolQuestion: Codable {
        
        /// Ответ.
        public let answer: Bool
        
    }
    
}

// MARK: - Resource accessing

public extension ProfileTask {
    
    func variantsDictionaryURL(question: VariantsFromDictionaryQuestion, bundleID: String) -> URL? {
        TasksBundleMap
            .dictionariesDirectoryURL(bundleID: bundleID)?
            .appendingPathComponent(question.dictionaryName)
    }
    
}
