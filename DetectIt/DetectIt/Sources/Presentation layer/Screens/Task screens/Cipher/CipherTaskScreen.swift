import SwiftUI
import DetectItCore
import DetectItUI

@MainActor
final class CipherTaskScreenModel: ObservableObject {
    let task: DecoderTask
    
    init(task: DecoderTask) {
        self.task = task
    }
    
    enum TaskState {
        case idle
        case loading
        case loaded
        case failure
    }
    
    static let maxAttempts = 3
    
    @Published var state: TaskState = .idle
    @Published var picture: UIImage?
    @Published var audio: Data?
    @Published var score: Int?
    @Published var answer: String = ""
    @Published var isCompleted: Bool = false
    @Published var attemptNumber: Int = 0 {
        didSet {
            remainingAttempts = Self.maxAttempts - attemptNumber
        }
    }
    @Published var remainingAttempts: Int = maxAttempts
    
    @Published var isAnswered: Bool = false
    @Published var isWrongAnswer: Bool = false
    
    func load() async {
        score = TaskScore.get(id: task.id, taskKind: task.kind)
        answer = TaskAnswer.get(decoderTaskID: task.id) ?? ""
        attemptNumber = TaskAnswer.getAttempt(decoderTaskID: task.id)
        
        isAnswered = !answer.isEmpty
        isCompleted = !answer.isEmpty && score != nil
        
        func updateState(image: UIImage?, audio: Data?, requireBoth: Bool = false) async {
            await MainActor.run {
                if requireBoth, let image, let audio {
                    self.picture = image
                    self.audio = audio
                    state = .loaded
                } else if let image {
                    self.picture = image
                    state = .loaded
                } else if let audio {
                    self.audio = audio
                    state = .loaded
                } else {
                    state = .failure
                }
            }
        }
        
        switch task.decodedResource {
        case .nothing:
            break
        case let .picture(path):
            guard let url = URL(string: path) else { break }
            
            let image = await ImageLoader.shared.load(.file(url))
            await updateState(image: image.0, audio: nil)
        case let .audio(path):
            let audio = FileManager.default.contents(atPath: path)
            await updateState(image: nil, audio: audio)
        case let .pictureAndAudio(picturePath, audioPath):
            guard let url = URL(string: picturePath) else { break }
            
            let image = await ImageLoader.shared.load(.file(url))
            let audio = FileManager.default.contents(atPath: audioPath)
            await updateState(image: image.0, audio: audio, requireBoth: true)
        }
    }
    
    func checkAnswer() {
        let isCorrect = task.answer.compare(with: answer)
        let score = isCorrect ? task.maxScore : 0
        
        if !isCorrect, remainingAttempts > 1 {
            self.isWrongAnswer = true
        } else {
            self.score = score
            TaskScore.set(value: score, id: task.id, taskKind: task.kind)
            TaskAnswer.set(answer: answer, decoderTaskID: task.id)
            withAnimation {
                self.isCompleted = true
            }
        }
        
        attemptNumber += 1
        TaskAnswer.setAttempt(attemptNumber, decoderTaskID: task.id)
    }
    
    func resetAnswer() {
        self.isCompleted = false
        self.score = nil
        TaskScore.set(value: 0, id: task.id, taskKind: task.kind)
        TaskAnswer.set(answer: "", decoderTaskID: task.id)
        TaskAnswer.setAttempt(0, decoderTaskID: task.id)
    }
}

struct CipherTaskScreen: View {
    let task: DecoderTask
    let isTaskCompleted: Bool
    let onClose: (_ isCompleted: Bool, _ score: Int) -> Void
    
    @StateObject private var model: CipherTaskScreenModel
    
    @State private var isPicturePresented = false
    @State private var isNotesPresented = false
    @State private var isSharingPresented = false
    
    // workaround to fix not clipped scroll view
    @State private var isBeingDismissed = false
    
    @FocusState private var isAnswerFocused
    
    @Namespace var namespace
    
    @Environment(\.dismiss) var dismiss
        
    init(task: DecoderTask, isTaskCompleted: Bool, onClose: @escaping (_: Bool, _: Int) -> Void) {
        self.task = task
        self.isTaskCompleted = isTaskCompleted
        self.onClose = onClose
        self._model = StateObject(wrappedValue: CipherTaskScreenModel(task: task))
    }
    
    var body: some View {
        contentView
            .padding()
            .overlay(hud)
            .preferredColorScheme(.dark)
            .task {
                await model.load()
            }
            .overlay {
                if isPicturePresented, let picture = model.picture {
                    PhotoViewerScreenSUI(image: picture, title: nil, namespace: namespace) {
                        withAnimation(.default.speed(2)) {
                            isPicturePresented = false
                        }
                    }
                }
            }
            .sheet(isPresented: $isNotesPresented) {
                TaskNotesScreenSUI(task: task)
            }
            .overlay {
                if isSharingPresented {
                    ActivityPopover(items: [TaskSharingViewSUI.makeSharingContent(task: task)]) { _, _, _, _ in
                        isSharingPresented = false
                    }
                }
            }
    }
    
