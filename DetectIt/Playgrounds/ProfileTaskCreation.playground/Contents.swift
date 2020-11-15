import Foundation
@testable import DetectItCore

let task = ProfileTask(
    id: "p",
    title: "",
    preposition:
    """
    
    """,
    crimeDescription:
    """
    
    """,
    cases: [
        .init(
            id: "c1",
            title: """
            
            """,
            text:
            """
            
            """,
            evidencePicture: nil
        ),
        .init(
            id: "c2",
            title: """
            
            """,
            text:
            """
            
            """,
            evidencePicture: nil
        ),
        .init(
            id: "c3",
            title: """
            
            """,
            text:
            """
            
            """,
            evidencePicture: nil
        ),
        .init(
            id: "c4",
            title: """
            
            """,
            text:
            """
            
            """,
            evidencePicture: nil
        ),
        .init(
            id: "c5",
            title: """
            
            """,
            text:
            """
            
            """,
            evidencePicture: nil
        ),
        .init(
            id: "c6",
            title: """
            
            """,
            text:
            """
            
            """,
            evidencePicture: nil
        ),
        .init(
            id: "c7",
            title: "",
            text:
            """
            
            """,
            evidencePicture: nil
        ),
        .init(
            id: "c8",
            title: "",
            text:
            """
            
            """,
            evidencePicture: nil
        )
    ],
    attachments: nil,
    questions: [
        .init(
            id: "q1",
            title: "",
            score: 2,
            number: nil,
            variant: .init(
                variants: [
                    .init(id: "v1", text: ""),
                    .init(id: "v2", text: "")
                ],
                correctVariantID: "v1"
            ),
            exactAnswer: nil,
            boolAnswer: nil
        ),
        .init(
            id: "q2",
            title: "",
            score: 1,
            number: nil,
            variant: .init(
                variants: [
                    .init(id: "v1", text: ""),
                    .init(id: "v2", text: ""),
                    .init(id: "v3", text: "")
                ],
                correctVariantID: "v1"
            ),
            exactAnswer: nil,
            boolAnswer: nil
        ),
        .init(
            id: "q3",
            title: "",
            score: 2,
            number: nil,
            variant: nil,
            exactAnswer: nil,
            boolAnswer: .init(answer: true)
        ),
        .init(
            id: "q4",
            title: "",
            score: 2,
            number: nil,
            variant: nil,
            exactAnswer: nil,
            boolAnswer: .init(answer: true)
        ),
        .init(
            id: "q5",
            title: "",
            score: 1,
            number: nil,
            variant: nil,
            exactAnswer: nil,
            boolAnswer: .init(answer: false)
        ),
        .init(
            id: "q6",
            title: "",
            score: 1,
            number: nil,
            variant: nil,
            exactAnswer: nil,
            boolAnswer: .init(answer: true)
        ),
        .init(
            id: "q7",
            title: "",
            score: 1,
            number: nil,
            variant: nil,
            exactAnswer: nil,
            boolAnswer: .init(answer: true)
        )
    ],
    difficulty: 3
)

let encodedTask = try! JSONEncoder().encode(task)
let obj = try! JSONSerialization.jsonObject(with: encodedTask, options: .allowFragments)
let data = try! JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
let json = String(data: data, encoding: .utf8)!

print(json)


/*
 
let task = ProfileTask(
 id: "",
 title: "",
 preposition:
 """
 
 """,
 crimeDescription:
 """
 
 """,
 cases: [
     .init(
         id: "c1",
         title: "",
         text:
         """
         
         """,
         evidencePicture: .init(title: "", pictureName: "c1.jpg")
     ),
     .init(
         id: "c2",
         title: "",
         text:
         """
         
         """,
         evidencePicture: nil
     ),
     .init(
         id: "c3",
         title: "",
         text:
         """
         
         """,
         evidencePicture: nil
     ),
     .init(
         id: "c4",
         title: "",
         text:
         """
         
         """,
         evidencePicture: nil
     ),
     .init(
         id: "c5",
         title: "",
         text:
         """
         
         """,
         evidencePicture: nil
     ),
     .init(
         id: "c6",
         title: "",
         text:
         """
         
         """,
         evidencePicture: nil
     ),
     .init(
         id: "c7",
         title: "",
         text:
         """
         
         """,
         evidencePicture: nil
     )
 ],
 attachments: nil,
 questions: [
     .init(
         id: "",
         title: "",
         score: 2,
         number: nil,
         variant: .init(
             variants: [
                 .init(id: "v1", text: ""),
                 .init(id: "v2", text: ""),
                 .init(id: "v3", text: "")
             ],
             correctVariantID: ""
         ),
         exactAnswer: nil,
         boolAnswer: nil
     ),
     .init(
         id: "",
         title: "",
         score: 2,
         number: nil,
         variant: nil,
         exactAnswer: nil,
         boolAnswer: .init(answer: true)
     )
 ],
 difficulty: 1
)
 
*/
