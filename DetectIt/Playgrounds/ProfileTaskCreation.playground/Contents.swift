import Foundation
@testable import DetectItCore

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

let encodedTask = try! JSONEncoder().encode(task)
let json = String(data: encodedTask, encoding: .utf8)!

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