    private var hud: some View {
        ScreenHUDView(
            isNotesPresented: $isNotesPresented,
            isSharingPresented: $isSharingPresented
        ) {
            close()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch model.state {
        case .idle:
            Color.clear
        case .loading:
            loadingView
        case .loaded:
            ScrollViewReader { scroll in
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        taskContent
                        answerView(completed: model.isCompleted)
                        if model.isCompleted {
                            completedTaskView
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollDismissesKeyboard(.immediately)
                .scrollIndicators(.hidden)
                .inlineModifier {
                    if #available(iOS 17.0, *) {
                        $0
                            .scrollClipDisabled(!isBeingDismissed)
                            .scrollBounceBehavior(.basedOnSize)
                    } else {
                        $0
                    }
                }
                .onChange(of: model.isCompleted) { _, completed in
                    guard completed else { return }
                    
                    AppRateManager.shared.commitEvent()
                    
                    Analytics.log(
                        "cipher_answer_sent",
                        parameters: [
                            "id": task.id,
                            "answer": model.answer
                        ]
                    )
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                        withAnimation {
                            scroll.scrollTo("completed_section", anchor: .top)
                        }
                    }
                }
                .onChange(of: isAnswerFocused) { _, isAnswerFocused in
                    guard isAnswerFocused else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                        withAnimation {
                            scroll.scrollTo("answer_button", anchor: .top)
                        }
                    }
                }
            }
        case .failure:
            errorView
        }
    }
    
    private var loadingView: some View {
        ScreenLoadingViewSUI(isInitiallyHidden: false, isVisible: true)
    }
    
    private var errorView: some View {
        ScreenPlaceholderViewSUI(
            title: "unknown_error_title".localized,
            message: "unknown_error_message".localized
        )
    }
    
    @ViewBuilder
    private var taskContent: some View {
        Spacer().frame(height: 52)
        
        Text(task.title)
            .font(.heading1)
            .foregroundStyle(Color.primaryText)
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
        
        Spacer().frame(height: 20)
        
        Text(task.preposition.readableAttributedText(font: Font.text3, color: Color.primaryText))
            .lineSpacing(2)
        
        Spacer().frame(height: 20)
        
        if let picture = model.picture {
            EvidencePictureView(image: picture)
                .matchedGeometryEffect(id: "photo", in: namespace)
                .onTapGesture {
                    withAnimation(.default.speed(2)) {
                        isPicturePresented = true
                    }
                }
            Spacer().frame(height: 20)
        }
        if let audio = model.audio {
            AudioPlayerSUI(data: audio)
            Spacer().frame(height: 20)
        }
        
        Spacer().frame(height: 20)
    }
    
    @ViewBuilder
    private func answerView(completed: Bool) -> some View {
        Text("decoder_task_screen_answer_title".localized)
            .font(.heading4)
            .foregroundStyle(Color.primaryText)
        
        AnswerFieldSUI(
            kind: .textField,
            keyboardType: .default,
            text: $model.answer
        )
        .frame(height: 56)
        .focused($isAnswerFocused)
        .disabled(completed)
        
        if !completed {
            Text(Plurals.attempts(model.remainingAttempts))
                .font(.text4)
                .foregroundStyle(Color.secondaryText)
            
            Spacer().frame(height: 40)
            
            AnswerButtonSUI(
                title: "answer_button_default_title".localized,
                isFilled: $model.isAnswered,
                isErrorOccured: $model.isWrongAnswer
            ) {
                model.checkAnswer()
            }
            .id("answer_button")
            .disabled(model.isCompleted || model.answer.isEmpty)
        }
    }
    
    @ViewBuilder
    private var completedTaskView: some View {
        Spacer().frame(height: 40)
            .id("completed_section")
        
        if let score = model.score {
            HStack {
                Text("decoder_task_screen_score_title".localized)
                    .font(.score1)
                    .foregroundStyle(Color.primaryText)
                
                Spacer()
                
                Text("\(score)/\(task.maxScore)")
                    .font(.score1)
                    .foregroundStyle(model.score == 0 ? .red : .green)
            }
            
            Spacer().frame(height: 40)
        }
        
        Text("decoder_task_screen_right_answer_title".localized)
            .font(.text3)
            .foregroundStyle(Color.primaryText)
        
        Text(task.answer.decodedMessage)
            .font(.heading2)
            .foregroundStyle(Color.green)
        
        Spacer().frame(height: 20)
        
        Text(task.answer.crimeDescription.readableAttributedText(font: Font.text3, color: Color.primaryText))
            .lineSpacing(2)
        
        Spacer().frame(height: 28)
        
        TaskSharingViewSUI(task: task) {
            Analytics.log(
                "share_task",
                parameters: [
                    "id": task.id,
                    "kind": task.kind.rawValue
                ]
            )
        }
        
        Spacer().frame(height: 32)
        
        ActionButton(title: "continue".localized, foreground: .black, background: .yellow) {
            close()
        }
    }
    
    private func close() {
        isBeingDismissed = true
        dismiss()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onClose(
                model.isCompleted,
                model.score ?? 0
            )
        }
    }
}

#Preview {
    CipherTaskScreen(
        task: DecoderTask(
            id: "c1",
            title: "Секретная записка",
            preposition: "Служба национальной безопасности перехватила подозрительное сообщение. Сотрудники службы предполагают, что некто хочет организовать встречу с целью незаконной передачи крупной суммы денег.\n\n**Ваша задача** — расшифровать сообщение и получить информацию о ##стране, месте и времени## встречи.\n\n##Ответ запишите в формате:## Россия, парк Зарядье, 20:30\n\n##Подсказка:## важно соблюдать последовательность слов, разделять слова запятыми, соблюдать формат записи времени.",
            difficulty: 1,
            score: 1,
            encodedPictureName: "encoded.jpg",
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
