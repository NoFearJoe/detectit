import Foundation
@testable import DetectItCore

let task = DecoderTask(
    id: "c32",
    title: "Одевайся теплее",
    preposition:
    """
    В отделение полиции был доставлен 50-летний мужчина, который подозревается в сотрудничестве с преступной группировкой.
    По данным полиции, мужчина должен направиться на встречу с остальными участниками группы, где будет происходить передача незаконного товара.

    При обыске вещей подозреваемого был найден ноутбук, на рабочем столе которого был обнаружен странный файл под именем "Одевайся теплее!11"
    Сотрудники полиции внимательно изучили улику и смогли предположить город, в который направлялся преступник.

    **Ваша задача** – расшифровать сообщение и указать ##город##, где планируется встреча.
    """
    ,
    difficulty: 2,
    score: 2,
    encodedPictureName: "encoded.jpg",
    encodedAudioName: nil,
    answer: .init(
        crimeDescription:
        """
        Найденный файл представлял собой изображение, на котором виднелись логотипы известных брендов: Calvin Klein, Hermes, Adidas, New Balance, Estee Lauder, Lacoste.
        Определив названия, необходимо было понять, что с ними делать дальше. И тут не надо придумывать сложных схем, достаточно посмотреть что будет, если выписать из каждого названия первую букву первого слова (на это еще может навести название файла, где вместо восклицательного знака специально написана цифра "1").
        Получается слово "CHANEL", которое является названием известного
        французского бренда, офис которого расположен в Париже.
        """
        ,
        decodedMessage: "Париж",
        possibleAnswers: ["Paris", "Париж, Франция", "Paris, France"]
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
