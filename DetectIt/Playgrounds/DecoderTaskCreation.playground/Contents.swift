import UIKit
@testable import DetectItCore

let task = DecoderTask(
    id: "",
    title: "",
    preposition:
    """
    
    """
    ,
    difficulty: 1,
    score: 1,
    encodedPictureName: "encoded.jpg",
    encodedAudioName: nil,
    answer: .init(
        crimeDescription:
        """
        
        """
        ,
        decodedMessage: "",
        possibleAnswers: nil
    )
)

let encodedTask = try! JSONEncoder().encode(task)
let json = String(data: encodedTask, encoding: .utf8)!

print(json)


/*
let task = DecoderTask(
    id: "",
    title: "",
    preposition:
    """
    
    """
    ,
    difficulty: 1,
    score: 1,
    encodedPictureName: "encoded.jpg",
    encodedAudioName: nil,
    answer: .init(
        crimeDescription:
        """
        
        """
        ,
        decodedMessage: "",
        possibleAnswers: nil
    )
)
*/
