import Foundation
@testable import DetectItCore

let task = QuestTask(
    id: "q1",
    title: "Test",
    preposition: "Test preposition and some long long long text",
    chapters: [
        .init(
            id: "c1",
            text: "Test chapter #1",
            actions: [
                .init(
                    id: "q1a1",
                    title: "Test action #1",
                    targetChapterID: "c2",
                    targetEndingID: nil
                ),
                .init(
                    id: "q1a2",
                    title: "Test action #2",
                    targetChapterID: nil,
                    targetEndingID: "e1"
                )
            ]
        ),
        .init(
            id: "c2",
            text: "Test chapter #2",
            actions: [
                .init(
                    id: "q2a1",
                    title: "Test action #1",
                    targetChapterID: nil,
                    targetEndingID: "e1"
                )
            ]
        )
    ],
    endings: [
        .init(
            id: "e1",
            text: "Test ending #1",
            score: 100
        )
    ],
    difficulty: 1
)

let encodedTask = try! JSONEncoder().encode(task)
let json = String(data: encodedTask, encoding: .utf8)!

print(json)
