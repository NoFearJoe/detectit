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

public extension ProfileTask {
    
    /// Случай. Случаем может быть описание событий за какой-то промежуток времени.
    struct Case: Codable {
        
        /// Идентификатор случая.
        public let id: String
        
        /// Заголовок.
        public let title: String
        
        /// Текст случая.
        public let text: String
        
        /// Картинка для случая (опционально).
        public let pictureName: String?
        
    }
    
}

public extension ProfileTask {
    
    /// Приложение к делу.
    /// Например, фотография карты с местами преступлений или аудиозапись интервью со свидетелем.
    struct Attachment: Codable {
        
        /// Идентификатор приложения.
        public let id: String
        
        /// Название изображения.
        public let pictureName: String?
        
        /// Название аудиофайла.
        public let audioFileName: String?
        
    }
    
}

public extension ProfileTask {
    
    /// Вопрос.
    struct Question: Codable {
        
        /// Идентификатор вопроса.
        public let id: String
        
        /// Текст вопроса.
        public let title: String
        
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
    
    /// Вопрос на ввод ответа из словаря. Например, "Назовите профессию преступника", "Назовите место преступления".
    struct VariantsFromDictionaryQuestion: Codable {
        
        /// Название словаря с вариантоами.
        public let dictionaryName: String
        
        /// Ответ.
        public let answer: String
        
    }
    
    /// Вопрос на ввод точного ответа. Например, "Как зовут преступника", "Назовите город, в котором произошло преступление".
    struct ExactAnswerQuestion: Codable {
        
        /// Самый точный ответ.
        public let answer: String
        
        /// Возможные ответы. Например, если ответом может быть несколько или один ответ может быть записан по-разному.
        public let possibleAnswers: [String]
        
    }
    
    /// Вопрос на да/нет. Непример, "Преуступление было запланиованным", "Преступник был пьян".
    struct BoolQuestion: Codable {
        
        /// Ответ.
        public let answer: Bool
        
    }
    
}
