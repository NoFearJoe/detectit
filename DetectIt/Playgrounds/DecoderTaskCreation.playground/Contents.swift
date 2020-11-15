import UIKit
@testable import DetectItCore

let task = DecoderTask(
    id: "",
    title: "",
    preposition:
    """
    
    """
    ,
    difficulty: 2,
    score: 2,
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
let obj = try! JSONSerialization.jsonObject(with: encodedTask, options: .allowFragments)
let data = try! JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
let json = String(data: data, encoding: .utf8)!

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
