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
        public let correctNumber: Int
        
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
        
        /// Варианты ответа.
        public let variants: [Variant]
        
        /// Ответ.
        public let correctVariantID: String
        
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
        
        static var yes: BoolQuestion {
            .init(answer: true)
        }
        
        static var no: BoolQuestion {
            .init(answer: false)
        }
        
    }
    
}

// MARK: - Check answer

public extension ProfileTask.Question {
    
    func compare(with answer: TaskAnswer.ProfileAnswer) -> Bool {
        if let numberQuestion = number, case .int(let number) = answer {
            return numberQuestion.correctNumber == number
        } else if let variantsQuestion = variant, case .string(let variantID) = answer {
            return variantsQuestion.correctVariantID == variantID
        } else if let exactAnswerQuestion = exactAnswer, case .string(let answer) = answer {
            return ExactAnswerValidator(
                correctAnswers: [exactAnswerQuestion.answer] + exactAnswerQuestion.possibleAnswers
            ).validate(answer: answer)
        } else if let boolAnswerQuestion = boolAnswer, case .bool(let answer) = answer {
            return boolAnswerQuestion.answer == answer
        } else {
            return false
        }
    }
    
}
