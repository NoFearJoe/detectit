//
//  AudioRecordTask.swift
//  DetectIt
//
//  Created by Илья Харабет on 21/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

/// Задание "Аудиозапись".
public struct AudioRecordTask: Codable {
    
    /// Идентификатор объекта.
    public let id: String
    
    /// Название задания.
    public let title: String
    
    /// Название аудиофайла для проигрывания.
    public let audioFileName: String
    
    /// Словарь со списком типов преступлений, подходящих для данной аудиозаписи.
    public let crimeTypesDictionary: String
    
    /// Словарь со списком мест преступлений, подходящих для данной аудиозаписи.
    public let crimePlacesDictionary: String
    
    /// Ответ.
    public let answer: Answer
    
}

public extension AudioRecordTask {
    
    struct Answer: Codable {
        
        /// Описаний произошедшего.
        public let crimeDescription: String
        
        /// Тип преступления.
        public let crimeType: String
        
        /// Место преступления.
        public let crimePlace: String
        
        /// Количество участников.
        public let criminalsCount: Int
        
    }
    
}
