import SwiftUI
import DetectItCore

struct CipherTaskScreen: View {
    let cipher: DecoderTask
    let isTaskCompleted: Bool
    let onClose: (_ isCompleted: Bool, _ score: Int) -> Void
    
    var body: some View {
        ScrollView {
            VStack {
                taskContent
                answerView
                completedTaskView
            }
        }
        .padding()
        .overlay {
            topPanel
        }
    }
    
    private var topPanel: some View {
        HStack {
            Spacer()
            
            CloseButton {
                
            }
        }
    }
    
    private var taskContent: some View {
        EmptyView()
    }
    
    private var answerView: some View {
        EmptyView()
    }
    
    private var completedTaskView: some View {
        EmptyView()
    }
}

#Preview {
    CipherTaskScreen(
        cipher: DecoderTask(
            id: "test",
            title: "Test",
            preposition: "Test preposition",
            difficulty: 1,
            score: 1,
            encodedPictureName: nil,
            encodedAudioName: nil,
            answer: .init(
                crimeDescription: "Test description",
                decodedMessage: "Decoded message",
                possibleAnswers: nil
            )
        ),
        isTaskCompleted: false,
        onClose: { _, _ in }
    )
}

// Reusables

struct CloseButton: View {
    let onClose: () -> Void
    
    var body: some View {
        Button(action: onClose) {
            Color.gray
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .overlay {
                    Image("cross")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
        }
    }
}
