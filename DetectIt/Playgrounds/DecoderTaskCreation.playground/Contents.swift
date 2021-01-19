import Foundation
@testable import DetectItCore

let task = DecoderTask(
    id: "44c_c2",
    title: "Последняя жертва",
    preposition:
    """
    В момент задержания убийцы по прозвищу "44й калибр", один из полицейских обнаружил в рюкзаке обвиняемого странную записку. Изначально никто не предал ей значение, но только спустя несколько недель, один из следователей понял, что же скрывала в себе эта улика. Оказывается, в ней была зашифрована информация о важной дате.

    Ваша задача – расшифровать записку и указать искомую дату.

    Ответ запишите в формате: 25.06.1970
    """
    ,
    difficulty: 1,
    score: 1,
    encodedPictureName: "encoded.jpg",
    encodedAudioName: nil,
    answer: .init(
        crimeDescription:
        """
        Для разгадки шифра Вам требовалось всего лишь внимательно рассмотреть написанные "символы". Шифровка была зеркальной, требовалось закрыть левую часть символа и получить искомый ответ: 31.07.1977 (07.31.1997).
        Именно 31 июля 1977 года настоящий убийца "44й калибр" совершил свое последнее преступление, и в этот же день он был арестован.
        """
        ,
        decodedMessage: "31.07.1977",
        possibleAnswers: ["31.7.1977", "07.31.1977", "7.31.1977", "31 июля 1977", "июль 31 1977", "июль 31, 1977"]
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
